#import "PVFVMServiceClient.h"

static NSString *const PVFVMServiceErrorDomain = @"PVFVMServiceErrorDomain";

typedef NS_ENUM(NSInteger, PVFVMServiceErrorCode) {
  PVFVMServiceErrorInvalidURI = 1,
  PVFVMServiceErrorDisconnected,
  PVFVMServiceErrorEncoding,
  PVFVMServiceErrorRPC
};

@interface PVFVMServiceClient ()
@property(nonatomic) NSURLSession *session;
@property(nonatomic, nullable) NSURLSessionWebSocketTask *task;
@property(nonatomic) dispatch_queue_t stateQueue;
@property(nonatomic) NSInteger nextRequestID;
@property(nonatomic)
    NSMutableDictionary<NSNumber *, PVFVMServiceCompletion> *pending;
@property(nonatomic, readwrite) NSURL *webSocketURL;
@end

@implementation PVFVMServiceClient

- (instancetype)initWithServiceURI:(NSString *)serviceURI
                             error:(NSError **)error {
  NSURL *url = [self.class webSocketURLFromServiceURI:serviceURI error:error];
  if (url == nil) {
    return nil;
  }

  self = [super init];
  if (self) {
    _webSocketURL = url;
    _session = [NSURLSession
        sessionWithConfiguration:NSURLSessionConfiguration
                                     .defaultSessionConfiguration];
    _stateQueue = dispatch_queue_create("com.pickview.flutter-vm-service",
                                        DISPATCH_QUEUE_SERIAL);
    _nextRequestID = 1;
    _pending = [NSMutableDictionary dictionary];
  }
  return self;
}

- (void)dealloc {
  [self close];
}

- (void)connect {
  [self close];
  NSURLSessionWebSocketTask *task =
      [self.session webSocketTaskWithURL:self.webSocketURL];
  self.task = task;
  [task resume];
  [self receiveNextMessage];
}

- (void)close {
  [self.task cancelWithCloseCode:NSURLSessionWebSocketCloseCodeGoingAway
                          reason:nil];
  self.task = nil;
}

- (void)
callMethod:(NSString *)method
            params:(NSDictionary *)params
        completion:(PVFVMServiceCompletion)completion {
  dispatch_async(self.stateQueue, ^{
    NSURLSessionWebSocketTask *task = self.task;
    if (task == nil) {
      NSError *error =
          [self.class errorWithCode:PVFVMServiceErrorDisconnected
                        description:@"WebSocket is not connected."];
      dispatch_async(dispatch_get_main_queue(), ^{
        completion(nil, error);
      });
      return;
    }

    NSInteger requestID = self.nextRequestID++;
    self.pending[@(requestID)] = [completion copy];
    NSMutableDictionary *payload = [@{
      @"jsonrpc" : @"2.0",
      @"id" : @(requestID),
      @"method" : method
    } mutableCopy];
    if (params.count > 0) {
      payload[@"params"] = params;
    }

    NSError *serializationError = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:payload
                                                   options:0
                                                     error:&serializationError];
    NSString *text = data == nil
                         ? nil
                         : [[NSString alloc] initWithData:data
                                                 encoding:NSUTF8StringEncoding];
    if (text == nil) {
      NSError *error =
          serializationError
              ?: [self.class errorWithCode:PVFVMServiceErrorEncoding
                               description:
                                   @"Failed to encode JSON-RPC request."];
      [self finishRequestID:requestID response:nil error:error];
      return;
    }

    NSURLSessionWebSocketMessage *message =
        [[NSURLSessionWebSocketMessage alloc] initWithString:text];
    [task sendMessage:message
        completionHandler:^(NSError *sendError) {
          if (sendError != nil) {
            [self finishRequestID:requestID response:nil error:sendError];
          }
        }];
  });
}

- (void)receiveNextMessage {
  NSURLSessionWebSocketTask *task = self.task;
  if (task == nil) {
    return;
  }
  __weak typeof(self) weakSelf = self;
  [task receiveMessageWithCompletionHandler:^(
            NSURLSessionWebSocketMessage *message, NSError *error) {
    __strong typeof(weakSelf) self = weakSelf;
    if (self == nil) {
      return;
    }
    if (error != nil) {
      [self failAllRequestsWithError:error];
      return;
    }
    [self handleMessage:message];
    [self receiveNextMessage];
  }];
}

- (void)handleMessage:(NSURLSessionWebSocketMessage *)message {
  NSData *data = nil;
  if (message.type == NSURLSessionWebSocketMessageTypeString) {
    data = [message.string dataUsingEncoding:NSUTF8StringEncoding];
  } else if (message.type == NSURLSessionWebSocketMessageTypeData) {
    data = message.data;
  }
  if (data == nil) {
    return;
  }

  NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data
                                                             options:0
                                                               error:nil];
  NSNumber *requestID = [dictionary[@"id"] isKindOfClass:NSNumber.class]
                            ? dictionary[@"id"]
                            : nil;
  if (requestID == nil) {
    return;
  }

  id rpcError = dictionary[@"error"];
  if (rpcError != nil) {
    NSString *description = [rpcError description];
    if ([NSJSONSerialization isValidJSONObject:rpcError]) {
      NSData *errorData =
          [NSJSONSerialization dataWithJSONObject:rpcError
                                          options:NSJSONWritingPrettyPrinted
                                            error:nil];
      description = [[NSString alloc] initWithData:errorData
                                          encoding:NSUTF8StringEncoding]
                        ?: description;
    }
    NSError *error =
        [self.class errorWithCode:PVFVMServiceErrorRPC
                      description:[@"VM Service returned JSON-RPC error:\n"
                                      stringByAppendingString:description]];
    [self finishRequestID:requestID.integerValue
                 response:dictionary
                    error:error];
    return;
  }
  [self finishRequestID:requestID.integerValue response:dictionary error:nil];
}

- (void)finishRequestID:(NSInteger)requestID
               response:(NSDictionary *)response
                  error:(NSError *)error {
  dispatch_async(self.stateQueue, ^{
    NSNumber *requestKey = @(requestID);
    PVFVMServiceCompletion completion = self.pending[requestKey];
    [self.pending removeObjectForKey:requestKey];
    if (completion != nil) {
      dispatch_async(dispatch_get_main_queue(), ^{
        completion(response, error);
      });
    }
  });
}

- (void)failAllRequestsWithError:(NSError *)error {
  dispatch_async(self.stateQueue, ^{
    NSArray<PVFVMServiceCompletion> *completions = self.pending.allValues;
    [self.pending removeAllObjects];
    dispatch_async(dispatch_get_main_queue(), ^{
      for (PVFVMServiceCompletion completion in completions) {
        completion(nil, error);
      }
    });
  });
}

+ (NSURL *)webSocketURLFromServiceURI:(NSString *)serviceURI
                                error:(NSError **)error {
  NSString *trimmed = [serviceURI
      stringByTrimmingCharactersInSet:NSCharacterSet
                                          .whitespaceAndNewlineCharacterSet];
  NSURLComponents *components = [NSURLComponents componentsWithString:trimmed];
  NSString *scheme = components.scheme.lowercaseString;
  if ([scheme isEqualToString:@"http"]) {
    components.scheme = @"ws";
  } else if ([scheme isEqualToString:@"https"]) {
    components.scheme = @"wss";
  } else if (![scheme isEqualToString:@"ws"] &&
             ![scheme isEqualToString:@"wss"]) {
    if (error != NULL) {
      *error = [self
          errorWithCode:PVFVMServiceErrorInvalidURI
            description:[NSString
                            stringWithFormat:@"Invalid VM Service URI: %@",
                                             serviceURI]];
    }
    return nil;
  }

  NSString *path = components.percentEncodedPath.length > 0
                       ? components.percentEncodedPath
                       : @"/";
  if (![path hasSuffix:@"/ws"]) {
    path = [path hasSuffix:@"/"] ? [path stringByAppendingString:@"ws"]
                                 : [path stringByAppendingString:@"/ws"];
  }
  components.percentEncodedPath = path;
  NSURL *url = components.URL;
  if (url == nil && error != NULL) {
    *error = [self
        errorWithCode:PVFVMServiceErrorInvalidURI
          description:[NSString stringWithFormat:@"Invalid VM Service URI: %@",
                                                 serviceURI]];
  }
  return url;
}

+ (NSError *)errorWithCode:(PVFVMServiceErrorCode)code
               description:(NSString *)description {
  return [NSError errorWithDomain:PVFVMServiceErrorDomain
                             code:code
                         userInfo:@{NSLocalizedDescriptionKey : description}];
}

@end

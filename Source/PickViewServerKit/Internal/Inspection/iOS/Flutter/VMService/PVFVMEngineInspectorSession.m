#import "PVFVMEngineInspectorSession.h"

#import <QuartzCore/QuartzCore.h>

#import "PVFVMFlutterTarget.h"
#import "PVFVMInspectorJSON.h"
#import "PVFVMServiceClient.h"

static NSString *const PVFVMEngineInspectorSessionErrorDomain =
    @"PVFVMEngineInspectorSessionErrorDomain";

typedef NS_ENUM(NSInteger, PVFVMEngineInspectorSessionErrorCode) {
  PVFVMEngineInspectorSessionErrorTimedOut = 1,
  PVFVMEngineInspectorSessionErrorNotConnected,
  PVFVMEngineInspectorSessionErrorIsolateChanged,
  PVFVMEngineInspectorSessionErrorInvalidPayload,
};

@interface PVFVMEngineInspectorSession ()
@property(nonatomic, readwrite) PVFVMFlutterTarget *target;
@property(nonatomic, readwrite, nullable) PVFVMServiceClient *serviceClient;
@property(nonatomic, readwrite, nullable) NSURL *vmServiceURL;
@property(nonatomic, readwrite, nullable) NSString *isolateID;
@property(nonatomic, readwrite) NSString *objectGroup;
@property(nonatomic, readwrite, nullable) NSDictionary *vmResponse;
@property(nonatomic, readwrite, getter=isConnected) BOOL connected;
@property(nonatomic) BOOL connecting;
@property(nonatomic) CFTimeInterval connectDeadline;
@property(nonatomic, copy, nullable)
    PVFVMInspectorConnectionCompletion connectCompletion;
@end

@implementation PVFVMEngineInspectorSession

- (instancetype)initWithTarget:(PVFVMFlutterTarget *)target {
  self = [super init];
  if (self) {
    _target = target;
    _objectGroup = [NSString
        stringWithFormat:@"ios-inspector-%p-%lld", target.engine,
                         (long long)(NSDate.date.timeIntervalSince1970 * 1000)];
  }
  return self;
}

- (void)dealloc {
  [self.serviceClient close];
}

- (void)connectWithTimeout:(NSTimeInterval)timeout
                completion:(PVFVMInspectorConnectionCompletion)completion {
  dispatch_block_t work = ^{
    NSString *currentIsolate = self.target.engine.isolateId;
    NSURL *currentURL = self.target.engine.vmServiceUrl;
    if (self.connected && currentIsolate.length > 0 &&
        [currentIsolate isEqualToString:self.isolateID] && currentURL != nil &&
        [currentURL isEqual:self.vmServiceURL]) {
      completion(nil);
      return;
    }
    if (self.connecting) {
      NSError *error = [self.class
          errorWithCode:PVFVMEngineInspectorSessionErrorNotConnected
             description:@"This Inspector session is already connecting."];
      completion(error);
      return;
    }

    [self close];
    self.connecting = YES;
    self.connectCompletion = [completion copy];
    self.connectDeadline = CACurrentMediaTime() + MAX(timeout, 0.1);
    [self attemptConnection];
  };
  if (NSThread.isMainThread) {
    work();
  } else {
    dispatch_async(dispatch_get_main_queue(), work);
  }
}

- (void)attemptConnection {
  if (!self.connecting) {
    return;
  }
  NSURL *url = self.target.engine.vmServiceUrl;
  NSString *isolateID = self.target.engine.isolateId;
  if (url == nil || isolateID.length == 0) {
    if (CACurrentMediaTime() >= self.connectDeadline) {
      [self finishConnectingWithError:[self.class
                                          errorWithCode:
                                              PVFVMEngineInspectorSessionErrorTimedOut
                                             description:
                                                 @"Timed out waiting for "
                                                  "FlutterEngine.vmServiceUrl "
                                                  "and isolateId. VM Service "
                                                  "is unavailable in Release."]];
      return;
    }
    [self retryConnectionSoon];
    return;
  }

  NSError *urlError = nil;
  PVFVMServiceClient *client =
      [[PVFVMServiceClient alloc] initWithServiceURI:url.absoluteString
                                            error:&urlError];
  if (client == nil) {
    [self finishConnectingWithError:urlError];
    return;
  }
  self.vmServiceURL = url;
  self.isolateID = isolateID;
  self.serviceClient = client;
  [client connect];

  __weak typeof(self) weakSelf = self;
  [client callMethod:@"getVM"
              params:nil
          completion:^(NSDictionary *response, NSError *error) {
            __strong typeof(weakSelf) self = weakSelf;
            if (self == nil || !self.connecting) {
              return;
            }
            if (error != nil) {
              [self.serviceClient close];
              self.serviceClient = nil;
              if (CACurrentMediaTime() < self.connectDeadline) {
                [self retryConnectionSoon];
              } else {
                [self finishConnectingWithError:error];
              }
              return;
            }
            if (![self.target.engine.isolateId
                    isEqualToString:self.isolateID]) {
              [self finishConnectingWithError:[self.class
                                                  errorWithCode:
                                                      PVFVMEngineInspectorSessionErrorIsolateChanged
                                                     description:
                                                         @"The engine isolate "
                                                          "changed while the "
                                                          "VM Service was "
                                                          "connecting."]];
              return;
            }
            self.vmResponse = response;
            self.connected = YES;
            [self finishConnectingWithError:nil];
          }];
}

- (void)retryConnectionSoon {
  __weak typeof(self) weakSelf = self;
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)),
                 dispatch_get_main_queue(), ^{
                   [weakSelf attemptConnection];
                 });
}

- (void)finishConnectingWithError:(NSError *)error {
  PVFVMInspectorConnectionCompletion completion = self.connectCompletion;
  self.connectCompletion = nil;
  self.connecting = NO;
  if (error != nil) {
    self.connected = NO;
  }
  if (completion != nil) {
    completion(error);
  }
}

- (void)close {
  [self.serviceClient close];
  self.serviceClient = nil;
  self.vmServiceURL = nil;
  self.isolateID = nil;
  self.vmResponse = nil;
  self.connected = NO;
  self.connecting = NO;
  self.connectCompletion = nil;
}

- (void)fetchRootWidgetTreeSummaryWithCompletion:
    (PVFVMInspectorPayloadCompletion)completion {
  NSError *stateError = [self connectionStateError];
  if (stateError != nil) {
    completion(nil, nil, stateError);
    return;
  }
  NSDictionary *params = @{
    @"isolateId" : self.isolateID,
    @"groupName" : self.objectGroup,
    @"isSummaryTree" : @"true",
    @"withPreviews" : @"true",
    @"fullDetails" : @"true"
  };
  __weak typeof(self) weakSelf = self;
  [self.serviceClient
      callMethod:@"ext.flutter.inspector.getRootWidgetTree"
          params:params
      completion:^(NSDictionary *response, NSError *error) {
        __strong typeof(weakSelf) self = weakSelf;
        if (self == nil) {
          return;
        }
        if (error == nil) {
          completion([PVFVMInspectorJSON normalizedPayloadFromResponse:response],
                     response, nil);
          return;
        }
        [self.serviceClient
            callMethod:@"ext.flutter.inspector.getRootWidgetSummaryTree"
                params:@{
                  @"isolateId" : self.isolateID,
                  @"objectGroup" : self.objectGroup
                }
            completion:^(NSDictionary *legacyResponse,
                         NSError *legacyError) {
              completion(legacyError == nil
                             ? [PVFVMInspectorJSON
                                   normalizedPayloadFromResponse:legacyResponse]
                             : nil,
                         legacyResponse, legacyError);
            }];
      }];
}

- (void)fetchRootWidgetTreeFullWithCompletion:
    (PVFVMInspectorPayloadCompletion)completion {
  [self callInspectorMethod:@"ext.flutter.inspector.getRootWidgetTree"
                     params:@{
                       @"groupName" : self.objectGroup,
                       @"isSummaryTree" : @"false",
                       @"withPreviews" : @"true",
                       @"fullDetails" : @"true"
                     }
                 completion:completion];
}

- (void)fetchLayoutExplorerForObjectID:(NSString *)objectID
                          subtreeDepth:(NSInteger)subtreeDepth
                            completion:(PVFVMInspectorPayloadCompletion)completion {
  [self callInspectorMethod:@"ext.flutter.inspector.getLayoutExplorerNode"
                     params:@{
                       @"id" : objectID,
                       @"groupName" : self.objectGroup,
                       @"subtreeDepth" :
                           [NSString stringWithFormat:@"%ld",
                                                      (long)subtreeDepth]
                     }
                 completion:completion];
}

- (void)fetchPropertiesForObjectID:(NSString *)objectID
                        completion:(PVFVMInspectorPayloadCompletion)completion {
  [self callInspectorMethod:@"ext.flutter.inspector.getProperties"
                     params:@{
                       @"arg" : objectID,
                       @"objectGroup" : self.objectGroup
                     }
                 completion:completion];
}

- (void)screenshotObjectID:(NSString *)objectID
               logicalSize:(CGSize)logicalSize
                    margin:(CGFloat)margin
             maxPixelRatio:(CGFloat)maxPixelRatio
                completion:(PVFVMInspectorScreenshotCompletion)completion {
  NSError *stateError = [self connectionStateError];
  if (stateError != nil) {
    completion(nil, nil, stateError);
    return;
  }
  CGFloat ratio = MAX(1, maxPixelRatio);
  NSInteger width =
      (NSInteger)MIN(4096.0, ceil((MAX(logicalSize.width, 1) + margin * 2) *
                                  ratio));
  NSInteger height =
      (NSInteger)MIN(4096.0, ceil((MAX(logicalSize.height, 1) + margin * 2) *
                                  ratio));
  NSDictionary *params = @{
    @"isolateId" : self.isolateID,
    @"id" : objectID,
    @"width" : [NSString stringWithFormat:@"%ld", (long)MAX(width, 1)],
    @"height" : [NSString stringWithFormat:@"%ld", (long)MAX(height, 1)],
    @"margin" : [NSString stringWithFormat:@"%.3f", margin],
    @"maxPixelRatio" : [NSString stringWithFormat:@"%.3f", ratio],
    @"debugPaint" : @"false"
  };
  [self.serviceClient
      callMethod:@"ext.flutter.inspector.screenshot"
          params:params
      completion:^(NSDictionary *response, NSError *error) {
        if (error != nil) {
          completion(nil, nil, error);
          return;
        }
        id payload = [PVFVMInspectorJSON normalizedPayloadFromResponse:response];
        if (![payload isKindOfClass:NSString.class]) {
          completion(nil, nil,
                     [self.class
                         errorWithCode:
                             PVFVMEngineInspectorSessionErrorInvalidPayload
                            description:@"Inspector screenshot did not return "
                                         "a base64 PNG string."]);
          return;
        }
        NSData *data = [[NSData alloc]
            initWithBase64EncodedString:payload
                                options:NSDataBase64DecodingIgnoreUnknownCharacters];
        UIImage *image = data == nil ? nil : [UIImage imageWithData:data];
        if (image == nil) {
          completion(nil, nil,
                     [self.class
                         errorWithCode:
                             PVFVMEngineInspectorSessionErrorInvalidPayload
                            description:@"Inspector screenshot PNG could not "
                                         "be decoded."]);
          return;
        }
        completion(image, data, nil);
      }];
}

- (void)callInspectorMethod:(NSString *)method
                     params:(NSDictionary *)params
                 completion:(PVFVMInspectorPayloadCompletion)completion {
  NSError *stateError = [self connectionStateError];
  if (stateError != nil) {
    completion(nil, nil, stateError);
    return;
  }
  NSMutableDictionary *fullParams = [params mutableCopy];
  fullParams[@"isolateId"] = self.isolateID;
  [self.serviceClient callMethod:method
                          params:fullParams
                      completion:^(NSDictionary *response, NSError *error) {
                        completion(
                            error == nil
                                ? [PVFVMInspectorJSON
                                      normalizedPayloadFromResponse:response]
                                : nil,
                            response, error);
                      }];
}

- (NSError *)connectionStateError {
  if (!self.connected || self.serviceClient == nil ||
      self.isolateID.length == 0) {
    return [self.class
        errorWithCode:PVFVMEngineInspectorSessionErrorNotConnected
           description:@"Inspector session is not connected."];
  }
  if (![self.target.engine.isolateId isEqualToString:self.isolateID]) {
    return [self.class
        errorWithCode:PVFVMEngineInspectorSessionErrorIsolateChanged
           description:@"The FlutterEngine isolate changed. Create or reconnect "
                        "the Inspector session before using old object IDs."];
  }
  return nil;
}

+ (NSError *)errorWithCode:(PVFVMEngineInspectorSessionErrorCode)code
               description:(NSString *)description {
  return [NSError errorWithDomain:PVFVMEngineInspectorSessionErrorDomain
                             code:code
                         userInfo:@{NSLocalizedDescriptionKey : description}];
}

@end

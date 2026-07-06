//
//  PVClientSession.m
//  PickViewClient
//
//  Created by kris cheng on 2026/7/6.
//

#import "PVClientSession.h"

#import "PVPendingRequest.h"
#import "PVConnectionProtocol.h"
#import "PVFrame.h"
#import "PVErrorCode.h"
#import "PVKitVersion.h"
#import "PVRequestType.h"

@interface PVClientSession ()
@property (nonatomic, strong) id<PVConnectionProtocol> connection;
@property (nonatomic, assign) PVClientSessionState state;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, PVPendingRequest *> *pendingRequests;
@property (nonatomic, assign) uint32_t nextTag;
@end

@implementation PVClientSession

- (instancetype)initWithConnection:(id<PVConnectionProtocol>)connection {
    self = [super init];
    if (self) {
        _connection = connection;
        _connection.delegate = self;
        _pendingRequests = [NSMutableDictionary dictionary];
        _state = PVClientSessionStateIdle;
    }
    return self;
}

- (void)openWithCompletion:(void (^)(NSError * _Nullable))completion {
    self.state = PVClientSessionStateConnecting;
    [self.connection connectWithCompletion:^(NSError *error) {
        if (error) {
            self.state = PVClientSessionStateFailed;
            if (completion) completion(error);
            return;
        }
        self.state = PVClientSessionStateHandshaking;
        [self validateVersionWithCompletion:^(NSError * _Nullable error) {
            if (error) {
                [self.connection close];
                self.state = PVClientSessionStateFailed;
                if (completion) completion(error);
                return;
            }
            self.state = PVClientSessionStateReady;
            if (completion) completion(nil);
        }];
    }];
}

- (void)validateVersionWithCompletion:(void (^)(NSError * _Nullable))completion {
    [self sendRequestType:PVRequestTypePing payload:nil timeoutInterval:5 completion:^(NSData * _Nullable payload, NSError * _Nullable error) {
        if (error) {
            if (completion) completion(error);
            return ;
        }

        NSError *validationError = nil;
        if (![self validateVersionPayload:payload error:&validationError]) {
            if (completion) {
                completion(validationError);
            }
            return;
        }

        if (completion) completion(nil);
    }];
}

- (void)sendRequestType:(uint32_t)type
                payload:(NSData *)payload
        timeoutInterval:(NSTimeInterval)timeoutInterval
             completion:(void (^)(NSData * _Nullable, NSError * _Nullable))completion {
    if (self.state != PVClientSessionStateReady && self.state != PVClientSessionStateHandshaking) {
        if (completion) {
            NSError *error = [NSError errorWithDomain:PVErrorDomain code:PVErrorCodeDisconnected userInfo:@{NSLocalizedDescriptionKey: @"Client session is not ready."}];
            completion(nil, error);
        }
        return;
    }

    uint32_t tag = [self nextRequestTag];
    PVFrame *frame = [[PVFrame alloc] initWithType:type tag:tag payload:payload];
    PVPendingRequest *request = [[PVPendingRequest alloc] initWithType:type tag:tag timeoutInterval:timeoutInterval completion:completion];
    self.pendingRequests[@(tag)] = request;

    [self.connection sendFrame:frame completion:^(NSError *error) {
        if (error) {
            [self finishRequestWithTag:tag payload:nil error:error];
        }
    }];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeoutInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!self.pendingRequests[@(tag)]) {
            return;
        }
        NSError *error = [NSError errorWithDomain:PVErrorDomain code:PVErrorCodeTimeout userInfo:@{NSLocalizedDescriptionKey: @"Request timed out."}];
        [self finishRequestWithTag:tag payload:nil error:error];
    });
}

- (void)sendPushType:(uint32_t)type payload:(NSData *)payload completion:(void (^)(NSError * _Nullable))completion {
    PVFrame *frame = [[PVFrame alloc] initWithType:type tag:0 payload:payload];
    [self.connection sendFrame:frame completion:completion];
}

- (void)close {
    NSError *error = [NSError errorWithDomain:PVErrorDomain
                                         code:PVErrorCodeDisconnected
                                     userInfo:@{NSLocalizedDescriptionKey: @"Client session closed."}];
    NSArray<NSNumber *> *tags = self.pendingRequests.allKeys;
    for (NSNumber *tag in tags) {
        [self finishRequestWithTag:tag.unsignedIntValue payload:nil error:error];
    }
    [self.connection close];
    self.state = PVClientSessionStateDisconnected;
}

- (uint32_t)nextRequestTag {
    self.nextTag += 1;
    if (self.nextTag == 0) {
        self.nextTag = 1;
    }
    return self.nextTag;
}

- (void)finishRequestWithTag:(uint32_t)tag payload:(NSData *)payload error:(NSError *)error {
    PVPendingRequest *request = self.pendingRequests[@(tag)];
    if (!request) {
        return;
    }
    [self.pendingRequests removeObjectForKey:@(tag)];
    if (request.completion) {
        request.completion(payload, error);
    }
}

- (BOOL)validateVersionPayload:(NSData *)data error:(NSError **)error {
    if (!data.length) {
        if (error) {
            *error = [NSError errorWithDomain:PVErrorDomain code:PVErrorCodeIncompatibleVersion userInfo:@{NSLocalizedDescriptionKey: @"Missing server version payload."}];
        }
        return NO;
    }

    NSError *serializationError = nil;
    id object = [NSPropertyListSerialization propertyListWithData:data
                                                          options:NSPropertyListImmutable
                                                           format:nil
                                                            error:&serializationError];
    if (![object isKindOfClass:NSDictionary.class]) {
        if (error) {
            NSString *reason = serializationError.localizedDescription ?: @"Invalid server version payload.";
            *error = [NSError errorWithDomain:PVErrorDomain code:PVErrorCodeIncompatibleVersion userInfo:@{NSLocalizedDescriptionKey: reason}];
        }
        return NO;
    }

    NSDictionary *info = (NSDictionary *)object;
    NSNumber *peerVersion = [info[@"protocolVersion"] isKindOfClass:NSNumber.class] ? info[@"protocolVersion"] : nil;
    if (!peerVersion) {
        if (error) {
            *error = [NSError errorWithDomain:PVErrorDomain code:PVErrorCodeIncompatibleVersion userInfo:@{NSLocalizedDescriptionKey: @"Missing server protocolVersion."}];
        }
        return NO;
    }

    uint32_t version = peerVersion.unsignedIntValue;
    if (version < PVSupportedPeerVersionMin || version > PVSupportedPeerVersionMax) {
        if (error) {
            NSString *reason = [NSString stringWithFormat:@"Unsupported server protocolVersion: %u.", version];
            *error = [NSError errorWithDomain:PVErrorDomain code:PVErrorCodeIncompatibleVersion userInfo:@{NSLocalizedDescriptionKey: reason}];
        }
        return NO;
    }

    NSNumber *supportedMin = [info[@"supportedMin"] isKindOfClass:NSNumber.class] ? info[@"supportedMin"] : nil;
    NSNumber *supportedMax = [info[@"supportedMax"] isKindOfClass:NSNumber.class] ? info[@"supportedMax"] : nil;
    if (supportedMin && supportedMax) {
        uint32_t minVersion = supportedMin.unsignedIntValue;
        uint32_t maxVersion = supportedMax.unsignedIntValue;
        if (PVProtocolVersion < minVersion || PVProtocolVersion > maxVersion) {
            if (error) {
                NSString *reason = [NSString stringWithFormat:@"Client protocolVersion %u is outside server supported range %u-%u.", PVProtocolVersion, minVersion, maxVersion];
                *error = [NSError errorWithDomain:PVErrorDomain code:PVErrorCodeIncompatibleVersion userInfo:@{NSLocalizedDescriptionKey: reason}];
            }
            return NO;
        }
    }
    return YES;
}

#pragma mark - PVConnectionDelegate

- (void)connection:(id<PVConnectionProtocol>)connection didReceiveFrame:(PVFrame *)frame {
    [self finishRequestWithTag:frame.tag payload:frame.payload error:nil];
}

- (void)connection:(id<PVConnectionProtocol>)connection didCloseWithError:(NSError *)error {
    self.state = PVClientSessionStateDisconnected;
    NSError *closeError = error ?: [NSError errorWithDomain:PVErrorDomain
                                                       code:PVErrorCodeDisconnected
                                                   userInfo:@{NSLocalizedDescriptionKey: @"Connection closed."}];
    NSArray<NSNumber *> *tags = self.pendingRequests.allKeys;
    for (NSNumber *tag in tags) {
        [self finishRequestWithTag:tag.unsignedIntValue payload:nil error:closeError];
    }
}

@end

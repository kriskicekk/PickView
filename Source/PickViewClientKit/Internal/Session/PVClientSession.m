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
#import "PVUtils.h"
#import "PVPeerIdentityConstant.h"
#import "PVPeerIdentity.h"
#import "PVLANEndpoint.h"

static NSTimeInterval const PVClientSessionHeartbeatInterval = 3.0;
static NSTimeInterval const PVClientSessionHeartbeatTimeout = 2.0;
static NSUInteger const PVClientSessionMaxMissedHeartbeats = 2;

@interface PVClientSession ()
@property (nonatomic, strong) id<PVConnectionProtocol> connection;
@property (nonatomic, strong) PVPeerIdentity *peerIdentity;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, PVPendingRequest *> *pendingRequests;
@property (nonatomic, assign) uint32_t nextTag;
@property (nonatomic, assign) BOOL didNotifyClose;
@property (nonatomic, strong, nullable) dispatch_source_t heartbeatTimer;
@property (nonatomic, assign) uint32_t heartbeatSequence;
@property (nonatomic, assign) NSUInteger missedHeartbeatCount;
@property (nonatomic, assign) BOOL heartbeatInFlight;

- (void)finishWithCloseError:(NSError *)error closeConnection:(BOOL)closeConnection notifyDelegate:(BOOL)notifyDelegate;
- (void)finishPendingRequestsWithError:(NSError *)error;
- (void)startHeartbeatIfNeed;
- (void)stopHeartbeat;
- (void)sendHeartbeatIfNeeded;
- (uint32_t)nextHeartbeatSequence;
- (NSData *)heartbeatPayloadWithSequence:(uint32_t)sequence;
- (void)handleHeartbeatFailure:(NSError *)error;
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

- (id<PVEndpointProtocol>)endpoint {
    return self.connection.endpoint;
}

- (NSString *)identifier {
    return self.connection.connectionIdentifier;
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
        [self validateVersionWithCompletion:^(PVPeerIdentity * _Nullable peerIdentity, NSError * _Nullable error) {
            if (error) {
                [self stopHeartbeat];
                [self.connection close];
                self.state = PVClientSessionStateFailed;
                if (completion) completion(error);
                return;
            }
            self.peerIdentity = peerIdentity;
            self.state = PVClientSessionStateReady;
            [self startHeartbeatIfNeed];
            if (completion) completion(nil);
        }];
    }];
}

- (void)validateVersionWithCompletion:(void (^)(PVPeerIdentity * _Nullable, NSError * _Nullable))completion {
    [self sendRequestType:PVRequestTypePing payload:nil timeoutInterval:5 completion:^(NSData * _Nullable payload, NSError * _Nullable error) {
        if (error) {
            if (completion) completion(nil, error);
            return;
        }

        if (!payload.length) {
            NSError *error = [NSError errorWithDomain:PVErrorDomain code:PVErrorCodeIncompatibleVersion userInfo:@{NSLocalizedDescriptionKey: @"Missing server version payload."}];
            if (completion) completion(nil, error);
            return;
        }

        NSError *serializationError = nil;
        id object = [NSPropertyListSerialization propertyListWithData:payload
                                                              options:NSPropertyListImmutable
                                                               format:nil
                                                                error:&serializationError];
        if (![object isKindOfClass:NSDictionary.class]) {
            NSString *reason = serializationError.localizedDescription ?: @"Invalid server version payload.";
            NSError *error = [NSError errorWithDomain:PVErrorDomain code:PVErrorCodeIncompatibleVersion userInfo:@{NSLocalizedDescriptionKey: reason}];
            if (completion) completion(nil, error);
            return;
        }

        PVPeerIdentity *peerIdentity = [[PVPeerIdentity alloc] initWithDictionary:(NSDictionary *)object];
        NSError *validationError = nil;
        if (![self validatePeerIdentity:peerIdentity error:&validationError]) {
            if (completion) {
                completion(nil, validationError);
            }
            return;
        }

        if (completion) completion(peerIdentity, nil);
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
    [self finishWithCloseError:error closeConnection:YES notifyDelegate:NO];
}

- (void)finishWithCloseError:(NSError *)error closeConnection:(BOOL)closeConnection notifyDelegate:(BOOL)notifyDelegate {
    if (self.didNotifyClose) {
        return;
    }

    self.didNotifyClose = YES;
    [self stopHeartbeat];
    self.state = PVClientSessionStateDisconnected;
    [self finishPendingRequestsWithError:error];

    if (closeConnection) {
        [self.connection close];
    }

    if (notifyDelegate && [self.delegate respondsToSelector:@selector(clientSession:didCloseWithError:)]) {
        [self.delegate clientSession:self didCloseWithError:error];
    }
}

- (void)finishPendingRequestsWithError:(NSError *)error {
    NSArray<NSNumber *> *tags = self.pendingRequests.allKeys;
    for (NSNumber *tag in tags) {
        [self finishRequestWithTag:tag.unsignedIntValue payload:nil error:error];
    }
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

- (BOOL)validatePeerIdentity:(PVPeerIdentity *)peerIdentity error:(NSError **)error {
    PVPeerIdentity *identity = [PVPeerIdentity sharedIdentity];

    NSString *peerVersion = peerIdentity.protocolVersion;
    if (!peerVersion || peerVersion.length == 0) {
        if (error) {
            *error = [NSError errorWithDomain:PVErrorDomain code:PVErrorCodeIncompatibleVersion userInfo:@{NSLocalizedDescriptionKey: @"Missing server protocolVersion."}];
        }
        return NO;
    }

    if ([PVUtils compareVersion:peerVersion toVersion:identity.supportedPeerVersionMin] == NSOrderedAscending ||
        [PVUtils compareVersion:peerVersion toVersion:identity.supportedPeerVersionMax] == NSOrderedDescending) {
        if (error) {
            NSString *reason = [NSString stringWithFormat:@"Unsupported server protocolVersion: %@.", peerVersion];
            *error = [NSError errorWithDomain:PVErrorDomain code:PVErrorCodeIncompatibleVersion userInfo:@{NSLocalizedDescriptionKey: reason}];
        }
        return NO;
    }

    NSString *peerSupportedMin = peerIdentity.supportedPeerVersionMin;
    NSString *peerSupportedMax = peerIdentity.supportedPeerVersionMax;
    if (peerSupportedMin && peerSupportedMax) {
        if ([PVUtils compareVersion:identity.protocolVersion toVersion:peerSupportedMin] == NSOrderedAscending ||
            [PVUtils compareVersion:identity.protocolVersion toVersion:peerSupportedMax] == NSOrderedDescending) {
            if (error) {
                NSString *reason = [NSString stringWithFormat:@"Client protocolVersion %@ is outside server supported range %@-%@.", PVClientProtocolVersion, peerSupportedMin, peerSupportedMax];
                *error = [NSError errorWithDomain:PVErrorDomain code:PVErrorCodeIncompatibleVersion userInfo:@{NSLocalizedDescriptionKey: reason}];
            }
            return NO;
        }
    }
    return YES;
}

- (void)startHeartbeatIfNeed {
    if (![self.endpoint isKindOfClass:PVLANEndpoint.class]) return;
    [self stopHeartbeat];
    self.missedHeartbeatCount = 0;
    self.heartbeatInFlight = NO;

    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(PVClientSessionHeartbeatInterval * NSEC_PER_SEC));
    uint64_t interval = (uint64_t)(PVClientSessionHeartbeatInterval * NSEC_PER_SEC);
    uint64_t leeway = (uint64_t)(0.3 * NSEC_PER_SEC);
    dispatch_source_set_timer(timer, startTime, interval, leeway);

    __weak typeof(self) weakSelf = self;
    dispatch_source_set_event_handler(timer, ^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return;
        [self sendHeartbeatIfNeeded];
    });

    self.heartbeatTimer = timer;
    dispatch_resume(timer);
}

- (void)stopHeartbeat {
    if (self.heartbeatTimer) {
        dispatch_source_cancel(self.heartbeatTimer);
        self.heartbeatTimer = nil;
    }
    self.heartbeatInFlight = NO;
    self.missedHeartbeatCount = 0;
}

- (void)sendHeartbeatIfNeeded {
    if (self.state != PVClientSessionStateReady || self.heartbeatInFlight) {
        return;
    }

    self.heartbeatInFlight = YES;
    uint32_t sequence = [self nextHeartbeatSequence];
    NSData *payload = [self heartbeatPayloadWithSequence:sequence];

    __weak typeof(self) weakSelf = self;
    [self sendRequestType:PVRequestTypeHeartbeat payload:payload timeoutInterval:PVClientSessionHeartbeatTimeout completion:^(NSData * _Nullable responsePayload, NSError * _Nullable error) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self || self.state != PVClientSessionStateReady) {
            return;
        }

        self.heartbeatInFlight = NO;
        if (error) {
            [self handleHeartbeatFailure:error];
            return;
        }

        self.missedHeartbeatCount = 0;
    }];
}

- (uint32_t)nextHeartbeatSequence {
    self.heartbeatSequence += 1;
    if (self.heartbeatSequence == 0) {
        self.heartbeatSequence = 1;
    }
    return self.heartbeatSequence;
}

- (NSData *)heartbeatPayloadWithSequence:(uint32_t)sequence {
    NSDictionary *payload = @{
        @"sequence": @(sequence),
        @"timestamp": @([[NSDate date] timeIntervalSince1970])
    };
    return [NSPropertyListSerialization dataWithPropertyList:payload
                                                      format:NSPropertyListBinaryFormat_v1_0
                                                     options:0
                                                       error:nil];
}

- (void)handleHeartbeatFailure:(NSError *)error {
    self.missedHeartbeatCount += 1;
    if (self.missedHeartbeatCount < PVClientSessionMaxMissedHeartbeats) {
        return;
    }

    NSMutableDictionary *userInfo = [@{NSLocalizedDescriptionKey: @"Heartbeat timed out."} mutableCopy];
    if (error) {
        userInfo[NSUnderlyingErrorKey] = error;
    }
    NSError *closeError = [NSError errorWithDomain:PVErrorDomain code:PVErrorCodeTimeout userInfo:userInfo];
    [self finishWithCloseError:closeError closeConnection:YES notifyDelegate:YES];
}

#pragma mark - PVConnectionDelegate

- (void)connection:(id<PVConnectionProtocol>)connection didReceiveFrame:(PVFrame *)frame {
    [self finishRequestWithTag:frame.tag payload:frame.payload error:nil];
}

- (void)connection:(id<PVConnectionProtocol>)connection didCloseWithError:(NSError *)error {
    if (connection != self.connection || self.didNotifyClose) {
        return;
    }

    NSError *closeError = error ?: [NSError errorWithDomain:PVErrorDomain
                                                       code:PVErrorCodeDisconnected
                                                   userInfo:@{NSLocalizedDescriptionKey: @"Connection closed."}];
    [self finishWithCloseError:closeError closeConnection:NO notifyDelegate:YES];
}

@end

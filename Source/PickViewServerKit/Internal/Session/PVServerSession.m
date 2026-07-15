//
//  PVServerSession.m
//  PickViewServer
//
//  Created by kris cheng on 2026/7/6.
//

#import "PVServerSession.h"
#import "PVRequestHandlerProtocol.h"
#import "PVConnectionProtocol.h"
#import "PVFrame.h"
#import "PVErrorCode.h"
#import "PVArchiveCodec.h"
#import "PVKitVersion.h"
#import "PVPeerIdentity.h"
#import "PVRequestType.h"
#import "PVResponseAttachment.h"

static NSTimeInterval const PVServerSessionAuthorizationTimeout = 30.0;

@interface PVServerSession ()
@property (nonatomic, strong) id<PVConnectionProtocol> connection;
@property (nonatomic, strong) id<PVRequestHandlerProtocol> requestHandler;
@property (nonatomic, assign) BOOL requiresAuthorization;
@property (nonatomic, assign) BOOL authorized;
@property (nonatomic, assign) BOOL authorizationInFlight;
@property (nonatomic, assign) NSUInteger authorizationToken;
@property (nonatomic, copy, nullable) PVServerSessionAuthorizationHandler authorizationHandler;
@end

@implementation PVServerSession

- (instancetype)initWithConnection:(id<PVConnectionProtocol>)connection
                     requestHandler:(id<PVRequestHandlerProtocol>)requestHandler
              requiresAuthorization:(BOOL)requiresAuthorization
               authorizationHandler:(PVServerSessionAuthorizationHandler)authorizationHandler {
    self = [super init];
    if (self) {
        _connection = connection;
        _requestHandler = requestHandler;
        _requiresAuthorization = requiresAuthorization;
        _authorized = !requiresAuthorization;
        _authorizationHandler = [authorizationHandler copy];
        _connection.delegate = self;
    }
    return self;
}

- (void)start {
    // Accepted connections are already open. The session becomes active once it is the connection delegate.
    [self.connection connectWithCompletion:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"[PickView Server] session start failed: %@", error.localizedDescription);
        }
    }];
}

- (void)close {
    [self.connection close];
}

#pragma mark - PVConnectionDelegate

- (void)connection:(id<PVConnectionProtocol>)connection didReceiveFrame:(PVFrame *)frame {
    if (self.requiresAuthorization && !self.authorized) {
        if (frame.type != PVRequestTypeConnectionAuthorization) {
            NSError *error = [NSError errorWithDomain:PVErrorDomain
                                                 code:PVErrorCodeConnectionRejected
                                             userInfo:@{NSLocalizedDescriptionKey: @"The LAN connection has not been authorized."}];
            PVFrame *response = [[PVFrame alloc] initWithType:frame.type
                                                         tag:frame.tag
                                                     payload:[self payloadForError:error]];
            [connection sendFrame:response completion:nil];
            return;
        }
        [self handleAuthorizationFrame:frame connection:connection];
        return;
    }

    if (![self.requestHandler canHandleRequestType:frame.type]) {
        NSError *error = [NSError errorWithDomain:PVErrorDomain code:PVErrorCodeUnknown userInfo:@{NSLocalizedDescriptionKey: @"Unsupported request type."}];
        PVFrame *response = [[PVFrame alloc] initWithType:frame.type tag:frame.tag payload:[self payloadForError:error]];
        [connection sendFrame:response completion:nil];
        return;
    }

    if (frame.tag == 0) {
        [self.requestHandler handleRequestType:frame.type payload:frame.payload completion:nil];
        return;
    }

    [self.requestHandler handleRequestType:frame.type payload:frame.payload completion:^(NSData *responsePayload, NSError *error) {
        NSError *responseError = error;
        if (!responsePayload.length && !responseError) {
            responseError = [NSError errorWithDomain:PVErrorDomain code:PVErrorCodeUnknown userInfo:@{NSLocalizedDescriptionKey: @"Empty response payload."}];
        }
        NSData *payload = responseError ? [self payloadForError:responseError] : responsePayload;
        PVFrame *response = [[PVFrame alloc] initWithType:frame.type tag:frame.tag payload:payload];
        [connection sendFrame:response completion:nil];
    }];
}

- (void)handleAuthorizationFrame:(PVFrame *)frame
                       connection:(id<PVConnectionProtocol>)connection {
    if (self.authorizationInFlight) {
        return;
    }

    NSError *decodeError = nil;
    id object = frame.payload.length
        ? [NSPropertyListSerialization propertyListWithData:frame.payload
                                                    options:NSPropertyListImmutable
                                                     format:nil
                                                      error:&decodeError]
        : nil;
    NSDictionary *request = [object isKindOfClass:NSDictionary.class] ? object : nil;
    NSDictionary *identityDictionary = [request[@"clientIdentity"] isKindOfClass:NSDictionary.class]
        ? request[@"clientIdentity"]
        : nil;
    PVPeerIdentity *clientIdentity = identityDictionary
        ? [[PVPeerIdentity alloc] initWithDictionary:identityDictionary]
        : nil;
    if (!clientIdentity.uuid.length || !clientIdentity.protocolVersion.length) {
        [self sendAuthorizationResponseForFrame:frame
                                      accepted:NO
                                        reason:decodeError.localizedDescription ?: @"The client identity is invalid."
                                     connection:connection];
        return;
    }

    self.authorizationInFlight = YES;
    NSUInteger token = ++self.authorizationToken;
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                 (int64_t)(PVServerSessionAuthorizationTimeout * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self || !self.authorizationInFlight || self.authorizationToken != token) {
            return;
        }
        self.authorizationInFlight = NO;
        [self sendAuthorizationResponseForFrame:frame
                                      accepted:NO
                                        reason:@"The connection request timed out."
                                     connection:connection];
    });

    if (!self.authorizationHandler) {
        self.authorizationInFlight = NO;
        [self sendAuthorizationResponseForFrame:frame
                                      accepted:NO
                                        reason:@"The app did not provide a connection approval handler."
                                     connection:connection];
        return;
    }

    self.authorizationHandler(clientIdentity, ^(BOOL accepted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) self = weakSelf;
            if (!self || !self.authorizationInFlight || self.authorizationToken != token) {
                return;
            }
            self.authorizationInFlight = NO;
            [self sendAuthorizationResponseForFrame:frame
                                          accepted:accepted
                                            reason:accepted ? nil : @"The connection request was rejected by the device."
                                         connection:connection];
        });
    });
}

- (void)sendAuthorizationResponseForFrame:(PVFrame *)requestFrame
                                  accepted:(BOOL)accepted
                                    reason:(NSString *)reason
                                 connection:(id<PVConnectionProtocol>)connection {
    NSMutableDictionary *response = [@{ @"accepted" : @(accepted) } mutableCopy];
    if (accepted) {
        PVPeerIdentity *identity = [PVPeerIdentity localIdentityWithProtocolVersion:PVServerProtocolVersion
                                                            supportedPeerVersionMin:PVServerSupportedPeerVersionMin
                                                            supportedPeerVersionMax:PVServerSupportedPeerVersionMax];
        response[@"peerIdentity"] = identity.dictionaryRepresentation;
        self.authorized = YES;
    } else {
        response[@"reason"] = reason.length ? reason : @"The connection request was rejected.";
    }

    NSData *payload = [NSPropertyListSerialization dataWithPropertyList:response
                                                                  format:NSPropertyListBinaryFormat_v1_0
                                                                 options:0
                                                                   error:nil];
    PVFrame *responseFrame = [[PVFrame alloc] initWithType:requestFrame.type
                                                      tag:requestFrame.tag
                                                  payload:payload];
    [connection sendFrame:responseFrame completion:^(__unused NSError *error) {
        if (!accepted) {
            [self close];
        }
    }];
}

- (NSData *)payloadForError:(NSError *)error {
    PVResponseAttachment *attachment = [PVResponseAttachment attachmentWithError:error];
    NSError *archiveError = nil;
    NSData *payload = [PVArchiveCodec archivedDataWithObject:attachment error:&archiveError];
    if (payload) {
        return payload;
    }
    return [NSPropertyListSerialization dataWithPropertyList:@{@"error": error.localizedDescription ?: @"Unknown error"}
                                                      format:NSPropertyListBinaryFormat_v1_0
                                                     options:0
                                                       error:nil];
}

- (void)connection:(id<PVConnectionProtocol>)connection didCloseWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(serverSession:didCloseWithError:)]) {
        [self.delegate serverSession:self didCloseWithError:error];
    }
}

@end

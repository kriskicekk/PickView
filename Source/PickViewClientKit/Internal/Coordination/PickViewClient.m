//
//  PickViewClient.m
//  PickViewClient
//
//  Created by kris cheng on 2026/7/6.
//

#import "PickViewClient.h"

#import "PickViewClientConfiguration.h"
#import "PVArchiveCodec.h"
#import "PVClientSession.h"
#import "PVClientSessionManager.h"
#import "PVConnectionProtocol.h"
#import "PVEndpointDiscovererDelegate.h"
#import "PVEndpointProtocol.h"
#import "PVErrorCode.h"
#import "PVDisplayItemDetail.h"
#import "PVDisplayItemDetailRequest.h"
#import "PVHierarchyInfo.h"
#import "PVLANConnection.h"
#import "PVLANEndpoint.h"
#import "PVLANEndpointDiscoverer.h"
#import "PVLoopbackConnection.h"
#import "PVLoopbackEndpoint.h"
#import "PVLoopbackEndpointDiscoverer.h"
#import "PVPeerIdentity.h"
#import "PVRequestAttachment.h"
#import "PVRequestType.h"
#import "PVResponseAttachment.h"
#import "PVUSBConnection.h"
#import "PVUSBEndpoint.h"
#import "PVUSBEndpointDiscoverer.h"
#import "PVWindowInfo.h"

static NSString * const PVClientLANBlockedByUSBMessage = @"当前 App 已经通过 USB 连接，请先断开 USB。";

@interface PickViewClient () <PVEndpointDiscovererDelegate, PVClientSessionDelegate, PVClientSessionManagerDelegate>

@property (nonatomic, strong) PickViewClientConfiguration *configuration;
@property (nonatomic, strong, nullable) PVUSBEndpointDiscoverer *usbDiscoverer;
@property (nonatomic, strong, nullable) PVLoopbackEndpointDiscoverer *loopbackDiscoverer;
@property (nonatomic, strong, nullable) PVLANEndpointDiscoverer *lanDiscoverer;

@property (nonatomic, strong) PVClientSessionManager *sessionManager;

@property (nonatomic, strong, nullable) NSTimer *scanTimer;

@end

@implementation PickViewClient

+ (PickViewClient *)sharedClient {
    static PickViewClient *client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        client = [[PickViewClient alloc] init];
    });
    return client;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _configuration = [PickViewClientConfiguration defaultConfiguration];
        _sessionManager = [[PVClientSessionManager alloc] init];
        _sessionManager.delegate = self;
    }
    return self;
}

- (void)startScanning {
    [self startScanningWithConfiguration:nil];
}

- (void)startScanningWithConfiguration:(PickViewClientConfiguration *)configuration {
    [self stop];

    self.configuration = configuration ?: [PickViewClientConfiguration defaultConfiguration];
    self.sessionManager = [[PVClientSessionManager alloc] init];
    self.sessionManager.delegate = self;

    if (self.configuration.enableUSBDiscovery) {
        self.usbDiscoverer = [[PVUSBEndpointDiscoverer alloc] init];
        self.usbDiscoverer.delegate = self;
        [self.usbDiscoverer start];
    }

    if (self.configuration.enableLoopbackDiscovery) {
        self.loopbackDiscoverer = [[PVLoopbackEndpointDiscoverer alloc] init];
        self.loopbackDiscoverer.delegate = self;
        [self.loopbackDiscoverer start];
    }

    if (self.configuration.enableLANDiscovery) {
        self.lanDiscoverer = [[PVLANEndpointDiscoverer alloc] init];
        self.lanDiscoverer.delegate = self;
        [self.lanDiscoverer start];
        [self notifyLog:@"started LAN discovery"];
    }

    [self notifyStatus:@"Waiting for USB device, local app, or LAN service..."];
    [self scanNow];
    if (self.configuration.scanInterval > 0) {
        self.scanTimer = [NSTimer scheduledTimerWithTimeInterval:self.configuration.scanInterval
                                                          target:self
                                                        selector:@selector(scanNow)
                                                        userInfo:nil
                                                         repeats:YES];
    }
}

- (void)scanNow {
    NSArray<id<PVEndpointProtocol>> *endpoints = self.sessionManager.allEndpoints;
    for (id<PVEndpointProtocol> endpoint in endpoints) {
        if ([endpoint isKindOfClass:PVLANEndpoint.class]) {
            continue;
        }
        [self tryConnectEndpoint:endpoint];
    }
}

- (void)connectToLANEndpointIdentifier:(NSString *)endpointIdentifier {
    PVClientSession *session = [self.sessionManager sessionForEndpointIdentifier:endpointIdentifier];
    if ([session.endpoint isKindOfClass:PVLANEndpoint.class] &&
        session.state == PVClientSessionStateReady) {
        [self notifyConnectedEndpoint:session.endpoint];
        return;
    }

    id<PVEndpointProtocol> endpoint = [self.sessionManager endpointForIdentifier:endpointIdentifier];
    if (![endpoint isKindOfClass:PVLANEndpoint.class]) {
        [self notifyLog:[NSString stringWithFormat:@"LAN endpoint not found: %@", endpointIdentifier ?: @""]];
        [self notifyStatus:@"LAN 设备已离线，请重新扫描后再连接。"];
        [self notifyLANSessionsChanged];
        return;
    }
    [self tryConnectEndpoint:endpoint];
}

- (void)requestWindowListForEndpointIdentifier:(NSString *)endpointIdentifier {
    PVClientSession *session = [self.sessionManager sessionForEndpointIdentifier:endpointIdentifier];
    if (!session) {
        [self notifyInspectionError:[self inspectionSessionNotFoundError] endpointIdentifier:endpointIdentifier];
        return;
    }

    [session sendRequestType:PVRequestTypeWindowList payload:nil timeoutInterval:10 completion:^(NSData *responsePayload, NSError *error) {
        if (error) {
            [self notifyInspectionError:error endpointIdentifier:endpointIdentifier];
            return;
        }

        NSError *decodeError = nil;
        PVResponseAttachment *attachment = [self responseAttachmentFromPayload:responsePayload error:&decodeError];
        if (!attachment || decodeError) {
            [self notifyInspectionError:decodeError ?: [self invalidInspectionResponseError] endpointIdentifier:endpointIdentifier];
            return;
        }
        if (attachment.error) {
            [self notifyInspectionError:attachment.error endpointIdentifier:endpointIdentifier];
            return;
        }

        id responseData = attachment.data;
        NSArray<PVWindowInfo *> *windows = [responseData isKindOfClass:NSArray.class] ? (NSArray<PVWindowInfo *> *)responseData : @[];
        [self notifyWindowInfos:windows endpointIdentifier:endpointIdentifier];
    }];
}

- (void)requestHierarchyForEndpointIdentifier:(NSString *)endpointIdentifier windowIdentifier:(NSString *)windowIdentifier {
    PVClientSession *session = [self.sessionManager sessionForEndpointIdentifier:endpointIdentifier];
    if (!session) {
        [self notifyInspectionError:[self inspectionSessionNotFoundError] endpointIdentifier:endpointIdentifier];
        return;
    }

    PVRequestAttachment *request = [PVRequestAttachment attachmentWithData:windowIdentifier ?: @""];
    NSError *archiveError = nil;
    NSData *payload = [PVArchiveCodec archivedDataWithObject:request error:&archiveError];
    if (!payload) {
        [self notifyInspectionError:archiveError ?: [self invalidInspectionResponseError] endpointIdentifier:endpointIdentifier];
        return;
    }

    [session sendRequestType:PVRequestTypeHierarchy payload:payload timeoutInterval:10 completion:^(NSData *responsePayload, NSError *error) {
        if (error) {
            [self notifyInspectionError:error endpointIdentifier:endpointIdentifier];
            return;
        }

        NSError *decodeError = nil;
        PVResponseAttachment *attachment = [self responseAttachmentFromPayload:responsePayload error:&decodeError];
        if (!attachment || decodeError) {
            [self notifyInspectionError:decodeError ?: [self invalidInspectionResponseError] endpointIdentifier:endpointIdentifier];
            return;
        }
        if (attachment.error) {
            [self notifyInspectionError:attachment.error endpointIdentifier:endpointIdentifier];
            return;
        }
        id responseData = attachment.data;
        if (![responseData isKindOfClass:PVHierarchyInfo.class]) {
            [self notifyInspectionError:[self invalidInspectionResponseError] endpointIdentifier:endpointIdentifier];
            return;
        }

        [self notifyHierarchy:(PVHierarchyInfo *)responseData endpointIdentifier:endpointIdentifier];
    }];
}

- (void)requestHierarchyDetailsForEndpointIdentifier:(NSString *)endpointIdentifier displayItemIdentifiers:(NSArray<NSString *> *)displayItemIdentifiers {
    PVClientSession *session = [self.sessionManager sessionForEndpointIdentifier:endpointIdentifier];
    if (!session) {
        [self notifyInspectionError:[self inspectionSessionNotFoundError] endpointIdentifier:endpointIdentifier];
        return;
    }
    if (!displayItemIdentifiers.count) {
        [self notifyDisplayItemDetails:@[] endpointIdentifier:endpointIdentifier];
        return;
    }

    PVDisplayItemDetailRequest *request = [[PVDisplayItemDetailRequest alloc] init];
    request.displayItemIDs = displayItemIdentifiers;
    request.needsSoloImage = YES;
    request.needsGroupImage = YES;
    request.lowImageQuality = NO;

    NSError *archiveError = nil;
    NSData *payload = [PVArchiveCodec archivedDataWithObject:request error:&archiveError];
    if (!payload) {
        [self notifyInspectionError:archiveError ?: [self invalidInspectionResponseError] endpointIdentifier:endpointIdentifier];
        return;
    }

    [session sendRequestType:PVRequestTypeHierarchyDetails payload:payload timeoutInterval:10 completion:^(NSData *responsePayload, NSError *error) {
        if (error) {
            [self notifyInspectionError:error endpointIdentifier:endpointIdentifier];
            return;
        }

        NSError *decodeError = nil;
        PVResponseAttachment *attachment = [self responseAttachmentFromPayload:responsePayload error:&decodeError];
        if (!attachment || decodeError) {
            [self notifyInspectionError:decodeError ?: [self invalidInspectionResponseError] endpointIdentifier:endpointIdentifier];
            return;
        }
        if (attachment.error) {
            [self notifyInspectionError:attachment.error endpointIdentifier:endpointIdentifier];
            return;
        }

        id responseData = attachment.data;
        NSArray<PVDisplayItemDetail *> *details = [responseData isKindOfClass:NSArray.class] ? (NSArray<PVDisplayItemDetail *> *)responseData : @[];
        [self notifyDisplayItemDetails:details endpointIdentifier:endpointIdentifier];
    }];
}

- (void)stop {
    [self.scanTimer invalidate];
    self.scanTimer = nil;

    [self.usbDiscoverer stop];
    self.usbDiscoverer = nil;

    [self.loopbackDiscoverer stop];
    self.loopbackDiscoverer = nil;

    [self.lanDiscoverer stop];
    self.lanDiscoverer = nil;

    [self.sessionManager clear];
    [self notifyLANSessionsChanged];
}

- (void)tryConnectEndpoint:(id<PVEndpointProtocol>)endpoint {
    if ([self.sessionManager isEndpointConnectingWithIdentifier:endpoint.identifier]) return;
    if ([self.sessionManager isEndpointConnectedWithIdentifier:endpoint.identifier]) return;
    [self.sessionManager markEndpointConnectingWithIdentifier:endpoint.identifier];
    if ([endpoint isKindOfClass:PVLANEndpoint.class]) {
        [self notifyLANSessionsChanged];
    }

    id<PVConnectionProtocol> connection = [self connectionForEndpoint:endpoint];
    if (!connection) {
        [self.sessionManager removeConnectingEndpointWithIdentifier:endpoint.identifier];
        if ([endpoint isKindOfClass:PVLANEndpoint.class]) {
            NSError *error = [NSError errorWithDomain:PVErrorDomain
                                                 code:PVErrorCodeUnsupportedEndpoint
                                             userInfo:@{NSLocalizedDescriptionKey: @"Unable to create a LAN connection."}];
            [self notifyConnectionFailedForEndpoint:endpoint error:error];
            [self notifyLANSessionsChanged];
        }
        return;
    }

    PVClientSession *session = [[PVClientSession alloc] initWithConnection:connection];
    session.delegate = self;

    __weak typeof(self) weakSelf = self;
    [session openWithCompletion:^(NSError *error) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return;
        if (!NSThread.isMainThread) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self handleOpenCompletionForSession:session endpoint:endpoint error:error];
            });
            return;
        }
        [self handleOpenCompletionForSession:session endpoint:endpoint error:error];
    }];
}

- (void)handleOpenCompletionForSession:(PVClientSession *)session endpoint:(id<PVEndpointProtocol>)endpoint error:(NSError *)error {
    [self.sessionManager removeConnectingEndpointWithIdentifier:endpoint.identifier];
    if (error) {
        [self notifyLog:[NSString stringWithFormat:@"connect %@ failed: %@", endpoint.displayName ?: endpoint.identifier, error.localizedDescription ?: @""]];
        if ([endpoint isKindOfClass:PVLANEndpoint.class]) {
            [self notifyConnectionFailedForEndpoint:endpoint error:error];
            [self notifyLANSessionsChanged];
        }
        return;
    }

    if ([endpoint isKindOfClass:PVLANEndpoint.class]) {
        PVClientSession *usbSession = [self.sessionManager findUSBSessionByPeerIdentityUUID:session.peerIdentity.uuid];
        if (usbSession && usbSession.state == PVClientSessionStateReady) {
            [session close];
            NSError *usbError = [NSError errorWithDomain:PVErrorDomain
                                                     code:PVErrorCodeAlreadyConnectedViaUSB
                                                 userInfo:@{NSLocalizedDescriptionKey: PVClientLANBlockedByUSBMessage}];
            [self notifyConnectionFailedForEndpoint:endpoint error:usbError];
            [self notifyLANSessionsChanged];
            return;
        }
    }

    [self.sessionManager markEndpointConnectedWithIdentifier:endpoint.identifier];
    [self.sessionManager addSession:session];
    [self notifyConnectedEndpoint:session.endpoint];
    if (session.state == PVClientSessionStateReady) {
        [self sendSmokeMessageWithSession:session endpoint:session.endpoint];
    }
}

- (nullable id<PVConnectionProtocol>)connectionForEndpoint:(id<PVEndpointProtocol>)endpoint {
    if ([endpoint isKindOfClass:PVUSBEndpoint.class]) {
        return [[PVUSBConnection alloc] initWithEndpoint:(PVUSBEndpoint *)endpoint];
    }
    if ([endpoint isKindOfClass:PVLoopbackEndpoint.class]) {
        return [[PVLoopbackConnection alloc] initWithEndpoint:(PVLoopbackEndpoint *)endpoint];
    }
    if ([endpoint isKindOfClass:PVLANEndpoint.class]) {
        return [[PVLANConnection alloc] initWithEndpoint:(PVLANEndpoint *)endpoint];
    }
    return nil;
}

- (void)sendSmokeMessageWithSession:(PVClientSession *)session endpoint:(id<PVEndpointProtocol>)endpoint {
    NSString *message = [NSString stringWithFormat:@"hello from macOS to %@", endpoint.displayName ?: endpoint.identifier];
    NSError *payloadError = nil;
    NSData *payload = [NSPropertyListSerialization dataWithPropertyList:@{@"message": message}
                                                                  format:NSPropertyListBinaryFormat_v1_0
                                                                 options:0
                                                                   error:&payloadError];
    if (!payload) {
        [self notifyLog:[NSString stringWithFormat:@"encode message failed: %@", payloadError.localizedDescription]];
        return;
    }

    [session sendRequestType:PVRequestTypeMessage payload:payload timeoutInterval:5 completion:^(NSData *responsePayload, NSError *error) {
        if (error) {
            [self notifyLog:[NSString stringWithFormat:@"message failed: %@", error.localizedDescription]];
            return;
        }

        NSString *echo = nil;
        if (responsePayload.length) {
            NSDictionary *response = [NSPropertyListSerialization propertyListWithData:responsePayload
                                                                               options:NSPropertyListImmutable
                                                                                format:nil
                                                                                 error:&error];
            if ([response isKindOfClass:NSDictionary.class]) {
                id value = response[@"echo"];
                if ([value isKindOfClass:NSString.class]) {
                    echo = value;
                }
            }
        }
        [self notifyLog:[NSString stringWithFormat:@"message echo: %@", echo ?: @""]];
        [self notifyEcho:echo ?: @"" fromEndpoint:endpoint];
    }];
}

- (PVResponseAttachment *)responseAttachmentFromPayload:(NSData *)payload error:(NSError **)error {
    id object = [PVArchiveCodec unarchivedObjectFromData:payload
                                          allowedClasses:[PVArchiveCodec defaultAllowedClasses]
                                                   error:error];
    if ([object isKindOfClass:PVResponseAttachment.class]) {
        return object;
    }
    return nil;
}

- (NSError *)inspectionSessionNotFoundError {
    return [NSError errorWithDomain:PVErrorDomain
                               code:PVErrorCodeDisconnected
                           userInfo:@{NSLocalizedDescriptionKey: @"Inspection session not found."}];
}

- (NSError *)invalidInspectionResponseError {
    return [NSError errorWithDomain:PVErrorDomain
                               code:PVErrorCodeUnknown
                           userInfo:@{NSLocalizedDescriptionKey: @"Invalid inspection response."}];
}

#pragma mark - PVClientSessionManagerDelegate

- (void)clientSessionManagerDidUpdateSessions:(PVClientSessionManager *)sessionManager {
    [self notifyLANSessionsChanged];
}

#pragma mark - PVClientSessionDelegate

- (void)clientSession:(PVClientSession *)session didCloseWithError:(NSError *)error {
    if (!NSThread.isMainThread) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self clientSession:session didCloseWithError:error];
        });
        return;
    }
    if (!session) return;
    [self.sessionManager removeClosedSession:session];

    NSString *reason = error.localizedDescription ?: @"Connection closed.";
    [self notifyLog:[NSString stringWithFormat:@"disconnected %@: %@", session.endpoint.displayName ?: session.endpoint.identifier ?: @"", reason]];
    [self notifyDisconnectedEndpoint:session.endpoint reason:reason];
    [self notifyLANSessionsChanged];
}

#pragma mark - PVDiscoveryDelegate

- (void)discoverer:(id<PVEndpointDiscovererProtocol>)discoverer didFindEndpoint:(id<PVEndpointProtocol>)endpoint {
    if (!NSThread.isMainThread) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self discoverer:discoverer didFindEndpoint:endpoint];
        });
        return;
    }
    [self.sessionManager addEndpoint:endpoint];
    [self notifyLog:[NSString stringWithFormat:@"found %@", endpoint.displayName ?: endpoint.identifier]];
    if ([endpoint isKindOfClass:PVLANEndpoint.class]) {
        [self notifyLANSessionsChanged];
    } else {
        [self tryConnectEndpoint:endpoint];
    }
}

- (void)discoverer:(id<PVEndpointDiscovererProtocol>)discoverer didRemoveEndpoint:(id<PVEndpointProtocol>)endpoint {
    if (!NSThread.isMainThread) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self discoverer:discoverer didRemoveEndpoint:endpoint];
        });
        return;
    }
    if ([endpoint isKindOfClass:PVLANEndpoint.class]) {
        // Bonjour discovery can briefly withdraw a service while its TCP
        // connection remains healthy. Keep the established LAN session and
        // let connection close/heartbeat own its lifetime.
        [self.sessionManager forgetEndpointForIdentifier:endpoint.identifier];
    } else {
        [self.sessionManager removeEndpointForIdentifier:endpoint.identifier];
    }
    [self notifyLog:[NSString stringWithFormat:@"removed %@", endpoint.displayName]];
    [self notifyLANSessionsChanged];
}

#pragma mark - Notify

- (void)notifyStatus:(NSString *)status {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(pickViewClient:didUpdateStatus:)]) {
            [self.delegate pickViewClient:self didUpdateStatus:status ?: @""];
        }
    });
}

- (void)notifyLog:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(pickViewClient:didLogMessage:)]) {
            [self.delegate pickViewClient:self didLogMessage:message ?: @""];
        }
    });
}

- (void)notifyConnectedEndpoint:(id<PVEndpointProtocol>)endpoint {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(pickViewClient:didConnectEndpoint:)]) {
            [self.delegate pickViewClient:self didConnectEndpoint:endpoint];
        }
    });
}

- (void)notifyConnectionFailedForEndpoint:(id<PVEndpointProtocol>)endpoint error:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(pickViewClient:didFailToConnectEndpoint:error:)]) {
            [self.delegate pickViewClient:self didFailToConnectEndpoint:endpoint error:error];
        }
    });
}

- (void)notifyDisconnectedEndpoint:(id<PVEndpointProtocol>)endpoint reason:(NSString *)reason {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(pickViewClient:didDisconnectEndpoint:reason:)]) {
            [self.delegate pickViewClient:self didDisconnectEndpoint:endpoint reason:reason ?: @""];
        }
    });
}

- (void)notifyEcho:(NSString *)echo fromEndpoint:(id<PVEndpointProtocol>)endpoint {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(pickViewClient:didReceiveEcho:fromEndpoint:)]) {
            [self.delegate pickViewClient:self didReceiveEcho:echo ?: @"" fromEndpoint:endpoint];
        }
    });
}

- (void)notifyLANSessionsChanged {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(pickViewClientDidUpdateLANSessions:)]) {
            [self.delegate pickViewClientDidUpdateLANSessions:self];
        }
    });
}

- (void)notifyWindowInfos:(NSArray<PVWindowInfo *> *)windowInfos endpointIdentifier:(NSString *)endpointIdentifier {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(pickViewClient:didReceiveWindowInfos:endpointIdentifier:)]) {
            [self.delegate pickViewClient:self didReceiveWindowInfos:windowInfos ?: @[] endpointIdentifier:endpointIdentifier ?: @""];
        }
    });
}

- (void)notifyHierarchy:(PVHierarchyInfo *)hierarchy endpointIdentifier:(NSString *)endpointIdentifier {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(pickViewClient:didReceiveHierarchy:endpointIdentifier:)]) {
            [self.delegate pickViewClient:self didReceiveHierarchy:hierarchy endpointIdentifier:endpointIdentifier ?: @""];
        }
    });
}

- (void)notifyDisplayItemDetails:(NSArray<PVDisplayItemDetail *> *)details endpointIdentifier:(NSString *)endpointIdentifier {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(pickViewClient:didReceiveDisplayItemDetails:endpointIdentifier:)]) {
            [self.delegate pickViewClient:self didReceiveDisplayItemDetails:details ?: @[] endpointIdentifier:endpointIdentifier ?: @""];
        }
    });
}

- (void)notifyInspectionError:(NSError *)error endpointIdentifier:(NSString *)endpointIdentifier {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(pickViewClient:didFailInspectionRequestForEndpointIdentifier:error:)]) {
            [self.delegate pickViewClient:self didFailInspectionRequestForEndpointIdentifier:endpointIdentifier ?: @"" error:error];
        }
    });
}

@end

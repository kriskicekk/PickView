//
//  PickViewClient.m
//  PickViewClient
//
//  Created by kris cheng on 2026/7/6.
//

#import "PickViewClient.h"

#import "PickViewClientConfiguration.h"
#import "PVClientSession.h"
#import "PVClientSessionManager.h"
#import "PVConnectionProtocol.h"
#import "PVEndpointDiscovererDelegate.h"
#import "PVEndpointProtocol.h"
#import "PVLANConnection.h"
#import "PVLANEndpoint.h"
#import "PVLANEndpointDiscoverer.h"
#import "PVPeerIdentity.h"
#import "PVRequestType.h"
#import "PVSimulatorConnection.h"
#import "PVSimulatorEndpoint.h"
#import "PVSimulatorEndpointDiscoverer.h"
#import "PVUSBConnection.h"
#import "PVUSBEndpoint.h"
#import "PVUSBEndpointDiscoverer.h"

static NSString * const PVClientLANBlockedByUSBMessage = @"当前 App 已经通过 USB 连接，请先断开 USB。";
static NSString * const PVClientLANUnavailableMessage = @"LAN session 不可用，请重新扫描后再连接。";

@interface PickViewClient () <PVEndpointDiscovererDelegate, PVClientSessionDelegate, PVClientSessionManagerDelegate>

@property (nonatomic, strong) PickViewClientConfiguration *configuration;
@property (nonatomic, strong, nullable) PVUSBEndpointDiscoverer *usbDiscoverer;
@property (nonatomic, strong, nullable) PVSimulatorEndpointDiscoverer *simulatorDiscoverer;
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

    if (self.configuration.enableSimulatorDiscovery) {
        self.simulatorDiscoverer = [[PVSimulatorEndpointDiscoverer alloc] init];
        self.simulatorDiscoverer.delegate = self;
        [self.simulatorDiscoverer start];
    }

    if (self.configuration.enableLANDiscovery) {
        self.lanDiscoverer = [[PVLANEndpointDiscoverer alloc] init];
        self.lanDiscoverer.delegate = self;
        [self.lanDiscoverer start];
        [self notifyLog:@"started LAN discovery"];
    }

    [self notifyStatus:@"Waiting for USB device, simulator, or LAN service..."];
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
        [self tryConnectEndpoint:endpoint];
    }
}

- (void)connectToLANEndpointIdentifier:(NSString *)endpointIdentifier {
    PVClientSession *session = [self.sessionManager sessionForEndpointIdentifier:endpointIdentifier];
    if (![session.endpoint isKindOfClass:PVLANEndpoint.class]) {
        [self notifyLog:[NSString stringWithFormat:@"LAN session not found: %@", endpointIdentifier ?: @""]];
        return;
    }
    if (session.state == PVClientSessionStateBlocked) {
        [self notifyStatus:PVClientLANBlockedByUSBMessage];
        [self notifyLog:PVClientLANBlockedByUSBMessage];
        [self notifyLANSessionsChanged];
        return;
    }
    if (session.state != PVClientSessionStateReady) {
        [self notifyStatus:PVClientLANUnavailableMessage];
        [self notifyLog:PVClientLANUnavailableMessage];
        [self notifyLANSessionsChanged];
        return;
    }

    [self notifyConnectedEndpoint:session.endpoint];
    [self notifyLANSessionsChanged];
    [self sendSmokeMessageWithSession:session endpoint:session.endpoint];
}

- (void)stop {
    [self.scanTimer invalidate];
    self.scanTimer = nil;

    [self.usbDiscoverer stop];
    self.usbDiscoverer = nil;

    [self.simulatorDiscoverer stop];
    self.simulatorDiscoverer = nil;

    [self.lanDiscoverer stop];
    self.lanDiscoverer = nil;

    [self.sessionManager clear];
    [self notifyLANSessionsChanged];
}

- (void)tryConnectEndpoint:(id<PVEndpointProtocol>)endpoint {
    if ([self.sessionManager isEndpointConnectingWithIdentifier:endpoint.identifier]) return;
    if ([self.sessionManager isEndpointConnectedWithIdentifier:endpoint.identifier]) return;
    [self.sessionManager markEndpointConnectingWithIdentifier:endpoint.identifier];

    id<PVConnectionProtocol> connection = [self connectionForEndpoint:endpoint];
    if (!connection) {
        [self.sessionManager removeConnectingEndpointWithIdentifier:endpoint.identifier];
        return;
    }

    PVClientSession *session = [[PVClientSession alloc] initWithConnection:connection];
    session.delegate = self;

    __weak typeof(self) weakSelf = self;
    [session openWithCompletion:^(NSError *error) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return;
        [self.sessionManager removeConnectingEndpointWithIdentifier:endpoint.identifier];
        if (error) {
            [self notifyLog:[NSString stringWithFormat:@"connect %@ failed: %@", endpoint.displayName ?: endpoint.identifier, error.localizedDescription ?: @""]];
            return;
        }
        [self.sessionManager markEndpointConnectedWithIdentifier:endpoint.identifier];
        [self.sessionManager addSession:session];
        [self notifyConnectedEndpoint:session.endpoint];
        if (session.state == PVClientSessionStateReady) [self sendSmokeMessageWithSession:session endpoint:session.endpoint];
        [self notifyLANSessionsChanged];
    }];
}

- (nullable id<PVConnectionProtocol>)connectionForEndpoint:(id<PVEndpointProtocol>)endpoint {
    if ([endpoint isKindOfClass:PVUSBEndpoint.class]) {
        return [[PVUSBConnection alloc] initWithEndpoint:(PVUSBEndpoint *)endpoint];
    }
    if ([endpoint isKindOfClass:PVSimulatorEndpoint.class]) {
        return [[PVSimulatorConnection alloc] initWithEndpoint:(PVSimulatorEndpoint *)endpoint];
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

#pragma mark - PVClientSessionManagerDelegate

- (void)clientSessionManagerDidUpdateSessions:(PVClientSessionManager *)sessionManager {
    [self notifyLANSessionsChanged];
}

#pragma mark - PVClientSessionDelegate

- (void)clientSession:(PVClientSession *)session didCloseWithError:(NSError *)error {
    if (!session) return;
    [self.sessionManager removeClosedSession:session];

    NSString *reason = error.localizedDescription ?: @"Connection closed.";
    [self notifyLog:[NSString stringWithFormat:@"disconnected %@: %@", session.endpoint.displayName ?: session.endpoint.identifier ?: @"", reason]];
    [self notifyDisconnectedEndpoint:session.endpoint reason:reason];
    [self notifyLANSessionsChanged];
}

#pragma mark - PVDiscoveryDelegate

- (void)discoverer:(id<PVEndpointDiscovererProtocol>)discoverer didFindEndpoint:(id<PVEndpointProtocol>)endpoint {
    [self.sessionManager addEndpoint:endpoint];
    [self notifyLog:[NSString stringWithFormat:@"found %@", endpoint.displayName ?: endpoint.identifier]];
    [self tryConnectEndpoint:endpoint];
}

- (void)discoverer:(id<PVEndpointDiscovererProtocol>)discoverer didRemoveEndpoint:(id<PVEndpointProtocol>)endpoint {
    [self.sessionManager removeEndpointForIdentifier:endpoint.identifier];
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

@end

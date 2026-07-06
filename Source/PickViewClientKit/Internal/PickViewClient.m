//
//  PickViewClient.m
//  PickViewClient
//
//  Created by kris cheng on 2026/7/6.
//

#import "PickViewClient.h"

#import "PickViewClientConfiguration.h"
#import "PVClientSession.h"
#import "PVConnectionProtocol.h"
#import "PVEndpointDiscovererDelegate.h"
#import "PVEndpointProtocol.h"
#import "PVRequestType.h"
#import "PVSimulatorConnection.h"
#import "PVSimulatorEndpoint.h"
#import "PVUSBConnection.h"
#import "PVUSBEndpoint.h"
#import "PVUSBEndpointDiscoverer.h"
#import "PVSimulatorEndpointDiscoverer.h"

@interface PickViewClient () <PVEndpointDiscovererDelegate>

@property (nonatomic, strong) PickViewClientConfiguration *configuration;
@property (nonatomic, strong, nullable) PVUSBEndpointDiscoverer *usbDiscoverer;
@property (nonatomic, strong, nullable) PVSimulatorEndpointDiscoverer *simulatorDiscoverer;

@property (nonatomic, strong) NSMutableDictionary<NSString *, id<PVEndpointProtocol>> *endpointsByID;
@property (nonatomic, strong) NSMutableSet<NSString *> *connectingEndpointIDs;
@property (nonatomic, strong) NSMutableSet<NSString *> *connectedEndpointIDs;

@property (nonatomic, strong) NSMutableArray<PVClientSession *> *sessions;

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
        _endpointsByID = [NSMutableDictionary dictionary];
        _connectingEndpointIDs = [NSMutableSet set];
        _connectedEndpointIDs = [NSMutableSet set];
        _sessions = [NSMutableArray array];
    }
    return self;
}

- (void)startScanning {
    [self startScanningWithConfiguration:nil];
}

- (void)startScanningWithConfiguration:(PickViewClientConfiguration *)configuration {
    [self stop];

    self.configuration = configuration ?: [PickViewClientConfiguration defaultConfiguration];
    self.endpointsByID = [NSMutableDictionary dictionary];
    self.connectingEndpointIDs = [NSMutableSet set];
    self.connectedEndpointIDs = [NSMutableSet set];
    self.sessions = [NSMutableArray array];

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
    NSArray<id<PVEndpointProtocol>> *endpoints = [self autoConnectableEndpointsFromEndpoints:[self sortedEndpointsForConnection:self.endpointsByID.allValues]];
    if (!self.endpointsByID.count) {
        return;
    }

    if (!endpoints.count) {
        return;
    }

    for (id<PVEndpointProtocol> endpoint in endpoints) {
        [self tryConnectEndpoint:endpoint];
    }
}

- (NSArray<id<PVEndpointProtocol>> *)sortedEndpointsForConnection:(NSArray<id<PVEndpointProtocol>> *)endpoints {
    return [endpoints sortedArrayUsingComparator:^NSComparisonResult(id<PVEndpointProtocol> endpointA, id<PVEndpointProtocol> endpointB) {
        if (endpointA.priority > endpointB.priority) {
            return NSOrderedAscending;
        } else if (endpointA.priority < endpointB.priority) {
            return NSOrderedDescending;
        } else {
            return [endpointA.identifier compare:endpointB.identifier];
        }
    }];
}

- (void)connectToLANEndpointIdentifier:(NSString *)endpointIdentifier {
    NSLog(@"[PickView Client] LAN connection is not implemented yet: %@", endpointIdentifier ?: @"");
}

- (void)stop {
    [self.scanTimer invalidate];
    self.scanTimer = nil;

    [self.usbDiscoverer stop];
    self.usbDiscoverer = nil;

    [self.simulatorDiscoverer stop];
    self.simulatorDiscoverer = nil;

    for (PVClientSession *session in self.sessions) {
        [session close];
    }
    [self.sessions removeAllObjects];
    [self.endpointsByID removeAllObjects];
    [self.connectingEndpointIDs removeAllObjects];
    [self.connectedEndpointIDs removeAllObjects];
}

- (void)tryConnectEndpoint:(id<PVEndpointProtocol>)endpoint {
    if (![self shouldAttemptEndpoint:endpoint]) {
        return;
    }

    if ([self.connectingEndpointIDs containsObject:endpoint.identifier]) {
        return;
    }
    if ([self.connectedEndpointIDs containsObject:endpoint.identifier]) {
        return;
    }

    [self.connectingEndpointIDs addObject:endpoint.identifier];
    id<PVConnectionProtocol> connection = [self connectionForEndpoint:endpoint];
    if (!connection) {
        [self.connectingEndpointIDs removeObject:endpoint.identifier];
        return;
    }

    PVClientSession *session = [[PVClientSession alloc] initWithConnection:connection];
    [self.sessions addObject:session];

    __weak typeof(self) weakSelf = self;
    [session openWithCompletion:^(NSError *error) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return;

        if (error) {
            [self.connectingEndpointIDs removeObject:endpoint.identifier];
            [self.sessions removeObject:session];
            NSLog(@"[PickView Client] connect failed %@: %@", endpoint.displayName, error.localizedDescription);
            return;
        }

        [self.connectingEndpointIDs removeObject:endpoint.identifier];
        [self.connectedEndpointIDs addObject:endpoint.identifier];
        NSLog(@"[PickView Client] connected %@", endpoint.displayName);
        [self sendSmokeMessageWithSession:session endpoint:endpoint];
    }];
}

- (nullable id<PVConnectionProtocol>)connectionForEndpoint:(id<PVEndpointProtocol>)endpoint {
    if ([endpoint isKindOfClass:PVUSBEndpoint.class]) {
        return [[PVUSBConnection alloc] initWithEndpoint:(PVUSBEndpoint *)endpoint];
    }
    if ([endpoint isKindOfClass:PVSimulatorEndpoint.class]) {
        return [[PVSimulatorConnection alloc] initWithEndpoint:(PVSimulatorEndpoint *)endpoint];
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
        NSLog(@"[PickView Client] encode message failed: %@", payloadError.localizedDescription);
        return;
    }

    [session sendRequestType:PVRequestTypeMessage payload:payload timeoutInterval:5 completion:^(NSData *responsePayload, NSError *error) {
        if (error) {
            NSLog(@"[PickView Client] message failed: %@", error.localizedDescription);
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
        NSLog(@"[PickView Client] message echo: %@", echo ?: @"");
    }];
}

- (NSArray<id<PVEndpointProtocol>> *)autoConnectableEndpointsFromEndpoints:(NSArray<id<PVEndpointProtocol>> *)endpoints {
    NSMutableArray<id<PVEndpointProtocol>> *autoConnectableEndpoints = [NSMutableArray array];
    for (id<PVEndpointProtocol> endpoint in endpoints) {
        [autoConnectableEndpoints addObject:endpoint];
    }
    return autoConnectableEndpoints;
}

- (BOOL)shouldAttemptEndpoint:(id<PVEndpointProtocol>)endpoint {
    if (self.configuration.preferUSBTransport &&
        endpoint.transportType != PVEndpointTransportTypeUSB &&
        [self hasActiveUSBConnectionOrAttempt]) {
        return NO;
    }
    return YES;
}

- (BOOL)hasActiveUSBConnectionOrAttempt {
    NSMutableSet<NSString *> *activeEndpointIDs = [NSMutableSet setWithSet:self.connectedEndpointIDs];
    [activeEndpointIDs unionSet:self.connectingEndpointIDs];

    for (NSString *endpointID in activeEndpointIDs) {
        id<PVEndpointProtocol> endpoint = self.endpointsByID[endpointID];
        if ([endpoint isKindOfClass:PVUSBEndpoint.class]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - PVDiscoveryDelegate

- (void)discoverer:(id<PVEndpointDiscovererProtocol>)discoverer didFindEndpoint:(id<PVEndpointProtocol>)endpoint {
    self.endpointsByID[endpoint.identifier] = endpoint;
    NSLog(@"[PickView Client] found %@", endpoint.displayName);
    [self tryConnectEndpoint:endpoint];
}

- (void)discoverer:(id<PVEndpointDiscovererProtocol>)discoverer didRemoveEndpoint:(id<PVEndpointProtocol>)endpoint {
    [self removeSessionForEndpoint:endpoint];
    [self.endpointsByID removeObjectForKey:endpoint.identifier];
    [self.connectedEndpointIDs removeObject:endpoint.identifier];
    [self.connectingEndpointIDs removeObject:endpoint.identifier];
    NSLog(@"[PickView Client] removed %@", endpoint.displayName);
}

- (void)removeSessionForEndpoint:(id<PVEndpointProtocol>)endpoint {
    NSMutableArray<PVClientSession *> *removedSessions = [NSMutableArray array];
    for (PVClientSession *session in self.sessions) {
        if ([session.connection.connectionIdentifier isEqualToString:endpoint.identifier]) {
            [session close];
            [removedSessions addObject:session];
        }
    }
    [self.sessions removeObjectsInArray:removedSessions];
}

@end

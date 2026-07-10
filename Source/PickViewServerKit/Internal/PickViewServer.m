//
//  PickViewServer.m
//  PickViewServer
//
//  Created by kris cheng on 2026/7/6.
//

#import "PickViewServer.h"

#import "PickViewServerConfiguration.h"
#import "PVAppInfoHandler.h"
#import "PVCompositeRequestHandler.h"
#import "PVConnectionProtocol.h"
#import "PVHeartbeatHandler.h"
#import "PVHierarchyDetailsHandler.h"
#import "PVHierarchyHandler.h"
#import "PVHierarchyProvider.h"
#import "PVIOSHierarchyProvider.h"
#import "PVLANListener.h"
#import "PVListenerProtocol.h"
#import "PVLocalLoopbackListener.h"
#import "PVMessageHandler.h"
#import "PVMacHierarchyProvider.h"
#import "PVPeerIdentity.h"
#import "PVKitVersion.h"
#import "PVRequestHandlerProtocol.h"
#import "PVServerSession.h"
#import "PVWindowListHandler.h"

#import <TargetConditionals.h>

static NSUInteger const PVLANBonjourServiceNameMaxBytes = 63;

static NSString *PVStringByTrimmingToUTF8ByteLength(NSString *string, NSUInteger maxBytes) {
    if ([string lengthOfBytesUsingEncoding:NSUTF8StringEncoding] <= maxBytes) {
        return string;
    }

    NSMutableString *result = [NSMutableString string];
    __block NSUInteger usedBytes = 0;
    [string enumerateSubstringsInRange:NSMakeRange(0, string.length)
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        NSUInteger substringBytes = [substring lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        if (usedBytes + substringBytes > maxBytes) {
            *stop = YES;
            return;
        }

        [result appendString:substring];
        usedBytes += substringBytes;
    }];
    return result.copy;
}

static NSString *PVLANServiceNameWithPeerID(NSString *baseName) {
    NSString *name = baseName.length ? baseName : @"PickView";
    PVPeerIdentity *identity = [PVPeerIdentity localIdentityWithProtocolVersion:PVServerProtocolVersion
                                                        supportedPeerVersionMin:PVServerSupportedPeerVersionMin
                                                        supportedPeerVersionMax:PVServerSupportedPeerVersionMax];
    NSString *peerID = identity.uuid;
    if (!peerID.length || [name containsString:peerID]) {
        return name;
    }

    NSString *suffix = [NSString stringWithFormat:@"-%@", peerID];
    NSUInteger suffixBytes = [suffix lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    if (suffixBytes >= PVLANBonjourServiceNameMaxBytes) {
        return PVStringByTrimmingToUTF8ByteLength(peerID, PVLANBonjourServiceNameMaxBytes);
    }

    NSUInteger maxBaseBytes = PVLANBonjourServiceNameMaxBytes - suffixBytes;
    NSString *trimmedName = PVStringByTrimmingToUTF8ByteLength(name, maxBaseBytes);
    return [trimmedName stringByAppendingString:suffix];
}

@interface PickViewServer () <PVListenerDelegate, PVServerSessionDelegate>
@property (nonatomic, strong) PickViewServerConfiguration *configuration;
@property (nonatomic, strong, nullable) PVLocalLoopbackListener *localLoopbackListener;
@property (nonatomic, strong, nullable) PVLANListener *lanListener;
@property (nonatomic, strong) NSMutableArray<PVServerSession *> *sessions;
@property (nonatomic, strong) NSMutableDictionary<NSString *, PVServerSession *> *sessionsDict;
@property (nonatomic, strong) NSMutableArray<id<PVRequestHandlerProtocol>> *customHandlers;
@property (nonatomic, strong) id<PVHierarchyProvider> hierarchyProvider;
@property (nonatomic, assign, getter=isRunning) BOOL running;
@end

@implementation PickViewServer

+ (PickViewServer *)sharedServer {
    static PickViewServer *server = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        server = [[PickViewServer alloc] init];
    });
    return server;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _configuration = [PickViewServerConfiguration defaultConfiguration];
        _sessions = [NSMutableArray array];
        _customHandlers = [NSMutableArray array];
        _sessionsDict = [NSMutableDictionary dictionary];
        _hierarchyProvider = [self makeDefaultHierarchyProvider];
    }
    return self;
}

- (void)start {
    [self startWithConfiguration:nil];
}

- (void)startWithConfiguration:(PickViewServerConfiguration *)configuration {
    if (self.isRunning || self.localLoopbackListener || self.lanListener) {
        [self stop];
    }

    self.configuration = configuration ?: [PickViewServerConfiguration defaultConfiguration];

    if (self.configuration.enableLocalLoopback) {
        self.localLoopbackListener = [[PVLocalLoopbackListener alloc] initWithPortRangeStart:self.configuration.portStart end:self.configuration.portEnd];
        self.localLoopbackListener.delegate = self;
        [self startListener:self.localLoopbackListener];
    }

    if ([self shouldStartLANTransport]) {
        NSString *lanServiceName = PVLANServiceNameWithPeerID(self.configuration.lanServiceName);
        self.lanListener = [[PVLANListener alloc] initWithServiceName:lanServiceName];
        self.lanListener.delegate = self;
        [self startListener:self.lanListener];
    }
}

- (BOOL)shouldStartLANTransport {
#if TARGET_OS_SIMULATOR
    return NO;
#else
    return self.configuration.enableLANTransport;
#endif
}

- (void)stop {
    for (PVServerSession *session in self.sessions) {
        [session close];
    }
    [self.sessions removeAllObjects];
    [self.sessionsDict removeAllObjects];

    [self.localLoopbackListener stop];
    self.localLoopbackListener = nil;

    [self.lanListener stop];
    self.lanListener = nil;

    self.running = NO;
}

- (void)registerHandler:(id<PVRequestHandlerProtocol>)handler {
    if (handler) {
        [self.customHandlers addObject:handler];
    }
}

- (PVCompositeRequestHandler *)makeRequestHandler {
    NSMutableArray<id<PVRequestHandlerProtocol>> *handlers = [NSMutableArray array];
    [handlers addObject:[[PVHeartbeatHandler alloc] init]];
    if (self.configuration.enableMessageHandler) {
        __weak typeof(self) weakSelf = self;
        PVMessageHandler *messageHandler = [[PVMessageHandler alloc] initWithReceiveBlock:^(NSString *message) {
            [weakSelf notifyReceivedMessage:message];
        }];
        [handlers addObject:messageHandler];
    }
    if (self.configuration.enableAppInfoHandler) {
        [handlers addObject:[[PVAppInfoHandler alloc] init]];
    }
    if (self.configuration.enableHierarchyHandler) {
        [handlers addObject:[[PVWindowListHandler alloc] initWithProvider:self.hierarchyProvider]];
        [handlers addObject:[[PVHierarchyHandler alloc] initWithProvider:self.hierarchyProvider]];
        [handlers addObject:[[PVHierarchyDetailsHandler alloc] initWithProvider:self.hierarchyProvider]];
    }
    [handlers addObjectsFromArray:self.customHandlers];
    return [[PVCompositeRequestHandler alloc] initWithHandlers:handlers];
}

- (id<PVHierarchyProvider>)makeDefaultHierarchyProvider {
#if TARGET_OS_IPHONE
    return [[PVIOSHierarchyProvider alloc] init];
#else
    return [[PVMacHierarchyProvider alloc] init];
#endif
}

- (void)startListener:(id<PVListenerProtocol>)listener {
    __weak typeof(self) weakSelf = self;
    [listener startWithCompletion:^(NSError *error) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return;

        if (error) {
            NSLog(@"[PickView Server]:%@ start failed with reason %@", [listener.class description], error.description);
            [self notifyStartError:error];
            return;
        }

        self.running = YES;
        NSLog(@"[PickView Server]:%@ listening on port %d", [listener.class description], [self listeningPortForListener:listener]);
        [self notifyListeningOnPort:[self listeningPortForListener:listener]];
    }];
}

- (int)listeningPortForListener:(id<PVListenerProtocol>)listener {
    if ([listener isKindOfClass:PVLocalLoopbackListener.class]) {
        return ((PVLocalLoopbackListener *)listener).listeningPort;
    }
    if ([listener isKindOfClass:PVLANListener.class]) {
        return ((PVLANListener *)listener).listeningPort;
    }
    return 0;
}

- (void)notifyListeningOnPort:(int)port {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(pickViewServer:didStartListeningOnPort:)]) {
            [self.delegate pickViewServer:self didStartListeningOnPort:port];
        }
    });
}

- (void)notifyStartError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(pickViewServer:didFailToStartWithError:)]) {
            [self.delegate pickViewServer:self didFailToStartWithError:error];
        }
    });
}

- (void)notifyAcceptedConnection:(id<PVConnectionProtocol>)connection {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(pickViewServer:didAcceptConnectionWithIdentifier:)]) {
            [self.delegate pickViewServer:self didAcceptConnectionWithIdentifier:connection.connectionIdentifier];
        }
    });
}

- (void)notifyReceivedMessage:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(pickViewServer:didReceiveMessage:)]) {
            [self.delegate pickViewServer:self didReceiveMessage:message ?: @""];
        }
    });
}

#pragma mark - PVListenerDelegate

- (void)listener:(id<PVListenerProtocol>)listener didAcceptConnection:(id<PVConnectionProtocol>)connection {
    PVServerSession *session = [[PVServerSession alloc] initWithConnection:connection requestHandler:[self makeRequestHandler]];
    session.delegate = self;
    [self.sessions addObject:session];
    self.sessionsDict[connection.connectionIdentifier] = session;
    [session start];
    NSLog(@"[PickView Server]:%@ did accept connection %@", [listener.class description], connection.connectionIdentifier);
    [self notifyAcceptedConnection:connection];
}

- (void)listener:(id<PVListenerProtocol>)listener closeConnection:(id<PVConnectionProtocol>)connection {
    PVServerSession *session = self.sessionsDict[connection.connectionIdentifier];
    if (session) {
        [self.sessionsDict removeObjectForKey:connection.connectionIdentifier];
        [self.sessions removeObject:session];
        [session close];
        NSLog(@"[PickView Server]:%@ did close connection %@", [listener.class description], connection.connectionIdentifier);
    }
}

#pragma mark - PVServerSessionDelegate

- (void)serverSession:(PVServerSession *)session didCloseWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.sessionsDict[session.connection.connectionIdentifier] == session) {
            [self.sessionsDict removeObjectForKey:session.connection.connectionIdentifier];
            [self.sessions removeObject:session];
        }
    });
}

@end

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
#import "PVLANListener.h"
#import "PVListenerProtocol.h"
#import "PVLoopbackListener.h"
#import "PVMessageHandler.h"
#import "PVPeerIdentity.h"
#import "PVKitVersion.h"
#import "PVRequestHandlerProtocol.h"
#import "PVServerSession.h"
#import "PVWindowListHandler.h"

#import <TargetConditionals.h>

#if TARGET_OS_IPHONE
#import "PVIOSHierarchyProvider.h"
#import <UIKit/UIKit.h>
#else
#import "PVMacHierarchyProvider.h"
#import <AppKit/AppKit.h>
#endif

@interface PickViewServer () <PVListenerDelegate, PVServerSessionDelegate>
@property (nonatomic, strong) PickViewServerConfiguration *configuration;
@property (nonatomic, strong, nullable) PVLoopbackListener *loopbackListener;
@property (nonatomic, strong, nullable) PVLANListener *lanListener;
@property (nonatomic, strong) NSMutableArray<PVServerSession *> *sessions;
@property (nonatomic, strong) NSMutableDictionary<NSString *, PVServerSession *> *sessionsDict;
@property (nonatomic, strong) NSMutableArray<id<PVRequestHandlerProtocol>> *customHandlers;
@property (nonatomic, strong) id<PVHierarchyProvider> hierarchyProvider;
@property (nonatomic, assign, getter=isRunning) BOOL running;
@end

@implementation PickViewServer

+ (void)load {
    [PickViewServer sharedServer];
}

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
#if TARGET_OS_IPHONE
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidBecomeReady:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
#else
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidBecomeReady:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidBecomeReady:)
                                                     name:NSApplicationDidBecomeActiveNotification
                                                   object:nil];
#endif
    }
    return self;
}

- (void)applicationDidBecomeReady:(NSNotification *)notification {
    (void)notification;
    if (self.isRunning || self.loopbackListener || self.lanListener) {
        return;
    }
    [self start];
}

- (void)start {
    [self startWithConfiguration:nil];
}

- (void)startWithConfiguration:(PickViewServerConfiguration *)configuration {
    if (self.isRunning || self.loopbackListener || self.lanListener) {
        [self stop];
    }

    self.configuration = configuration ?: [PickViewServerConfiguration defaultConfiguration];

    if (self.configuration.enableLocalLoopback) {
        self.loopbackListener = [[PVLoopbackListener alloc] initWithPortRangeStart:self.configuration.portStart end:self.configuration.portEnd];
        self.loopbackListener.delegate = self;
        [self startListener:self.loopbackListener];
    }
    
#if TARGET_OS_IPHONE
    if ([self shouldStartLANTransport]) {
        NSString *lanServiceName = self.configuration.lanServiceName.length
            ? self.configuration.lanServiceName
            : @"PickView";
        UIDevice *device = UIDevice.currentDevice;
        NSString *systemVersion = [NSString stringWithFormat:@"iOS %@",
                                   device.systemVersion ?: @""];
        self.lanListener = [[PVLANListener alloc]
            initWithServiceName:lanServiceName
                     deviceName:device.name
                  systemVersion:systemVersion];
        self.lanListener.delegate = self;
        [self startListener:self.lanListener];
    }
#endif
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

    [self.loopbackListener stop];
    self.loopbackListener = nil;

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
    if ([listener isKindOfClass:PVLoopbackListener.class]) {
        return ((PVLoopbackListener *)listener).listeningPort;
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
    BOOL requiresAuthorization = [listener isKindOfClass:PVLANListener.class];
    __weak typeof(self) weakSelf = self;
    PVServerSession *session = [[PVServerSession alloc]
        initWithConnection:connection
             requestHandler:[self makeRequestHandler]
      requiresAuthorization:requiresAuthorization
       authorizationHandler:requiresAuthorization
            ? ^(PVPeerIdentity *peerIdentity, PVServerSessionAuthorizationDecision decision) {
                __strong typeof(weakSelf) self = weakSelf;
                [self requestConnectionAuthorizationForPeer:peerIdentity decision:decision];
            }
            : nil];
    session.delegate = self;
    [self.sessions addObject:session];
    self.sessionsDict[connection.connectionIdentifier] = session;
    [session start];
    NSLog(@"[PickView Server]:%@ did accept connection %@", [listener.class description], connection.connectionIdentifier);
    [self notifyAcceptedConnection:connection];
}

- (void)requestConnectionAuthorizationForPeer:(PVPeerIdentity *)peerIdentity
                                      decision:(PVServerSessionAuthorizationDecision)decision {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(pickViewServer:didReceiveConnectionRequestFromPeer:decisionHandler:)]) {
            [self.delegate pickViewServer:self
              didReceiveConnectionRequestFromPeer:peerIdentity
                                  decisionHandler:decision];
            return;
        }

#if TARGET_OS_IPHONE
        UIViewController *presenter = [self activePresenterViewController];
        if (!presenter) {
            decision(NO);
            return;
        }
        NSString *peerName = peerIdentity.deviceName.length
            ? peerIdentity.deviceName
            : (peerIdentity.appName.length ? peerIdentity.appName : @"PickView Client");
        NSString *message = [NSString stringWithFormat:@"%@ 请求连接并检查当前 App。", peerName];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"PickView 连接请求"
                                                                        message:message
                                                                 preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"拒绝"
                                                  style:UIAlertActionStyleCancel
                                                handler:^(__unused UIAlertAction *action) {
            decision(NO);
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"允许"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(__unused UIAlertAction *action) {
            decision(YES);
        }]];
        [presenter presentViewController:alert animated:YES completion:nil];
#else
        decision(NO);
#endif
    });
}

#if TARGET_OS_IPHONE
- (UIViewController *)activePresenterViewController {
    UIWindow *keyWindow = nil;
    for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
        if (![scene isKindOfClass:UIWindowScene.class] ||
            scene.activationState != UISceneActivationStateForegroundActive) {
            continue;
        }
        for (UIWindow *window in ((UIWindowScene *)scene).windows) {
            if (window.isKeyWindow) {
                keyWindow = window;
                break;
            }
        }
        if (keyWindow) {
            break;
        }
    }
    UIViewController *viewController = keyWindow.rootViewController;
    while (viewController.presentedViewController) {
        viewController = viewController.presentedViewController;
    }
    if ([viewController isKindOfClass:UINavigationController.class]) {
        viewController = ((UINavigationController *)viewController).visibleViewController;
    }
    if ([viewController isKindOfClass:UITabBarController.class]) {
        viewController = ((UITabBarController *)viewController).selectedViewController;
    }
    return viewController;
}
#endif

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

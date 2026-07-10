#import "PVDetailPrefix.h"

#import "PVDetailAppsManager.h"

#import "PVInspectionRequestClient.h"
#import "PVRequestAttachment.h"
#import "PVRequestType.h"
#import "PickViewClient.h"
#import "PVClientSession.h"
#import "PVClientSessionManager.h"
#import "PVEndpointProtocol.h"
#import "PVPeerIdentity.h"

NSString *const PVDetailInspectingAppDidEndNotificationName = @"PVDetailInspectingAppDidEndNotificationName";

@interface PVDetailAppsManager ()

@property(nonatomic, strong) RACSubject *willConnectToApp;
@property(nonatomic, strong) RACSubject *didAutoReconnectSucc;
@property(nonatomic, strong) RACDisposable *connectionMonitorDisposable;
@property(nonatomic, strong) PVAppInfo *reconnectingAppInfo;
@property(nonatomic, strong) NSImage *reconnectingAppIcon;
@property(nonatomic, strong) NSDate *lastReconnectAttemptDate;
@property(nonatomic, assign) BOOL reconnectInFlight;

@end

@implementation PVDetailAppsManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static PVDetailAppsManager *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _willConnectToApp = [RACSubject subject];
        _didAutoReconnectSucc = [RACSubject subject];

        @weakify(self);
        _connectionMonitorDisposable = [[RACSignal interval:1 onScheduler:RACScheduler.mainThreadScheduler] subscribeNext:^(NSDate *date) {
            @strongify(self);
            [self inspectConnectionStateAtDate:date];
        }];
    }
    return self;
}

- (void)setInspectingApp:(PVDetailInspectableApp *)inspectingApp {
    BOOL shouldPostNotification = (_inspectingApp && !inspectingApp);

    _inspectingApp = inspectingApp;
    if (inspectingApp) {
        self.reconnectingAppInfo = nil;
        self.reconnectingAppIcon = nil;
        self.lastReconnectAttemptDate = nil;
        self.reconnectInFlight = NO;
        [self.willConnectToApp sendNext:inspectingApp];
    }

    if (shouldPostNotification) {
        [[NSNotificationCenter defaultCenter] postNotificationName:PVDetailInspectingAppDidEndNotificationName object:self];
    }
}

- (void)inspectConnectionStateAtDate:(NSDate *)date {
    if (self.inspectingApp) {
        PVClientSession *session = self.inspectingApp.session;
        BOOL sessionIsAvailable = session &&
                                  [PickViewClient.sharedClient.sessionManager.allSessions containsObject:session] &&
                                  session.state == PVClientSessionStateReady;
        if (!sessionIsAvailable) {
            self.reconnectingAppInfo = self.inspectingApp.appInfo;
            self.reconnectingAppIcon = self.inspectingApp.appInfo.appIcon;
            _inspectingApp = nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:PVDetailInspectingAppDidEndNotificationName object:self];
        }
    }

    if (!self.reconnectingAppInfo || self.reconnectInFlight) {
        return;
    }
    if (self.lastReconnectAttemptDate && [date timeIntervalSinceDate:self.lastReconnectAttemptDate] < 3) {
        return;
    }

    self.lastReconnectAttemptDate = date;
    self.reconnectInFlight = YES;
    PVAppInfo *targetInfo = self.reconnectingAppInfo;
    @weakify(self);
    [[self fetchAppInfosWithImage:NO localInfos:nil] subscribeNext:^(NSArray<PVDetailInspectableApp *> *apps) {
        @strongify(self);
        PVDetailInspectableApp *matchedApp = [apps pv_inspect_firstFiltered:^BOOL(PVDetailInspectableApp *app) {
            return [targetInfo isEqualToAppInfo:app.appInfo];
        }];
        if (matchedApp) {
            matchedApp.appInfo.appIcon = self.reconnectingAppIcon;
            self.inspectingApp = matchedApp;
            [self.didAutoReconnectSucc sendNext:matchedApp];
        }
    } error:^(NSError *error) {
        @strongify(self);
        self.reconnectInFlight = NO;
    } completed:^{
        @strongify(self);
        self.reconnectInFlight = NO;
    }];
}

- (RACSignal *)fetchAppInfosWithImage:(BOOL)needImages localInfos:(NSArray<PVAppInfo *> *)localInfos {
    NSArray<PVClientSession *> *sessions = PickViewClient.sharedClient.sessionManager.allSessions ?: @[];
    NSArray<PVClientSession *> *readySessions = [sessions pv_inspect_filter:^BOOL(PVClientSession *session) {
        return session.state == PVClientSessionStateReady;
    }];

    if (!readySessions.count) {
        return [RACSignal return:@[]];
    }

    NSArray<RACSignal *> *signals = [readySessions pv_inspect_map:^id(NSUInteger idx, PVClientSession *session) {
        return [self fetchInspectableAppForSession:session needImages:needImages localInfos:localInfos];
    }];

    return [[RACSignal zip:signals] map:^id _Nullable(RACTuple *tuple) {
        return [tuple.allObjects pv_inspect_filter:^BOOL(id obj) {
            return [obj isKindOfClass:PVDetailInspectableApp.class];
        }];
    }];
}

- (RACSignal *)fetchInspectableAppForSession:(PVClientSession *)session
                                  needImages:(BOOL)needImages
                                  localInfos:(NSArray<PVAppInfo *> *)localInfos {
    NSArray<PVAppInfo *> *validAppInfos = [localInfos pv_inspect_filter:^BOOL(PVAppInfo *info) {
        BOOL cacheIsFresh = [[NSDate date] timeIntervalSince1970] - info.cachedTimestamp <= 8;
        BOOL hasRequestedImages = !needImages || info.screenshot != nil;
        return cacheIsFresh && hasRequestedImages;
    }];
    NSArray<NSNumber *> *localInfoIdentifiers = [validAppInfos pv_inspect_map:^id(NSUInteger idx, PVAppInfo *value) {
        return @(value.appInfoIdentifier);
    }] ?: @[];

    NSDictionary *params = @{@"needImages": @(needImages), @"local": localInfoIdentifiers};
    PVRequestAttachment *request = [PVRequestAttachment attachmentWithData:params];
    PVInspectionRequestClient *requestClient = [[PVInspectionRequestClient alloc] initWithSession:session];

    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        if (!self) {
            [subscriber sendCompleted];
            return nil;
        }

        [requestClient sendRequestType:PVRequestTypeAppInfo object:request timeoutInterval:8 completion:^(id responseData, BOOL finished, NSError *error) {
            @strongify(self);
            if (!self) return;

            PVAppInfo *appInfo = error ? nil : [self appInfoFromResponseObject:responseData validLocalInfos:validAppInfos];
            if (!appInfo) {
                appInfo = [self appInfoForSession:session localInfos:validAppInfos];
            }

            [subscriber sendNext:[self inspectableAppForSession:session appInfo:appInfo]];
            [subscriber sendCompleted];
        }];

        return nil;
    }];
}

- (PVDetailInspectableApp *)inspectableAppForSession:(PVClientSession *)session appInfo:(PVAppInfo *)appInfo {
    PVDetailInspectableApp *app = [[PVDetailInspectableApp alloc] init];
    app.session = session;
    app.appInfo = appInfo;
    return app;
}

- (PVAppInfo *)appInfoFromResponseObject:(id)responseData validLocalInfos:(NSArray<PVAppInfo *> *)validAppInfos {
    if (![responseData isKindOfClass:PVAppInfo.class]) {
        return nil;
    }

    PVAppInfo *receivedInfo = (PVAppInfo *)responseData;
    receivedInfo.cachedTimestamp = [[NSDate date] timeIntervalSince1970];
    if (receivedInfo.shouldUseCache) {
        PVAppInfo *localInfo = [validAppInfos pv_inspect_firstFiltered:^BOOL(PVAppInfo *obj) {
            return obj.appInfoIdentifier == receivedInfo.appInfoIdentifier;
        }];
        if (localInfo) {
            receivedInfo = localInfo;
        }
    }
    return receivedInfo;
}

- (PVAppInfo *)appInfoForSession:(PVClientSession *)session localInfos:(NSArray<PVAppInfo *> *)localInfos {
    PVPeerIdentity *identity = session.peerIdentity;
    PVAppInfo *info = [[PVAppInfo alloc] init];
    info.appInfoIdentifier = (NSUInteger)labs((long)(session.identifier ?: identity.uuid ?: @"").hash);
    info.appName = identity.appName.length ? identity.appName : @"PickView";
    info.appBundleIdentifier = identity.bundleID ?: @"";
    info.deviceDescription = identity.deviceName.length ? identity.deviceName : session.endpoint.displayName ?: @"Device";
    info.osDescription = identity.systemVersion ?: @"";
    info.serverReadableVersion = identity.protocolVersion ?: @"";
    info.serverVersion = 1;
    info.swiftEnabledInPickViewServer = 0;
    info.deviceType = [self deviceTypeForSession:session];
    info.cachedTimestamp = [[NSDate date] timeIntervalSince1970];

    PVAppInfo *cachedInfo = [localInfos pv_inspect_firstFiltered:^BOOL(PVAppInfo *obj) {
        return [obj isEqualToAppInfo:info];
    }];
    if (cachedInfo) {
        info.appIcon = cachedInfo.appIcon;
        info.screenshot = cachedInfo.screenshot;
    }

    return info;
}

- (PVAppInfoDevice)deviceTypeForSession:(PVClientSession *)session {
    switch (session.peerIdentity.platform) {
        case PVPeerPlatformIOSSimulator:
            return PVAppInfoDeviceSimulator;
        case PVPeerPlatformMacOS:
            return PVAppInfoDeviceMac;
        case PVPeerPlatformIOSDevice:
        case PVPeerPlatformUnknown:
            if ([session.peerIdentity.deviceName localizedCaseInsensitiveContainsString:@"iPad"]) {
                return PVAppInfoDeviceIPad;
            }
            return PVAppInfoDeviceOthers;
    }
    return PVAppInfoDeviceOthers;
}

@end

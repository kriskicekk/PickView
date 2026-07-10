//
//  PVClientWindowController.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVClientWindowController.h"

#import "PVDetailPrefix.h"

#import "PickViewClientKit.h"
#import "PVLANEndpoint.h"
#import "PVHierarchyRowView.h"
#import "PVLaunchWindowController.h"
#import "PVToolbarScaleView.h"
#import "PVDetailStaticHierarchyDataSource.h"
#import "PVDetailPerformanceReporter.h"
#import "PVDetailNavigationManager.h"
#import "PVDetailInspectableApp.h"
#import "PVDetailAppsManager.h"
#import "PVPeerIdentity.h"
#import "PVPreviewSceneView.h"
#import "PVWorkspaceViewController.h"

static NSToolbarItemIdentifier const PVToolbarItemIdentifierDevices = @"PVToolbarItemIdentifierDevices";
static NSToolbarItemIdentifier const PVToolbarItemIdentifierReload = @"PVToolbarItemIdentifierReload";
static NSToolbarItemIdentifier const PVToolbarItemIdentifierFastMode = @"PVToolbarItemIdentifierFastMode";
static NSToolbarItemIdentifier const PVToolbarItemIdentifierApp = @"PVToolbarItemIdentifierApp";
static NSToolbarItemIdentifier const PVToolbarItemIdentifierDimension = @"PVToolbarItemIdentifierDimension";
static NSToolbarItemIdentifier const PVToolbarItemIdentifierRotation = @"PVToolbarItemIdentifierRotation";
static NSToolbarItemIdentifier const PVToolbarItemIdentifierSetting = @"PVToolbarItemIdentifierSetting";
static NSToolbarItemIdentifier const PVToolbarItemIdentifierScale = @"PVToolbarItemIdentifierScale";
static NSToolbarItemIdentifier const PVToolbarItemIdentifierMeasure = @"PVToolbarItemIdentifierMeasure";
static NSToolbarItemIdentifier const PVToolbarItemIdentifierConsole = @"PVToolbarItemIdentifierConsole";
static NSToolbarItemIdentifier const PVToolbarItemIdentifierStatus = @"PVToolbarItemIdentifierStatus";
static NSToolbarItemIdentifier const PVToolbarItemIdentifierLAN = @"PVToolbarItemIdentifierLAN";

@interface PVClientWindowController () <NSTableViewDataSource, NSTableViewDelegate, NSOutlineViewDataSource, NSOutlineViewDelegate, NSToolbarDelegate, PickViewClientDelegate>

@property (nonatomic, strong) NSTextField *statusLabel;
@property (nonatomic, strong) PVLaunchWindowController *launchWindowController;
@property (nonatomic, strong) PVWorkspaceViewController *workspaceViewController;
@property (nonatomic, strong) NSTableView *windowTableView;
@property (nonatomic, strong) NSOutlineView *hierarchyOutlineView;
@property (nonatomic, strong) PVPreviewSceneView *previewSceneView;
@property (nonatomic, strong) NSTextField *detailPreviewLabel;
@property (nonatomic, strong) NSButton *connectionStateButton;
@property (nonatomic, strong) NSButton *toolbarAppButton;
@property (nonatomic, strong) NSSegmentedControl *dimensionControl;
@property (nonatomic, strong) NSButton *rotationButton;
@property (nonatomic, strong) NSSlider *scaleSlider;
@property (nonatomic, copy, nullable) NSString *toolbarEndpointIdentifier;
@property (nonatomic, strong) NSTextView *logView;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSTextField *> *inspectorValueLabels;
@property (nonatomic, copy) NSArray<PVClientSession *> *deviceSessions;
@property (nonatomic, copy) NSArray<PVClientSession *> *previewDeviceSessions;
@property (nonatomic, copy) NSArray<PVClientSession *> *LANDeviceSessions;
@property (nonatomic, copy) NSArray<PVWindowInfo *> *windowInfos;
@property (nonatomic, strong, nullable) PVHierarchyInfo *currentHierarchy;
@property (nonatomic, strong, nullable) PVDisplayItem *selectedDisplayItem;
@property (nonatomic, strong) NSMutableDictionary<NSString *, PVDisplayItemDetail *> *displayItemDetailsByID;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSImage *> *devicePreviewImagesByEndpointID;
@property (nonatomic, strong) NSMutableDictionary<NSString *, PVDetailInspectableApp *> *inspectableAppsByEndpointID;
@property (nonatomic, copy, nullable) NSString *connectedLANEndpointIdentifier;
@property (nonatomic, copy, nullable) NSString *inspectedEndpointIdentifier;
@property (nonatomic, assign) BOOL isEnteringSession;
@property (nonatomic, assign) NSUInteger launchPreviewRequestID;
@property (nonatomic, assign) BOOL launchPreviewRequestInFlight;
@property (nonatomic, assign) NSUInteger launchPreviewRetryCount;

@end

@implementation PVClientWindowController

- (instancetype)init {
    self = [super initWithWindow:nil];
    if (self) {
        _deviceSessions = @[];
        _previewDeviceSessions = @[];
        _LANDeviceSessions = @[];
        _windowInfos = @[];
        _inspectorValueLabels = [NSMutableDictionary dictionary];
        _displayItemDetailsByID = [NSMutableDictionary dictionary];
        _devicePreviewImagesByEndpointID = [NSMutableDictionary dictionary];
        _inspectableAppsByEndpointID = [NSMutableDictionary dictionary];
        _launchWindowController = [[PVLaunchWindowController alloc] init];
        __weak typeof(self) weakSelf = self;
        _launchWindowController.selectionHandler = ^(NSInteger row) {
            [weakSelf openDeviceAtRow:row];
        };
        _launchWindowController.LANSelectionHandler = ^(NSInteger row) {
            [weakSelf openLANDeviceAtRow:row];
        };
        [self buildWindow];
    }
    return self;
}

- (void)buildWindow {
    NSSize workspaceSize = [self workspaceWindowSize];
    NSRect frame = NSMakeRect(0, 0, workspaceSize.width, workspaceSize.height);
    NSWindowStyleMask styleMask = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable | NSWindowStyleMaskFullSizeContentView;
    self.window = [[NSWindow alloc] initWithContentRect:frame
                                              styleMask:styleMask
                                                backing:NSBackingStoreBuffered
                                                  defer:NO];
    self.window.title = @"PickView";
    self.window.restorable = NO;
    self.window.titleVisibility = NSWindowTitleHidden;
    self.window.titlebarAppearsTransparent = NO;
    self.window.backgroundColor = NSColor.windowBackgroundColor;
    self.window.tabbingMode = NSWindowTabbingModeDisallowed;
    self.window.minSize = NSMakeSize(850.0, 500.0);
    if (@available(macOS 11.0, *)) {
        self.window.toolbarStyle = NSWindowToolbarStyleUnified;
    }
    [self.window center];

    self.statusLabel = [NSTextField labelWithString:@"Waiting for USB device, local app, or LAN service..."];
    self.statusLabel.font = [NSFont systemFontOfSize:13 weight:NSFontWeightRegular];
    self.statusLabel.textColor = NSColor.secondaryLabelColor;
    self.statusLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.statusLabel.widthAnchor constraintGreaterThanOrEqualToConstant:260.0].active = YES;

    self.connectionStateButton = [NSButton buttonWithTitle:@"LAN Disconnected" target:nil action:nil];
    self.connectionStateButton.bezelStyle = NSBezelStyleRounded;
    self.connectionStateButton.font = [NSFont systemFontOfSize:12 weight:NSFontWeightRegular];
    self.connectionStateButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.connectionStateButton.enabled = NO;

    self.workspaceViewController = [[PVWorkspaceViewController alloc] init];
    self.window.contentViewController = self.workspaceViewController;
    self.windowTableView = self.workspaceViewController.windowTableView;
    self.windowTableView.rowHeight = 28.0;
    self.windowTableView.delegate = self;
    self.windowTableView.dataSource = self;
    self.windowTableView.target = self;
    self.windowTableView.doubleAction = @selector(requestHierarchyForSelectedWindow);
    self.hierarchyOutlineView = self.workspaceViewController.hierarchyOutlineView;
    self.hierarchyOutlineView.rowHeight = 28.0;
    self.hierarchyOutlineView.delegate = self;
    self.hierarchyOutlineView.dataSource = self;
    self.previewSceneView = self.workspaceViewController.previewSceneView;
    __weak typeof(self) weakSelf = self;
    self.previewSceneView.selectionHandler = ^(PVDisplayItem *displayItem) {
        [weakSelf selectDisplayItemFromPreview:displayItem];
    };
    self.detailPreviewLabel = self.workspaceViewController.detailPreviewLabel;
    self.inspectorValueLabels = self.workspaceViewController.inspectorValueLabels;
    self.logView = [[NSTextView alloc] init];
    self.logView.editable = NO;
    self.logView.font = [NSFont monospacedSystemFontOfSize:12 weight:NSFontWeightRegular];

    [self installToolbar];
}

- (void)installToolbar {
    NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:@"PickViewWorkspaceToolbar"];
    toolbar.displayMode = NSToolbarDisplayModeIconAndLabel;
    toolbar.sizeMode = NSToolbarSizeModeRegular;
    toolbar.delegate = self;
    self.window.toolbar = toolbar;
}

- (void)reloadCurrentInspection {
    if (self.inspectedEndpointIdentifier.length) {
        [self requestWindowListForEndpointIdentifier:self.inspectedEndpointIdentifier];
        return;
    }
    [self scanKnownEndpoints];
}

- (NSString *)toolbarTitleForEndpointIdentifier:(NSString *)endpointIdentifier {
    for (PVClientSession *session in self.deviceSessions) {
        if (![session.identifier isEqualToString:endpointIdentifier]) {
            continue;
        }

        NSString *appName = session.peerIdentity.appName.length ? session.peerIdentity.appName : @"PickView";
        NSString *deviceName = session.peerIdentity.deviceName.length ? session.peerIdentity.deviceName : session.endpoint.displayName;
        return [NSString stringWithFormat:@"%@ - %@", appName, deviceName ?: @"Device"];
    }
    return @"PickView";
}

- (void)updateToolbarAppWithEndpointIdentifier:(NSString *)endpointIdentifier {
    self.toolbarEndpointIdentifier = endpointIdentifier;
    self.toolbarAppButton.title = [self toolbarTitleForEndpointIdentifier:endpointIdentifier];
}

- (NSImage *)templateImageNamed:(NSString *)name {
    NSImage *image = [NSImage imageNamed:name];
    image.template = YES;
    return image;
}

#pragma mark - NSToolbarDelegate

- (NSArray<NSToolbarItemIdentifier> *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar {
    return @[
        PVToolbarItemIdentifierReload,
        PVToolbarItemIdentifierFastMode,
        PVToolbarItemIdentifierApp,
        NSToolbarFlexibleSpaceItemIdentifier,
        PVToolbarItemIdentifierDimension,
        PVToolbarItemIdentifierRotation,
        PVToolbarItemIdentifierSetting,
        PVToolbarItemIdentifierScale,
        NSToolbarFlexibleSpaceItemIdentifier,
        PVToolbarItemIdentifierMeasure,
        PVToolbarItemIdentifierConsole
    ];
}

- (NSArray<NSToolbarItemIdentifier> *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {
    return @[
        PVToolbarItemIdentifierReload,
        PVToolbarItemIdentifierFastMode,
        PVToolbarItemIdentifierApp,
        NSToolbarFlexibleSpaceItemIdentifier,
        PVToolbarItemIdentifierDimension,
        PVToolbarItemIdentifierRotation,
        PVToolbarItemIdentifierSetting,
        NSToolbarFlexibleSpaceItemIdentifier,
        PVToolbarItemIdentifierScale,
        NSToolbarFlexibleSpaceItemIdentifier,
        PVToolbarItemIdentifierMeasure,
        PVToolbarItemIdentifierConsole
    ];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar
     itemForItemIdentifier:(NSToolbarItemIdentifier)itemIdentifier
 willBeInsertedIntoToolbar:(BOOL)flag {
    if ([itemIdentifier isEqualToString:PVToolbarItemIdentifierDevices]) {
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        item.label = @"Devices";
        item.paletteLabel = @"Devices";
        item.image = [NSImage imageNamed:NSImageNameComputer];
        item.target = self;
        item.action = @selector(showDeviceBrowser);
        return item;
    }

    if ([itemIdentifier isEqualToString:PVToolbarItemIdentifierReload]) {
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        item.label = @"Reload";
        item.paletteLabel = @"Reload";
        item.image = [self templateImageNamed:@"icon_reload"];
        item.target = self;
        item.action = @selector(reloadCurrentInspection);
        return item;
    }

    if ([itemIdentifier isEqualToString:PVToolbarItemIdentifierFastMode]) {
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        item.label = @"Fast Mode";
        item.image = [self templateImageNamed:@"icon_turbo"];
        item.target = self;
        item.action = @selector(fastModeButtonClicked:);
        return item;
    }

    if ([itemIdentifier isEqualToString:PVToolbarItemIdentifierApp]) {
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        NSString *title = [self toolbarTitleForEndpointIdentifier:self.toolbarEndpointIdentifier];
        self.toolbarAppButton = [NSButton buttonWithTitle:title target:self action:@selector(showDeviceBrowser)];
        self.toolbarAppButton.bezelStyle = NSBezelStyleTexturedRounded;
        self.toolbarAppButton.font = [NSFont systemFontOfSize:12 weight:NSFontWeightMedium];
        self.toolbarAppButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.toolbarAppButton.widthAnchor constraintEqualToConstant:220.0].active = YES;
        item.view = self.toolbarAppButton;
        return item;
    }

    if ([itemIdentifier isEqualToString:PVToolbarItemIdentifierDimension]) {
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        item.label = @"2D / 3D";
        self.dimensionControl = [NSSegmentedControl segmentedControlWithImages:@[
            [self templateImageNamed:@"icon_2d"],
            [self templateImageNamed:@"icon_3d"]
        ]
                                                                  trackingMode:NSSegmentSwitchTrackingSelectOne
                                                                        target:self
                                                                        action:@selector(dimensionControlChanged:)];
        self.dimensionControl.segmentDistribution = NSSegmentDistributionFillEqually;
        self.dimensionControl.selectedSegment = 1;
        self.dimensionControl.translatesAutoresizingMaskIntoConstraints = NO;
        [self.dimensionControl.widthAnchor constraintEqualToConstant:88.0].active = YES;
        item.view = self.dimensionControl;
        return item;
    }

    if ([itemIdentifier isEqualToString:PVToolbarItemIdentifierRotation]) {
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        item.label = @"Free Rotation";
        self.rotationButton = [NSButton buttonWithImage:[self templateImageNamed:@"icon_rotation"] target:self action:@selector(rotationButtonClicked:)];
        self.rotationButton.bezelStyle = NSBezelStyleTexturedRounded;
        self.rotationButton.buttonType = NSButtonTypePushOnPushOff;
        self.rotationButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.rotationButton.widthAnchor constraintEqualToConstant:48.0].active = YES;
        item.view = self.rotationButton;
        return item;
    }

    if ([itemIdentifier isEqualToString:PVToolbarItemIdentifierSetting]) {
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        item.label = @"View";
        item.image = [self templateImageNamed:@"icon_setting"];
        item.target = self;
        item.action = @selector(settingButtonClicked:);
        return item;
    }

    if ([itemIdentifier isEqualToString:PVToolbarItemIdentifierScale]) {
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        item.label = @"Zoom";
        PVToolbarScaleView *scaleView = [[PVToolbarScaleView alloc] initWithFrame:NSMakeRect(0, 0, 160.0, 30.0)];
        scaleView.slider.doubleValue = self.previewSceneView.previewScale;
        scaleView.slider.target = self;
        scaleView.slider.action = @selector(scaleSliderChanged:);
        scaleView.decreaseButton.target = self;
        scaleView.decreaseButton.action = @selector(scaleDecreaseButtonClicked:);
        scaleView.increaseButton.target = self;
        scaleView.increaseButton.action = @selector(scaleIncreaseButtonClicked:);
        self.scaleSlider = scaleView.slider;
        item.view = scaleView;
        return item;
    }

    if ([itemIdentifier isEqualToString:PVToolbarItemIdentifierMeasure]) {
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        item.label = @"Measure";
        item.image = [self templateImageNamed:@"icon_measure"];
        item.target = self;
        item.action = @selector(measureButtonClicked:);
        item.enabled = NO;
        return item;
    }

    if ([itemIdentifier isEqualToString:PVToolbarItemIdentifierConsole]) {
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        item.label = @"Console";
        item.image = [self templateImageNamed:@"icon_console"];
        item.target = self;
        item.action = @selector(consoleButtonClicked:);
        item.enabled = NO;
        return item;
    }

    if ([itemIdentifier isEqualToString:PVToolbarItemIdentifierStatus]) {
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        item.view = self.statusLabel;
        return item;
    }

    if ([itemIdentifier isEqualToString:PVToolbarItemIdentifierLAN]) {
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        [self.connectionStateButton.widthAnchor constraintEqualToConstant:140.0].active = YES;
        item.view = self.connectionStateButton;
        return item;
    }

    return nil;
}

- (void)dimensionControlChanged:(NSSegmentedControl *)sender {
    PVPreviewDimension dimension = sender.selectedSegment == 1 ? PVPreviewDimension3D : PVPreviewDimension2D;
    [self.previewSceneView setDimension:dimension animated:YES];
}

- (void)rotationButtonClicked:(NSButton *)sender {
    self.previewSceneView.freeRotationEnabled = sender.state == NSControlStateValueOn;
}

- (void)fastModeButtonClicked:(id)sender {
    self.statusLabel.stringValue = @"Fast Mode is reserved for async screenshot refresh.";
}

- (void)settingButtonClicked:(id)sender {
    NSViewController *viewController = [[NSViewController alloc] init];
    NSView *contentView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 220, 64)];
    contentView.wantsLayer = YES;
    contentView.layer.backgroundColor = NSColor.windowBackgroundColor.CGColor;
    viewController.view = contentView;

    NSTextField *label = [NSTextField labelWithString:@"Z Interspace"];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.font = [NSFont systemFontOfSize:12 weight:NSFontWeightRegular];
    [contentView addSubview:label];

    NSSlider *slider = [NSSlider sliderWithValue:self.previewSceneView.zInterspace
                                       minValue:0.0
                                       maxValue:1.0
                                         target:self
                                         action:@selector(zInterspaceSliderChanged:)];
    slider.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:slider];

    [NSLayoutConstraint activateConstraints:@[
        [label.topAnchor constraintEqualToAnchor:contentView.topAnchor constant:12],
        [label.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:14],
        [label.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-14],
        [slider.leadingAnchor constraintEqualToAnchor:label.leadingAnchor],
        [slider.trailingAnchor constraintEqualToAnchor:label.trailingAnchor],
        [slider.topAnchor constraintEqualToAnchor:label.bottomAnchor constant:8]
    ]];

    NSPopover *popover = [[NSPopover alloc] init];
    popover.contentViewController = viewController;
    popover.contentSize = contentView.frame.size;
    popover.behavior = NSPopoverBehaviorTransient;
    [popover showRelativeToRect:NSMakeRect(0, 0, 1, 1) ofView:self.window.contentView preferredEdge:NSRectEdgeMaxY];
}

- (void)zInterspaceSliderChanged:(NSSlider *)sender {
    self.previewSceneView.zInterspace = sender.doubleValue;
}

- (void)measureButtonClicked:(id)sender {
}

- (void)consoleButtonClicked:(id)sender {
}

- (void)scaleSliderChanged:(NSSlider *)sender {
    self.previewSceneView.previewScale = sender.doubleValue;
}

- (void)scaleDecreaseButtonClicked:(NSButton *)sender {
    self.scaleSlider.doubleValue = MAX(0.0, self.scaleSlider.doubleValue - 0.08);
    self.previewSceneView.previewScale = self.scaleSlider.doubleValue;
}

- (void)scaleIncreaseButtonClicked:(NSButton *)sender {
    self.scaleSlider.doubleValue = MIN(1.0, self.scaleSlider.doubleValue + 0.08);
    self.previewSceneView.previewScale = self.scaleSlider.doubleValue;
}

- (void)start {
    PickViewClient.sharedClient.delegate = self;
    [self.launchWindowController showWindow:nil];
    [PickViewClient.sharedClient startScanning];
}

- (void)stop {
    [self.launchWindowController.window orderOut:nil];
    [[PickViewClient sharedClient] stop];
}

- (void)scanKnownEndpoints {
    [PickViewClient.sharedClient scanNow];
}

- (void)updateLANConnectionControls {
    self.connectionStateButton.title = self.connectedLANEndpointIdentifier.length ? @"LAN Connected" : @"LAN Disconnected";
}

- (void)appendLog:(NSString *)line {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *nextLine = [NSString stringWithFormat:@"%@\n", line ?: @""];
        self.logView.string = [self.logView.string stringByAppendingString:nextLine];
        [self.logView scrollRangeToVisible:NSMakeRange(self.logView.string.length, 0)];
    });
}

- (void)showDeviceBrowser {
    self.isEnteringSession = NO;
    [self updateToolbarAppWithEndpointIdentifier:nil];
    [self.window orderOut:nil];
    [self.launchWindowController showWindow:nil];
    [self reloadDeviceSessionsWithClient:PickViewClient.sharedClient];
}

- (void)showWorkspaceForEndpointIdentifier:(NSString *)endpointIdentifier {
    if (!endpointIdentifier.length) {
        return;
    }

    [self.launchWindowController close];
    self.window.titleVisibility = NSWindowTitleHidden;
    self.window.titlebarAppearsTransparent = NO;
    self.window.backgroundColor = NSColor.windowBackgroundColor;
    [self updateToolbarAppWithEndpointIdentifier:endpointIdentifier];
    [self resizeWindowToContentSize:[self workspaceWindowSize] center:YES];
    [self showWindow:nil];
    [self.window makeKeyAndOrderFront:nil];
    [self clearInspectionViews];
    [self requestWindowListForEndpointIdentifier:endpointIdentifier];
}

- (void)reloadDeviceSessionsWithClient:(PickViewClient *)client {
    self.deviceSessions = client.sessionManager.allSessions;
    self.LANDeviceSessions = client.sessionManager.lanSessions;
    self.previewDeviceSessions = [self.deviceSessions pv_inspect_filter:^BOOL(PVClientSession *session) {
        if (![session.endpoint isKindOfClass:PVLANEndpoint.class]) {
            return YES;
        }
        return session.state == PVClientSessionStateReady &&
               [session.identifier isEqualToString:self.connectedLANEndpointIdentifier];
    }];
    NSSet<NSString *> *activeEndpointIdentifiers = [NSSet setWithArray:[self.deviceSessions valueForKey:@"identifier"]];
    for (NSString *identifier in self.inspectableAppsByEndpointID.allKeys.copy) {
        if (![activeEndpointIdentifiers containsObject:identifier]) {
            [self.inspectableAppsByEndpointID removeObjectForKey:identifier];
            [self.devicePreviewImagesByEndpointID removeObjectForKey:identifier];
        }
    }
    if (self.toolbarEndpointIdentifier.length) {
        [self updateToolbarAppWithEndpointIdentifier:self.toolbarEndpointIdentifier];
    }
    [self.launchWindowController reloadWithPreviewSessions:self.previewDeviceSessions
                                               LANSessions:self.LANDeviceSessions
                                             previewImages:self.devicePreviewImagesByEndpointID.copy
                            connectedLANEndpointIdentifier:self.connectedLANEndpointIdentifier];
    [self refreshLaunchPreviewImagesIfNeeded];
}

- (void)refreshLaunchPreviewImagesIfNeeded {
    if (!self.launchWindowController.window.isVisible || !self.previewDeviceSessions.count || self.launchPreviewRequestInFlight) {
        return;
    }

    NSArray<PVClientSession *> *sessionsNeedingPreview = [self.previewDeviceSessions pv_inspect_filter:^BOOL(PVClientSession *session) {
        return session.state == PVClientSessionStateReady &&
               session.identifier.length > 0 &&
               self.devicePreviewImagesByEndpointID[session.identifier] == nil;
    }];
    if (!sessionsNeedingPreview.count) {
        self.launchPreviewRetryCount = 0;
        return;
    }

    NSUInteger requestID = self.launchPreviewRequestID + 1;
    self.launchPreviewRequestID = requestID;
    self.launchPreviewRequestInFlight = YES;

    @weakify(self);
    [[[[PVDetailAppsManager sharedInstance] fetchAppInfosWithImage:YES localInfos:nil] deliverOnMainThread] subscribeNext:^(NSArray<PVDetailInspectableApp *> *apps) {
        @strongify(self);
        if (!self || requestID != self.launchPreviewRequestID) {
            return;
        }
        self.launchPreviewRequestInFlight = NO;

        BOOL didUpdate = NO;
        for (PVDetailInspectableApp *app in apps) {
            NSString *identifier = app.session.identifier;
            if (identifier.length) {
                self.inspectableAppsByEndpointID[identifier] = app;
            }
            NSImage *screenshot = app.appInfo.screenshot;
            if (!identifier.length || !screenshot || self.devicePreviewImagesByEndpointID[identifier]) {
                continue;
            }
            self.devicePreviewImagesByEndpointID[identifier] = screenshot;
            didUpdate = YES;
        }

        if (didUpdate) {
            [self.launchWindowController reloadWithPreviewSessions:self.previewDeviceSessions
                                                       LANSessions:self.LANDeviceSessions
                                                     previewImages:self.devicePreviewImagesByEndpointID.copy
                                    connectedLANEndpointIdentifier:self.connectedLANEndpointIdentifier];
        }
        [self scheduleLaunchPreviewRetryIfNeeded];
    } error:^(NSError * _Nullable error) {
        @strongify(self);
        self.launchPreviewRequestInFlight = NO;
        NSLog(@"[PickView Mac] Failed to load app previews: %@", error.localizedDescription);
        [self scheduleLaunchPreviewRetryIfNeeded];
    }];
}

- (void)scheduleLaunchPreviewRetryIfNeeded {
    if (!self.launchWindowController.window.isVisible || self.launchPreviewRetryCount >= 5) {
        return;
    }
    BOOL stillNeedsPreview = [self.previewDeviceSessions pv_inspect_any:^BOOL(PVClientSession *session) {
        return session.state == PVClientSessionStateReady &&
               session.identifier.length > 0 &&
               self.devicePreviewImagesByEndpointID[session.identifier] == nil;
    }];
    if (!stillNeedsPreview) {
        self.launchPreviewRetryCount = 0;
        return;
    }
    self.launchPreviewRetryCount += 1;
    NSUInteger requestID = self.launchPreviewRequestID;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (requestID == self.launchPreviewRequestID) {
            [self refreshLaunchPreviewImagesIfNeeded];
        }
    });
}

- (NSSize)workspaceWindowSize {
    NSScreen *screen = self.window.screen ?: NSScreen.mainScreen;
    NSSize screenSize = screen.frame.size;
    return NSMakeSize(screenSize.width * 0.7, screenSize.height * 0.7);
}

- (void)resizeWindowToContentSize:(NSSize)contentSize center:(BOOL)center {
    [self.window setContentSize:contentSize];
    if (center) {
        [self.window center];
    }
}

- (void)openDeviceAtRow:(NSInteger)row {
    if (self.isEnteringSession) {
        return;
    }
    if (row < 0 || row >= (NSInteger)self.previewDeviceSessions.count) {
        return;
    }

    PVClientSession *session = self.previewDeviceSessions[(NSUInteger)row];
    if (session.state == PVClientSessionStateBlocked) {
        [self showMessage:@"This app is already connected through USB. Disconnect USB before using LAN."];
        return;
    }
    if (session.state != PVClientSessionStateReady) {
        [self showMessage:@"This session is not ready. Wait for connection or rescan."];
        return;
    }

    self.isEnteringSession = YES;
    [self enterDetailWithSession:session];
}

- (void)openLANDeviceAtRow:(NSInteger)row {
    if (self.isEnteringSession || row < 0 || row >= (NSInteger)self.LANDeviceSessions.count) {
        return;
    }
    PVClientSession *session = self.LANDeviceSessions[(NSUInteger)row];
    if (session.state == PVClientSessionStateBlocked) {
        [self showMessage:@"This app is already connected through USB."];
        return;
    }
    if (session.state != PVClientSessionStateReady) {
        [self showMessage:@"This LAN device is not available."];
        return;
    }

    self.connectedLANEndpointIdentifier = session.identifier;
    [PickViewClient.sharedClient connectToLANEndpointIdentifier:session.identifier];
    [self reloadDeviceSessionsWithClient:PickViewClient.sharedClient];
    self.isEnteringSession = YES;
    [self enterDetailWithSession:session];
}

- (void)enterDetailWithSession:(PVClientSession *)session {
    PVDetailInspectableApp *cachedApp = self.inspectableAppsByEndpointID[session.identifier];
    if (cachedApp.session == session) {
        [self enterDetailWithInspectableApp:cachedApp];
        return;
    }

    @weakify(self);
    [[[[PVDetailAppsManager sharedInstance] fetchAppInfosWithImage:NO localInfos:nil] deliverOnMainThread] subscribeNext:^(NSArray<PVDetailInspectableApp *> *apps) {
        @strongify(self);
        PVDetailInspectableApp *targetApp = [apps pv_inspect_firstFiltered:^BOOL(PVDetailInspectableApp *app) {
            return app.session == session;
        }];
        if (!targetApp) {
            self.isEnteringSession = NO;
            [self showMessage:@"This session is no longer available. Please rescan and try again."];
            return;
        }
        self.inspectableAppsByEndpointID[session.identifier] = targetApp;
        [self enterDetailWithInspectableApp:targetApp];
    } error:^(NSError * _Nullable error) {
        @strongify(self);
        self.isEnteringSession = NO;
        [[NSAlert alertWithError:error ?: PVInspectErr_Inner] beginSheetModalForWindow:self.launchWindowController.window completionHandler:nil];
    }];
}

- (void)enterDetailWithInspectableApp:(PVDetailInspectableApp *)targetApp {
    [PVDetailPerformanceReporter.sharedInstance willStartReload];
    @weakify(self);
    [[targetApp fetchHierarchyData] subscribeNext:^(PVHierarchyInfo *info) {
        @strongify(self);
        self.isEnteringSession = NO;
        if (!info) {
            [self showMessage:@"Failed to load view hierarchy."];
            return;
        }

        [PVDetailAppsManager sharedInstance].inspectingApp = targetApp;
        [[PVDetailStaticHierarchyDataSource sharedInstance] reloadWithHierarchyInfo:info keepState:NO];
        [PVDetailPerformanceReporter.sharedInstance didFetchHierarchy];
        [[PVDetailNavigationManager sharedInstance] showStaticWorkspace];
        [self.launchWindowController close];
        [self.window orderOut:nil];

    } error:^(NSError * _Nullable error) {
        @strongify(self);
        self.isEnteringSession = NO;
        [[NSAlert alertWithError:error ?: PVInspectErr_Inner] beginSheetModalForWindow:self.launchWindowController.window completionHandler:nil];
    }];
}

- (void)showMessage:(NSString *)message {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = message ?: @"";
    NSWindow *hostWindow = self.launchWindowController.window.isVisible ? self.launchWindowController.window : self.window;
    [alert beginSheetModalForWindow:hostWindow completionHandler:nil];
}

- (void)reloadLANStateWithClient:(PickViewClient *)client {
    BOOL stillHasConnectedEndpoint = NO;
    for (PVClientSession *session in client.sessionManager.lanSessions) {
        if (session.state == PVClientSessionStateReady &&
            [session.identifier isEqualToString:self.connectedLANEndpointIdentifier]) {
            stillHasConnectedEndpoint = YES;
            break;
        }
    }
    if (!stillHasConnectedEndpoint) {
        self.connectedLANEndpointIdentifier = nil;
    }
    [self reloadDeviceSessionsWithClient:client];
    [self updateLANConnectionControls];
}

- (void)clearInspectionViews {
    self.windowInfos = @[];
    self.currentHierarchy = nil;
    self.selectedDisplayItem = nil;
    [self.displayItemDetailsByID removeAllObjects];
    [self.previewSceneView resetPreview];
    self.detailPreviewLabel.stringValue = @"Select a view item to load preview.";
    [self resetInspector];
    [self.workspaceViewController setWindowListHidden:YES];
    [self.windowTableView deselectAll:nil];
    [self.windowTableView reloadData];
    [self.hierarchyOutlineView reloadData];
}

- (void)requestWindowListForEndpointIdentifier:(NSString *)endpointIdentifier {
    if (!endpointIdentifier.length) {
        return;
    }
    self.inspectedEndpointIdentifier = endpointIdentifier;
    [PickViewClient.sharedClient requestWindowListForEndpointIdentifier:endpointIdentifier];
}

- (void)requestHierarchyForSelectedWindow {
    NSInteger selectedRow = self.windowTableView.selectedRow;
    if (selectedRow < 0 || selectedRow >= (NSInteger)self.windowInfos.count || !self.inspectedEndpointIdentifier.length) {
        return;
    }

    PVWindowInfo *windowInfo = self.windowInfos[(NSUInteger)selectedRow];
    self.statusLabel.stringValue = [NSString stringWithFormat:@"Loading view tree: %@", [self windowTitleForWindowInfo:windowInfo]];
    [PickViewClient.sharedClient requestHierarchyForEndpointIdentifier:self.inspectedEndpointIdentifier windowIdentifier:windowInfo.windowID];
}

- (void)requestDetailsForCurrentHierarchy {
    if (!self.inspectedEndpointIdentifier.length || !self.currentHierarchy.rootItems.count) {
        return;
    }

    NSArray<PVDisplayItem *> *displayItems = [self flattenedDisplayItemsFromItems:self.currentHierarchy.rootItems];
    NSMutableArray<NSString *> *objectIDs = [NSMutableArray array];
    for (PVDisplayItem *displayItem in displayItems) {
        if (displayItem.objectID.length && !self.displayItemDetailsByID[displayItem.objectID]) {
            [objectIDs addObject:displayItem.objectID];
        }
    }

    NSUInteger batchSize = 24;
    for (NSUInteger start = 0; start < objectIDs.count; start += batchSize) {
        NSUInteger length = MIN(batchSize, objectIDs.count - start);
        NSArray<NSString *> *batch = [objectIDs subarrayWithRange:NSMakeRange(start, length)];
        [PickViewClient.sharedClient requestHierarchyDetailsForEndpointIdentifier:self.inspectedEndpointIdentifier displayItemIdentifiers:batch];
    }
}

- (NSArray<PVDisplayItem *> *)flattenedDisplayItemsFromItems:(NSArray<PVDisplayItem *> *)items {
    NSMutableArray<PVDisplayItem *> *displayItems = [NSMutableArray array];
    [self appendDisplayItems:items toArray:displayItems];
    return displayItems.copy;
}

- (void)appendDisplayItems:(NSArray<PVDisplayItem *> *)items toArray:(NSMutableArray<PVDisplayItem *> *)output {
    for (PVDisplayItem *item in items) {
        [output addObject:item];
        [self appendDisplayItems:item.children toArray:output];
    }
}

- (void)selectDisplayItemFromPreview:(PVDisplayItem *)displayItem {
    if (!displayItem) {
        return;
    }

    NSInteger row = [self.hierarchyOutlineView rowForItem:displayItem];
    if (row >= 0) {
        [self.hierarchyOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:(NSUInteger)row] byExtendingSelection:NO];
        [self.hierarchyOutlineView scrollRowToVisible:row];
    } else {
        [self requestDetailsForDisplayItem:displayItem];
    }
}

- (NSString *)windowTitleForWindowInfo:(PVWindowInfo *)windowInfo {
    return windowInfo.title.length ? windowInfo.title : windowInfo.windowID ?: @"Window";
}

- (NSString *)windowDisplayValueForWindowInfo:(PVWindowInfo *)windowInfo columnIdentifier:(NSString *)identifier {
    if ([identifier isEqualToString:@"windowTitle"]) {
        return [self windowTitleForWindowInfo:windowInfo];
    }
    if ([identifier isEqualToString:@"windowClass"]) {
        return windowInfo.className;
    }
    if ([identifier isEqualToString:@"windowState"]) {
        return [self windowStateTextForWindowInfo:windowInfo];
    }
    return @"";
}

- (NSString *)windowStateTextForWindowInfo:(PVWindowInfo *)windowInfo {
    NSMutableArray<NSString *> *states = [NSMutableArray array];
    if (windowInfo.isKeyWindow) [states addObject:@"key"];
    if (windowInfo.isMainWindow) [states addObject:@"main"];
    if (windowInfo.isVisible) [states addObject:@"visible"];
    return states.count ? [states componentsJoinedByString:@", "] : @"hidden";
}

- (NSString *)windowSubtitleForWindowInfo:(PVWindowInfo *)windowInfo {
    NSString *className = windowInfo.className.length ? windowInfo.className : @"Window";
    return [NSString stringWithFormat:@"%@  %@", className, [self stringForRect:windowInfo.frame]];
}

- (NSTableCellView *)textCellForTableView:(NSTableView *)tableView identifier:(NSString *)identifier {
    NSTableCellView *cell = [tableView makeViewWithIdentifier:identifier owner:self];
    if (!cell) {
        cell = [[NSTableCellView alloc] initWithFrame:NSZeroRect];
        cell.identifier = identifier;

        NSTextField *textField = [NSTextField labelWithString:@""];
        textField.translatesAutoresizingMaskIntoConstraints = NO;
        textField.lineBreakMode = NSLineBreakByTruncatingMiddle;
        cell.textField = textField;
        [cell addSubview:textField];

        [NSLayoutConstraint activateConstraints:@[
            [textField.leadingAnchor constraintEqualToAnchor:cell.leadingAnchor constant:8],
            [textField.trailingAnchor constraintEqualToAnchor:cell.trailingAnchor constant:-8],
            [textField.centerYAnchor constraintEqualToAnchor:cell.centerYAnchor]
        ]];
    }
    return cell;
}

- (PVHierarchyRowView *)hierarchyRowViewForTableView:(NSTableView *)tableView identifier:(NSString *)identifier {
    PVHierarchyRowView *cell = [tableView makeViewWithIdentifier:identifier owner:self];
    if (!cell) {
        cell = [[PVHierarchyRowView alloc] initWithFrame:NSZeroRect];
        cell.identifier = identifier;
    }
    return cell;
}

- (NSString *)frameTextForDisplayItem:(PVDisplayItem *)item {
    CGRect frame = item.frame;
    return [NSString stringWithFormat:@"x:%.0f y:%.0f w:%.0f h:%.0f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height];
}

- (void)requestDetailsForDisplayItem:(PVDisplayItem *)displayItem {
    if (!displayItem.objectID.length || !self.inspectedEndpointIdentifier.length) {
        return;
    }

    self.selectedDisplayItem = displayItem;
    [self.previewSceneView selectDisplayItem:displayItem];
    [self updateInspectorWithDisplayItem:displayItem detail:nil];
    PVDisplayItemDetail *detail = self.displayItemDetailsByID[displayItem.objectID];
    if (detail) {
        [self updatePreviewWithDisplayItemDetail:detail];
    } else {
        self.detailPreviewLabel.stringValue = [NSString stringWithFormat:@"Loading preview: %@", displayItem.displayName ?: @""];
        [PickViewClient.sharedClient requestHierarchyDetailsForEndpointIdentifier:self.inspectedEndpointIdentifier displayItemIdentifiers:@[displayItem.objectID]];
    }
}

- (void)updatePreviewWithDisplayItemDetail:(PVDisplayItemDetail *)detail {
    NSData *imageData = detail.groupImageData ?: detail.soloImageData;
    NSImage *previewImage = imageData.length ? [[NSImage alloc] initWithData:imageData] : nil;
    if (previewImage && self.inspectedEndpointIdentifier.length) {
        self.devicePreviewImagesByEndpointID[self.inspectedEndpointIdentifier] = previewImage;
        [self reloadDeviceSessionsWithClient:PickViewClient.sharedClient];
    }
    [self.previewSceneView updateDetailsByID:self.displayItemDetailsByID selectedItem:self.selectedDisplayItem];
    [self updateInspectorWithDisplayItem:self.selectedDisplayItem detail:detail];
    if (detail.failureCode != 0) {
        self.detailPreviewLabel.stringValue = [NSString stringWithFormat:@"Preview unavailable: %@", detail.displayItemID ?: @""];
        return;
    }
    NSString *name = self.selectedDisplayItem.displayName.length ? self.selectedDisplayItem.displayName : detail.displayItemID;
    self.detailPreviewLabel.stringValue = [NSString stringWithFormat:@"%@  x:%.0f y:%.0f w:%.0f h:%.0f",
                                           name ?: @"",
                                           detail.frame.origin.x,
                                           detail.frame.origin.y,
                                           detail.frame.size.width,
                                           detail.frame.size.height];
}

- (void)resetInspector {
    for (NSTextField *label in self.inspectorValueLabels.allValues) {
        label.stringValue = @"-";
    }
}

- (void)updateInspectorWithDisplayItem:(PVDisplayItem *)displayItem detail:(PVDisplayItemDetail *)detail {
    if (!displayItem) {
        [self resetInspector];
        return;
    }

    [self setInspectorValue:displayItem.viewClassName.length ? displayItem.viewClassName : displayItem.displayName forKey:@"class"];
    [self setInspectorValue:displayItem.layerClassName forKey:@"layer"];
    [self setInspectorValue:[self stringForRect:detail ? detail.frame : displayItem.frame] forKey:@"frame"];
    [self setInspectorValue:[self stringForRect:detail ? detail.bounds : displayItem.bounds] forKey:@"bounds"];
    BOOL hidden = detail ? detail.isHidden : displayItem.isHidden;
    CGFloat alpha = detail ? detail.alpha : displayItem.alpha;
    [self setInspectorValue:hidden ? @"YES" : @"NO" forKey:@"hidden"];
    [self setInspectorValue:[NSString stringWithFormat:@"%.2f", alpha] forKey:@"alpha"];
    [self setInspectorValue:displayItem.objectID forKey:@"object"];
}

- (void)setInspectorValue:(NSString *)value forKey:(NSString *)key {
    NSTextField *label = self.inspectorValueLabels[key];
    label.stringValue = value.length ? value : @"-";
}

- (NSString *)stringForRect:(CGRect)rect {
    return [NSString stringWithFormat:@"x:%.0f y:%.0f w:%.0f h:%.0f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if (tableView == self.windowTableView) {
        return (NSInteger)self.windowInfos.count;
    }
    return 0;
}

#pragma mark - NSTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (tableView == self.windowTableView) {
        PVWindowInfo *windowInfo = self.windowInfos[(NSUInteger)row];
        PVHierarchyRowView *cell = [self hierarchyRowViewForTableView:tableView identifier:@"windowHierarchyCell"];
        [cell configureWithTitle:[self windowTitleForWindowInfo:windowInfo]
                         subtitle:[self windowSubtitleForWindowInfo:windowInfo]
                        className:windowInfo.className
                           hidden:!windowInfo.isVisible
                            alpha:1.0];
        return cell;
    }

    return nil;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    if (notification.object == self.windowTableView) {
        [self requestHierarchyForSelectedWindow];
    }
}

#pragma mark - NSOutlineViewDataSource

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    if (!item) {
        return (NSInteger)self.currentHierarchy.rootItems.count;
    }
    if ([item isKindOfClass:PVDisplayItem.class]) {
        return (NSInteger)((PVDisplayItem *)item).children.count;
    }
    return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    if (!item) {
        return self.currentHierarchy.rootItems[(NSUInteger)index];
    }
    return ((PVDisplayItem *)item).children[(NSUInteger)index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return [item isKindOfClass:PVDisplayItem.class] && ((PVDisplayItem *)item).children.count > 0;
}

#pragma mark - NSOutlineViewDelegate

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    PVHierarchyRowView *cell = [self hierarchyRowViewForTableView:outlineView identifier:@"hierarchyCell"];
    if ([item isKindOfClass:PVDisplayItem.class]) {
        PVDisplayItem *displayItem = item;
        NSString *name = displayItem.displayName.length ? displayItem.displayName : displayItem.viewClassName;
        NSString *className = displayItem.viewClassName.length ? displayItem.viewClassName : @"View";
        NSString *subtitle = [NSString stringWithFormat:@"%@  %@", className, [self frameTextForDisplayItem:displayItem]];
        [cell configureWithTitle:name ?: @""
                         subtitle:subtitle
                        className:className
                           hidden:displayItem.isHidden
                            alpha:displayItem.alpha];
    } else {
        [cell configureWithTitle:@""
                         subtitle:@""
                           hidden:NO
                            alpha:1.0];
    }
    return cell;
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    NSInteger selectedRow = self.hierarchyOutlineView.selectedRow;
    if (selectedRow < 0) {
        return;
    }

    id item = [self.hierarchyOutlineView itemAtRow:selectedRow];
    if ([item isKindOfClass:PVDisplayItem.class]) {
        [self requestDetailsForDisplayItem:(PVDisplayItem *)item];
    }
}

#pragma mark - PickViewClientDelegate

- (void)pickViewClient:(PickViewClient *)client didUpdateStatus:(NSString *)status {
    self.statusLabel.stringValue = status ?: @"";
}

- (void)pickViewClient:(PickViewClient *)client didLogMessage:(NSString *)message {
    [self appendLog:message];
}

- (void)pickViewClient:(PickViewClient *)client didConnectEndpoint:(id<PVEndpointProtocol>)endpoint {
    BOOL isUnconfirmedLAN = [endpoint isKindOfClass:PVLANEndpoint.class] &&
                            ![endpoint.identifier isEqualToString:self.connectedLANEndpointIdentifier];
    self.statusLabel.stringValue = isUnconfirmedLAN
        ? [NSString stringWithFormat:@"LAN device ready: %@", endpoint.displayName]
        : [NSString stringWithFormat:@"Connected: %@", endpoint.displayName];
    [self reloadDeviceSessionsWithClient:client];
    if ([endpoint isKindOfClass:PVLANEndpoint.class]) {
        [self updateLANConnectionControls];
        [self reloadLANStateWithClient:client];
    }
}

- (void)pickViewClient:(PickViewClient *)client didDisconnectEndpoint:(id<PVEndpointProtocol>)endpoint reason:(NSString *)reason {
    if ([endpoint.identifier isEqualToString:self.connectedLANEndpointIdentifier]) {
        self.connectedLANEndpointIdentifier = nil;
    }
    if ([endpoint.identifier isEqualToString:self.inspectedEndpointIdentifier]) {
        self.inspectedEndpointIdentifier = nil;
        [self clearInspectionViews];
        [self showDeviceBrowser];
    }
    [self.devicePreviewImagesByEndpointID removeObjectForKey:endpoint.identifier ?: @""];
    self.statusLabel.stringValue = reason.length ? reason : [NSString stringWithFormat:@"Disconnected: %@", endpoint.displayName];
    [self appendLog:self.statusLabel.stringValue];
    [self updateLANConnectionControls];
    [self reloadLANStateWithClient:client];
    [self reloadDeviceSessionsWithClient:client];
}

- (void)pickViewClient:(PickViewClient *)client didReceiveEcho:(NSString *)echo fromEndpoint:(id<PVEndpointProtocol>)endpoint {
    [self appendLog:[NSString stringWithFormat:@"received echo from %@: %@", endpoint.displayName, echo ?: @""]];
}

- (void)pickViewClientDidUpdateLANSessions:(PickViewClient *)client {
    [self reloadLANStateWithClient:client];
    [self reloadDeviceSessionsWithClient:client];
}

- (void)pickViewClient:(PickViewClient *)client didReceiveWindowInfos:(NSArray<PVWindowInfo *> *)windowInfos endpointIdentifier:(NSString *)endpointIdentifier {
    if (![endpointIdentifier isEqualToString:self.inspectedEndpointIdentifier]) {
        return;
    }

    self.windowInfos = windowInfos ?: @[];
    self.currentHierarchy = nil;
    self.selectedDisplayItem = nil;
    [self.displayItemDetailsByID removeAllObjects];
    [self.previewSceneView resetPreview];
    self.detailPreviewLabel.stringValue = @"Select a view item to load preview.";
    [self resetInspector];
    [self.workspaceViewController setWindowListHidden:self.windowInfos.count == 0];
    [self.windowTableView reloadData];
    [self.windowTableView deselectAll:nil];
    [self.hierarchyOutlineView reloadData];
    [self appendLog:[NSString stringWithFormat:@"received windows: %@", @(self.windowInfos.count)]];
    if (self.windowInfos.count) {
        self.statusLabel.stringValue = @"Loading view tree...";
        [self.windowTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
    } else {
        self.statusLabel.stringValue = @"No windows found.";
    }
}

- (void)pickViewClient:(PickViewClient *)client didReceiveHierarchy:(PVHierarchyInfo *)hierarchy endpointIdentifier:(NSString *)endpointIdentifier {
    if (![endpointIdentifier isEqualToString:self.inspectedEndpointIdentifier]) {
        return;
    }

    self.currentHierarchy = hierarchy;
    self.selectedDisplayItem = nil;
    [self.displayItemDetailsByID removeAllObjects];
    self.detailPreviewLabel.stringValue = @"Select a view item to load preview.";
    [self resetInspector];
    [self.previewSceneView renderHierarchy:hierarchy detailsByID:self.displayItemDetailsByID selectedItem:nil];
    [self.hierarchyOutlineView reloadData];
    [self.hierarchyOutlineView expandItem:nil expandChildren:YES];
    if (hierarchy.rootItems.count) {
        [self.hierarchyOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
    }
    [self requestDetailsForCurrentHierarchy];
    self.statusLabel.stringValue = @"View tree loaded. Updating screenshots...";
    [self appendLog:[NSString stringWithFormat:@"received hierarchy roots: %@", @(hierarchy.rootItems.count)]];
}

- (void)pickViewClient:(PickViewClient *)client didReceiveDisplayItemDetails:(NSArray<PVDisplayItemDetail *> *)details endpointIdentifier:(NSString *)endpointIdentifier {
    if (![endpointIdentifier isEqualToString:self.inspectedEndpointIdentifier]) {
        return;
    }

    for (PVDisplayItemDetail *detail in details) {
        if (detail.displayItemID.length) {
            self.displayItemDetailsByID[detail.displayItemID] = detail;
        }
    }
    [self.previewSceneView updateDetailsByID:self.displayItemDetailsByID selectedItem:self.selectedDisplayItem];

    NSInteger selectedRow = self.hierarchyOutlineView.selectedRow;
    id selectedItem = selectedRow >= 0 ? [self.hierarchyOutlineView itemAtRow:selectedRow] : nil;
    if ([selectedItem isKindOfClass:PVDisplayItem.class]) {
        PVDisplayItem *displayItem = selectedItem;
        PVDisplayItemDetail *detail = self.displayItemDetailsByID[displayItem.objectID];
        if (detail) {
            [self updatePreviewWithDisplayItemDetail:detail];
        }
    }
    self.statusLabel.stringValue = @"Screenshots updated. Select or rotate views.";
}

- (void)pickViewClient:(PickViewClient *)client didFailInspectionRequestForEndpointIdentifier:(NSString *)endpointIdentifier error:(NSError *)error {
    if (![endpointIdentifier isEqualToString:self.inspectedEndpointIdentifier]) {
        return;
    }
    [self appendLog:[NSString stringWithFormat:@"inspection failed: %@", error.localizedDescription ?: @""]];
}

@end

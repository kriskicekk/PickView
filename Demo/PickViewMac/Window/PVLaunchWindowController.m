//
//  PVLaunchWindowController.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVLaunchWindowController.h"

#import "PVClientSession.h"
#import "PVLANSessionCellModel.h"
#import "PVLaunchDeviceCellView.h"
#import "PVLaunchLANDeviceCellView.h"

static CGFloat const PVLaunchWindowHeight = 430.0;
static CGFloat const PVLaunchWindowMinWidth = 320.0;
static CGFloat const PVLaunchLANWindowWidth = 640.0;
static CGFloat const PVLaunchWindowHorizontalInset = 30.0;
static CGFloat const PVLaunchDeviceSpacing = 10.0;

typedef NS_ENUM(NSInteger, PVLaunchDeviceMode) {
    PVLaunchDeviceModePreview,
    PVLaunchDeviceModeLAN
};

@interface PVLaunchFlippedView : NSView
@end

@implementation PVLaunchFlippedView

- (BOOL)isFlipped {
    return YES;
}

@end

@interface PVLaunchWindowController ()

@property (nonatomic, strong) NSSegmentedControl *modeControl;
@property (nonatomic, strong) NSStackView *deviceStackView;
@property (nonatomic, strong) NSScrollView *LANScrollView;
@property (nonatomic, strong) NSStackView *LANStackView;
@property (nonatomic, strong) NSProgressIndicator *indicator;
@property (nonatomic, strong) NSTextField *emptyLabel;
@property (nonatomic, strong) NSTextField *LANEmptyLabel;
@property (nonatomic, strong) NSTextField *helpLabel;
@property (nonatomic, copy) NSArray<PVClientSession *> *previewSessions;
@property (nonatomic, copy) NSArray<PVClientSession *> *LANSessions;
@property (nonatomic, copy) NSDictionary<NSString *, NSImage *> *previewImages;
@property (nonatomic, copy) NSString *connectedLANEndpointIdentifier;

@end

@implementation PVLaunchWindowController

- (instancetype)init {
    NSRect frame = NSMakeRect(0, 0, PVLaunchWindowMinWidth, PVLaunchWindowHeight);
    NSWindowStyleMask styleMask = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskFullSizeContentView;
    NSWindow *window = [[NSWindow alloc] initWithContentRect:frame
                                                   styleMask:styleMask
                                                     backing:NSBackingStoreBuffered
                                                       defer:NO];
    window.title = @"PickView";
    window.restorable = NO;
    window.titleVisibility = NSWindowTitleHidden;
    window.titlebarAppearsTransparent = YES;
    window.movableByWindowBackground = YES;
    window.backgroundColor = NSColor.clearColor;
    [window center];

    self = [super initWithWindow:window];
    if (self) {
        _previewSessions = @[];
        _LANSessions = @[];
        _previewImages = @{};
        [self buildContentView];
    }
    return self;
}

- (void)buildContentView {
    NSVisualEffectView *contentView = [[NSVisualEffectView alloc] initWithFrame:self.window.contentView.bounds];
    contentView.blendingMode = NSVisualEffectBlendingModeBehindWindow;
    contentView.state = NSVisualEffectStateActive;
    contentView.material = NSVisualEffectMaterialWindowBackground;
    self.window.contentView = contentView;

    self.modeControl = [NSSegmentedControl segmentedControlWithLabels:@[@"Preview Devices", @"LAN Devices"]
                                                         trackingMode:NSSegmentSwitchTrackingSelectOne
                                                               target:self
                                                               action:@selector(changeDeviceMode:)];
    self.modeControl.translatesAutoresizingMaskIntoConstraints = NO;
    self.modeControl.selectedSegment = PVLaunchDeviceModePreview;
    [contentView addSubview:self.modeControl];

    self.deviceStackView = [[NSStackView alloc] init];
    self.deviceStackView.translatesAutoresizingMaskIntoConstraints = NO;
    self.deviceStackView.orientation = NSUserInterfaceLayoutOrientationHorizontal;
    self.deviceStackView.alignment = NSLayoutAttributeTop;
    self.deviceStackView.spacing = PVLaunchDeviceSpacing;
    [contentView addSubview:self.deviceStackView];

    NSView *LANDocumentView = [[PVLaunchFlippedView alloc] init];
    LANDocumentView.translatesAutoresizingMaskIntoConstraints = NO;
    self.LANStackView = [[NSStackView alloc] init];
    self.LANStackView.translatesAutoresizingMaskIntoConstraints = NO;
    self.LANStackView.orientation = NSUserInterfaceLayoutOrientationVertical;
    self.LANStackView.alignment = NSLayoutAttributeWidth;
    self.LANStackView.spacing = 8;
    [LANDocumentView addSubview:self.LANStackView];

    self.LANScrollView = [[NSScrollView alloc] init];
    self.LANScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.LANScrollView.drawsBackground = NO;
    self.LANScrollView.hasVerticalScroller = YES;
    self.LANScrollView.autohidesScrollers = YES;
    self.LANScrollView.documentView = LANDocumentView;
    [contentView addSubview:self.LANScrollView];

    self.indicator = [[NSProgressIndicator alloc] init];
    self.indicator.translatesAutoresizingMaskIntoConstraints = NO;
    self.indicator.indeterminate = YES;
    self.indicator.style = NSProgressIndicatorStyleSpinning;
    self.indicator.controlSize = NSControlSizeSmall;
    [contentView addSubview:self.indicator];

    self.emptyLabel = [self emptyLabelWithText:@"Searching for inspectable apps"];
    [contentView addSubview:self.emptyLabel];
    self.LANEmptyLabel = [self emptyLabelWithText:@"No LAN devices found"];
    [contentView addSubview:self.LANEmptyLabel];

    self.helpLabel = [NSTextField labelWithString:@"Can't see your app?"];
    self.helpLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.helpLabel.font = [NSFont systemFontOfSize:12 weight:NSFontWeightRegular];
    self.helpLabel.textColor = NSColor.linkColor;
    [contentView addSubview:self.helpLabel];

    [NSLayoutConstraint activateConstraints:@[
        [self.modeControl.topAnchor constraintEqualToAnchor:contentView.topAnchor constant:18],
        [self.modeControl.centerXAnchor constraintEqualToAnchor:contentView.centerXAnchor],

        [self.deviceStackView.topAnchor constraintEqualToAnchor:self.modeControl.bottomAnchor constant:14],
        [self.deviceStackView.centerXAnchor constraintEqualToAnchor:contentView.centerXAnchor],

        [self.LANScrollView.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:24],
        [self.LANScrollView.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-24],
        [self.LANScrollView.topAnchor constraintEqualToAnchor:self.modeControl.bottomAnchor constant:16],
        [self.LANScrollView.bottomAnchor constraintEqualToAnchor:self.helpLabel.topAnchor constant:-12],

        [LANDocumentView.widthAnchor constraintEqualToAnchor:self.LANScrollView.contentView.widthAnchor],
        [self.LANStackView.leadingAnchor constraintEqualToAnchor:LANDocumentView.leadingAnchor],
        [self.LANStackView.trailingAnchor constraintEqualToAnchor:LANDocumentView.trailingAnchor],
        [self.LANStackView.topAnchor constraintEqualToAnchor:LANDocumentView.topAnchor],
        [self.LANStackView.bottomAnchor constraintEqualToAnchor:LANDocumentView.bottomAnchor],

        [self.indicator.centerYAnchor constraintEqualToAnchor:contentView.centerYAnchor constant:-8],
        [self.emptyLabel.leadingAnchor constraintEqualToAnchor:self.indicator.trailingAnchor constant:6],
        [self.emptyLabel.centerYAnchor constraintEqualToAnchor:self.indicator.centerYAnchor],
        [self.emptyLabel.centerXAnchor constraintEqualToAnchor:contentView.centerXAnchor constant:14],

        [self.LANEmptyLabel.centerXAnchor constraintEqualToAnchor:contentView.centerXAnchor],
        [self.LANEmptyLabel.centerYAnchor constraintEqualToAnchor:contentView.centerYAnchor],

        [self.helpLabel.centerXAnchor constraintEqualToAnchor:contentView.centerXAnchor],
        [self.helpLabel.bottomAnchor constraintEqualToAnchor:contentView.bottomAnchor constant:-14]
    ]];

    [self reloadContent];
}

- (NSTextField *)emptyLabelWithText:(NSString *)text {
    NSTextField *label = [NSTextField labelWithString:text];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.font = [NSFont systemFontOfSize:14 weight:NSFontWeightRegular];
    label.textColor = NSColor.labelColor;
    return label;
}

- (void)reloadWithPreviewSessions:(NSArray<PVClientSession *> *)previewSessions
                       LANSessions:(NSArray<PVClientSession *> *)LANSessions
                     previewImages:(NSDictionary<NSString *,NSImage *> *)previewImages
    connectedLANEndpointIdentifier:(NSString *)connectedLANEndpointIdentifier {
    self.previewSessions = previewSessions ?: @[];
    self.LANSessions = LANSessions ?: @[];
    self.previewImages = previewImages ?: @{};
    self.connectedLANEndpointIdentifier = connectedLANEndpointIdentifier;
    [self reloadContent];
}

- (void)reloadContent {
    [self reloadPreviewDevices];
    [self reloadLANDevices];
    [self updateModeVisibility];
}

- (void)reloadPreviewDevices {
    [self removeArrangedSubviewsFromStackView:self.deviceStackView];

    __block CGFloat windowWidth = PVLaunchWindowMinWidth;
    if (self.previewSessions.count) {
        windowWidth = PVLaunchWindowHorizontalInset * 2.0 + PVLaunchDeviceSpacing * (self.previewSessions.count - 1);
    }
    [self.previewSessions enumerateObjectsUsingBlock:^(PVClientSession *session, NSUInteger idx, BOOL *stop) {
        PVLaunchDeviceCellView *deviceView = [[PVLaunchDeviceCellView alloc] initWithFrame:NSZeroRect];
        [deviceView configureWithSession:session
                            previewImage:self.previewImages[session.identifier]
                                     row:(NSInteger)idx
                                  target:self
                                  action:@selector(selectDeviceView:)];
        NSSize deviceSize = deviceView.intrinsicContentSize;
        [deviceView.widthAnchor constraintEqualToConstant:deviceSize.width].active = YES;
        [deviceView.heightAnchor constraintEqualToConstant:deviceSize.height].active = YES;
        [self.deviceStackView addArrangedSubview:deviceView];
        windowWidth += deviceSize.width;
    }];
    if (self.modeControl.selectedSegment == PVLaunchDeviceModePreview) {
        [self.window setContentSize:NSMakeSize(MAX(PVLaunchWindowMinWidth, windowWidth), PVLaunchWindowHeight)];
    }
}

- (void)reloadLANDevices {
    [self removeArrangedSubviewsFromStackView:self.LANStackView];
    [self.LANSessions enumerateObjectsUsingBlock:^(PVClientSession *session, NSUInteger idx, BOOL *stop) {
        PVLANSessionCellModel *model = [[PVLANSessionCellModel alloc] initWithSession:session
                                                       connectedEndpointIdentifier:self.connectedLANEndpointIdentifier];
        PVLaunchLANDeviceCellView *cell = [[PVLaunchLANDeviceCellView alloc] initWithFrame:NSZeroRect];
        [cell configureWithModel:model row:(NSInteger)idx target:self action:@selector(selectLANDeviceButton:)];
        [self.LANStackView addArrangedSubview:cell];
    }];
}

- (void)removeArrangedSubviewsFromStackView:(NSStackView *)stackView {
    for (NSView *view in stackView.arrangedSubviews.copy) {
        [stackView removeArrangedSubview:view];
        [view removeFromSuperview];
    }
}

- (void)changeDeviceMode:(NSSegmentedControl *)sender {
    [self updateModeVisibility];
}

- (void)updateModeVisibility {
    BOOL showsPreview = self.modeControl.selectedSegment == PVLaunchDeviceModePreview;
    BOOL hasPreviewDevices = self.previewSessions.count > 0;
    BOOL hasLANDevices = self.LANSessions.count > 0;

    self.deviceStackView.hidden = !showsPreview || !hasPreviewDevices;
    self.indicator.hidden = !showsPreview || hasPreviewDevices;
    self.emptyLabel.hidden = !showsPreview || hasPreviewDevices;
    self.LANScrollView.hidden = showsPreview || !hasLANDevices;
    self.LANEmptyLabel.hidden = showsPreview || hasLANDevices;

    if (showsPreview && !hasPreviewDevices) {
        [self.indicator startAnimation:self];
    } else {
        [self.indicator stopAnimation:self];
    }

    if (showsPreview) {
        CGFloat contentWidth = PVLaunchWindowHorizontalInset * 2;
        for (NSView *view in self.deviceStackView.arrangedSubviews) {
            contentWidth += view.intrinsicContentSize.width;
        }
        if (self.deviceStackView.arrangedSubviews.count > 1) {
            contentWidth += PVLaunchDeviceSpacing * (self.deviceStackView.arrangedSubviews.count - 1);
        }
        contentWidth += PVLaunchWindowHorizontalInset * 2;
        [self.window setContentSize:NSMakeSize(MAX(PVLaunchWindowMinWidth, contentWidth), PVLaunchWindowHeight)];
    } else {
        [self.window setContentSize:NSMakeSize(PVLaunchLANWindowWidth, PVLaunchWindowHeight)];
    }
}

- (void)selectDeviceView:(NSControl *)sender {
    if (self.selectionHandler) {
        self.selectionHandler(sender.tag);
    }
}

- (void)selectLANDeviceButton:(NSButton *)sender {
    if (self.LANSelectionHandler) {
        self.LANSelectionHandler(sender.tag);
    }
}

@end

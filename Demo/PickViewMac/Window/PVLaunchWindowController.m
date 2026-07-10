//
//  PVLaunchWindowController.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVLaunchWindowController.h"

#import "PVClientSession.h"
#import "PVLaunchDeviceCellView.h"

static CGFloat const PVLaunchWindowHeight = 400.0;
static CGFloat const PVLaunchWindowMinWidth = 252.0;
static CGFloat const PVLaunchWindowHorizontalInset = 30.0;
static CGFloat const PVLaunchDeviceSpacing = 10.0;

@interface PVLaunchWindowController ()

@property (nonatomic, strong) NSStackView *deviceStackView;
@property (nonatomic, strong) NSProgressIndicator *indicator;
@property (nonatomic, strong) NSTextField *emptyLabel;
@property (nonatomic, strong) NSTextField *helpLabel;

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

    self.deviceStackView = [[NSStackView alloc] init];
    self.deviceStackView.translatesAutoresizingMaskIntoConstraints = NO;
    self.deviceStackView.orientation = NSUserInterfaceLayoutOrientationHorizontal;
    self.deviceStackView.alignment = NSLayoutAttributeTop;
    self.deviceStackView.spacing = PVLaunchDeviceSpacing;
    [contentView addSubview:self.deviceStackView];

    self.indicator = [[NSProgressIndicator alloc] init];
    self.indicator.translatesAutoresizingMaskIntoConstraints = NO;
    self.indicator.indeterminate = YES;
    self.indicator.style = NSProgressIndicatorStyleSpinning;
    self.indicator.controlSize = NSControlSizeSmall;
    [contentView addSubview:self.indicator];

    self.emptyLabel = [NSTextField labelWithString:@"Searching for inspectable apps"];
    self.emptyLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.emptyLabel.font = [NSFont systemFontOfSize:14 weight:NSFontWeightRegular];
    self.emptyLabel.textColor = NSColor.labelColor;
    [contentView addSubview:self.emptyLabel];

    self.helpLabel = [NSTextField labelWithString:@"Can't see your app?"];
    self.helpLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.helpLabel.font = [NSFont systemFontOfSize:12 weight:NSFontWeightRegular];
    self.helpLabel.textColor = NSColor.linkColor;
    [contentView addSubview:self.helpLabel];

    [NSLayoutConstraint activateConstraints:@[
        [self.deviceStackView.topAnchor constraintEqualToAnchor:contentView.topAnchor constant:30],
        [self.deviceStackView.centerXAnchor constraintEqualToAnchor:contentView.centerXAnchor],

        [self.indicator.centerYAnchor constraintEqualToAnchor:contentView.centerYAnchor constant:-20],
        [self.emptyLabel.leadingAnchor constraintEqualToAnchor:self.indicator.trailingAnchor constant:6],
        [self.emptyLabel.centerYAnchor constraintEqualToAnchor:self.indicator.centerYAnchor],
        [self.emptyLabel.centerXAnchor constraintEqualToAnchor:contentView.centerXAnchor constant:14],

        [self.helpLabel.centerXAnchor constraintEqualToAnchor:contentView.centerXAnchor],
        [self.helpLabel.bottomAnchor constraintEqualToAnchor:contentView.bottomAnchor constant:-14]
    ]];

    [self reloadWithSessions:@[] previewImages:@{}];
}

- (void)reloadWithSessions:(NSArray<PVClientSession *> *)sessions
             previewImages:(NSDictionary<NSString *, NSImage *> *)previewImages {
    for (NSView *view in self.deviceStackView.arrangedSubviews.copy) {
        [self.deviceStackView removeArrangedSubview:view];
        [view removeFromSuperview];
    }

    __block CGFloat windowWidth = PVLaunchWindowMinWidth;
    if (sessions.count) {
        windowWidth = PVLaunchWindowHorizontalInset * 2.0 + PVLaunchDeviceSpacing * (sessions.count - 1);
    }

    [sessions enumerateObjectsUsingBlock:^(PVClientSession *session, NSUInteger idx, BOOL *stop) {
        PVLaunchDeviceCellView *deviceView = [[PVLaunchDeviceCellView alloc] initWithFrame:NSZeroRect];
        [deviceView configureWithSession:session
                            previewImage:previewImages[session.identifier]
                                     row:(NSInteger)idx
                                  target:self
                                  action:@selector(selectDeviceView:)];
        NSSize deviceSize = deviceView.intrinsicContentSize;
        [deviceView.widthAnchor constraintEqualToConstant:deviceSize.width].active = YES;
        [deviceView.heightAnchor constraintEqualToConstant:deviceSize.height].active = YES;
        [self.deviceStackView addArrangedSubview:deviceView];
        windowWidth += deviceSize.width;
    }];

    BOOL hasDevices = sessions.count > 0;
    self.deviceStackView.hidden = !hasDevices;
    self.indicator.hidden = hasDevices;
    self.emptyLabel.hidden = hasDevices;
    if (hasDevices) {
        [self.indicator stopAnimation:self];
    } else {
        [self.indicator startAnimation:self];
    }

    [self.window setContentSize:NSMakeSize(MAX(PVLaunchWindowMinWidth, windowWidth), PVLaunchWindowHeight)];
}

- (void)selectDeviceView:(NSControl *)sender {
    if (self.selectionHandler) {
        self.selectionHandler(sender.tag);
    }
}

@end

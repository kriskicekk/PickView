//
//  PVLaunchDeviceCellView.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVLaunchDeviceCellView.h"

#import "PVClientSession.h"
#import "PVEndpointProtocol.h"
#import "PVPeerIdentity.h"

static NSSize const PVLaunchDevicePreviewSize = {142.0, 260.0};
static NSEdgeInsets const PVLaunchDeviceInsets = {12.0, 25.0, 12.0, 25.0};
static CGFloat const PVLaunchDeviceIconTop = 10.0;
static CGFloat const PVLaunchDeviceIconTextSpacing = 8.0;

@interface PVLaunchDeviceCellView ()

@property (nonatomic, strong) CALayer *hoverBackgroundLayer;
@property (nonatomic, strong) NSImageView *previewImageView;
@property (nonatomic, strong) NSImageView *iconImageView;
@property (nonatomic, strong) NSTextField *titleLabel;
@property (nonatomic, strong) NSTextField *subtitleLabel;

@end

@implementation PVLaunchDeviceCellView

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        self.wantsLayer = YES;
        self.layer.cornerRadius = 4;
        self.layer.masksToBounds = YES;

        _hoverBackgroundLayer = [CALayer layer];
        _hoverBackgroundLayer.opacity = 0;
        _hoverBackgroundLayer.cornerRadius = 4;
        [self.layer addSublayer:_hoverBackgroundLayer];

        _previewImageView = [[NSImageView alloc] init];
        _previewImageView.imageAlignment = NSImageAlignCenter;
        _previewImageView.imageScaling = NSImageScaleProportionallyUpOrDown;
        _previewImageView.wantsLayer = YES;
        _previewImageView.layer.cornerRadius = 8;
        _previewImageView.layer.backgroundColor = NSColor.controlBackgroundColor.CGColor;
        [self addSubview:_previewImageView];

        _iconImageView = [[NSImageView alloc] init];
        [_iconImageView setContentCompressionResistancePriority:NSLayoutPriorityRequired forOrientation:NSLayoutConstraintOrientationHorizontal];
        [self addSubview:_iconImageView];

        _titleLabel = [NSTextField labelWithString:@""];
        _titleLabel.font = [NSFont systemFontOfSize:13 weight:NSFontWeightRegular];
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:_titleLabel];

        _subtitleLabel = [NSTextField labelWithString:@""];
        _subtitleLabel.font = [NSFont systemFontOfSize:12 weight:NSFontWeightRegular];
        _subtitleLabel.textColor = NSColor.labelColor;
        _subtitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:_subtitleLabel];

        [self updateLayer];
    }
    return self;
}

- (void)configureWithSession:(PVClientSession *)session
                previewImage:(NSImage *)previewImage
                         row:(NSInteger)row
                      target:(id)target
                      action:(SEL)action {
    self.tag = row;
    self.target = target;
    self.action = action;
    self.enabled = session.state == PVClientSessionStateReady;

    PVPeerIdentity *identity = session.peerIdentity;
    NSString *deviceName = identity.deviceName.length ? identity.deviceName : (session.endpoint.displayName ?: @"Unknown Device");
    NSString *appName = identity.appName.length ? identity.appName : @"Unknown App";
    NSString *bundleID = identity.bundleID.length ? identity.bundleID : session.identifier ?: @"";

    self.previewImageView.image = previewImage ?: [self placeholderImageWithTitle:@"Preview"];
    self.iconImageView.image = [self iconImageForSession:session];
    self.titleLabel.stringValue = deviceName;
    self.subtitleLabel.stringValue = [self subtitleTextWithSession:session];
    self.toolTip = [NSString stringWithFormat:@"%@\n%@\n%@", deviceName, appName, bundleID];

    [self invalidateIntrinsicContentSize];
    [self setNeedsLayout:YES];
}

- (void)layout {
    [super layout];
    self.hoverBackgroundLayer.frame = self.layer.bounds;

    CGFloat previewX = (NSWidth(self.bounds) - PVLaunchDevicePreviewSize.width) / 2.0;
    CGFloat previewY = NSHeight(self.bounds) - PVLaunchDeviceInsets.top - PVLaunchDevicePreviewSize.height;
    self.previewImageView.frame = NSMakeRect(previewX, previewY, PVLaunchDevicePreviewSize.width, PVLaunchDevicePreviewSize.height);

    NSSize iconSize = self.iconImageView.image.size;
    if (NSEqualSizes(iconSize, NSZeroSize)) {
        iconSize = NSMakeSize(28, 28);
    }
    CGFloat iconY = previewY - PVLaunchDeviceIconTop - iconSize.height;

    CGFloat labelMaxWidth = MAX(40.0, NSWidth(self.bounds) - PVLaunchDeviceInsets.left - PVLaunchDeviceInsets.right - iconSize.width - PVLaunchDeviceIconTextSpacing);
    NSSize titleSize = [self titleSizeForWidth:labelMaxWidth];
    NSSize subtitleSize = [self subtitleSizeForWidth:labelMaxWidth];
    CGFloat labelWidth = MIN(labelMaxWidth, MAX(titleSize.width, subtitleSize.width));
    CGFloat labelBlockHeight = titleSize.height + 2.0 + subtitleSize.height;
    CGFloat labelBlockY = iconY + (iconSize.height - labelBlockHeight) / 2.0;
    CGFloat groupWidth = iconSize.width + PVLaunchDeviceIconTextSpacing + labelWidth;
    CGFloat iconX = (NSWidth(self.bounds) - groupWidth) / 2.0 - 2.0;

    self.iconImageView.frame = NSMakeRect(iconX, iconY, iconSize.width, iconSize.height);
    self.titleLabel.frame = NSMakeRect(NSMaxX(self.iconImageView.frame) + PVLaunchDeviceIconTextSpacing,
                                       labelBlockY + subtitleSize.height + 2.0,
                                       labelWidth,
                                       titleSize.height);
    self.subtitleLabel.frame = NSMakeRect(NSMinX(self.titleLabel.frame),
                                          labelBlockY,
                                          labelWidth,
                                          subtitleSize.height);
}

- (NSSize)intrinsicContentSize {
    return [self sizeThatFits:NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX)];
}

- (NSSize)sizeThatFits:(NSSize)limitedSize {
    NSSize iconSize = self.iconImageView.image.size;
    if (NSEqualSizes(iconSize, NSZeroSize)) {
        iconSize = NSMakeSize(28, 28);
    }

    CGFloat previewWidth = PVLaunchDevicePreviewSize.width + PVLaunchDeviceInsets.left + PVLaunchDeviceInsets.right;
    CGFloat labelsWidth = iconSize.width + PVLaunchDeviceIconTextSpacing + MAX([self titleSizeForWidth:CGFLOAT_MAX].width, [self subtitleSizeForWidth:CGFLOAT_MAX].width) + PVLaunchDeviceInsets.left + PVLaunchDeviceInsets.right;
    CGFloat width = MAX(previewWidth, labelsWidth);
    CGFloat height = PVLaunchDeviceInsets.top + PVLaunchDevicePreviewSize.height + PVLaunchDeviceIconTop + iconSize.height + PVLaunchDeviceInsets.bottom;
    return NSMakeSize(ceil(width), ceil(height));
}

- (void)mouseUp:(NSEvent *)event {
    if (!self.enabled) {
        return;
    }
    [NSApp sendAction:self.action to:self.target from:self];
}

- (void)mouseEntered:(NSEvent *)event {
    [super mouseEntered:event];
    self.hoverBackgroundLayer.opacity = self.enabled ? 1 : 0;
}

- (void)mouseExited:(NSEvent *)event {
    [super mouseExited:event];
    self.hoverBackgroundLayer.opacity = 0;
}

- (void)updateTrackingAreas {
    [super updateTrackingAreas];
    for (NSTrackingArea *area in self.trackingAreas.copy) {
        [self removeTrackingArea:area];
    }
    NSTrackingAreaOptions options = NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways | NSTrackingInVisibleRect;
    NSTrackingArea *area = [[NSTrackingArea alloc] initWithRect:self.bounds options:options owner:self userInfo:nil];
    [self addTrackingArea:area];
}

- (void)updateLayer {
    [super updateLayer];
    BOOL darkMode = [self.effectiveAppearance.name containsString:@"Dark"];
    self.hoverBackgroundLayer.backgroundColor = (darkMode ? [NSColor colorWithWhite:0 alpha:0.17] : [NSColor colorWithWhite:0 alpha:0.08]).CGColor;
    self.layer.backgroundColor = NSColor.clearColor.CGColor;
}

- (NSSize)titleSizeForWidth:(CGFloat)width {
    return [self.titleLabel sizeThatFits:NSMakeSize(width, CGFLOAT_MAX)];
}

- (NSSize)subtitleSizeForWidth:(CGFloat)width {
    return [self.subtitleLabel sizeThatFits:NSMakeSize(width, CGFLOAT_MAX)];
}

- (NSImage *)iconImageForSession:(PVClientSession *)session {
    if (session.endpoint.transportType == PVEndpointTransportTypeLocalLoopback) {
        return [NSImage imageNamed:@"icon_simulator_big"];
    }
    return [NSImage imageNamed:@"icon_iphone_big"] ?: [NSImage imageNamed:@"icon_ipad_big"];
}

- (NSString *)subtitleTextWithSession:(PVClientSession *)session {
    NSString *systemVersion = session.peerIdentity.systemVersion;
    if (!systemVersion.length) {
        return @"iOS";
    }
    if ([systemVersion localizedCaseInsensitiveContainsString:@"iOS"]) {
        return systemVersion;
    }
    return [NSString stringWithFormat:@"iOS %@", systemVersion];
}

- (NSImage *)placeholderImageWithTitle:(NSString *)title {
    NSImage *image = [[NSImage alloc] initWithSize:PVLaunchDevicePreviewSize];
    [image lockFocus];
    [[NSColor colorWithWhite:0.92 alpha:1] setFill];
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(0, 0, PVLaunchDevicePreviewSize.width, PVLaunchDevicePreviewSize.height) xRadius:14 yRadius:14];
    [path fill];

    NSDictionary<NSAttributedStringKey, id> *attributes = @{
        NSFontAttributeName: [NSFont systemFontOfSize:13 weight:NSFontWeightMedium],
        NSForegroundColorAttributeName: NSColor.secondaryLabelColor
    };
    NSSize textSize = [title sizeWithAttributes:attributes];
    [title drawAtPoint:NSMakePoint((PVLaunchDevicePreviewSize.width - textSize.width) / 2.0,
                                   (PVLaunchDevicePreviewSize.height - textSize.height) / 2.0)
        withAttributes:attributes];
    [image unlockFocus];
    return image;
}

@end

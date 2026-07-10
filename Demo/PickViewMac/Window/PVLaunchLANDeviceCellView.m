//
//  PVLaunchLANDeviceCellView.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/10.
//

#import "PVLaunchLANDeviceCellView.h"

#import "PVLANSessionCellModel.h"

@interface PVLaunchLANDeviceCellView ()

@property (nonatomic, strong) NSImageView *iconImageView;
@property (nonatomic, strong) NSTextField *deviceLabel;
@property (nonatomic, strong) NSTextField *appLabel;
@property (nonatomic, strong) NSTextField *bundleLabel;
@property (nonatomic, strong) NSTextField *statusLabel;
@property (nonatomic, strong) NSButton *actionButton;

@end


@implementation PVLaunchLANDeviceCellView

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        self.wantsLayer = YES;
        self.layer.cornerRadius = 6;
        self.layer.borderWidth = 1;

        _iconImageView = [[NSImageView alloc] init];
        _iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _iconImageView.image = [NSImage imageWithSystemSymbolName:@"wifi" accessibilityDescription:@"LAN"];
        _iconImageView.contentTintColor = NSColor.secondaryLabelColor;
        [self addSubview:_iconImageView];

        _deviceLabel = [NSTextField labelWithString:@""];
        _deviceLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _deviceLabel.font = [NSFont systemFontOfSize:13 weight:NSFontWeightSemibold];
        _deviceLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:_deviceLabel];

        _appLabel = [NSTextField labelWithString:@""];
        _appLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _appLabel.font = [NSFont systemFontOfSize:12];
        _appLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:_appLabel];

        _bundleLabel = [NSTextField labelWithString:@""];
        _bundleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _bundleLabel.font = [NSFont monospacedSystemFontOfSize:11 weight:NSFontWeightRegular];
        _bundleLabel.textColor = NSColor.secondaryLabelColor;
        _bundleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [self addSubview:_bundleLabel];

        _statusLabel = [NSTextField labelWithString:@""];
        _statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _statusLabel.font = [NSFont systemFontOfSize:11 weight:NSFontWeightMedium];
        _statusLabel.alignment = NSTextAlignmentRight;
        [self addSubview:_statusLabel];

        _actionButton = [NSButton buttonWithTitle:@"Connect" target:nil action:nil];
        _actionButton.translatesAutoresizingMaskIntoConstraints = NO;
        _actionButton.bezelStyle = NSBezelStyleRounded;
        _actionButton.controlSize = NSControlSizeSmall;
        [self addSubview:_actionButton];

        [NSLayoutConstraint activateConstraints:@[
            [_iconImageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:14],
            [_iconImageView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
            [_iconImageView.widthAnchor constraintEqualToConstant:22],
            [_iconImageView.heightAnchor constraintEqualToConstant:22],

            [_deviceLabel.leadingAnchor constraintEqualToAnchor:_iconImageView.trailingAnchor constant:12],
            [_deviceLabel.topAnchor constraintEqualToAnchor:self.topAnchor constant:10],
            [_deviceLabel.trailingAnchor constraintLessThanOrEqualToAnchor:_statusLabel.leadingAnchor constant:-12],

            [_appLabel.leadingAnchor constraintEqualToAnchor:_deviceLabel.leadingAnchor],
            [_appLabel.topAnchor constraintEqualToAnchor:_deviceLabel.bottomAnchor constant:3],
            [_appLabel.trailingAnchor constraintLessThanOrEqualToAnchor:_actionButton.leadingAnchor constant:-14],

            [_bundleLabel.leadingAnchor constraintEqualToAnchor:_deviceLabel.leadingAnchor],
            [_bundleLabel.topAnchor constraintEqualToAnchor:_appLabel.bottomAnchor constant:2],
            [_bundleLabel.trailingAnchor constraintLessThanOrEqualToAnchor:_actionButton.leadingAnchor constant:-14],

            [_statusLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-14],
            [_statusLabel.topAnchor constraintEqualToAnchor:self.topAnchor constant:10],
            [_statusLabel.widthAnchor constraintGreaterThanOrEqualToConstant:90],

            [_actionButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-14],
            [_actionButton.centerYAnchor constraintEqualToAnchor:_appLabel.centerYAnchor constant:8],
            [_actionButton.widthAnchor constraintGreaterThanOrEqualToConstant:96],
            [self.heightAnchor constraintEqualToConstant:72]
        ]];
        [self updateLayer];
    }
    return self;
}

- (void)configureWithModel:(PVLANSessionCellModel *)model
                       row:(NSInteger)row
                    target:(id)target
                    action:(SEL)action {
    self.deviceLabel.stringValue = model.deviceNameText;
    self.appLabel.stringValue = model.appNameText;
    self.bundleLabel.stringValue = model.bundleIDText;
    self.statusLabel.stringValue = model.statusText;
    self.statusLabel.textColor = model.session.state == PVClientSessionStateBlocked ? NSColor.secondaryLabelColor : NSColor.labelColor;
    self.actionButton.title = model.buttonTitle;
    self.actionButton.enabled = model.buttonEnabled;
    self.actionButton.tag = row;
    self.actionButton.target = target;
    self.actionButton.action = action;
    self.toolTip = [NSString stringWithFormat:@"%@\n%@\n%@", model.deviceNameText, model.appNameText, model.bundleIDText];
}

- (void)updateLayer {
    [super updateLayer];
    self.layer.backgroundColor = NSColor.controlBackgroundColor.CGColor;
    self.layer.borderColor = NSColor.separatorColor.CGColor;
}

@end

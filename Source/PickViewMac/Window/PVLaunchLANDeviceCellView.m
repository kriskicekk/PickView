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
@property (nonatomic, strong) NSTextField *LANNameLabel;
@property (nonatomic, strong) NSTextField *deviceInfoLabel;
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

        _LANNameLabel = [NSTextField labelWithString:@""];
        _LANNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _LANNameLabel.font = [NSFont systemFontOfSize:13 weight:NSFontWeightSemibold];
        _LANNameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [_LANNameLabel setContentCompressionResistancePriority:NSLayoutPriorityDefaultLow
                                               forOrientation:NSLayoutConstraintOrientationHorizontal];
        [self addSubview:_LANNameLabel];

        _deviceInfoLabel = [NSTextField labelWithString:@""];
        _deviceInfoLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _deviceInfoLabel.font = [NSFont systemFontOfSize:13
                                                 weight:NSFontWeightSemibold];
        _deviceInfoLabel.textColor = NSColor.labelColor;
        _deviceInfoLabel.alignment = NSTextAlignmentLeft;
        _deviceInfoLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [_deviceInfoLabel setContentCompressionResistancePriority:NSLayoutPriorityRequired
                                                   forOrientation:NSLayoutConstraintOrientationHorizontal];
        [_deviceInfoLabel setContentHuggingPriority:NSLayoutPriorityRequired
                                    forOrientation:NSLayoutConstraintOrientationHorizontal];
        [self addSubview:_deviceInfoLabel];

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

            [_LANNameLabel.leadingAnchor constraintEqualToAnchor:_iconImageView.trailingAnchor constant:12],
            [_LANNameLabel.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
            [_LANNameLabel.widthAnchor constraintLessThanOrEqualToConstant:260],

            [_deviceInfoLabel.leadingAnchor constraintEqualToAnchor:_LANNameLabel.trailingAnchor constant:12],
            [_deviceInfoLabel.trailingAnchor constraintLessThanOrEqualToAnchor:_actionButton.leadingAnchor constant:-12],
            [_deviceInfoLabel.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],

            [_actionButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-14],
            [_actionButton.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
            [_actionButton.widthAnchor constraintGreaterThanOrEqualToConstant:88],
            [self.heightAnchor constraintEqualToConstant:52]
        ]];
        [self updateLayer];
    }
    return self;
}

- (void)configureWithModel:(PVLANSessionCellModel *)model
                       row:(NSInteger)row
                    target:(id)target
                    action:(SEL)action {
    self.LANNameLabel.stringValue = model.LANNameText;
    self.deviceInfoLabel.stringValue = model.deviceInfoText;
    self.deviceInfoLabel.hidden = model.deviceInfoText.length == 0;
    self.actionButton.title = model.buttonTitle;
    self.actionButton.enabled = model.buttonEnabled;
    self.actionButton.tag = row;
    self.actionButton.target = target;
    self.actionButton.action = action;
    self.toolTip = model.deviceInfoText.length
        ? [NSString stringWithFormat:@"%@ %@",
            model.LANNameText,
            model.deviceInfoText]
        : model.LANNameText;
}

- (void)updateLayer {
    [super updateLayer];
    self.layer.backgroundColor = NSColor.controlBackgroundColor.CGColor;
    self.layer.borderColor = NSColor.separatorColor.CGColor;
}

@end

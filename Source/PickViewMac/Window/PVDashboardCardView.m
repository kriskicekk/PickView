//
//  PVDashboardCardView.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDashboardCardView.h"

static CGFloat const PVDashboardCardCornerRadius = 6.0;
static CGFloat const PVDashboardCardHorizontalInset = 12.0;

@interface PVDashboardCardView ()

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSArray<NSArray<NSString *> *> *rows;
@property (nonatomic, strong) NSVisualEffectView *backgroundView;
@property (nonatomic, strong) NSImageView *iconImageView;
@property (nonatomic, strong) NSTextField *titleLabel;
@property (nonatomic, strong) NSStackView *contentStackView;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSTextField *> *valueLabelsByKey;

@end

@implementation PVDashboardCardView

- (instancetype)initWithTitle:(NSString *)title rows:(NSArray<NSArray<NSString *> *> *)rows {
    NSAssert(title.length > 0, @"Dashboard card title should not be empty.");
    NSAssert(rows.count > 0, @"Dashboard card rows should not be empty.");

    self = [super initWithFrame:NSZeroRect];
    if (self) {
        _title = [title copy];
        _rows = [rows copy];
        _valueLabelsByKey = [NSMutableDictionary dictionary];
        [self buildViews];
    }
    return self;
}

- (void)buildViews {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.wantsLayer = YES;
    self.layer.cornerRadius = PVDashboardCardCornerRadius;

    self.backgroundView = [[NSVisualEffectView alloc] init];
    self.backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    self.backgroundView.blendingMode = NSVisualEffectBlendingModeWithinWindow;
    self.backgroundView.state = NSVisualEffectStateActive;
    self.backgroundView.material = NSVisualEffectMaterialContentBackground;
    self.backgroundView.wantsLayer = YES;
    self.backgroundView.layer.cornerRadius = PVDashboardCardCornerRadius;
    [self addSubview:self.backgroundView];

    self.iconImageView = [[NSImageView alloc] init];
    self.iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.iconImageView.image = [NSImage imageNamed:[self dashboardIconNameForTitle:self.title]];
    [self addSubview:self.iconImageView];

    self.titleLabel = [NSTextField labelWithString:self.title];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.font = [NSFont systemFontOfSize:13.0 weight:NSFontWeightSemibold];
    self.titleLabel.textColor = NSColor.labelColor;
    [self addSubview:self.titleLabel];

    self.contentStackView = [[NSStackView alloc] init];
    self.contentStackView.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentStackView.orientation = NSUserInterfaceLayoutOrientationVertical;
    self.contentStackView.alignment = NSLayoutAttributeLeading;
    self.contentStackView.spacing = 0.0;
    [self addSubview:self.contentStackView];

    [self.rows enumerateObjectsUsingBlock:^(NSArray<NSString *> *row, NSUInteger idx, BOOL *stop) {
        NSAssert(row.count >= 2, @"Dashboard row should be [title, key].");
        if (idx > 0) {
            NSView *separatorView = [self separatorView];
            [self.contentStackView addArrangedSubview:separatorView];
            [separatorView.widthAnchor constraintEqualToAnchor:self.contentStackView.widthAnchor].active = YES;
        }
        NSView *rowView = [self rowViewWithTitle:row[0] key:row[1]];
        [self.contentStackView addArrangedSubview:rowView];
        [rowView.widthAnchor constraintEqualToAnchor:self.contentStackView.widthAnchor].active = YES;
    }];

    [NSLayoutConstraint activateConstraints:@[
        [self.backgroundView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [self.backgroundView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.backgroundView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.backgroundView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],

        [self.iconImageView.topAnchor constraintEqualToAnchor:self.topAnchor constant:8.0],
        [self.iconImageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:PVDashboardCardHorizontalInset],
        [self.iconImageView.widthAnchor constraintEqualToConstant:16.0],
        [self.iconImageView.heightAnchor constraintEqualToConstant:16.0],

        [self.titleLabel.centerYAnchor constraintEqualToAnchor:self.iconImageView.centerYAnchor],
        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.iconImageView.trailingAnchor constant:7.0],
        [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-PVDashboardCardHorizontalInset],

        [self.contentStackView.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:7.0],
        [self.contentStackView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:PVDashboardCardHorizontalInset],
        [self.contentStackView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-PVDashboardCardHorizontalInset],
        [self.contentStackView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-10.0]
    ]];
}

- (NSString *)dashboardIconNameForTitle:(NSString *)title {
    if ([title containsString:@"Class"]) {
        return @"dashboard_class";
    }
    if ([title containsString:@"Layout"]) {
        return @"dashboard_layout";
    }
    if ([title containsString:@"View"] || [title containsString:@"Layer"]) {
        return @"dashboard_layer";
    }
    return @"dashboard_custom";
}

- (NSView *)separatorView {
    NSView *view = [[NSView alloc] init];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    view.wantsLayer = YES;
    view.layer.backgroundColor = NSColor.separatorColor.CGColor;
    [view.heightAnchor constraintEqualToConstant:1.0].active = YES;
    return view;
}

- (NSView *)rowViewWithTitle:(NSString *)title key:(NSString *)key {
    NSAssert(title.length > 0, @"Dashboard row title should not be empty.");
    NSAssert(key.length > 0, @"Dashboard row key should not be empty.");

    NSView *view = [[NSView alloc] init];
    view.translatesAutoresizingMaskIntoConstraints = NO;

    NSTextField *nameLabel = [NSTextField labelWithString:title];
    nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    nameLabel.font = [NSFont systemFontOfSize:12.0 weight:NSFontWeightRegular];
    nameLabel.textColor = NSColor.secondaryLabelColor;
    [view addSubview:nameLabel];

    NSTextField *valueLabel = [NSTextField labelWithString:@"-"];
    valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
    valueLabel.font = [NSFont monospacedSystemFontOfSize:12.0 weight:NSFontWeightRegular];
    valueLabel.textColor = NSColor.labelColor;
    valueLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    valueLabel.maximumNumberOfLines = 2;
    [view addSubview:valueLabel];
    self.valueLabelsByKey[key] = valueLabel;

    [NSLayoutConstraint activateConstraints:@[
        [view.heightAnchor constraintGreaterThanOrEqualToConstant:24.0],
        [nameLabel.leadingAnchor constraintEqualToAnchor:view.leadingAnchor],
        [nameLabel.centerYAnchor constraintEqualToAnchor:view.centerYAnchor],
        [nameLabel.widthAnchor constraintEqualToConstant:76.0],

        [valueLabel.leadingAnchor constraintEqualToAnchor:nameLabel.trailingAnchor constant:8.0],
        [valueLabel.trailingAnchor constraintEqualToAnchor:view.trailingAnchor],
        [valueLabel.centerYAnchor constraintEqualToAnchor:view.centerYAnchor]
    ]];

    return view;
}

- (NSTextField *)valueLabelForKey:(NSString *)key {
    return self.valueLabelsByKey[key];
}

@end

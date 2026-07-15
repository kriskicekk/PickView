//
//  PVHierarchyRowView.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVHierarchyRowView.h"

@interface PVHierarchyRowView ()

@property (nonatomic, strong) NSImageView *iconImageView;
@property (nonatomic, strong) NSTextField *titleLabel;
@property (nonatomic, strong) NSTextField *subtitleLabel;

@end

@implementation PVHierarchyRowView

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        [self buildViews];
    }
    return self;
}

- (void)buildViews {
    self.wantsLayer = YES;

    self.iconImageView = [[NSImageView alloc] init];
    self.iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.iconImageView.image = [NSImage imageNamed:@"hierarchy_view"];
    self.iconImageView.contentTintColor = NSColor.secondaryLabelColor;
    [self addSubview:self.iconImageView];

    self.titleLabel = [NSTextField labelWithString:@""];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.font = [NSFont systemFontOfSize:12.0 weight:NSFontWeightMedium];
    self.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    self.titleLabel.maximumNumberOfLines = 1;
    [self addSubview:self.titleLabel];
    self.textField = self.titleLabel;

    self.subtitleLabel = [NSTextField labelWithString:@""];
    self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.subtitleLabel.font = [NSFont systemFontOfSize:11.0 weight:NSFontWeightRegular];
    self.subtitleLabel.textColor = NSColor.secondaryLabelColor;
    self.subtitleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    self.subtitleLabel.maximumNumberOfLines = 1;
    [self addSubview:self.subtitleLabel];

    [NSLayoutConstraint activateConstraints:@[
        [self.iconImageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:5.0],
        [self.iconImageView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        [self.iconImageView.widthAnchor constraintEqualToConstant:14.0],
        [self.iconImageView.heightAnchor constraintEqualToConstant:14.0],

        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.iconImageView.trailingAnchor constant:5.0],
        [self.titleLabel.centerYAnchor constraintEqualToAnchor:self.centerYAnchor constant:-1.0],

        [self.subtitleLabel.leadingAnchor constraintEqualToAnchor:self.titleLabel.trailingAnchor constant:10.0],
        [self.subtitleLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.trailingAnchor constant:-8.0],
        [self.subtitleLabel.centerYAnchor constraintEqualToAnchor:self.titleLabel.centerYAnchor]
    ]];
}

- (void)configureWithTitle:(NSString *)title
                  subtitle:(NSString *)subtitle
                    hidden:(BOOL)hidden
                     alpha:(CGFloat)alpha {
    [self configureWithTitle:title subtitle:subtitle className:nil hidden:hidden alpha:alpha];
}

- (void)configureWithTitle:(NSString *)title
                  subtitle:(NSString *)subtitle
                 className:(NSString *)className
                    hidden:(BOOL)hidden
                     alpha:(CGFloat)alpha {
    self.titleLabel.stringValue = title.length ? title : @"<unknown>";
    self.subtitleLabel.stringValue = subtitle.length ? subtitle : @"-";
    self.iconImageView.image = [NSImage imageNamed:[self hierarchyIconNameForClassName:className title:title subtitle:subtitle]];
    BOOL dimmed = hidden || alpha < 0.01;
    self.titleLabel.textColor = dimmed ? NSColor.tertiaryLabelColor : NSColor.labelColor;
    self.subtitleLabel.textColor = dimmed ? NSColor.tertiaryLabelColor : NSColor.secondaryLabelColor;
    self.iconImageView.alphaValue = dimmed ? 0.35 : 0.75;
}

- (NSString *)hierarchyIconNameForClassName:(NSString *)className
                                      title:(NSString *)title
                                   subtitle:(NSString *)subtitle {
    static NSArray<NSDictionary<NSString *, NSString *> *> *viewIconMap = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        viewIconMap = @[
            @{@"UIWindow": @"hierarchy_window"},
            @{@"NSWindow": @"hierarchy_window"},
            @{@"UINavigationBar": @"hierarchy_navigationbar"},
            @{@"UITabBar": @"hierarchy_tabbar"},
            @{@"UITextView": @"hierarchy_textview"},
            @{@"NSTextView": @"hierarchy_textview"},
            @{@"UIStackView": @"hierarchy_stackview"},
            @{@"NSStackView": @"hierarchy_stackview"},
            @{@"UITextField": @"hierarchy_textfield"},
            @{@"NSTextField": @"hierarchy_textfield"},
            @{@"UITableView": @"hierarchy_tableview"},
            @{@"NSTableView": @"hierarchy_tableview"},
            @{@"UICollectionView": @"hierarchy_collectionview"},
            @{@"UICollectionViewCell": @"hierarchy_collectioncell"},
            @{@"UICollectionReusableView": @"hierarchy_collectionreuseview"},
            @{@"UITableViewCell": @"hierarchy_tablecell"},
            @{@"UISlider": @"hierarchy_slider"},
            @{@"NSSlider": @"hierarchy_slider"},
            @{@"WKWebView": @"hierarchy_webview"},
            @{@"UIWebView": @"hierarchy_webview"},
            @{@"_UITableViewCellSeparatorView": @"hierarchy_tablecellseparator"},
            @{@"UITableViewCellContentView": @"hierarchy_cellcontent"},
            @{@"_UITableViewHeaderFooterContentView": @"hierarchy_cellcontent"},
            @{@"UITableViewHeaderFooterView": @"hierarchy_tableheaderfooter"},
            @{@"UIScrollView": @"hierarchy_scrollview"},
            @{@"NSScrollView": @"hierarchy_scrollview"},
            @{@"UILabel": @"hierarchy_label"},
            @{@"NSTextField": @"hierarchy_label"},
            @{@"UIButton": @"hierarchy_button"},
            @{@"NSButton": @"hierarchy_button"},
            @{@"UIImageView": @"hierarchy_imageview"},
            @{@"NSImageView": @"hierarchy_imageview"},
            @{@"UIControl": @"hierarchy_control"},
            @{@"UIVisualEffectView": @"hierarchy_effectview"},
            @{@"NSVisualEffectView": @"hierarchy_effectview"},
            @{@"CAShapeLayer": @"hierarchy_shapelayer"},
            @{@"CAGradientLayer": @"hierarchy_gradientlayer"},
            @{@"CALayer": @"hierarchy_layer"}
        ];
    });

    NSString *text = className.length ? className : [NSString stringWithFormat:@"%@ %@", title ?: @"", subtitle ?: @""];
    for (NSDictionary<NSString *, NSString *> *map in viewIconMap) {
        NSString *mappedClass = map.allKeys.firstObject;
        if ([text containsString:mappedClass]) {
            return map[mappedClass];
        }
    }
    return @"hierarchy_view";
}

@end

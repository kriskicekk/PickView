//
//  PVDetailDashboardAttributeColorView.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailDashboardAttributeColorView.h"
#import "PVDetailColorIndicatorLayer.h"
#import "PVDetailDashboardCardView.h"
#import "PVDetailPreferenceManager.h"
#import "PVDetailDashboardViewController.h"
#import "PVDetailHierarchyDataSource.h"

@interface PVDetailDashboardAttributeColorContainerView : PVDetailBaseView

@property(nonatomic, weak) id clickTarget;
@property(nonatomic, assign) SEL clickAction;

@end

@implementation PVDetailDashboardAttributeColorContainerView

- (void)mouseDown:(NSEvent *)event {
    [super mouseDown:event];
    if (self.clickTarget && self.clickAction) {
        [NSApp sendAction:self.clickAction to:self.clickTarget from:event];
    }
}

@end

@interface PVDetailDashboardAttributeColorView () <NSMenuDelegate>

@property(nonatomic, strong) PVDetailColorIndicatorLayer *indicatorLayer;
@property(nonatomic, strong) PVDetailLabel *descLabel;
@property(nonatomic, strong) PVDetailDashboardAttributeColorContainerView *containerView;
@property(nonatomic, strong) NSImageView *iconImageView;
@property(nonatomic, strong) PVDetailLabel *aliasLabel;

@property(nonatomic, copy) NSArray<PVAttrIdentifier> *identifiersToHideAlias;

@end

@implementation PVDetailDashboardAttributeColorView {
    CGFloat _mainContainerHeight;
    CGFloat _aliasLabelMarginTop;
    CGFloat _labelX;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
//        [self setBackgroundColor:[NSColor blueColor]];
        
        self.identifiersToHideAlias = @[PVAttr_ViewLayer_Border_Color, PVAttr_ViewLayer_Shadow_Color];
        
        _mainContainerHeight = 30;
        _aliasLabelMarginTop = 1;
        _labelX = 28;
        
        self.containerView = [PVDetailDashboardAttributeColorContainerView new];
        self.containerView.layer.cornerRadius = DashboardCardControlCornerRadius;
        self.containerView.clickTarget = self;
        self.containerView.clickAction = @selector(_handleClick:);
        [self addSubview:self.containerView];
        
        self.indicatorLayer = [PVDetailColorIndicatorLayer new];
        [self.containerView.layer addSublayer:self.indicatorLayer];
        
        self.iconImageView = [NSImageView new];
        self.iconImageView.image = NSImageMake(@"Icon_ArrowUpDown");
        [self.containerView addSubview:self.iconImageView];
        
        self.descLabel = [PVDetailLabel new];
        self.descLabel.textColor = [NSColor colorNamed:@"DashboardCardValueColor"];
        self.descLabel.font = NSFontMake(13);
        [self.containerView addSubview:self.descLabel];
        
        @weakify(self);
        [[RACObserve([PVDetailPreferenceManager mainManager], rgbaFormat) skip:1] subscribeNext:^(NSNumber *bool_rgbaFormat) {
            @strongify(self);
            [self renderWithAttribute];
        }];
    }
    return self;
}

- (void)layout {
    [super layout];
    $(self.containerView).fullWidth.height(_mainContainerHeight).y(0);
    $(self.indicatorLayer).width(16).height(16).x(8).verAlign;
    $(self.descLabel).x(_labelX).toRight(20).heightToFit.verAlign.offsetY(-1);
    $(self.iconImageView).sizeToFit.verAlign.right(9);
    if (self.aliasLabel.isVisible) {
        $(self.aliasLabel).x(_labelX).toRight(0).y(self.containerView.$maxY + _aliasLabelMarginTop).heightToFit;
    }
}

- (void)renderWithAttribute {
    self.iconImageView.hidden = ![self canEdit];
    
    NSColor *color = [NSColor lk_colorFromRGBAComponents:self.attribute.value];
    self.indicatorLayer.color = color;
    
    if (color) {
        self.descLabel.stringValue = [PVDetailPreferenceManager mainManager].rgbaFormat ? color.rgbaString : color.hexString;
    } else {
        self.descLabel.stringValue = @"nil";
    }
    
    PVDetailHierarchyDataSource *dataSource = self.dashboardViewController.currentDataSource;
    NSArray<NSString *> *alias = [dataSource aliasForColor:color];
    if (alias && ![self.identifiersToHideAlias containsObject:self.attribute.identifier]) {
        if (!self.aliasLabel) {
            self.aliasLabel = [PVDetailLabel new];
            self.aliasLabel.textColor = [NSColor colorNamed:@"DashboardCardValueColor"];
            [self addSubview:self.aliasLabel];
        }
        self.aliasLabel.hidden = NO;
        self.aliasLabel.attributedStringValue = $([alias componentsJoinedByString:@"\n"]).font(NSFontMake(11)).lineHeight(18).attrString;
    } else {
        self.aliasLabel.hidden = YES;
    }
    [self setNeedsLayout:YES];
}

- (NSSize)sizeThatFits:(NSSize)limitedSize {
    CGFloat height = _mainContainerHeight;
    if (self.aliasLabel.isVisible) {
        CGFloat width = limitedSize.width - _labelX;
        height += _aliasLabelMarginTop + [self.aliasLabel sizeThatFits:NSMakeSize(width, CGFLOAT_MAX)].height;
    }
    limitedSize.height = height;
    return limitedSize;
}


- (void)setDashboardViewController:(PVDetailDashboardViewController *)dashboardViewController {
    [super setDashboardViewController:dashboardViewController];
    self.containerView.backgroundColorName = @"DashboardCardValueBGColor";
}

#pragma mark - <NSMenuDelegate>

- (void)_handleClick:(NSEvent *)event {
    if (!self.canEdit) {
        return;
    }
    
    PVDetailHierarchyDataSource *dataSource = self.dashboardViewController.currentDataSource;
    NSMenu *menu = dataSource.selectColorMenu;
    menu.delegate = self;
    [NSMenu popUpContextMenu:menu withEvent:event forView:self.containerView];
}

- (void)menuNeedsUpdate:(NSMenu *)menu {
    [menu.itemArray enumerateObjectsUsingBlock:^(NSMenuItem * _Nonnull menuItem, NSUInteger idx, BOOL * _Nonnull stop) {
        if (menuItem.hasSubmenu) {
            [menuItem.submenu.itemArray enumerateObjectsUsingBlock:^(NSMenuItem * _Nonnull subMenuItem, NSUInteger idx, BOOL * _Nonnull stop) {
                [self _updateMenuItem:subMenuItem];
            }];
        } else {
            [self _updateMenuItem:menuItem];
        }
    }];
}

- (void)_updateMenuItem:(NSMenuItem *)menuItem {
    if (menuItem.tag == self.dashboardViewController.currentDataSource.customColorMenuItemTag) {
        // "自定义颜色"
        menuItem.state = NSControlStateValueOff;
        menuItem.target = self;
        menuItem.action = @selector(_handleCustomColorMenuItem);
        return;
    }
    
    if (menuItem.tag == self.dashboardViewController.currentDataSource.toggleColorFormatMenuItemTag) {
        menuItem.state = NSControlStateValueOff;
        menuItem.target = self;
        menuItem.action = @selector(_handleToggleColorFormatMenuItem);
        return;
    }

    menuItem.target = self;
    menuItem.action = @selector(_handlePresetMenuItem:);
    NSColor *color = menuItem.representedObject;
    if ([self.attribute.value isEqual:[color lk_rgbaComponents]] || self.attribute.value == color) {
        // if 中后面的 == 是用来判断二者都是 nil 的情况
        menuItem.state = NSControlStateValueOn;
    } else {
        menuItem.state = NSControlStateValueOff;
    }
}

- (void)_handlePresetMenuItem:(NSMenuItem *)item {
    [self _modifyToColor:item.representedObject];
}

- (void)_handleCustomColorMenuItem {
    NSColor *initialColor = [NSColor lk_colorFromRGBAComponents:self.attribute.value];
    
    NSColorPanel *panel = [NSColorPanel sharedColorPanel];
    [panel setShowsAlpha:YES];
    [panel setContinuous:NO];
    [panel setColor:initialColor];
    [panel setTarget:self];
    [panel setAction:@selector(_handleSystemColorPanel:)];
    [panel orderFront:self];
}

- (void)_handleToggleColorFormatMenuItem {
    BOOL isRGBA = [PVDetailPreferenceManager mainManager].rgbaFormat;
    [PVDetailPreferenceManager mainManager].rgbaFormat = !isRGBA;
}

- (void)_handleSystemColorPanel:(NSColorPanel *)panel {
    [self _modifyToColor:panel.color];
}

- (void)_modifyToColor:(NSColor *)targetColor {
    NSArray *expecetdValue = [(NSColor *)targetColor lk_rgbaComponents];
    if ([expecetdValue isEqual:self.attribute.value]) {
        NSLog(@"修改没有变化，不做任何提交");
        return;
    }
    // 提交修改
    @weakify(self);
    [[self.dashboardViewController modifyAttribute:self.attribute newValue:expecetdValue] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self renderWithAttribute];
    }];
}

@end

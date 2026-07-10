//
//  LKDashboardSectionView.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "LKDashboardSectionView.h"
#import "LKDashboardAttributeRectView.h"
#import "LKDashboardAttributeNumberInputView.h"
#import "PVAttributesSection.h"
#import "PickViewDashboardBlueprint.h"
#import "LKDashboardAttributeInsetsView.h"
#import "LKDashboardAttributeSwitchView.h"
#import "LKDashboardAttributeColorView.h"
#import "LKDashboardAttributeEnumsView.h"
#import "LKDashboardAttributePointView.h"
#import "LKDashboardAttributeSizeView.h"
#import "LKDashboardAttributeRowsCountView.h"
#import "LKDashboardAttributeClassView.h"
#import "LKDashboardAttributeRelationView.h"
#import "LKDashboardAttributeConstraintsView.h"
#import "LKDashboardAttributeTextView.h"
#import "LKDashboardAttributeShadowView.h"
#import "LKPreferenceManager.h"
#import "LKDashboardAttributeOpenImageView.h"
#import "LKDashboardAttributeJsonView.h"

@interface LKDashboardSectionView ()

@property(nonatomic, strong) NSMutableArray<LKDashboardAttributeView *> *attrViews;
@property(nonatomic, strong) LKLabel *titleLabel;
@property(nonatomic, strong) CALayer *topSepLayer;

@property(nonatomic, strong) NSButton *manageButton;
@property(nonatomic, strong) NSButton *jsonPopupButton;

@end

@implementation LKDashboardSectionView {
    CGFloat _titleMarginTop;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        _titleMarginTop = 6;
//        self.layer.borderWidth = 1;
//        self.layer.borderColor = [NSColor blueColor].CGColor;
//        self.layer.backgroundColor = PickViewColorRGBAMake(255, 0, 0, .2).CGColor;
        
        /// 使得 topSepLayer 可以从右边延伸出去
        self.layer.masksToBounds = NO;
        
        self.attrViews = [NSMutableArray array];
    
        self.topSepLayer = [CALayer new];
        [self.topSepLayer pickview_removeImplicitAnimations];
        [self.layer addSublayer:self.topSepLayer];
        
        [self updateColors];
    }
    return self;
}

- (void)layout {
    [super layout];
    
    CGFloat contentsX = 0;
    CGFloat selfWidth = self.$width;
    CGFloat contentsY = 0;
    
    if (self.manageButton.isVisible) {
        CGFloat y;
        if (self.topSepLayer.hidden) {
            y = 0;
        } else if (self.titleLabel.isVisible) {
            y = 6;
        } else {
            y = 9;
        }

        $(self.manageButton).sizeToFit.x(0).y(y);
        contentsX = self.manageButton.$maxX + 6;
    }
    
    if (self.jsonPopupButton.isVisible) {
        $(self.jsonPopupButton).width(30).height(28).right(-5).y(0);
    }
    
    if (!self.topSepLayer.hidden) {
        $(self.topSepLayer).x(contentsX).width(selfWidth).height(1).y(0);
        contentsY = DashboardAttrItemVerInterspace;
    }
    
    if (self.titleLabel.isVisible) {
        CGFloat titleWidth = selfWidth;
        if (self.jsonPopupButton.isVisible) {
            titleWidth -= 20;
        }
        $(self.titleLabel).x(contentsX).width(titleWidth).heightToFit.y(self.topSepLayer.hidden ? 0 : _titleMarginTop);
        contentsY = self.titleLabel.$maxY + DashboardAttrItemVerInterspace;
    }
    
    NSArray<LKDashboardAttributeView *> *attrViews = [self.attrViews pickview_filter:^BOOL(LKDashboardAttributeView *view) {
        return view.isVisible;
    }];
    [attrViews enumerateObjectsUsingBlock:^(LKDashboardAttributeView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        LKDashboardAttributeView *prevView = (idx > 0 ? attrViews[idx - 1] : nil);
        CGFloat width;
        NSUInteger numberOfColumns = view.numberOfColumnsOccupied;
        if (numberOfColumns == 0) {
            width = [view sizeThatFits:NSSizeMax].width;
        } else {
            width = floor((selfWidth + DashboardAttrItemHorInterspace) / (CGFloat)numberOfColumns) - DashboardAttrItemHorInterspace;
        }
        
        CGFloat x, y;
        if (prevView && (prevView.$maxX + DashboardAttrItemHorInterspace + width <= (selfWidth + contentsX))) {
            x = prevView.$maxX + DashboardAttrItemHorInterspace;
            y = prevView.$y;
        } else {
            x = contentsX;
            y = prevView ? (prevView.$maxY + DashboardAttrItemVerInterspace) : contentsY;
        }
        $(view).width(width).heightToFit.x(x).y(y);
    }];
}

- (NSSize)sizeThatFits:(NSSize)limitedSize {
    NSArray<LKDashboardAttributeView *> *attrViews = [self.attrViews pickview_filter:^BOOL(LKDashboardAttributeView *view) {
        return view.isVisible;
    }];
    
    CGFloat height = 0;
    if (!self.topSepLayer.hidden) {
        height += DashboardAttrItemVerInterspace;
    }
    if (self.titleLabel.isVisible) {
        CGFloat titleWidth = limitedSize.width;
        if (self.jsonPopupButton.isVisible) {
            titleWidth -= 20;
        }
        height += [self.titleLabel sizeThatFits:NSMakeSize(titleWidth, CGFLOAT_MAX)].height + _titleMarginTop;
    }
    __block CGFloat prevMaxX = 0;
    height = [attrViews pickview_reduceCGFloat:^CGFloat(CGFloat accumulator, NSUInteger idx, LKDashboardAttributeView *view) {
        NSUInteger numberOfColumns = view.numberOfColumnsOccupied;
        CGFloat width;
        if (numberOfColumns == 0) {
            width = [view sizeThatFits:limitedSize].width;
        } else {
            width = floor((limitedSize.width + DashboardAttrItemHorInterspace) / numberOfColumns) - DashboardAttrItemHorInterspace;
        }
        
        if (idx > 0 && (prevMaxX + DashboardAttrItemHorInterspace + width <= limitedSize.width)) {
            prevMaxX = prevMaxX + DashboardAttrItemHorInterspace + width;
            return accumulator;
        } else {
            accumulator += [view sizeThatFits:limitedSize].height;
            if (idx > 0) {
                accumulator += DashboardAttrItemVerInterspace;
            }
            prevMaxX = width;
            return accumulator;
        }

    } initialAccumlator:height];
    
    limitedSize.height = height;
    return limitedSize;
}

- (void)setAttrSection:(PVAttributesSection *)attrSection {
    _attrSection = attrSection;
    if (!attrSection) {
        NSAssert(NO, @"");
        return;
    }
    
    NSString *title = [self resolveSectionTitle];
    if (title.length) {
        if (self.titleLabel) {
            self.titleLabel.hidden = NO;
        } else {
            self.titleLabel = [LKLabel new];
            self.titleLabel.font = [NSFont boldSystemFontOfSize:12];
//            self.titleLabel.backgroundColor = [NSColor greenColor];
            [self addSubview:self.titleLabel];
        }
        self.titleLabel.stringValue = title;
    } else {
        self.titleLabel.hidden = YES;
    }
    
    NSMutableArray<LKDashboardAttributeView *> *notUsedViews = [self.attrViews mutableCopy];
    
    [self.attrSection.attributes enumerateObjectsUsingBlock:^(PVAttribute * _Nonnull attr, NSUInteger idx, BOOL * _Nonnull stop) {
        Class attrViewClass = [self _targetAttrClassForType:attr.attrType identifier:attr.identifier];
        if (!attrViewClass) {
            NSAssert(NO, @"");
            return;
        }
        LKDashboardAttributeView *view = [notUsedViews pickview_firstFiltered:^BOOL(LKDashboardAttributeView *obj) {
            return [obj isMemberOfClass:attrViewClass];
        }];
        if (view) {
            [notUsedViews removeObject:view];
            view.hidden = NO;
        } else {
            view = [attrViewClass new];
            view.dashboardViewController = self.dashboardViewController;
            [self.attrViews addObject:view];
            [self addSubview:view];
        }
        view.attribute = attr;
    }];
    
    [notUsedViews enumerateObjectsUsingBlock:^(LKDashboardAttributeView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hidden = YES;
    }];
    
    BOOL hasJSONAttr = [self.attrSection.attributes pickview_any:^BOOL(PVAttribute *obj) {
        return obj.attrType == PVAttrTypeJson;
    }];
    if (hasJSONAttr) {
        [self showJSONPopupButton];
    } else {
        [self hideJSONPopupButton];
    }
    
    [self setNeedsLayout:YES];
}

- (void)setShowTopSeparator:(BOOL)showTopSeparator {
    _showTopSeparator = showTopSeparator;
    self.topSepLayer.hidden = !showTopSeparator;
}

- (void)updateColors {
    [super updateColors];
    self.topSepLayer.backgroundColor = self.isDarkMode ? SeparatorDarkModeColor.CGColor : SeparatorLightModeColor.CGColor;
}

- (Class)_targetAttrClassForType:(PVAttrType)type identifier:(PVAttrIdentifier)identifier {
    switch (type) {
        case PVAttrTypeCGRect:
            return [LKDashboardAttributeRectView class];
        case PVAttrTypeUIEdgeInsets:
            return [LKDashboardAttributeInsetsView class];
        case PVAttrTypeBOOL:
            return [LKDashboardAttributeSwitchView class];
        case PVAttrTypeFloat:
        case PVAttrTypeDouble:
        case PVAttrTypeLong:
            return [LKDashboardAttributeNumberInputView class];
        case PVAttrTypeUIColor:
            return [LKDashboardAttributeColorView class];
        case PVAttrTypeEnumInt:
        case PVAttrTypeEnumLong:
        case PVAttrTypeEnumString:
            return [LKDashboardAttributeEnumsView class];
        case PVAttrTypeCGPoint:
            return [LKDashboardAttributePointView class];
        case PVAttrTypeCGSize:
            return [LKDashboardAttributeSizeView class];
        case PVAttrTypeNSString:
            return [LKDashboardAttributeTextView class];
        case PVAttrTypeShadow:
            return [LKDashboardAttributeShadowView class];
        case PVAttrTypeJson:
            return [LKDashboardAttributeJsonView class];
        case PVAttrTypeCustomObj:
            if ([identifier isEqualToString:PVAttr_UITableView_RowsNumber_Number]) {
                return [LKDashboardAttributeRowsCountView class];
            } else if ([identifier isEqualToString:PVAttr_Class_Class_Class]) {
                return [LKDashboardAttributeClassView class];
            } else if ([identifier isEqualToString:PVAttr_Relation_Relation_Relation]) {
                return [LKDashboardAttributeRelationView class];
            } else if ([identifier isEqualToString:PVAttr_AutoLayout_Constraints_Constraints]) {
                return [LKDashboardAttributeConstraintsView class];
            } else if ([identifier isEqualToString:PVAttr_UIImageView_Open_Open]) {
                return [LKDashboardAttributeOpenImageView class];
            } else if ([identifier isEqualToString:PVAttr_UIVisualEffectView_Style_Style]) {
                return [LKDashboardAttributeEnumsView class];
            } else {
                NSAssert(NO, @"");
                return nil;
            }
        default:
            NSAssert(NO, @"");
            return nil;
    }
}

- (void)showJSONPopupButton {
    if (self.jsonPopupButton) {
        return;
    }
    self.jsonPopupButton = [NSButton buttonWithImage:NSImageMake(@"open_newwindow") target:self action:@selector(_handleJSONPopupButton)];
    self.jsonPopupButton.bezelStyle = NSBezelStyleRoundRect;
    self.jsonPopupButton.bordered = NO;
    [self addSubview:self.jsonPopupButton];
    [self addSubview:self.jsonPopupButton];
}

- (void)hideJSONPopupButton {
    [self.jsonPopupButton removeFromSuperview];
}

- (void)_handleJSONPopupButton {
    LKDashboardAttributeJsonView *view = (LKDashboardAttributeJsonView *)[self.attrViews pickview_firstFiltered:^BOOL(LKDashboardAttributeView *obj) {
        return obj.attribute.attrType == PVAttrTypeJson;
    }];
    if (![view isKindOfClass:[LKDashboardAttributeJsonView class]]) {
        NSAssert(NO, @"");
        return;
    }
    [view showInNewWindow];
}

#pragma mark - Manage

- (void)setManageState:(LKDashboardSectionManageState)manageState {
    _manageState = manageState;
    if (manageState == LKDashboardSectionManageState_None) {
        self.manageButton.hidden = YES;
        [self setNeedsLayout:YES];
        return;
    }
    
    NSImage *image = nil;
    if (manageState == LKDashboardSectionManageState_CanAdd) {
        image = NSImageMake(@"icon_manage_add");
    } else if (manageState == LKDashboardSectionManageState_CanRemove) {
        image = NSImageMake(@"icon_manage_remove");
    } else {
        NSAssert(NO, @"");
        return;
    }
    
    if (self.manageButton) {
        self.manageButton.image = image;
        self.manageButton.hidden = NO;
    } else {
        self.manageButton = [NSButton buttonWithImage:image target:self action:@selector(_handleManageButton)];
        self.manageButton.bezelStyle = NSBezelStyleRoundRect;
        self.manageButton.bordered = NO;
        [self addSubview:self.manageButton];
    }
    [self setNeedsLayout:YES];
}

- (void)_handleManageButton {
    LKPreferenceManager *manager = [LKPreferenceManager mainManager];
    if (self.manageState == LKDashboardSectionManageState_CanAdd) {
        [manager showSection:self.attrSection.identifier];
    } else if (self.manageState == LKDashboardSectionManageState_CanRemove) {
        [manager hideSection:self.attrSection.identifier];
    } else {
        NSAssert(NO, @"");
    }
}

- (NSString *)resolveSectionTitle {
    if (!self.attrSection.isUserCustom) {
        return [PickViewDashboardBlueprint sectionTitleWithSectionID:self.attrSection.identifier];
    }
    PVAttribute *attr = self.attrSection.attributes.firstObject;
    if (!attr) {
        NSAssert(NO, @"");
        return nil;
    }
    switch (attr.attrType) {
        case PVAttrTypeBOOL:
            return nil;
        default:
            return attr.displayTitle;
    }
}

@end

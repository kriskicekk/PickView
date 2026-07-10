//
//  PVDetailDashboardCardView.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailDashboardCardView.h"
#import "PVAttributesGroup.h"
#import "PVAttributesSection.h"
#import "PVDetailDashboardAttributeNumberInputView.h"
#import "PVDetailDashboardAttributeSwitchView.h"
#import "PVDetailDashboardAttributeColorView.h"
#import "PVDetailDashboardAttributeEnumsView.h"
#import "PVDetailDashboardViewController.h"
#import "PVDetailDashboardSectionView.h"
#import "PVDashboardBlueprint.h"
#import "PVDetailPreferenceManager.h"
#import "PVDetailDashboardCardTitleControl.h"
#import "PVDetailDashboardAccessoryWindowController.h"
#import "PVDetailUserActionManager.h"
#import "PVAttributesGroup+PVClient.h"
#import "PVAttributesSection+PVClient.h"
#import "PVDetailDashboardSectionViewPool.h"

@interface PVDetailDashboardCardView () <PVDetailUserActionManagerDelegate, PVDetailDashboardAccessoryWindowControllerDelegate>

@property(nonatomic, strong) PVDetailVisualEffectView *backgroundEffectView;
@property(nonatomic, strong) PVDetailDashboardCardTitleControl *titleControl;
@property(nonatomic, strong) NSButton *detailButton;
@property(nonatomic, strong) NSButton *relationHelpButton;

@property(nonatomic, strong) PVDetailBaseView *fadeView;

@property(nonatomic, strong) PVDetailDashboardSectionViewPool *sectionViewPool;
@property(nonatomic, strong) NSMutableArray<PVDetailDashboardSectionView *> *sectionViews;

@property(nonatomic, strong) PVDetailDashboardAccessoryWindowController *accessoryWC;


@end

@implementation PVDetailDashboardCardView {
    CGFloat _titleHeight;
    CGFloat _contentsY;
    CGFloat _insetBottom;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        _titleHeight = 30;
        _contentsY = 35;
        _insetBottom = 12;
        self.sectionViews = [NSMutableArray array];
        
        self.layer.cornerRadius = DashboardCardCornerRadius;
        
        self.backgroundEffectView = [PVDetailVisualEffectView new];
        self.backgroundEffectView.blendingMode = NSVisualEffectBlendingModeWithinWindow;
        self.backgroundEffectView.state = NSVisualEffectStateActive;
        [self addSubview:self.backgroundEffectView];
 
        self.titleControl = [PVDetailDashboardCardTitleControl new];
        [self.titleControl addTarget:self clickAction:@selector(_handleClickTitle)];
        [self addSubview:self.titleControl];
        
        self.detailButton = [NSButton buttonWithImage:NSImageMake(@"icon_more") target:self action:@selector(_handleClickDetailButton)];
        self.detailButton.bezelStyle = NSBezelStyleRoundRect;
        self.detailButton.bordered = NO;
        [self addSubview:self.detailButton];
        
        self.sectionViewPool = [PVDetailDashboardSectionViewPool new];
        
        [self updateColors];
        
        [[PVDetailUserActionManager sharedInstance] addDelegate:self];
    }
    return self;
}

- (void)layout {
    [super layout];
    
    $(self.backgroundEffectView).fullFrame;
    $(self.titleControl).fullWidth.height(_titleHeight).y(0);
    if (self.detailButton.isVisible) {
        $(self.detailButton).width(50).height(28).right(-3).y(0);
    }
    if (self.relationHelpButton.isVisible) {
        $(self.relationHelpButton).width(30).height(28).right(5).y(0);
    }
    
    if (!self.attrGroup || !self.sectionViews.count) {
        return;
    }
    
    __block CGFloat y = _contentsY;
    [self.sectionViews enumerateObjectsUsingBlock:^(PVDetailDashboardSectionView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        $(view).x(DashboardHorInset).toRight(DashboardHorInset).heightToFit.y(y);
        y = view.$maxY + DashboardSectionMarginTop;
    }];
}

- (CGSize)sizeThatFits:(NSSize)limitedSize {
    if (self.isCollapsed) {
        limitedSize.height = _titleHeight;
        return limitedSize;
    }
    limitedSize.width -= DashboardHorInset * 2;
    __block CGFloat height = _contentsY;
    [self.sectionViews enumerateObjectsUsingBlock:^(PVDetailDashboardSectionView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat sectionHeight = [obj sizeThatFits:limitedSize].height;
        height += (sectionHeight + DashboardSectionMarginTop);
    }];
    height -= DashboardSectionMarginTop;
    height += _insetBottom;
    
    limitedSize.height = height;
    return limitedSize;
}

- (void)render {
    if (!self.attrGroup) {
        NSAssert(NO, @"");
        return;
    }
    if ([self.attrGroup.identifier isEqualToString:PVAttrGroup_Class]) {
        _contentsY = 28;
    } else if ([self.attrGroup.identifier isEqualToString:PVAttrGroup_Relation]) {
        _contentsY = 30;
    } else {
        _contentsY = 35;
    }
    
    self.titleControl.label.stringValue = [self.attrGroup queryDisplayTitle];
    self.titleControl.iconImageView.image = [PVDetailDashboardCardView imageWithAttrGroup:self.attrGroup];
    [self.titleControl setNeedsLayout:YES];
    
    self.detailButton.hidden = ![self _shouldShowDetailButtonWithGroupID:self.attrGroup.identifier];
    
    [self.sectionViews enumerateObjectsUsingBlock:^(PVDetailDashboardSectionView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    [self.sectionViews removeAllObjects];
    [self.sectionViewPool recycleAll];

    [self.attrGroup.attrSections enumerateObjectsUsingBlock:^(PVAttributesSection * _Nonnull sec, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!sec.isUserCustom && ![[PVDetailPreferenceManager mainManager] isSectionShowing:sec.identifier]) {
            return;
        }
        
        PVDetailDashboardSectionView *secView = [self.sectionViewPool dequeViewForSection:sec];
        [self.sectionViews addObject:secView];
        [self addSubview:secView];
        secView.dashboardViewController = self.dashboardViewController;
        secView.attrSection = sec;
        secView.showTopSeparator = (idx > 0);
        
        if (self.accessoryWC) {
            secView.manageState = PVDetailDashboardSectionManageState_CanRemove;
        } else {
            secView.manageState = PVDetailDashboardSectionManageState_None;
        }
    }];
    
    if (self.accessoryWC) {
        [self _renderAccessoryWindowController];
    }
    
    if ([self.attrGroup.identifier isEqualToString:PVAttrGroup_Relation]) {
        [self showRelationHelpButton];
    } else {
        [self hideRelationHelpButton];
    }
    
    [self setNeedsLayout:YES];
}

- (void)setIsCollapsed:(BOOL)isCollapsed {
    _isCollapsed = isCollapsed;
    self.titleControl.disclosureImageView.image = isCollapsed ? NSImageMake(@"icon_arrow_right") : NSImageMake(@"icon_arrow_down");
}

- (void)playFadeAnimationWithHighlightRect:(CGRect)rect {
    if (self.fadeView) {
        return;
    }

    self.fadeView = [PVDetailBaseView new];
    self.fadeView.backgroundColor = self.isDarkMode ? PVColorRGBAMake(0, 0, 0, .7) : PVColorRGBAMake(0, 0, 0, .6);
    self.fadeView.alphaValue = 0;
    self.fadeView.frame = self.bounds;
    [self addSubview:self.fadeView];

    
    if (!CGRectEqualToRect(rect, CGRectZero)) {
        CGFloat totalHeight = self.fadeView.$height;
        if (totalHeight <= 0) {
            NSAssert(NO, @"");
            totalHeight = 1;
        }

        CAGradientLayer *maskLayer = [CAGradientLayer layer];
        maskLayer.colors = @[(id)[NSColor blackColor].CGColor,
                             (id)[NSColor blackColor].CGColor,
                             (id)[[NSColor clearColor] CGColor],
                             (id)[[NSColor clearColor] CGColor],
                             (id)[NSColor blackColor].CGColor,
                             (id)[NSColor blackColor].CGColor];
        maskLayer.startPoint = CGPointMake(0, 0);
        maskLayer.endPoint = CGPointMake(0, 1);
        maskLayer.locations = @[@0,
                                @((CGRectGetMinY(rect) - 4) / totalHeight),
                                @((CGRectGetMinY(rect) + 10) / totalHeight),
                                @((CGRectGetMaxY(rect) + 2) / totalHeight),
                                @((CGRectGetMaxY(rect) + 16) / totalHeight),
                                @1];
        maskLayer.frame = self.fadeView.bounds;
        self.fadeView.layer.mask = maskLayer;
    }
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        context.duration = .3;
        self.fadeView.animator.alphaValue = 1;
    } completionHandler:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self _removeFadeAnimation];
        });
    }];
}

- (void)_removeFadeAnimation {
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        context.duration = .3;
        self.fadeView.animator.alphaValue = 0;
    } completionHandler:^{
        [self.fadeView removeFromSuperview];
        self.fadeView = nil;
    }];
}

- (void)_handleClickTitle {
    if ([self.delegate respondsToSelector:@selector(dashboardCardViewNeedToggleCollapse:)]) {
        [self.delegate dashboardCardViewNeedToggleCollapse:self];
    }
}

+ (NSImage *)imageWithAttrGroup:(PVAttributesGroup *)group {
    static dispatch_once_t onceToken;
    static NSDictionary<PVAttrGroupIdentifier, NSImage *> *dict = nil;
    dispatch_once(&onceToken,^{
        dict = @{
                 PVAttrGroup_Class: NSImageMake(@"dashboard_class"),
                 PVAttrGroup_Relation: NSImageMake(@"dashboard_relation"),
                 PVAttrGroup_Layout: NSImageMake(@"dashboard_layout"),
                 PVAttrGroup_AutoLayout: NSImageMake(@"dashboard_autolayout"),
                 PVAttrGroup_ViewLayer: NSImageMake(@"dashboard_layer"),
                 PVAttrGroup_UIImageView: NSImageMake(@"dashboard_imageview"),
                 PVAttrGroup_UILabel: NSImageMake(@"dashboard_label"),
                 PVAttrGroup_UIButton: NSImageMake(@"dashboard_button"),
                 PVAttrGroup_UIControl: NSImageMake(@"dashboard_control"),
                 PVAttrGroup_UIScrollView: NSImageMake(@"dashboard_scrollview"),
                 PVAttrGroup_UITableView: NSImageMake(@"dashboard_tableview"),
                 PVAttrGroup_UITextView: NSImageMake(@"dashboard_textview"),
                 PVAttrGroup_UITextField: NSImageMake(@"dashboard_textfield"),
                 PVAttrGroup_UIVisualEffectView: NSImageMake(@"dashboard_effectview"),
                 PVAttrGroup_UIStackView: NSImageMake(@"dashboard_stackview"),
                 PVAttrGroup_NSImageView: NSImageMake(@"dashboard_imageview"),
                 PVAttrGroup_NSControl: NSImageMake(@"dashboard_control"),
                 PVAttrGroup_NSButton: NSImageMake(@"dashboard_button"),
                 PVAttrGroup_NSScrollView: NSImageMake(@"dashboard_scrollview"),
                 PVAttrGroup_NSTableView: NSImageMake(@"dashboard_tableview"),
                 PVAttrGroup_NSTextView: NSImageMake(@"dashboard_textview"),
                 PVAttrGroup_NSTextField: NSImageMake(@"dashboard_textfield"),
                 PVAttrGroup_NSVisualEffectView: NSImageMake(@"dashboard_effectview"),
                 PVAttrGroup_NSStackView: NSImageMake(@"dashboard_stackview"),
                 PVAttrGroup_NSWindow: NSImageMake(@"dashboard_layer"),
                 PVAttrGroup_UIWindowScene: NSImageMake(@"dashboard_layer"),
                 PVAttrGroup_UITraitCollection: NSImageMake(@"dashboard_layer"),
                 PVAttrGroup_UserCustom: NSImageMake(@"dashboard_custom")
                 };
    });
    NSImage *image = dict[group.identifier];
    NSAssert(image, @"");
    return image;
}

- (PVDetailDashboardSectionView *)querySectionViewWithSection:(PVAttributesSection *)sec {
    return [self.sectionViews pv_inspect_firstFiltered:^BOOL(PVDetailDashboardSectionView *obj) {
        return obj.attrSection == sec;
    }];
}

- (void)showRelationHelpButton {
    if (!self.relationHelpButton) {
        self.relationHelpButton = [NSButton buttonWithImage:NSImageMake(@"ic_question") target:self action:@selector(_handleRelationHelpButton)];
        self.relationHelpButton.bezelStyle = NSBezelStyleRoundRect;
        self.relationHelpButton.bordered = NO;
        [self addSubview:self.detailButton];
    }
    [self addSubview:self.relationHelpButton];
}

- (void)hideRelationHelpButton {
    [self.relationHelpButton removeFromSuperview];
}

#pragma mark - Others

- (void)mouseDown:(NSEvent *)event {
    [super mouseDown:event];
    [[PVDetailUserActionManager sharedInstance] sendAction:PVDetailUserActionType_DashboardClick];
}

#pragma mark - <PVDetailUserActionManagerDelegate>

- (void)PVDetailUserActionManager:(PVDetailUserActionManager *)manager didAct:(PVDetailUserActionType)type {
    if (!self.accessoryWC) {
        return;
    }
    NSArray<NSNumber *> *validTypes = @[@(PVDetailUserActionType_PreviewOperation), @(PVDetailUserActionType_DashboardClick), @(PVDetailUserActionType_SelectedItemChange)];
    if (![validTypes containsObject:@(type)]) {
        return;
    }
    [self.accessoryWC close];
}

#pragma mark - Accessory

- (void)_handleClickDetailButton {
    if (self.accessoryWC) {
        [self.accessoryWC close];
        return;
    }
    
    [[PVDetailUserActionManager sharedInstance] sendAction:PVDetailUserActionType_DashboardClick];
    
    if (self.isCollapsed) {
        /// 如果当前是折叠状态，则展开
        if ([self.delegate respondsToSelector:@selector(dashboardCardViewNeedToggleCollapse:)]) {
            [self.delegate dashboardCardViewNeedToggleCollapse:self];
        }
    }
    
    self.accessoryWC = [[PVDetailDashboardAccessoryWindowController alloc] initWithDashboardController:self.dashboardViewController attrGroupID:self.attrGroup.identifier];
    self.accessoryWC.delegate = self;
    
    [self _renderAccessoryWindowController];
    
    [self.window addChildWindow:self.accessoryWC.window ordered:NSWindowAbove];
}

- (void)_renderAccessoryWindowController {
    if (!self.accessoryWC) {
        NSAssert(NO, @"");
        return;
    }
    
    [self.sectionViews enumerateObjectsUsingBlock:^(PVDetailDashboardSectionView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.manageState = PVDetailDashboardSectionManageState_CanRemove;
    }];
    
    NSArray<PVAttrSectionIdentifier> *allSecIDs = [PVDashboardBlueprint sectionIDsForGroupID:self.attrGroup.identifier];
    NSArray<PVAttrSectionIdentifier> *hiddenSecIDs = [allSecIDs pv_inspect_filter:^BOOL(PVAttrSectionIdentifier obj) {
        return ![[PVDetailPreferenceManager mainManager] isSectionShowing:obj];
    }];
    if (hiddenSecIDs.count == 0) {
        self.accessoryWC.window.contentView.hidden = YES;
        return;
    }
    self.accessoryWC.window.contentView.hidden = NO;
    
    NSArray<PVAttributesSection *> *sections = [hiddenSecIDs pv_inspect_map:^id(NSUInteger idx, PVAttrSectionIdentifier secID) {
        PVAttributesSection *sec = [self.attrGroup.attrSections pv_inspect_firstFiltered:^BOOL(PVAttributesSection *obj) {
            return [obj.identifier isEqualToString:secID];
        }];
        return sec;
    }];
    
    NSSize contentSize = [self.accessoryWC renderWithAttrSections:sections];
    
    // 这里是左上角坐标系，比如 cardView 顶部恰好和窗口顶部重合时，y 为 0
    CGRect selfFrameInWindow = [self.window.contentView convertRect:self.frame fromView:self.superview];
    // 这里是左下角坐标系
    CGRect selfWindowFrame = self.window.frame;
    // 做个 MAX 以防止超出下边缘屏幕
    CGFloat panelY = MAX(selfWindowFrame.origin.y + (selfWindowFrame.size.height - selfFrameInWindow.origin.y) - contentSize.height, 0);
    CGFloat panelX = CGRectGetMaxX(selfWindowFrame) + 5;
    CGFloat panelMaxX = panelX + contentSize.width;
    if (panelMaxX > self.window.screen.frame.size.width) {
        // 防止超出屏幕右侧
        panelX = selfWindowFrame.origin.x + CGRectGetMinX(selfFrameInWindow) - contentSize.width - 5;
    }
    CGRect panelFrame = CGRectMake(panelX, panelY, contentSize.width, contentSize.height);
    // panelFrame 是左下角坐标系。虽然这里的 controller.window 是 self.window 的 childWindow，但 panelFrame 仍然是相对于 screen 的坐标，换句话说，如果 panelFrame.y 是 0，则 panel 的底部会和屏幕底部重合
    [self.accessoryWC.window setFrame:panelFrame display:YES];
}

- (void)dashboardAccessoryWindowControllerWillClose:(PVDetailDashboardAccessoryWindowController *)controller {
    [self.sectionViews enumerateObjectsUsingBlock:^(PVDetailDashboardSectionView * _Nonnull secView, NSUInteger idx, BOOL * _Nonnull stop) {
        secView.manageState = PVDetailDashboardSectionManageState_None;
    }];
    self.accessoryWC = nil;
}

- (BOOL)_shouldShowDetailButtonWithGroupID:(PVAttrGroupIdentifier)identifier {
    if ([identifier isEqualToString:PVAttrGroup_UserCustom]) {
        return NO;
    }
    NSUInteger sectionCount = [PVDashboardBlueprint sectionIDsForGroupID:identifier].count;
    if (sectionCount > 1) {
        return YES;
    } else {
        return NO;
    }
}

- (void)_handleRelationHelpButton {
    NSMenu *menu = [NSMenu new];
    
    NSMenuItem *menuItem = [NSMenuItem new];
    menuItem.image = NSImageMake(@"Icon_Inspiration_small");
    menuItem.title = NSLocalizedString(@"How to display more member variables…", nil);
    menuItem.target = self;
    menuItem.action = @selector(handleRelationDocument);
    [menu addItem:menuItem];
    
    [NSMenu popUpContextMenu:menu withEvent:NSApplication.sharedApplication.currentEvent forView:self.relationHelpButton];
}

- (void)handleRelationDocument {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://bytedance.larkoffice.com/docx/CKRndHqdeoub11xSqUZcMlFhnWe"]];
}

@end

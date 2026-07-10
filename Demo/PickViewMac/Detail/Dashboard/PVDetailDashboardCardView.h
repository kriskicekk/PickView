//
//  PVDetailDashboardCardView.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailBaseView.h"
#import "PVDisplayItem.h"
#import "PVDetailDashboardAttributeView.h"

@class PVDetailDashboardViewController, PVDetailDashboardCardView, PVDetailDashboardSectionView;

@protocol PVDetailDashboardCardViewDelegate <NSObject>

- (void)dashboardCardViewNeedToggleCollapse:(PVDetailDashboardCardView *)view;

@end

@interface PVDetailDashboardCardView : PVDetailBaseView

@property(nonatomic, weak) PVDetailDashboardViewController *dashboardViewController;

@property(nonatomic, weak) id<PVDetailDashboardCardViewDelegate> delegate;

/// 用来渲染的数据，设置该属性并不会触发任何渲染之类的行为
@property(nonatomic, strong) PVAttributesGroup *attrGroup;
/// 使用 attrGroup 属性来渲染
- (void)render;

@property(nonatomic, assign) BOOL isCollapsed;

- (PVDetailDashboardSectionView *)querySectionViewWithSection:(PVAttributesSection *)sec;

/// 如果 rect 为 CGRectZero，则会全部变暗
- (void)playFadeAnimationWithHighlightRect:(CGRect)rect;

@end

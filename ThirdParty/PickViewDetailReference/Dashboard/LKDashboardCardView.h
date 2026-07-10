//
//  LKDashboardCardView.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "LKBaseView.h"
#import "PickViewDisplayItem.h"
#import "LKDashboardAttributeView.h"

@class LKDashboardViewController, LKDashboardCardView, LKDashboardSectionView;

@protocol LKDashboardCardViewDelegate <NSObject>

- (void)dashboardCardViewNeedToggleCollapse:(LKDashboardCardView *)view;

@end

@interface LKDashboardCardView : LKBaseView

@property(nonatomic, weak) LKDashboardViewController *dashboardViewController;

@property(nonatomic, weak) id<LKDashboardCardViewDelegate> delegate;

/// 用来渲染的数据，设置该属性并不会触发任何渲染之类的行为
@property(nonatomic, strong) PVAttributesGroup *attrGroup;
/// 使用 attrGroup 属性来渲染
- (void)render;

@property(nonatomic, assign) BOOL isCollapsed;

- (LKDashboardSectionView *)querySectionViewWithSection:(PVAttributesSection *)sec;

/// 如果 rect 为 CGRectZero，则会全部变暗
- (void)playFadeAnimationWithHighlightRect:(CGRect)rect;

@end

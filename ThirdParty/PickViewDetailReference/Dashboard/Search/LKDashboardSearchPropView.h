//
//  LKDashboardSearchPropView.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "LKDashboardSearchCardView.h"
#import "PVAttrIdentifiers.h"

@class PVAttribute, LKDashboardSearchPropView;

@protocol LKDashboardSearchPropViewDelegate <NSObject>

- (void)dashboardSearchPropView:(LKDashboardSearchPropView *)view didClickRevealAttribute:(PVAttribute *)attr;

@end

@interface LKDashboardSearchPropView : LKDashboardSearchCardView

@property(nonatomic, weak) id<LKDashboardSearchPropViewDelegate> delegate;

- (void)renderWithAttribute:(PVAttribute *)attribute;

@end

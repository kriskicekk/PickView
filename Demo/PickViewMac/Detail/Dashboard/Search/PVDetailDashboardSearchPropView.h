//
//  PVDetailDashboardSearchPropView.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailDashboardSearchCardView.h"
#import "PVAttrIdentifiers.h"

@class PVAttribute, PVDetailDashboardSearchPropView;

@protocol PVDetailDashboardSearchPropViewDelegate <NSObject>

- (void)dashboardSearchPropView:(PVDetailDashboardSearchPropView *)view didClickRevealAttribute:(PVAttribute *)attr;

@end

@interface PVDetailDashboardSearchPropView : PVDetailDashboardSearchCardView

@property(nonatomic, weak) id<PVDetailDashboardSearchPropViewDelegate> delegate;

- (void)renderWithAttribute:(PVAttribute *)attribute;

@end

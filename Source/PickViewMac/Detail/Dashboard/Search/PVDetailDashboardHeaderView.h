//
//  PVDetailDashboardHeaderView.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailBaseView.h"

@class PVDetailDashboardHeaderView;

@protocol PVDetailDashboardHeaderViewDelegate <NSObject>

- (void)dashboardHeaderView:(PVDetailDashboardHeaderView *)view didToggleActive:(BOOL)isActive;

- (void)dashboardHeaderView:(PVDetailDashboardHeaderView *)view didInputString:(NSString *)string;

@end

@interface PVDetailDashboardHeaderView : PVDetailBaseView

@property(nonatomic, assign) BOOL isActive;

- (NSString *)currentInputString;

@property(nonatomic, weak) id<PVDetailDashboardHeaderViewDelegate> delegate;

@end

//
//  LKDashboardHeaderView.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "LKBaseView.h"

@class LKDashboardHeaderView;

@protocol LKDashboardHeaderViewDelegate <NSObject>

- (void)dashboardHeaderView:(LKDashboardHeaderView *)view didToggleActive:(BOOL)isActive;

- (void)dashboardHeaderView:(LKDashboardHeaderView *)view didInputString:(NSString *)string;

@end

@interface LKDashboardHeaderView : LKBaseView

@property(nonatomic, assign) BOOL isActive;

- (NSString *)currentInputString;

@property(nonatomic, weak) id<LKDashboardHeaderViewDelegate> delegate;

@end

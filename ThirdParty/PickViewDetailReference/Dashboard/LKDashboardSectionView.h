//
//  LKDashboardSectionView.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "LKBaseView.h"

@class PVAttributesSection, LKDashboardViewController;

typedef NS_ENUM(NSInteger, LKDashboardSectionManageState) {
    LKDashboardSectionManageState_None,
    LKDashboardSectionManageState_CanAdd,
    LKDashboardSectionManageState_CanRemove
};

@interface LKDashboardSectionView : LKBaseView

@property(nonatomic, strong) PVAttributesSection *attrSection;

@property(nonatomic, assign) BOOL showTopSeparator;

@property(nonatomic, weak) LKDashboardViewController *dashboardViewController;

@property(nonatomic, assign) LKDashboardSectionManageState manageState;

@end

//
//  PVDetailDashboardSectionView.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailBaseView.h"

@class PVAttributesSection, PVDetailDashboardViewController;

typedef NS_ENUM(NSInteger, PVDetailDashboardSectionManageState) {
    PVDetailDashboardSectionManageState_None,
    PVDetailDashboardSectionManageState_CanAdd,
    PVDetailDashboardSectionManageState_CanRemove
};

@interface PVDetailDashboardSectionView : PVDetailBaseView

@property(nonatomic, strong) PVAttributesSection *attrSection;

@property(nonatomic, assign) BOOL showTopSeparator;

@property(nonatomic, weak) PVDetailDashboardViewController *dashboardViewController;

@property(nonatomic, assign) PVDetailDashboardSectionManageState manageState;

@end

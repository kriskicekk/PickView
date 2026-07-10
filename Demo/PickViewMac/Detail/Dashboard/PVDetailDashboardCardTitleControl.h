//
//  PVDetailDashboardCardTitleControl.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailBaseControl.h"

@interface PVDetailDashboardCardTitleControl : PVDetailBaseControl

@property(nonatomic, strong, readonly) NSImageView *iconImageView;
@property(nonatomic, strong, readonly) PVDetailLabel *label;
@property(nonatomic, strong, readonly) NSImageView *disclosureImageView;

@end

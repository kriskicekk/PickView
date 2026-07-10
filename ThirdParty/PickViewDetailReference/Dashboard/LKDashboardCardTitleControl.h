//
//  LKDashboardCardTitleControl.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "LKBaseControl.h"

@interface LKDashboardCardTitleControl : LKBaseControl

@property(nonatomic, strong, readonly) NSImageView *iconImageView;
@property(nonatomic, strong, readonly) LKLabel *label;
@property(nonatomic, strong, readonly) NSImageView *disclosureImageView;

@end

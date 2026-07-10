//
//  LKDashboardAttributeConstraintsItemControl.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "LKTextControl.h"

@class PickViewAutoLayoutConstraint;

@interface LKDashboardAttributeConstraintsItemControl : LKTextControl

@property(nonatomic, strong) PickViewAutoLayoutConstraint *constraint;

@end

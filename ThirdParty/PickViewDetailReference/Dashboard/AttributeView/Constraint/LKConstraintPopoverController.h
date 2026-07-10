//
//  LKConstraintPopoverController.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "LKBaseViewController.h"

@class PickViewAutoLayoutConstraint, LKHierarchyDataSource, PickViewObject;

@interface LKConstraintPopoverController : LKBaseViewController

- (instancetype)initWithConstraint:(PickViewAutoLayoutConstraint *)constraint;

- (NSSize)contentSize;

@property(nonatomic, copy) void (^requestJumpingToObject)(PickViewObject *pickviewObj);

@end

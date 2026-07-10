//
//  PVDetailConstraintPopoverController.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailBaseViewController.h"

@class PVAutoLayoutConstraint, PVDetailHierarchyDataSource, PVObject;

@interface PVDetailConstraintPopoverController : PVDetailBaseViewController

- (instancetype)initWithConstraint:(PVAutoLayoutConstraint *)constraint;

- (NSSize)contentSize;

@property(nonatomic, copy) void (^requestJumpingToObject)(PVObject *pickviewObj);

@end

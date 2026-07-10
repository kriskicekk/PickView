//
//  LKHierarchyHandlersPopoverController.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "LKBaseViewController.h"

@class PickViewDisplayItem;

@interface LKHierarchyHandlersPopoverController : LKBaseViewController

- (instancetype)initWithDisplayItem:(PickViewDisplayItem *)item editable:(BOOL)editable;

- (NSSize)neededSize;

@end

//
//  PVDetailHierarchyHandlersPopoverController.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailBaseViewController.h"

@class PVDisplayItem;

@interface PVDetailHierarchyHandlersPopoverController : PVDetailBaseViewController

- (instancetype)initWithDisplayItem:(PVDisplayItem *)item editable:(BOOL)editable;

- (NSSize)neededSize;

@end

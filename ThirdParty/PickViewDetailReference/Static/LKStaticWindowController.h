//
//  LKStaticWindowController.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "LKWindowController.h"
#import "LKMenuPopoverAppsListController.h"

@class LKStaticViewController;

@interface LKStaticWindowController : LKWindowController

@property(nonatomic, strong, readonly) LKStaticViewController *viewController;

- (void)popupAllInspectableAppsWithSource:(MenuPopoverAppsListControllerEventSource)source;

@end

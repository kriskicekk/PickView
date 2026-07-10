//
//  PVDetailStaticWindowController.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailWindowController.h"
#import "PVDetailMenuPopoverAppsListController.h"

@class PVDetailStaticViewController;

@interface PVDetailStaticWindowController : PVDetailWindowController

@property(nonatomic, strong, readonly) PVDetailStaticViewController *viewController;

- (void)popupAllInspectableAppsWithSource:(MenuPopoverAppsListControllerEventSource)source;

@end

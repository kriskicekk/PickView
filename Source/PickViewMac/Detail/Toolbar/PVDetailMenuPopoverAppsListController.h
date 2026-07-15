//
//  PVDetailMenuPopoverAppsListController.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailBaseViewController.h"

@class PVDetailInspectableApp;

typedef NS_ENUM(NSInteger, MenuPopoverAppsListControllerEventSource) {
    MenuPopoverAppsListControllerEventSourceReloadButton,
    MenuPopoverAppsListControllerEventSourceNoConnectionTips,
    MenuPopoverAppsListControllerEventSourceAppButton
};

@interface PVDetailMenuPopoverAppsListController : PVDetailBaseViewController

- (instancetype)initWithApps:(NSArray<PVDetailInspectableApp *> *)apps source:(MenuPopoverAppsListControllerEventSource)source;

@property(nonatomic, copy) void (^didSelectApp)(PVDetailInspectableApp *app);

- (NSSize)bestSize;

@end

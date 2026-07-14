#import "PVFVMFlutterRuntime.h"
#import <Foundation/Foundation.h>

@class PVFVMFlutterTarget;

NS_ASSUME_NONNULL_BEGIN

@interface PVFVMFlutterEngineLocator : NSObject

+ (instancetype)sharedLocator;

- (void)registerEngine:(FlutterEngine *)engine;
- (void)unregisterEngine:(FlutterEngine *)engine;

/// Returns every currently visible FlutterViewController as a separate target.
- (NSArray<PVFVMFlutterTarget *> *)visibleTargets;

/// Returns visible targets plus explicitly registered prewarmed/headless engines.
- (NSArray<PVFVMFlutterTarget *> *)allTargets;

/// Returns every FlutterViewController reachable from the current UIWindow
/// controller graphs, including non-visible controllers kept in container
/// stacks.
- (NSArray<FlutterViewController *> *)
    flutterViewControllersInWindowHierarchy;

- (PVFVMFlutterTarget *)targetForViewController:
    (FlutterViewController *)viewController;

@end

NS_ASSUME_NONNULL_END

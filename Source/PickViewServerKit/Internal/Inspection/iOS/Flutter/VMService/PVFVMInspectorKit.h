#import "PVFVMFlutterRuntime.h"
#import <Foundation/Foundation.h>

@class PVFVMEngineInspectorSession;
@class PVFVMFlutterEngineLocator;
@class PVFVMFlutterTarget;
@class PVFVMFlutterViewControllerRecord;
@class PVFVMFlutterViewControllerRegistry;

NS_ASSUME_NONNULL_BEGIN

@interface PVFVMInspectorKit : NSObject

+ (instancetype)sharedKit;

@property(nonatomic, readonly) PVFVMFlutterEngineLocator *engineLocator;
@property(nonatomic, readonly)
    PVFVMFlutterViewControllerRegistry *viewControllerRegistry;

- (void)registerEngine:(FlutterEngine *)engine;
- (void)unregisterEngine:(FlutterEngine *)engine;

/// Discovers FlutterViewControllers currently attached to visible UIKit trees.
- (NSArray<PVFVMFlutterTarget *> *)visibleTargets;

/// Includes visible targets and explicitly registered headless engines.
- (NSArray<PVFVMFlutterTarget *> *)allTargets;

/// Caches the exact FlutterViewController -> Engine -> Session relationship.
- (PVFVMFlutterViewControllerRecord *)
    registerViewController:(FlutterViewController *)viewController;

/// Explicit removal. Normal VC deallocation removes the record automatically.
- (void)unregisterViewController:(FlutterViewController *)viewController;

/// Returns the cached record, creating it lazily when needed.
- (PVFVMFlutterViewControllerRecord *)
    recordForViewController:(FlutterViewController *)viewController;

/// Traverses current UIWindow controller graphs and lazily caches every
/// FlutterViewController found there.
- (NSArray<PVFVMFlutterViewControllerRecord *> *)
    recordsInCurrentWindowHierarchy;

/// Maps a concrete Flutter page to its exact engine, without isolate guessing.
- (PVFVMFlutterTarget *)targetForViewController:
    (FlutterViewController *)viewController;

/// Sessions are isolated by FlutterEngine and UI isolate.
- (PVFVMEngineInspectorSession *)sessionForTarget:(PVFVMFlutterTarget *)target;

/// Convenience form of targetForViewController: followed by sessionForTarget:.
- (PVFVMEngineInspectorSession *)sessionForViewController:
    (FlutterViewController *)viewController;

@end

NS_ASSUME_NONNULL_END

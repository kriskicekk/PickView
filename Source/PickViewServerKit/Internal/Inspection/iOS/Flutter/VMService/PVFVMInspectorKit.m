#import "PVFVMInspectorKit.h"

#import "PVFVMEngineInspectorSession.h"
#import "PVFVMFlutterEngineLocator.h"
#import "PVFVMFlutterTarget.h"
#import "PVFVMFlutterViewControllerRecord.h"
#import "PVFVMFlutterViewControllerRegistry.h"

@interface PVFVMFlutterViewControllerRegistry (PVFVMInspectorKitInternal)
- (PVFVMFlutterViewControllerRecord *)
    registerViewController:(FlutterViewController *)viewController
                     target:(PVFVMFlutterTarget *)target
                    session:(PVFVMEngineInspectorSession *)session;
- (void)unregisterViewController:(FlutterViewController *)viewController;
@end

@interface PVFVMInspectorKit ()
@property(nonatomic, readwrite) PVFVMFlutterEngineLocator *engineLocator;
@property(nonatomic, readwrite)
    PVFVMFlutterViewControllerRegistry *viewControllerRegistry;
@property(nonatomic)
    NSMapTable<FlutterEngine *, PVFVMEngineInspectorSession *> *sessions;
@end

@implementation PVFVMInspectorKit

+ (instancetype)sharedKit {
  static PVFVMInspectorKit *kit;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    kit = [[self alloc] initPrivate];
  });
  return kit;
}

- (instancetype)initPrivate {
  self = [super init];
  if (self) {
    _engineLocator = PVFVMFlutterEngineLocator.sharedLocator;
    _viewControllerRegistry =
        [[PVFVMFlutterViewControllerRegistry alloc] init];
    _sessions = [NSMapTable weakToWeakObjectsMapTable];
  }
  return self;
}

- (instancetype)init {
  return PVFVMInspectorKit.sharedKit;
}

- (void)registerEngine:(FlutterEngine *)engine {
  [self.engineLocator registerEngine:engine];
}

- (void)unregisterEngine:(FlutterEngine *)engine {
  @synchronized(self.sessions) {
    PVFVMEngineInspectorSession *session = [self.sessions objectForKey:engine];
    [session close];
    [self.sessions removeObjectForKey:engine];
  }
  [self.engineLocator unregisterEngine:engine];
}

- (NSArray<PVFVMFlutterTarget *> *)visibleTargets {
  return self.engineLocator.visibleTargets;
}

- (NSArray<PVFVMFlutterTarget *> *)allTargets {
  return self.engineLocator.allTargets;
}

- (PVFVMFlutterViewControllerRecord *)
    registerViewController:(FlutterViewController *)viewController {
  PVFVMFlutterViewControllerRecord *existing =
      [self.viewControllerRegistry
          existingRecordForViewController:viewController];
  if (existing != nil) {
    return existing;
  }
  PVFVMFlutterTarget *target =
      [self.engineLocator targetForViewController:viewController];
  PVFVMEngineInspectorSession *session = [self sessionForTarget:target];
  return [self.viewControllerRegistry registerViewController:viewController
                                                      target:target
                                                     session:session];
}

- (void)unregisterViewController:(FlutterViewController *)viewController {
  [self.viewControllerRegistry unregisterViewController:viewController];
}

- (PVFVMFlutterViewControllerRecord *)
    recordForViewController:(FlutterViewController *)viewController {
  PVFVMFlutterViewControllerRecord *record =
      [self.viewControllerRegistry
          existingRecordForViewController:viewController];
  return record ?: [self registerViewController:viewController];
}

- (NSArray<PVFVMFlutterViewControllerRecord *> *)
    recordsInCurrentWindowHierarchy {
  NSArray<FlutterViewController *> *viewControllers =
      self.engineLocator.flutterViewControllersInWindowHierarchy;
  NSMutableArray<PVFVMFlutterViewControllerRecord *> *records =
      [NSMutableArray arrayWithCapacity:viewControllers.count];
  for (FlutterViewController *viewController in viewControllers) {
    [records addObject:[self recordForViewController:viewController]];
  }
  return records;
}

- (PVFVMFlutterTarget *)targetForViewController:
    (FlutterViewController *)viewController {
  return [self.engineLocator targetForViewController:viewController];
}

- (PVFVMEngineInspectorSession *)sessionForTarget:(PVFVMFlutterTarget *)target {
  @synchronized(self.sessions) {
    PVFVMEngineInspectorSession *session =
        [self.sessions objectForKey:target.engine];
    if (session != nil &&
        (session.isolateID.length == 0 || target.isolateID.length == 0 ||
         [session.isolateID isEqualToString:target.isolateID])) {
      return session;
    }
    [session close];
    session = [[PVFVMEngineInspectorSession alloc] initWithTarget:target];
    [self.sessions setObject:session forKey:target.engine];
    return session;
  }
}

- (PVFVMEngineInspectorSession *)sessionForViewController:
    (FlutterViewController *)viewController {
  return [self recordForViewController:viewController].session;
}

@end

#import "PVFVMFlutterEngineLocator.h"

#import "PVFVMFlutterTarget.h"

@interface PVFVMFlutterTarget (PVFVMFlutterEngineLocatorInternal)
- (instancetype)initWithEngine:(FlutterEngine *)engine
                 viewController:(nullable FlutterViewController *)viewController
                         visible:(BOOL)visible
                      registered:(BOOL)registered
                   frameInWindow:(CGRect)frameInWindow;
@end

@interface PVFVMFlutterEngineLocator ()
@property(nonatomic) NSHashTable<FlutterEngine *> *registeredEngines;
@end

@implementation PVFVMFlutterEngineLocator

+ (instancetype)sharedLocator {
  static PVFVMFlutterEngineLocator *locator;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    locator = [[self alloc] initPrivate];
  });
  return locator;
}

- (instancetype)initPrivate {
  self = [super init];
  if (self) {
    _registeredEngines = [NSHashTable weakObjectsHashTable];
  }
  return self;
}

- (instancetype)init {
  return [PVFVMFlutterEngineLocator sharedLocator];
}

- (void)registerEngine:(FlutterEngine *)engine {
  if (engine == nil) {
    return;
  }
  [self performOnMainThread:^{
    [self.registeredEngines addObject:engine];
  }];
}

- (void)unregisterEngine:(FlutterEngine *)engine {
  if (engine == nil) {
    return;
  }
  [self performOnMainThread:^{
    [self.registeredEngines removeObject:engine];
  }];
}

- (NSArray<PVFVMFlutterTarget *> *)visibleTargets {
  __block NSArray<PVFVMFlutterTarget *> *targets;
  [self performOnMainThread:^{
    targets = [self buildTargetsIncludingRegistered:NO];
  }];
  return targets ?: @[];
}

- (NSArray<PVFVMFlutterTarget *> *)allTargets {
  __block NSArray<PVFVMFlutterTarget *> *targets;
  [self performOnMainThread:^{
    targets = [self buildTargetsIncludingRegistered:YES];
  }];
  return targets ?: @[];
}

- (NSArray<FlutterViewController *> *)
    flutterViewControllersInWindowHierarchy {
  __block NSArray<FlutterViewController *> *viewControllers;
  [self performOnMainThread:^{
    NSMutableArray<FlutterViewController *> *result = [NSMutableArray array];
    NSHashTable<UIViewController *> *seen = [NSHashTable
        hashTableWithOptions:NSPointerFunctionsObjectPointerPersonality];
    for (UIWindow *window in [self applicationWindows]) {
      if (window.rootViewController == nil) {
        continue;
      }
      [self collectFlutterViewControllersFrom:window.rootViewController
                                          into:result
                                          seen:seen];
    }
    viewControllers = result;
  }];
  return viewControllers ?: @[];
}

- (PVFVMFlutterTarget *)targetForViewController:
    (FlutterViewController *)viewController {
  __block PVFVMFlutterTarget *target;
  [self performOnMainThread:^{
    FlutterEngine *engine = viewController.engine;
    BOOL visible = [self isViewControllerVisible:viewController];
    target = [[PVFVMFlutterTarget alloc]
        initWithEngine:engine
         viewController:viewController
                 visible:visible
              registered:[self.registeredEngines containsObject:engine]
           frameInWindow:visible ? [self frameInWindowForViewController:
                                               viewController]
                                 : CGRectZero];
  }];
  return target;
}

- (NSArray<PVFVMFlutterTarget *> *)buildTargetsIncludingRegistered:
    (BOOL)includeRegistered {
  NSArray<FlutterViewController *> *visibleViewControllers =
      [self visibleFlutterViewControllers];
  NSMutableArray<PVFVMFlutterTarget *> *targets = [NSMutableArray array];
  NSHashTable<FlutterEngine *> *seen =
      [NSHashTable hashTableWithOptions:NSPointerFunctionsObjectPointerPersonality];

  for (FlutterViewController *viewController in visibleViewControllers) {
    FlutterEngine *engine = viewController.engine;
    if (engine == nil || [seen containsObject:engine]) {
      continue;
    }
    [seen addObject:engine];
    [targets addObject:[[PVFVMFlutterTarget alloc]
                           initWithEngine:engine
                            viewController:viewController
                                    visible:YES
                                 registered:[self.registeredEngines
                                                containsObject:engine]
                              frameInWindow:[self
                                                frameInWindowForViewController:
                                                    viewController]]];
  }

  if (includeRegistered) {
    for (FlutterEngine *engine in self.registeredEngines.allObjects) {
      if (engine == nil || [seen containsObject:engine]) {
        continue;
      }
      [seen addObject:engine];
      FlutterViewController *viewController = engine.viewController;
      BOOL visible = [self isViewControllerVisible:viewController];
      [targets addObject:[[PVFVMFlutterTarget alloc]
                             initWithEngine:engine
                              viewController:viewController
                                      visible:visible
                                   registered:YES
                                frameInWindow:visible
                                                  ? [self
                                                        frameInWindowForViewController:
                                                            viewController]
                                                  : CGRectZero]];
    }
  }
  return targets;
}

- (NSArray<FlutterViewController *> *)visibleFlutterViewControllers {
  NSMutableArray<FlutterViewController *> *result = [NSMutableArray array];
  NSHashTable<FlutterViewController *> *seen =
      [NSHashTable hashTableWithOptions:NSPointerFunctionsObjectPointerPersonality];
  for (UIWindow *window in [self applicationWindows]) {
    if (window.hidden || window.alpha <= 0.01 || window.rootViewController == nil) {
      continue;
    }
    [self collectVisibleFlutterViewControllersFrom:window.rootViewController
                                              into:result
                                              seen:seen];
  }
  return result;
}

- (NSArray<UIWindow *> *)applicationWindows {
  UIApplication *application = UIApplication.sharedApplication;
  NSMutableArray<UIWindow *> *windows = [NSMutableArray array];
  if (@available(iOS 13.0, *)) {
    for (UIScene *scene in application.connectedScenes) {
      if (![scene isKindOfClass:UIWindowScene.class] ||
          (scene.activationState != UISceneActivationStateForegroundActive &&
           scene.activationState != UISceneActivationStateForegroundInactive)) {
        continue;
      }
      [windows addObjectsFromArray:((UIWindowScene *)scene).windows];
    }
  } else {
    [windows addObjectsFromArray:application.windows];
  }
  [windows sortUsingComparator:^NSComparisonResult(UIWindow *left,
                                                    UIWindow *right) {
    if (left.isKeyWindow == right.isKeyWindow) {
      return NSOrderedSame;
    }
    return left.isKeyWindow ? NSOrderedAscending : NSOrderedDescending;
  }];
  return windows;
}

- (void)collectFlutterViewControllersFrom:(UIViewController *)controller
                                      into:(NSMutableArray *)result
                                      seen:(NSHashTable *)seen {
  if (controller == nil || [seen containsObject:controller]) {
    return;
  }
  [seen addObject:controller];

  if ([controller isKindOfClass:NSClassFromString(@"FlutterViewController")]) {
    [result addObject:(FlutterViewController *)controller];
  }

  if (controller.presentedViewController != nil) {
    [self collectFlutterViewControllersFrom:controller.presentedViewController
                                       into:result
                                       seen:seen];
  }
  if ([controller isKindOfClass:UINavigationController.class]) {
    for (UIViewController *item in
         ((UINavigationController *)controller).viewControllers) {
      [self collectFlutterViewControllersFrom:item into:result seen:seen];
    }
  }
  if ([controller isKindOfClass:UITabBarController.class]) {
    for (UIViewController *item in
         ((UITabBarController *)controller).viewControllers) {
      [self collectFlutterViewControllersFrom:item into:result seen:seen];
    }
  }
  if ([controller isKindOfClass:UISplitViewController.class]) {
    for (UIViewController *item in
         ((UISplitViewController *)controller).viewControllers) {
      [self collectFlutterViewControllersFrom:item into:result seen:seen];
    }
  }
  for (UIViewController *child in controller.childViewControllers) {
    [self collectFlutterViewControllersFrom:child into:result seen:seen];
  }
}

- (void)collectVisibleFlutterViewControllersFrom:(UIViewController *)controller
                                             into:(NSMutableArray *)result
                                             seen:(NSHashTable *)seen {
  UIViewController *presented = controller.presentedViewController;
  if (presented != nil && !presented.isBeingDismissed &&
      presented.viewIfLoaded.window != nil) {
    [self collectVisibleFlutterViewControllersFrom:presented
                                              into:result
                                              seen:seen];
    return;
  }

  if ([controller isKindOfClass:NSClassFromString(@"FlutterViewController")] &&
      [self isViewControllerVisible:controller] &&
      ![seen containsObject:controller]) {
    [seen addObject:(FlutterViewController *)controller];
    [result addObject:(FlutterViewController *)controller];
  }

  if ([controller isKindOfClass:UINavigationController.class]) {
    UIViewController *visible =
        ((UINavigationController *)controller).visibleViewController;
    if (visible != nil) {
      [self collectVisibleFlutterViewControllersFrom:visible
                                                into:result
                                                seen:seen];
    }
    return;
  }
  if ([controller isKindOfClass:UITabBarController.class]) {
    UIViewController *selected =
        ((UITabBarController *)controller).selectedViewController;
    if (selected != nil) {
      [self collectVisibleFlutterViewControllersFrom:selected
                                                into:result
                                                seen:seen];
    }
    return;
  }

  for (UIViewController *child in controller.childViewControllers) {
    if (child.viewIfLoaded.window == nil || child.viewIfLoaded.hidden ||
        child.viewIfLoaded.alpha <= 0.01) {
      continue;
    }
    [self collectVisibleFlutterViewControllersFrom:child
                                              into:result
                                              seen:seen];
  }
}

- (BOOL)isViewControllerVisible:(UIViewController *)viewController {
  UIView *view = viewController.viewIfLoaded;
  UIWindow *window = view.window;
  if (viewController == nil || window == nil || view.hidden ||
      view.alpha <= 0.01 || CGRectIsEmpty(view.bounds)) {
    return NO;
  }
  CGRect frame = [view convertRect:view.bounds toView:window];
  return CGRectIntersectsRect(frame, window.bounds);
}

- (CGRect)frameInWindowForViewController:(UIViewController *)viewController {
  UIView *view = viewController.viewIfLoaded;
  return view.window == nil ? CGRectZero
                            : [view convertRect:view.bounds toView:view.window];
}

- (void)performOnMainThread:(dispatch_block_t)block {
  if (NSThread.isMainThread) {
    block();
  } else {
    dispatch_sync(dispatch_get_main_queue(), block);
  }
}

@end

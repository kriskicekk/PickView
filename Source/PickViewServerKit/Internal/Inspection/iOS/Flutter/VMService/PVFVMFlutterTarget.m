#import "PVFVMFlutterTarget.h"

@interface PVFVMFlutterTarget ()
@property(nonatomic, readwrite) FlutterEngine *engine;
@property(nonatomic, weak, readwrite, nullable)
    FlutterViewController *viewController;
@property(nonatomic, readwrite) CGRect frameInWindow;
@property(nonatomic, readwrite, getter=isVisible) BOOL visible;
@property(nonatomic, readwrite, getter=isRegistered) BOOL registered;

- (instancetype)initWithEngine:(FlutterEngine *)engine
                 viewController:(nullable FlutterViewController *)viewController
                         visible:(BOOL)visible
                      registered:(BOOL)registered
                   frameInWindow:(CGRect)frameInWindow;
@end

@implementation PVFVMFlutterTarget

- (instancetype)initWithEngine:(FlutterEngine *)engine
                 viewController:(FlutterViewController *)viewController
                         visible:(BOOL)visible
                      registered:(BOOL)registered
                   frameInWindow:(CGRect)frameInWindow {
  self = [super init];
  if (self) {
    _engine = engine;
    _viewController = viewController;
    _visible = visible;
    _registered = registered;
    _frameInWindow = frameInWindow;
  }
  return self;
}

- (NSString *)engineIdentifier {
  return [NSString stringWithFormat:@"engine:%p", self.engine];
}

- (NSString *)sessionIdentifier {
  return [NSString stringWithFormat:@"%@:%@", self.engineIdentifier,
                                    self.isolateID ?: @"pending"];
}

- (NSString *)isolateID {
  return self.engine.isolateId;
}

- (NSURL *)vmServiceURL {
  return self.engine.vmServiceUrl;
}

- (CGRect)frameInWindow {
  UIView *view = self.viewController.viewIfLoaded;
  if (view.window == nil) {
    return _frameInWindow;
  }
  return [view convertRect:view.bounds toView:view.window];
}

- (BOOL)isVisible {
  UIView *view = self.viewController.viewIfLoaded;
  UIWindow *window = view.window;
  if (view == nil || window == nil) {
    return _visible;
  }
  if (view.hidden || view.alpha <= 0.01 || CGRectIsEmpty(view.bounds)) {
    return NO;
  }
  return CGRectIntersectsRect(self.frameInWindow, window.bounds);
}

- (NSDictionary *)dictionaryRepresentation {
  NSMutableDictionary *dictionary = [@{
    @"engineIdentifier" : self.engineIdentifier,
    @"sessionIdentifier" : self.sessionIdentifier,
    @"enginePointer" : [NSString stringWithFormat:@"%p", self.engine],
    @"viewControllerPointer" :
        self.viewController == nil
            ? (id)NSNull.null
            : [NSString stringWithFormat:@"%p", self.viewController],
    @"visible" : @(self.visible),
    @"registered" : @(self.registered),
    @"isolateId" : self.isolateID ?: (id)NSNull.null,
    @"vmServiceUrl" : self.vmServiceURL.absoluteString ?: (id)NSNull.null,
    @"frameInWindow" : @{
      @"x" : @(self.frameInWindow.origin.x),
      @"y" : @(self.frameInWindow.origin.y),
      @"width" : @(self.frameInWindow.size.width),
      @"height" : @(self.frameInWindow.size.height)
    }
  } mutableCopy];
  dictionary[@"viewControllerClass"] =
      self.viewController == nil ? (id)NSNull.null
                                 : NSStringFromClass(self.viewController.class);
  return dictionary;
}

@end

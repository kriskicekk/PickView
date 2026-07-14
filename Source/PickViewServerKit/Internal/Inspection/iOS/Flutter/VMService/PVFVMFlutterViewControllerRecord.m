#import "PVFVMFlutterViewControllerRecord.h"

#import "PVFVMEngineInspectorSession.h"
#import "PVFVMFlutterTarget.h"

@interface PVFVMFlutterViewControllerRecord ()
@property(nonatomic, readwrite) NSString *recordIdentifier;
@property(nonatomic, readwrite) NSString *viewControllerIdentifier;
@property(nonatomic, readwrite) NSString *engineIdentifier;
@property(nonatomic, weak, readwrite, nullable)
    FlutterViewController *viewController;
@property(nonatomic, readwrite) FlutterEngine *engine;
@property(nonatomic, readwrite) PVFVMFlutterTarget *target;
@property(nonatomic, readwrite) PVFVMEngineInspectorSession *session;
@property(nonatomic, readwrite) NSDate *createdAt;
@property(nonatomic, readwrite, nullable) NSDate *removedAt;
@property(nonatomic, readwrite) PVFVMFlutterViewControllerRemovalReason
    removalReason;
@property(nonatomic, readwrite, getter=isActive) BOOL active;

- (instancetype)initWithViewController:
                    (FlutterViewController *)viewController
                                 target:(PVFVMFlutterTarget *)target
                                session:(PVFVMEngineInspectorSession *)session;
- (void)markRemovedWithReason:
    (PVFVMFlutterViewControllerRemovalReason)reason;
@end

@implementation PVFVMFlutterViewControllerRecord

- (instancetype)initWithViewController:
                    (FlutterViewController *)viewController
                                 target:(PVFVMFlutterTarget *)target
                                session:(PVFVMEngineInspectorSession *)session {
  self = [super init];
  if (self) {
    _recordIdentifier = NSUUID.UUID.UUIDString;
    _viewControllerIdentifier =
        [NSString stringWithFormat:@"flutter-vc:%p", viewController];
    _engineIdentifier = target.engineIdentifier;
    _viewController = viewController;
    _engine = target.engine;
    _target = target;
    _session = session;
    _createdAt = NSDate.date;
    _removalReason = PVFVMFlutterViewControllerRemovalReasonNone;
    _active = YES;
  }
  return self;
}

- (void)markRemovedWithReason:
    (PVFVMFlutterViewControllerRemovalReason)reason {
  if (!self.active) {
    return;
  }
  self.active = NO;
  self.removedAt = NSDate.date;
  self.removalReason = reason;
}

- (NSDictionary *)dictionaryRepresentation {
  NSMutableDictionary *dictionary = [@{
    @"recordIdentifier" : self.recordIdentifier,
    @"viewControllerIdentifier" : self.viewControllerIdentifier,
    @"engineIdentifier" : self.engineIdentifier,
    @"viewControllerAlive" : @(self.viewController != nil),
    @"active" : @(self.active),
    @"createdAt" : [self.class stringFromDate:self.createdAt],
    @"removedAt" : self.removedAt == nil
        ? (id)NSNull.null
        : [self.class stringFromDate:self.removedAt],
    @"removalReason" : [self.class stringFromRemovalReason:self.removalReason],
    @"target" : self.target.dictionaryRepresentation,
    @"session" : @{
      @"objectGroup" : self.session.objectGroup,
      @"isolateId" : self.session.isolateID ?: (id)NSNull.null,
      @"vmServiceUrl" :
          self.session.vmServiceURL.absoluteString ?: (id)NSNull.null,
      @"connected" : @(self.session.isConnected)
    }
  } mutableCopy];
  dictionary[@"viewControllerPointer"] =
      self.viewController == nil
          ? (id)NSNull.null
          : [NSString stringWithFormat:@"%p", self.viewController];
  dictionary[@"enginePointer"] =
      [NSString stringWithFormat:@"%p", self.engine];
  return dictionary;
}

+ (NSString *)stringFromDate:(NSDate *)date {
  NSISO8601DateFormatter *formatter = [[NSISO8601DateFormatter alloc] init];
  return [formatter stringFromDate:date];
}

+ (NSString *)stringFromRemovalReason:
    (PVFVMFlutterViewControllerRemovalReason)reason {
  switch (reason) {
  case PVFVMFlutterViewControllerRemovalReasonExplicit:
    return @"explicit";
  case PVFVMFlutterViewControllerRemovalReasonDeallocated:
    return @"viewControllerDeallocated";
  case PVFVMFlutterViewControllerRemovalReasonNone:
    return @"none";
  }
}

@end

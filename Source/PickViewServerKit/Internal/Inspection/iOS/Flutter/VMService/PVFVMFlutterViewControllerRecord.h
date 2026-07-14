#import "PVFVMFlutterRuntime.h"
#import <Foundation/Foundation.h>

@class PVFVMEngineInspectorSession;
@class PVFVMFlutterTarget;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PVFVMFlutterViewControllerRemovalReason) {
  PVFVMFlutterViewControllerRemovalReasonNone = 0,
  PVFVMFlutterViewControllerRemovalReasonExplicit,
  PVFVMFlutterViewControllerRemovalReasonDeallocated,
};

@interface PVFVMFlutterViewControllerRecord : NSObject

@property(nonatomic, readonly) NSString *recordIdentifier;
@property(nonatomic, readonly) NSString *viewControllerIdentifier;
@property(nonatomic, readonly) NSString *engineIdentifier;
@property(nonatomic, weak, readonly, nullable)
    FlutterViewController *viewController;
@property(nonatomic, readonly) FlutterEngine *engine;
@property(nonatomic, readonly) PVFVMFlutterTarget *target;
@property(nonatomic, readonly) PVFVMEngineInspectorSession *session;
@property(nonatomic, readonly) NSDate *createdAt;
@property(nonatomic, readonly, nullable) NSDate *removedAt;
@property(nonatomic, readonly) PVFVMFlutterViewControllerRemovalReason
    removalReason;
@property(nonatomic, readonly, getter=isActive) BOOL active;

- (NSDictionary *)dictionaryRepresentation;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

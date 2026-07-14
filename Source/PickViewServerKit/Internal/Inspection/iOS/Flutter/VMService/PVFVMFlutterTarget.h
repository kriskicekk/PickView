#import "PVFVMFlutterRuntime.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PVFVMFlutterTarget : NSObject

@property(nonatomic, readonly) FlutterEngine *engine;
@property(nonatomic, weak, readonly, nullable)
    FlutterViewController *viewController;
@property(nonatomic, readonly) NSString *engineIdentifier;
@property(nonatomic, readonly) NSString *sessionIdentifier;
@property(nonatomic, readonly, nullable) NSString *isolateID;
@property(nonatomic, readonly, nullable) NSURL *vmServiceURL;
@property(nonatomic, readonly) CGRect frameInWindow;
@property(nonatomic, readonly, getter=isVisible) BOOL visible;
@property(nonatomic, readonly, getter=isRegistered) BOOL registered;

- (NSDictionary *)dictionaryRepresentation;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

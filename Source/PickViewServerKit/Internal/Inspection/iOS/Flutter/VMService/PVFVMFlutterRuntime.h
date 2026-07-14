//
//  PVFVMFlutterRuntime.h
//  PickViewServer
//

#import <UIKit/UIKit.h>

#if __has_include(<Flutter/Flutter.h>)
#import <Flutter/Flutter.h>
#else

/// Minimal declarations keep PickViewServer independent from a Flutter Pod
/// dependency. At runtime these classes are discovered by name and only used
/// when the host app has linked Flutter.
@class FlutterViewController;

@interface FlutterEngine : NSObject
@property(nonatomic, readonly, nullable) NSString *isolateId;
@property(nonatomic, readonly, nullable) NSURL *vmServiceUrl;
@property(nonatomic, weak, readonly, nullable) FlutterViewController *viewController;
@end

@interface FlutterViewController : UIViewController
@property(nonatomic, readonly, nullable) FlutterEngine *engine;
@end

#endif

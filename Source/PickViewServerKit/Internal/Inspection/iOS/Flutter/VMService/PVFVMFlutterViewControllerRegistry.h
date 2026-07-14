#import "PVFVMFlutterRuntime.h"
#import <Foundation/Foundation.h>

@class PVFVMFlutterViewControllerRecord;

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSNotificationName const
    PVFVMFlutterViewControllerRegistryDidAddRecordNotification;
FOUNDATION_EXPORT NSNotificationName const
    PVFVMFlutterViewControllerRegistryDidRemoveRecordNotification;
FOUNDATION_EXPORT NSString *const
    PVFVMFlutterViewControllerRegistryRecordUserInfoKey;

typedef void (^PVFVMFlutterViewControllerRecordAddedHandler)(
    PVFVMFlutterViewControllerRecord *record);
typedef void (^PVFVMFlutterViewControllerRecordRemovedHandler)(
    PVFVMFlutterViewControllerRecord *record);

@interface PVFVMFlutterViewControllerRegistry : NSObject

@property(nonatomic, copy, nullable)
    PVFVMFlutterViewControllerRecordAddedHandler recordAddedHandler;
@property(nonatomic, copy, nullable)
    PVFVMFlutterViewControllerRecordRemovedHandler recordRemovedHandler;

- (nullable PVFVMFlutterViewControllerRecord *)
    existingRecordForViewController:(FlutterViewController *)viewController;
- (NSArray<PVFVMFlutterViewControllerRecord *> *)allRecords;

@end

NS_ASSUME_NONNULL_END

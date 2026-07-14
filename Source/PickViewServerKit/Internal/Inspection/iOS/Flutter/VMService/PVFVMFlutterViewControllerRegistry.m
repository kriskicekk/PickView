#import "PVFVMFlutterViewControllerRegistry.h"

#import <objc/runtime.h>

#import "PVFVMEngineInspectorSession.h"
#import "PVFVMFlutterTarget.h"
#import "PVFVMFlutterViewControllerRecord.h"
#import "PVFVMInspectorJSON.h"

NSNotificationName const PVFVMFlutterViewControllerRegistryDidAddRecordNotification =
    @"PVFVMFlutterViewControllerRegistryDidAddRecordNotification";
NSNotificationName const
    PVFVMFlutterViewControllerRegistryDidRemoveRecordNotification =
        @"PVFVMFlutterViewControllerRegistryDidRemoveRecordNotification";
NSString *const PVFVMFlutterViewControllerRegistryRecordUserInfoKey =
    @"record";

static char PVFVMFlutterViewControllerDeallocSentinelKey;

@interface PVFVMFlutterViewControllerRecord (PVFVMRegistryInternal)
- (instancetype)initWithViewController:
                    (FlutterViewController *)viewController
                                 target:(PVFVMFlutterTarget *)target
                                session:(PVFVMEngineInspectorSession *)session;
- (void)markRemovedWithReason:
    (PVFVMFlutterViewControllerRemovalReason)reason;
@end

@interface PVFVMFlutterViewControllerDeallocSentinel : NSObject
@property(nonatomic, copy, nullable) dispatch_block_t deallocHandler;
@end

@implementation PVFVMFlutterViewControllerDeallocSentinel
- (void)dealloc {
  if (self.deallocHandler != nil) {
    self.deallocHandler();
  }
}
@end

@interface PVFVMFlutterViewControllerRegistry ()
@property(nonatomic)
    NSMapTable<FlutterViewController *, PVFVMFlutterViewControllerRecord *>
        *recordsByViewController;
@property(nonatomic)
    NSMutableDictionary<NSString *, PVFVMFlutterViewControllerRecord *>
        *recordsByIdentifier;
@end

@implementation PVFVMFlutterViewControllerRegistry

- (instancetype)init {
  self = [super init];
  if (self) {
    _recordsByViewController = [NSMapTable weakToStrongObjectsMapTable];
    _recordsByIdentifier = [NSMutableDictionary dictionary];
  }
  return self;
}

- (PVFVMFlutterViewControllerRecord *)existingRecordForViewController:
    (FlutterViewController *)viewController {
  __block PVFVMFlutterViewControllerRecord *record;
  [self performOnMainThread:^{
    record = [self.recordsByViewController objectForKey:viewController];
  }];
  return record;
}

- (NSArray<PVFVMFlutterViewControllerRecord *> *)allRecords {
  __block NSArray<PVFVMFlutterViewControllerRecord *> *records;
  [self performOnMainThread:^{
    records = [self.recordsByIdentifier.allValues
        sortedArrayUsingComparator:^NSComparisonResult(
            PVFVMFlutterViewControllerRecord *left,
            PVFVMFlutterViewControllerRecord *right) {
          return [left.createdAt compare:right.createdAt];
        }];
  }];
  return records ?: @[];
}

- (PVFVMFlutterViewControllerRecord *)
    registerViewController:(FlutterViewController *)viewController
                     target:(PVFVMFlutterTarget *)target
                    session:(PVFVMEngineInspectorSession *)session {
  __block PVFVMFlutterViewControllerRecord *record;
  [self performOnMainThread:^{
    record = [self.recordsByViewController objectForKey:viewController];
    if (record != nil) {
      return;
    }

    record = [[PVFVMFlutterViewControllerRecord alloc]
        initWithViewController:viewController
                       target:target
                      session:session];
    [self.recordsByViewController setObject:record forKey:viewController];
    self.recordsByIdentifier[record.recordIdentifier] = record;
    [self attachDeallocSentinelToViewController:viewController
                                         record:record];
    [self publishAddedRecord:record];
  }];
  return record;
}

- (void)unregisterViewController:(FlutterViewController *)viewController {
  [self performOnMainThread:^{
    PVFVMFlutterViewControllerRecord *record =
        [self.recordsByViewController objectForKey:viewController];
    if (record == nil) {
      return;
    }
    PVFVMFlutterViewControllerDeallocSentinel *sentinel =
        objc_getAssociatedObject(viewController,
                                 &PVFVMFlutterViewControllerDeallocSentinelKey);
    sentinel.deallocHandler = nil;
    objc_setAssociatedObject(viewController,
                             &PVFVMFlutterViewControllerDeallocSentinelKey, nil,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.recordsByViewController removeObjectForKey:viewController];
    [self removeRecordIdentifier:record.recordIdentifier
                          reason:PVFVMFlutterViewControllerRemovalReasonExplicit];
  }];
}

- (void)attachDeallocSentinelToViewController:
            (FlutterViewController *)viewController
                                         record:
            (PVFVMFlutterViewControllerRecord *)record {
  PVFVMFlutterViewControllerDeallocSentinel *sentinel =
      [[PVFVMFlutterViewControllerDeallocSentinel alloc] init];
  NSString *recordIdentifier = record.recordIdentifier;
  __weak typeof(self) weakSelf = self;
  sentinel.deallocHandler = ^{
    dispatch_async(dispatch_get_main_queue(), ^{
      [weakSelf
          removeRecordIdentifier:recordIdentifier
                          reason:
                              PVFVMFlutterViewControllerRemovalReasonDeallocated];
    });
  };
  objc_setAssociatedObject(viewController,
                           &PVFVMFlutterViewControllerDeallocSentinelKey, sentinel,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)removeRecordIdentifier:(NSString *)recordIdentifier
                         reason:
                             (PVFVMFlutterViewControllerRemovalReason)reason {
  PVFVMFlutterViewControllerRecord *record =
      self.recordsByIdentifier[recordIdentifier];
  if (record == nil) {
    return;
  }
  [record markRemovedWithReason:reason];
  [self.recordsByIdentifier removeObjectForKey:recordIdentifier];
  [self publishRemovedRecord:record];
}

- (void)publishAddedRecord:(PVFVMFlutterViewControllerRecord *)record {
  NSLog(@"PVFVM_FLUTTER_VC_RECORD_ADDED %@",
        [PVFVMInspectorJSON
            prettyJSONStringForObject:record.dictionaryRepresentation]);
  if (self.recordAddedHandler != nil) {
    self.recordAddedHandler(record);
  }
  [NSNotificationCenter.defaultCenter
      postNotificationName:PVFVMFlutterViewControllerRegistryDidAddRecordNotification
                    object:self
                  userInfo:@{
                    PVFVMFlutterViewControllerRegistryRecordUserInfoKey : record
                  }];
}

- (void)publishRemovedRecord:(PVFVMFlutterViewControllerRecord *)record {
  NSLog(@"PVFVM_FLUTTER_VC_RECORD_REMOVED %@",
        [PVFVMInspectorJSON
            prettyJSONStringForObject:record.dictionaryRepresentation]);
  if (self.recordRemovedHandler != nil) {
    self.recordRemovedHandler(record);
  }
  [NSNotificationCenter.defaultCenter
      postNotificationName:
          PVFVMFlutterViewControllerRegistryDidRemoveRecordNotification
                    object:self
                  userInfo:@{
                    PVFVMFlutterViewControllerRegistryRecordUserInfoKey : record
                  }];
}

- (void)performOnMainThread:(dispatch_block_t)block {
  if (NSThread.isMainThread) {
    block();
  } else {
    dispatch_sync(dispatch_get_main_queue(), block);
  }
}

@end

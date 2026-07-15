//
//  PVIOSHierarchyProvider.m
//  PickViewServer
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVIOSHierarchyProvider.h"

#import "CALayer+PVInspect.h"
#import "Color+PVInspect.h"
#import "PVAppInfo.h"
#import "PVAppInfoCollector.h"
#import "PVAttrGroupsMaker.h"
#import "PVAttribute.h"
#import "PVAttributeModification.h"
#import "PVAttributesGroup.h"
#import "PVAttributesSection.h"
#import "PVCustomAttrGroupsMaker.h"
#import "PVCustomAttrModification.h"
#import "PVCustomAttrSetterManager.h"
#import "PVCustomDisplayItemInfo.h"
#import "PVDisplayItem.h"
#import "PVDisplayItemDetail.h"
#import "PVErrorCode.h"
#import "PVEventHandler.h"
#import "PVHierarchyInfo.h"
#import "PVInspectionDefines.h"
#import "PVIvarTrace.h"
#import "NSObject+PVServerTrace.h"
#import "PVObject.h"
#import "PVStaticAsyncUpdateTask.h"
#import "PVTuple.h"
#import "PVUIKitAttributeAccessors.h"
#import "PVWindowInfo.h"

#import "PVFlutterHierarchyCoordinator.h"

#import <objc/runtime.h>
#import <TargetConditionals.h>

#if TARGET_OS_IPHONE
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#endif

@interface PVIOSHierarchyProvider ()
@property (nonatomic, strong) NSMapTable<NSNumber *, id> *objectRegistry;
@property(nonatomic, strong) PVFlutterHierarchyCoordinator *flutterCoordinator;
@end

@implementation PVIOSHierarchyProvider

- (instancetype)init {
    self = [super init];
    if (self) {
        _objectRegistry = [NSMapTable strongToWeakObjectsMapTable];
        _flutterCoordinator = [PVFlutterHierarchyCoordinator new];
    }
    return self;
}

#if TARGET_OS_IPHONE
- (void)prepareHierarchyForWindowID:(NSString *)windowID
                         completion:(void (^)(NSError *error))completion {
    dispatch_block_t work = ^{
        UIWindow *window = [self windowForIdentifier:windowID];
        if (!window) {
            NSError *error = [NSError errorWithDomain:PVErrorDomain
                                                 code:PVErrorCodeUnknown
                                             userInfo:@{NSLocalizedDescriptionKey: @"Window not found."}];
            completion(error);
            return;
        }
        [self.flutterCoordinator prepareWindow:window completion:nil];
        if (completion) completion(nil);
    };
    if (NSThread.isMainThread) work();
    else dispatch_async(dispatch_get_main_queue(), work);
}

- (void)detailsForDisplayItemIDs:(NSArray<NSString *> *)displayItemIDs
                  needsSoloImage:(BOOL)needsSoloImage
                 needsGroupImage:(BOOL)needsGroupImage
                 lowImageQuality:(BOOL)lowImageQuality
                      completion:(void (^)(NSArray<PVDisplayItemDetail *> *details))completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.flutterCoordinator performAfterPendingPreparation:^{
        NSMutableArray<NSString *> *nativeIDs = [NSMutableArray array];
        NSMutableArray<NSString *> *flutterIDs = [NSMutableArray array];
        for (NSString *displayItemID in displayItemIDs) {
            if ([self.flutterCoordinator ownsDisplayItemID:displayItemID]) {
                [flutterIDs addObject:displayItemID];
            } else {
                [nativeIDs addObject:displayItemID];
            }
        }
        NSMutableArray<PVDisplayItemDetail *> *results =
            [[self detailsForDisplayItemIDsOnMainThread:nativeIDs
                                         needsSoloImage:needsSoloImage
                                        needsGroupImage:needsGroupImage
                                        lowImageQuality:lowImageQuality] mutableCopy] ?: [NSMutableArray array];
        if (flutterIDs.count == 0) {
            completion(results.copy);
            return;
        }
        [self.flutterCoordinator detailsForDisplayItemIDs:flutterIDs
                                           needsSoloImage:needsSoloImage
                                          needsGroupImage:needsGroupImage
                                          lowImageQuality:lowImageQuality
                                               completion:^(NSArray<PVDisplayItemDetail *> *details) {
            [results addObjectsFromArray:details];
            completion(results.copy);
        }];
        }];
    });
}

- (void)detailsForTaskPackages:(NSArray<PVStaticAsyncUpdateTasksPackage *> *)packages
               lowImageQuality:(BOOL)lowImageQuality
                    completion:(void (^)(NSArray<PVDisplayItemDetail *> *details))completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableArray<PVStaticAsyncUpdateTask *> *nativeTasks = [NSMutableArray array];
        NSMutableArray<PVStaticAsyncUpdateTask *> *flutterTasks = [NSMutableArray array];
        BOOL containsFlutterHostTask = NO;
        for (PVStaticAsyncUpdateTasksPackage *package in packages) {
            for (PVStaticAsyncUpdateTask *task in package.tasks) {
                if ([self.flutterCoordinator ownsObjectOID:task.oid]) {
                    [flutterTasks addObject:task];
                } else {
                    [nativeTasks addObject:task];
                    CALayer *layer = [self layerForOid:task.oid];
                    if ([self.flutterCoordinator isFlutterHostLayer:layer]) {
                        containsFlutterHostTask = YES;
                    }
                }
            }
        }

        // Native layers may change while Flutter Inspector is connecting. Read
        // them immediately so that Flutter preparation does not turn otherwise
        // valid native tasks into stale-layer failures.
        NSMutableArray<PVDisplayItemDetail *> *results = [NSMutableArray array];
        if (nativeTasks.count) {
            PVStaticAsyncUpdateTasksPackage *nativePackage = [PVStaticAsyncUpdateTasksPackage new];
            nativePackage.tasks = nativeTasks.copy;
            [results addObjectsFromArray:
                [self detailsForTaskPackagesOnMainThread:@[nativePackage]
                                         lowImageQuality:lowImageQuality] ?: @[]];
        }

        if (!containsFlutterHostTask && flutterTasks.count == 0) {
            completion(results.copy);
            return;
        }

        [self.flutterCoordinator performAfterPendingPreparation:^{
            // The host detail was captured above. Once preparation finishes,
            // only attach the virtual Flutter subtree to that cached detail.
            for (PVDisplayItemDetail *detail in results) {
                if (detail.failureCode == PVDisplayItemDetailFailureCodeStaleObject) continue;
                CALayer *layer = [self layerForOid:detail.displayItemOid];
                if (![self.flutterCoordinator isFlutterHostLayer:layer]) continue;
                UIView *view = layer.pv_inspect_hostView;
                NSArray<PVDisplayItem *> *flutterItems = view
                    ? [self.flutterCoordinator virtualItemsForHostView:view]
                    : @[];
                if (flutterItems.count == 0) {
                    flutterItems = [self.flutterCoordinator virtualItemsForHostLayer:layer];
                }
                if (flutterItems.count > 0) detail.subitems = flutterItems;
            }

            if (flutterTasks.count == 0) {
                completion(results.copy);
                return;
            }
            PVStaticAsyncUpdateTasksPackage *flutterPackage = [PVStaticAsyncUpdateTasksPackage new];
            flutterPackage.tasks = flutterTasks.copy;
            [self.flutterCoordinator detailsForTaskPackages:@[flutterPackage]
                                            lowImageQuality:lowImageQuality
                                                 completion:^(NSArray<PVDisplayItemDetail *> *details) {
                [results addObjectsFromArray:details];
                completion(results.copy);
            }];
        }];
    });
}
#endif

- (NSArray<PVWindowInfo *> *)allWindows {
#if TARGET_OS_IPHONE
    if (!NSThread.isMainThread) {
        __block NSArray<PVWindowInfo *> *infos = nil;
        dispatch_sync(dispatch_get_main_queue(), ^{
            infos = [self allWindowsOnMainThread];
        });
        return infos ?: @[];
    }
    return [self allWindowsOnMainThread];
#else
    return @[];
#endif
}

- (PVHierarchyInfo *)hierarchyForWindowID:(NSString *)windowID error:(NSError **)error {
#if TARGET_OS_IPHONE
    if (!NSThread.isMainThread) {
        __block PVHierarchyInfo *info = nil;
        __block NSError *innerError = nil;
        dispatch_sync(dispatch_get_main_queue(), ^{
            info = [self hierarchyForWindowIDOnMainThread:windowID error:&innerError];
        });
        if (error) {
            *error = innerError;
        }
        return info;
    }
    return [self hierarchyForWindowIDOnMainThread:windowID error:error];
#else
    if (error) {
        *error = [NSError errorWithDomain:PVErrorDomain
                                     code:PVErrorCodeUnsupportedEndpoint
                                 userInfo:@{NSLocalizedDescriptionKey: @"UIKit hierarchy provider is unavailable on this platform."}];
    }
    return nil;
#endif
}

- (NSArray<PVDisplayItemDetail *> *)detailsForDisplayItemIDs:(NSArray<NSString *> *)displayItemIDs
                                              needsSoloImage:(BOOL)needsSoloImage
                                             needsGroupImage:(BOOL)needsGroupImage
                                             lowImageQuality:(BOOL)lowImageQuality {
#if TARGET_OS_IPHONE
    if (!NSThread.isMainThread) {
        __block NSArray<PVDisplayItemDetail *> *details = nil;
        dispatch_sync(dispatch_get_main_queue(), ^{
            details = [self detailsForDisplayItemIDsOnMainThread:displayItemIDs
                                                  needsSoloImage:needsSoloImage
                                                 needsGroupImage:needsGroupImage
                                                 lowImageQuality:lowImageQuality];
        });
        return details ?: @[];
    }
    return [self detailsForDisplayItemIDsOnMainThread:displayItemIDs
                                      needsSoloImage:needsSoloImage
                                     needsGroupImage:needsGroupImage
                                     lowImageQuality:lowImageQuality];
#else
    return @[];
#endif
}

- (NSArray<PVDisplayItemDetail *> *)detailsForTaskPackages:(NSArray<PVStaticAsyncUpdateTasksPackage *> *)packages
                                           lowImageQuality:(BOOL)lowImageQuality {
#if TARGET_OS_IPHONE
    if (!NSThread.isMainThread) {
        __block NSArray<PVDisplayItemDetail *> *details = nil;
        dispatch_sync(dispatch_get_main_queue(), ^{
            details = [self detailsForTaskPackagesOnMainThread:packages lowImageQuality:lowImageQuality];
        });
        return details ?: @[];
    }
    return [self detailsForTaskPackagesOnMainThread:packages lowImageQuality:lowImageQuality];
#else
    return @[];
#endif
}

- (PVDisplayItemDetail *)modifyAttribute:(PVAttributeModification *)modification error:(NSError **)error {
#if TARGET_OS_IPHONE
    if (!NSThread.isMainThread) {
        __block PVDisplayItemDetail *detail = nil;
        __block NSError *innerError = nil;
        dispatch_sync(dispatch_get_main_queue(), ^{
            detail = [self modifyAttributeOnMainThread:modification error:&innerError];
        });
        if (detail && !innerError) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                detail = [self detailForModifiedObjectOid:modification.targetOid];
            });
        }
        if (error) {
            *error = innerError;
        }
        return detail;
    }
    return [self modifyAttributeOnMainThread:modification error:error];
#else
    if (error) {
        *error = [self unsupportedPlatformError];
    }
    return nil;
#endif
}

- (BOOL)modifyCustomAttribute:(PVCustomAttrModification *)modification error:(NSError **)error {
#if TARGET_OS_IPHONE
    if (!NSThread.isMainThread) {
        __block BOOL success = NO;
        __block NSError *innerError = nil;
        dispatch_sync(dispatch_get_main_queue(), ^{
            success = [self modifyCustomAttributeOnMainThread:modification error:&innerError];
        });
        if (error) {
            *error = innerError;
        }
        return success;
    }
    return [self modifyCustomAttributeOnMainThread:modification error:error];
#else
    if (error) {
        *error = [self unsupportedPlatformError];
    }
    return NO;
#endif
}

- (PVObject *)objectWithOid:(unsigned long)oid error:(NSError **)error {
#if TARGET_OS_IPHONE
    if (!NSThread.isMainThread) {
        __block PVObject *object = nil;
        __block NSError *innerError = nil;
        dispatch_sync(dispatch_get_main_queue(), ^{
            object = [self objectWithOidOnMainThread:oid error:&innerError];
        });
        if (error) {
            *error = innerError;
        }
        return object;
    }
    return [self objectWithOidOnMainThread:oid error:error];
#else
    if (error) {
        *error = [self unsupportedPlatformError];
    }
    return nil;
#endif
}

- (NSArray<PVAttributesGroup *> *)attributesForObjectWithOid:(unsigned long)oid error:(NSError **)error {
#if TARGET_OS_IPHONE
    if (!NSThread.isMainThread) {
        __block NSArray<PVAttributesGroup *> *groups = nil;
        __block NSError *innerError = nil;
        dispatch_sync(dispatch_get_main_queue(), ^{
            groups = [self attributesForObjectWithOidOnMainThread:oid error:&innerError];
        });
        if (error) {
            *error = innerError;
        }
        return groups;
    }
    return [self attributesForObjectWithOidOnMainThread:oid error:error];
#else
    if (error) {
        *error = [self unsupportedPlatformError];
    }
    return nil;
#endif
}

- (NSData *)imageDataForImageViewWithOid:(unsigned long)oid error:(NSError **)error {
#if TARGET_OS_IPHONE
    if (!NSThread.isMainThread) {
        __block NSData *data = nil;
        __block NSError *innerError = nil;
        dispatch_sync(dispatch_get_main_queue(), ^{
            data = [self imageDataForImageViewWithOidOnMainThread:oid error:&innerError];
        });
        if (error) {
            *error = innerError;
        }
        return data;
    }
    return [self imageDataForImageViewWithOidOnMainThread:oid error:error];
#else
    if (error) {
        *error = [self unsupportedPlatformError];
    }
    return nil;
#endif
}

- (NSArray<NSString *> *)selectorNamesForClassName:(NSString *)className hasArg:(BOOL)hasArg error:(NSError **)error {
    Class targetClass = NSClassFromString(className);
    if (!targetClass) {
        if (error) {
            *error = [self errorWithCode:PVErrorCodeUnknown description:[NSString stringWithFormat:@"Didn't find the class named \"%@\".", className ?: @""]];
        }
        return nil;
    }

    NSSet<NSString *> *prefixesToAvoid = [NSSet setWithObjects:@"_", @"CA_", @"cpl", @"mf_", @"vs_", @"pep_", @"isNS", @"avkit_", @"PG_", @"px_", @"pl_", @"nsli_", @"pu_", @"pxg_", nil];
    NSMutableArray<NSString *> *names = [NSMutableArray array];
    Class currentClass = targetClass;
    while (currentClass) {
        NSString *currentClassName = NSStringFromClass(currentClass);
        BOOL isSystemClass = [currentClassName hasPrefix:@"UI"] || [currentClassName hasPrefix:@"CA"] || [currentClassName hasPrefix:@"NS"];
        unsigned int methodCount = 0;
        Method *methods = class_copyMethodList(currentClass, &methodCount);
        for (unsigned int index = 0; index < methodCount; index++) {
            NSString *selectorName = NSStringFromSelector(method_getName(methods[index]));
            if (!hasArg && [selectorName containsString:@":"]) {
                continue;
            }
            if (isSystemClass) {
                BOOL shouldAvoid = NO;
                for (NSString *prefix in prefixesToAvoid) {
                    if ([selectorName hasPrefix:prefix]) {
                        shouldAvoid = YES;
                        break;
                    }
                }
                if (shouldAvoid) {
                    continue;
                }
            }
            if (selectorName.length && ![names containsObject:selectorName]) {
                [names addObject:selectorName];
            }
        }
        if (methods) {
            free(methods);
        }
        currentClass = currentClass.superclass;
    }
    [names sortUsingComparator:^NSComparisonResult(NSString *first, NSString *second) {
        if (first.length < second.length) {
            return NSOrderedAscending;
        }
        if (first.length > second.length) {
            return NSOrderedDescending;
        }
        return [first compare:second];
    }];
    return names.copy;
}

- (NSDictionary *)invokeMethodWithOid:(unsigned long)oid text:(NSString *)text error:(NSError **)error {
#if TARGET_OS_IPHONE
    if (!NSThread.isMainThread) {
        __block NSDictionary *result = nil;
        __block NSError *innerError = nil;
        dispatch_sync(dispatch_get_main_queue(), ^{
            result = [self invokeMethodWithOidOnMainThread:oid text:text error:&innerError];
        });
        if (error) {
            *error = innerError;
        }
        return result;
    }
    return [self invokeMethodWithOidOnMainThread:oid text:text error:error];
#else
    if (error) {
        *error = [self unsupportedPlatformError];
    }
    return nil;
#endif
}

- (NSNumber *)modifyGestureRecognizerWithOid:(unsigned long)oid enabled:(BOOL)enabled error:(NSError **)error {
#if TARGET_OS_IPHONE
    if (!NSThread.isMainThread) {
        __block NSNumber *result = nil;
        __block NSError *innerError = nil;
        dispatch_sync(dispatch_get_main_queue(), ^{
            result = [self modifyGestureRecognizerWithOidOnMainThread:oid enabled:enabled error:&innerError];
        });
        if (error) {
            *error = innerError;
        }
        return result;
    }
    return [self modifyGestureRecognizerWithOidOnMainThread:oid enabled:enabled error:error];
#else
    if (error) {
        *error = [self unsupportedPlatformError];
    }
    return nil;
#endif
}

#if TARGET_OS_IPHONE
- (NSArray<PVWindowInfo *> *)allWindowsOnMainThread {
    NSArray<UIWindow *> *windows = [self allUIKitWindows];
    NSMutableArray<PVWindowInfo *> *infos = [NSMutableArray arrayWithCapacity:windows.count];
    for (UIWindow *window in windows) {
        [infos addObject:[self windowInfoForWindow:window]];
    }
    return infos.copy;
}

- (PVHierarchyInfo *)hierarchyForWindowIDOnMainThread:(NSString *)windowID error:(NSError **)error {
    UIWindow *window = [self windowForIdentifier:windowID];
    if (!window) {
        if (error) {
            *error = [NSError errorWithDomain:PVErrorDomain
                                         code:PVErrorCodeUnknown
                                     userInfo:@{NSLocalizedDescriptionKey: @"Window not found."}];
        }
        return nil;
    }

    [self reloadIvarTraces];

    PVHierarchyInfo *info = [[PVHierarchyInfo alloc] init];
    info.appInfo = [PVAppInfoCollector currentInfoWithImages:NO localIdentifiers:@[]];
    info.serverVersion = info.appInfo.serverVersion;
    info.windowInfo = [self windowInfoForWindow:window];
    info.rootItems = @[[self displayItemForLayer:window.layer]];
    info.displayItems = info.rootItems;
    info.colorAlias = [self configuredColorAlias];
    info.collapsedClassList = [self configuredCollapsedClassList];
    return info;
}

- (UIWindow *)windowForIdentifier:(NSString *)windowID {
    NSArray<UIWindow *> *windows = [self allUIKitWindows];
    if (!windowID.length) {
        return [self keyWindowFromWindows:windows] ?: windows.firstObject;
    }

    for (UIWindow *window in windows) {
        if ([[self identifierForObject:window prefix:@"ios-window"] isEqualToString:windowID]) {
            return window;
        }
    }
    return nil;
}

- (NSArray<UIWindow *> *)allUIKitWindows {
    NSMutableArray<UIWindow *> *windows = [NSMutableArray array];
    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if (![scene isKindOfClass:UIWindowScene.class]) {
                continue;
            }
            UIWindowScene *windowScene = (UIWindowScene *)scene;
            [windows addObjectsFromArray:windowScene.windows];
        }
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [windows addObjectsFromArray:UIApplication.sharedApplication.windows ?: @[]];
#pragma clang diagnostic pop
    }
    return windows.copy;
}

- (UIWindow *)keyWindowFromWindows:(NSArray<UIWindow *> *)windows {
    for (UIWindow *window in windows) {
        if (window.isKeyWindow) {
            return window;
        }
    }
    return nil;
}

- (PVWindowInfo *)windowInfoForWindow:(UIWindow *)window {
    PVWindowInfo *info = [[PVWindowInfo alloc] init];
    info.windowID = [self identifierForObject:window prefix:@"ios-window"];
    info.title = NSStringFromClass(window.class);
    info.className = NSStringFromClass(window.class);
    info.frame = window.frame;
    info.keyWindow = window.isKeyWindow;
    info.mainWindow = window.isKeyWindow;
    info.visible = !window.isHidden;
    info.level = (NSInteger)window.windowLevel;
    return info;
}

- (NSArray<PVDisplayItemDetail *> *)detailsForDisplayItemIDsOnMainThread:(NSArray<NSString *> *)displayItemIDs
                                                          needsSoloImage:(BOOL)needsSoloImage
                                                         needsGroupImage:(BOOL)needsGroupImage
                                                         lowImageQuality:(BOOL)lowImageQuality {
    NSMutableArray<PVDisplayItemDetail *> *details = [NSMutableArray arrayWithCapacity:displayItemIDs.count];
    for (NSString *displayItemID in displayItemIDs) {
        if (![displayItemID isKindOfClass:NSString.class] || !displayItemID.length) {
            continue;
        }

        UIView *view = [self viewForDisplayItemID:displayItemID];
        PVDisplayItemDetail *detail = [[PVDisplayItemDetail alloc] init];
        detail.displayItemID = displayItemID;
        detail.displayItemOid = (unsigned long)(uintptr_t)view.layer;
        if (!view) {
            detail.failureCode = PVDisplayItemDetailFailureCodeStaleObject;
            NSLog(@"PV_DETAIL_STALE_OBJECT source=displayItemID objectID=%@ oid=%lu",
                  displayItemID, detail.displayItemOid);
            [details addObject:detail];
            continue;
        }

        detail.frame = view.frame;
        detail.bounds = view.bounds;
        detail.hidden = view.isHidden;
        detail.alpha = view.alpha;
        detail.attributesGroupList = [PVAttrGroupsMaker attrGroupsForLayer:view.layer];
        [self applyCustomAttrInfoToDetail:detail layer:view.layer];
        if (needsSoloImage) {
            detail.soloImageData = [self imageDataForView:view includeSubviews:NO lowQuality:lowImageQuality];
            detail.soloScreenshot = detail.soloImageData.length ? [UIImage imageWithData:detail.soloImageData] : nil;
        }
        if (needsGroupImage) {
            detail.groupImageData = [self imageDataForView:view includeSubviews:YES lowQuality:lowImageQuality];
            detail.groupScreenshot = detail.groupImageData.length ? [UIImage imageWithData:detail.groupImageData] : nil;
        }
        [details addObject:detail];
    }
    return details.copy;
}

- (NSArray<PVDisplayItemDetail *> *)detailsForTaskPackagesOnMainThread:(NSArray<PVStaticAsyncUpdateTasksPackage *> *)packages
                                                        lowImageQuality:(BOOL)lowImageQuality {
    NSMutableArray<PVDisplayItemDetail *> *details = [NSMutableArray array];
    NSMutableSet<NSNumber *> *attrGroupsSyncedOids = [NSMutableSet set];
    [UIView pv_lks_rebuildGlobalInvolvedRawConstraintsWithWindows:[self allUIKitWindows]];

    for (PVStaticAsyncUpdateTasksPackage *package in packages) {
        for (PVStaticAsyncUpdateTask *task in package.tasks) {
            PVDisplayItemDetail *detail = [[PVDisplayItemDetail alloc] init];
            detail.displayItemOid = task.oid;

            CALayer *layer = [self layerForOid:task.oid];
            if (!layer) {
                detail.failureCode = PVDisplayItemDetailFailureCodeStaleObject;
                NSLog(@"PV_DETAIL_STALE_OBJECT source=task oid=%lu taskType=%ld "
                      "needAttributes=%@ needBasisVisualInfo=%@ needSubitems=%@",
                      task.oid, (long)task.taskType,
                      task.attrRequest == PVDetailUpdateTaskAttrRequest_NotNeed ? @"NO" : @"YES",
                      task.needBasisVisualInfo ? @"YES" : @"NO",
                      task.needSubitems ? @"YES" : @"NO");
                [details addObject:detail];
                continue;
            }

            UIView *view = layer.pv_inspect_hostView;
            if (view) {
                detail.displayItemID = [self identifierForObject:view prefix:@"ios-view"];
            }

            if (task.taskType == PVStaticAsyncUpdateTaskTypeSoloScreenshot) {
                detail.soloImageData = [self imageDataForLayer:layer includeSublayers:NO lowQuality:lowImageQuality];
                detail.soloScreenshot = detail.soloImageData.length ? [UIImage imageWithData:detail.soloImageData] : nil;
            } else if (task.taskType == PVStaticAsyncUpdateTaskTypeGroupScreenshot) {
                detail.groupImageData = [self imageDataForLayer:layer includeSublayers:YES lowQuality:lowImageQuality];
                detail.groupScreenshot = detail.groupImageData.length ? [UIImage imageWithData:detail.groupImageData] : nil;
            }

            if ([self shouldMakeAttributesFromTask:task syncedOids:attrGroupsSyncedOids]) {
                detail.attributesGroupList = [PVAttrGroupsMaker attrGroupsForLayer:layer];
                [self applyCustomAttrInfoToDetail:detail layer:layer];
                [attrGroupsSyncedOids addObject:@(task.oid)];
            }

            if (task.needBasisVisualInfo) {
                detail.frameValue = [NSValue valueWithCGRect:layer.frame];
                detail.boundsValue = [NSValue valueWithCGRect:layer.bounds];
                detail.hiddenValue = @(layer.isHidden);
                detail.alphaValue = @(layer.opacity);
            }

            NSArray<PVDisplayItem *> *flutterItems = view
                ? [self.flutterCoordinator virtualItemsForHostView:view]
                : @[];
            if (flutterItems.count == 0) {
                flutterItems = [self.flutterCoordinator virtualItemsForHostLayer:layer];
            }
            if (flutterItems.count > 0) {
                // Flutter hierarchy loading is asynchronous. The first native
                // hierarchy contains the normal host-layer subtree; its first
                // detail response replaces that subtree with Inspector nodes.
                detail.subitems = flutterItems;
            } else if (task.needSubitems) {
                detail.subitems = [self subitemsForLayer:layer];
            }

            detail.frame = layer.frame;
            detail.bounds = layer.bounds;
            detail.hidden = layer.isHidden;
            detail.alpha = layer.opacity;
            [details addObject:detail];
        }
    }
    return details.copy;
}

- (PVDisplayItemDetail *)modifyAttributeOnMainThread:(PVAttributeModification *)modification error:(NSError **)error {
    if (![modification isKindOfClass:PVAttributeModification.class]) {
        if (error) {
            *error = PVInspectErr_Inner;
        }
        return nil;
    }

    id receiver = [self inspectObjectForOid:modification.targetOid];
    if (!receiver) {
        if (error) {
            *error = PVInspectErr_ObjNotFound;
        }
        return nil;
    }
    if (!modification.setterSelector || ![receiver respondsToSelector:modification.setterSelector]) {
        if (error) {
            *error = PVInspectErr_Inner;
        }
        return nil;
    }

    NSMethodSignature *signature = [receiver methodSignatureForSelector:modification.setterSelector];
    if (signature.numberOfArguments != 3) {
        if (error) {
            *error = PVInspectErr_Inner;
        }
        return nil;
    }

    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = receiver;
    invocation.selector = modification.setterSelector;
    if (![self setInvocation:invocation argumentWithModification:modification error:error]) {
        return nil;
    }

    NSError *invokeError = nil;
    @try {
        [invocation invoke];
    } @catch (NSException *exception) {
        NSString *detail = [NSString stringWithFormat:@"<%@: %p>: an exception was raised when invoking %@. (%@)", NSStringFromClass([receiver class]), receiver, NSStringFromSelector(modification.setterSelector), exception.reason ?: @""];
        invokeError = [NSError errorWithDomain:PVInspectErrorDomain
                                          code:PVInspectErrCode_Exception
                                      userInfo:@{NSLocalizedDescriptionKey: @"The modification may failed.",
                                                 NSLocalizedRecoverySuggestionErrorKey: detail}];
    }

    CALayer *layer = nil;
    if ([receiver isKindOfClass:CALayer.class]) {
        layer = receiver;
    } else if ([receiver isKindOfClass:UIView.class]) {
        layer = ((UIView *)receiver).layer;
    }
    if (!layer) {
        if (error) {
            *error = PVInspectErr_ObjNotFound;
        }
        return nil;
    }

    PVDisplayItemDetail *detail = [self detailForLayer:layer oid:modification.targetOid];
    if (error) {
        *error = invokeError;
    }
    return detail;
}

- (PVDisplayItemDetail *)detailForModifiedObjectOid:(unsigned long)oid {
    id receiver = [self inspectObjectForOid:oid];
    CALayer *layer = [receiver isKindOfClass:CALayer.class] ? receiver : ([receiver isKindOfClass:UIView.class] ? ((UIView *)receiver).layer : nil);
    return layer ? [self detailForLayer:layer oid:oid] : nil;
}

- (PVDisplayItemDetail *)detailForLayer:(CALayer *)layer oid:(unsigned long)oid {
    PVDisplayItemDetail *detail = [[PVDisplayItemDetail alloc] init];
    detail.displayItemOid = oid;
    detail.attributesGroupList = [PVAttrGroupsMaker attrGroupsForLayer:layer];
    [self applyCustomAttrInfoToDetail:detail layer:layer];
    detail.frameValue = [NSValue valueWithCGRect:layer.frame];
    detail.boundsValue = [NSValue valueWithCGRect:layer.bounds];
    detail.hiddenValue = @(layer.isHidden);
    detail.alphaValue = @(layer.opacity);
    return detail;
}

- (BOOL)modifyCustomAttributeOnMainThread:(PVCustomAttrModification *)modification error:(NSError **)error {
    if (!modification.customSetterID.length) {
        if (error) {
            *error = PVInspectErr_Inner;
        }
        return NO;
    }

    switch (modification.attrType) {
        case PVAttrTypeNSString: {
            NSString *newValue = modification.value;
            if (newValue != nil && ![newValue isKindOfClass:NSString.class]) {
                if (error) *error = PVInspectErr_Inner;
                return NO;
            }
            PVStringSetter setter = [[PVCustomAttrSetterManager sharedInstance] getStringSetterWithID:modification.customSetterID];
            if (!setter) {
                if (error) *error = PVInspectErr_ObjNotFound;
                return NO;
            }
            setter(newValue);
            return YES;
        }
        case PVAttrTypeDouble: {
            NSNumber *newValue = modification.value;
            if (![newValue isKindOfClass:NSNumber.class]) {
                if (error) *error = PVInspectErr_Inner;
                return NO;
            }
            PVNumberSetter setter = [[PVCustomAttrSetterManager sharedInstance] getNumberSetterWithID:modification.customSetterID];
            if (!setter) {
                if (error) *error = PVInspectErr_ObjNotFound;
                return NO;
            }
            setter(newValue);
            return YES;
        }
        case PVAttrTypeBOOL: {
            NSNumber *newValue = modification.value;
            if (![newValue isKindOfClass:NSNumber.class]) {
                if (error) *error = PVInspectErr_Inner;
                return NO;
            }
            PVBoolSetter setter = [[PVCustomAttrSetterManager sharedInstance] getBoolSetterWithID:modification.customSetterID];
            if (!setter) {
                if (error) *error = PVInspectErr_ObjNotFound;
                return NO;
            }
            setter(newValue.boolValue);
            return YES;
        }
        case PVAttrTypeUIColor: {
            PVColorSetter setter = [[PVCustomAttrSetterManager sharedInstance] getColorSetterWithID:modification.customSetterID];
            if (!setter) {
                if (error) *error = PVInspectErr_ObjNotFound;
                return NO;
            }

            NSArray<NSNumber *> *newValue = modification.value;
            if (newValue == nil) {
                setter(nil);
                return YES;
            }
            if (![newValue isKindOfClass:NSArray.class]) {
                if (error) *error = PVInspectErr_Inner;
                return NO;
            }
            UIColor *color = [UIColor pv_inspect_colorFromRGBAComponents:newValue];
            if (!color) {
                if (error) *error = PVInspectErr_Inner;
                return NO;
            }
            setter(color);
            return YES;
        }
        case PVAttrTypeEnumString: {
            NSString *newValue = modification.value;
            if (![newValue isKindOfClass:NSString.class]) {
                if (error) *error = PVInspectErr_Inner;
                return NO;
            }
            PVEnumSetter setter = [[PVCustomAttrSetterManager sharedInstance] getEnumSetterWithID:modification.customSetterID];
            if (!setter) {
                if (error) *error = PVInspectErr_ObjNotFound;
                return NO;
            }
            setter(newValue);
            return YES;
        }
        case PVAttrTypeCGRect: {
            NSValue *newValue = modification.value;
            if (![newValue isKindOfClass:NSValue.class]) {
                if (error) *error = PVInspectErr_Inner;
                return NO;
            }
            PVRectSetter setter = [[PVCustomAttrSetterManager sharedInstance] getRectSetterWithID:modification.customSetterID];
            if (!setter) {
                if (error) *error = PVInspectErr_ObjNotFound;
                return NO;
            }
            setter(newValue.CGRectValue);
            return YES;
        }
        case PVAttrTypeCGSize: {
            NSValue *newValue = modification.value;
            if (![newValue isKindOfClass:NSValue.class]) {
                if (error) *error = PVInspectErr_Inner;
                return NO;
            }
            PVSizeSetter setter = [[PVCustomAttrSetterManager sharedInstance] getSizeSetterWithID:modification.customSetterID];
            if (!setter) {
                if (error) *error = PVInspectErr_ObjNotFound;
                return NO;
            }
            setter(newValue.CGSizeValue);
            return YES;
        }
        case PVAttrTypeCGPoint: {
            NSValue *newValue = modification.value;
            if (![newValue isKindOfClass:NSValue.class]) {
                if (error) *error = PVInspectErr_Inner;
                return NO;
            }
            PVPointSetter setter = [[PVCustomAttrSetterManager sharedInstance] getPointSetterWithID:modification.customSetterID];
            if (!setter) {
                if (error) *error = PVInspectErr_ObjNotFound;
                return NO;
            }
            setter(newValue.CGPointValue);
            return YES;
        }
        case PVAttrTypeUIEdgeInsets: {
            NSValue *newValue = modification.value;
            if (![newValue isKindOfClass:NSValue.class]) {
                if (error) *error = PVInspectErr_Inner;
                return NO;
            }
            PVInsetsSetter setter = [[PVCustomAttrSetterManager sharedInstance] getInsetsSetterWithID:modification.customSetterID];
            if (!setter) {
                if (error) *error = PVInspectErr_ObjNotFound;
                return NO;
            }
            setter(newValue.UIEdgeInsetsValue);
            return YES;
        }
        default:
            if (error) {
                *error = PVInspectErr_Inner;
            }
            return NO;
    }
}

- (PVObject *)objectWithOidOnMainThread:(unsigned long)oid error:(NSError **)error {
    NSObject *object = [self inspectObjectForOid:oid];
    if (!object) {
        if (error) {
            *error = PVInspectErr_ObjNotFound;
        }
        return nil;
    }
    return [self identityForObject:object prefix:@"ios-object"];
}

- (NSArray<PVAttributesGroup *> *)attributesForObjectWithOidOnMainThread:(unsigned long)oid error:(NSError **)error {
    id object = [self inspectObjectForOid:oid];
    CALayer *layer = nil;
    if ([object isKindOfClass:CALayer.class]) {
        layer = object;
    } else if ([object isKindOfClass:UIView.class]) {
        layer = ((UIView *)object).layer;
    }
    if (!layer) {
        if (error) {
            *error = PVInspectErr_ObjNotFound;
        }
        return nil;
    }
    NSMutableArray<PVAttributesGroup *> *groups = [[PVAttrGroupsMaker attrGroupsForLayer:layer] mutableCopy] ?: [NSMutableArray array];
    [groups addObjectsFromArray:[self customAttrGroupsForLayer:layer]];
    return groups.copy;
}

- (NSArray<PVAttributesGroup *> *)customAttrGroupsForLayer:(CALayer *)layer {
    PVCustomAttrGroupsMaker *maker = [[PVCustomAttrGroupsMaker alloc] initWithLayer:layer];
    [maker execute];
    return [maker getGroups] ?: @[];
}

- (void)applyCustomAttrInfoToDetail:(PVDisplayItemDetail *)detail layer:(CALayer *)layer {
    PVCustomAttrGroupsMaker *maker = [[PVCustomAttrGroupsMaker alloc] initWithLayer:layer];
    [maker execute];
    detail.customAttrGroupList = [maker getGroups] ?: @[];
    detail.customDisplayTitle = [maker getCustomDisplayTitle];
    detail.danceUISource = [maker getDanceUISource];
}

- (NSData *)imageDataForImageViewWithOidOnMainThread:(unsigned long)oid error:(NSError **)error {
    id object = [self inspectObjectForOid:oid];
    if (![object isKindOfClass:UIImageView.class]) {
        if (error) {
            *error = object ? PVInspectErr_Inner : PVInspectErr_ObjNotFound;
        }
        return nil;
    }
    UIImage *image = ((UIImageView *)object).image;
    NSData *data = image ? UIImagePNGRepresentation(image) : nil;
    if (!data && image) {
        data = UIImageJPEGRepresentation(image, 1);
    }
    return data ?: [NSData data];
}

- (NSDictionary *)invokeMethodWithOidOnMainThread:(unsigned long)oid text:(NSString *)text error:(NSError **)error {
    NSObject *target = [self inspectObjectForOid:oid];
    if (!target) {
        if (error) {
            *error = PVInspectErr_ObjNotFound;
        }
        return nil;
    }
    SEL selector = NSSelectorFromString(text);
    if (!selector || ![target respondsToSelector:selector]) {
        if (error) {
            NSString *message = [NSString stringWithFormat:@"%@ doesn't have an instance method called \"%@\".", NSStringFromClass(target.class), text ?: @""];
            *error = PVInspectErrorMake(message, @"");
        }
        return nil;
    }

    NSMethodSignature *signature = [target methodSignatureForSelector:selector];
    if (signature.numberOfArguments > 2) {
        if (error) {
            *error = PVInspectErrorMake(@"PickView doesn't support invoking methods with arguments yet.", @"");
        }
        return nil;
    }

    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = target;
    invocation.selector = selector;

    @try {
        [invocation invoke];
    } @catch (NSException *exception) {
        if (error) {
            *error = [NSError errorWithDomain:PVInspectErrorDomain
                                         code:PVInspectErrCode_Exception
                                     userInfo:@{NSLocalizedDescriptionKey: @"The invocation failed.",
                                                NSLocalizedRecoverySuggestionErrorKey: exception.reason ?: @""}];
        }
        return nil;
    }

    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSString *description = [self descriptionFromInvocation:invocation signature:signature resultObject:result];
    if (description.length) {
        result[@"description"] = description;
    }
    return result.copy;
}

- (NSNumber *)modifyGestureRecognizerWithOidOnMainThread:(unsigned long)oid enabled:(BOOL)enabled error:(NSError **)error {
    UIGestureRecognizer *recognizer = [self gestureRecognizerForOid:oid];
    if (!recognizer) {
        if (error) {
            *error = PVInspectErr_ObjNotFound;
        }
        return nil;
    }
    recognizer.enabled = enabled;
    return @(recognizer.enabled);
}

- (BOOL)shouldMakeAttributesFromTask:(PVStaticAsyncUpdateTask *)task syncedOids:(NSSet<NSNumber *> *)syncedOids {
    switch (task.attrRequest) {
        case PVDetailUpdateTaskAttrRequest_Automatic:
            return ![syncedOids containsObject:@(task.oid)];
        case PVDetailUpdateTaskAttrRequest_Need:
            return YES;
        case PVDetailUpdateTaskAttrRequest_NotNeed:
            return NO;
    }
    NSAssert(NO, @"");
    return YES;
}

- (CALayer *)layerForOid:(unsigned long)oid {
    for (UIWindow *window in [self allUIKitWindows]) {
        CALayer *matchedLayer = [self layerInLayer:window.layer matchingOid:oid];
        if (matchedLayer) {
            return matchedLayer;
        }
    }
    return nil;
}

- (CALayer *)layerInLayer:(CALayer *)layer matchingOid:(unsigned long)oid {
    if ((unsigned long)(uintptr_t)layer == oid) {
        return layer;
    }
    for (CALayer *sublayer in layer.sublayers) {
        CALayer *matchedLayer = [self layerInLayer:sublayer matchingOid:oid];
        if (matchedLayer) {
            return matchedLayer;
        }
    }
    return nil;
}

- (NSArray<PVDisplayItem *> *)subitemsForLayer:(CALayer *)layer {
    NSMutableArray<PVDisplayItem *> *children = [NSMutableArray arrayWithCapacity:layer.sublayers.count];
    for (CALayer *sublayer in layer.sublayers) {
        [children addObject:[self displayItemForLayer:sublayer]];
    }
    [children addObjectsFromArray:[self customDisplayItemsForLayer:layer saveAttrSetter:YES]];
    return children.copy;
}

- (NSArray<PVAttributesGroup *> *)attributeGroupsForView:(UIView *)view {
    if (!view) {
        return @[];
    }

    NSMutableArray<PVAttributesGroup *> *groups = [NSMutableArray array];
    [groups addObject:[self groupWithIdentifier:PVAttrGroup_Class sections:@[
        [self sectionWithIdentifier:PVAttrSec_Class_Class attributes:@[
            [self attributeWithIdentifier:PVAttr_Class_Class_Class
                                     type:PVAttrTypeCustomObj
                                    value:@[[self classChainForClass:view.class]]]
        ]]
    ]]];
    [groups addObject:[self groupWithIdentifier:PVAttrGroup_Relation sections:@[
        [self sectionWithIdentifier:PVAttrSec_Relation_Relation attributes:@[
            [self attributeWithIdentifier:PVAttr_Relation_Relation_Relation
                                     type:PVAttrTypeCustomObj
                                    value:[self relationStringsForView:view]]
        ]]
    ]]];
    [groups addObject:[self groupWithIdentifier:PVAttrGroup_Layout sections:@[
        [self sectionWithIdentifier:PVAttrSec_Layout_Frame attributes:@[
            [self attributeWithIdentifier:PVAttr_Layout_Frame_Frame type:PVAttrTypeCGRect value:[NSValue valueWithCGRect:view.frame]]
        ]],
        [self sectionWithIdentifier:PVAttrSec_Layout_Bounds attributes:@[
            [self attributeWithIdentifier:PVAttr_Layout_Bounds_Bounds type:PVAttrTypeCGRect value:[NSValue valueWithCGRect:view.bounds]]
        ]],
        [self sectionWithIdentifier:PVAttrSec_Layout_Position attributes:@[
            [self attributeWithIdentifier:PVAttr_Layout_Position_Position type:PVAttrTypeCGPoint value:[NSValue valueWithCGPoint:view.layer.position]]
        ]],
        [self sectionWithIdentifier:PVAttrSec_Layout_AnchorPoint attributes:@[
            [self attributeWithIdentifier:PVAttr_Layout_AnchorPoint_AnchorPoint type:PVAttrTypeCGPoint value:[NSValue valueWithCGPoint:view.layer.anchorPoint]]
        ]]
    ]]];
    [groups addObject:[self groupWithIdentifier:PVAttrGroup_ViewLayer sections:@[
        [self sectionWithIdentifier:PVAttrSec_ViewLayer_Visibility attributes:@[
            [self attributeWithIdentifier:PVAttr_ViewLayer_Visibility_Hidden type:PVAttrTypeBOOL value:@(view.isHidden)],
            [self attributeWithIdentifier:PVAttr_ViewLayer_Visibility_Opacity type:PVAttrTypeDouble value:@(view.alpha)]
        ]],
        [self sectionWithIdentifier:PVAttrSec_ViewLayer_InterationAndMasks attributes:@[
            [self attributeWithIdentifier:PVAttr_ViewLayer_InterationAndMasks_Interaction type:PVAttrTypeBOOL value:@(view.userInteractionEnabled)],
            [self attributeWithIdentifier:PVAttr_ViewLayer_InterationAndMasks_MasksToBounds type:PVAttrTypeBOOL value:@(view.layer.masksToBounds)]
        ]],
        [self sectionWithIdentifier:PVAttrSec_ViewLayer_Corner attributes:@[
            [self attributeWithIdentifier:PVAttr_ViewLayer_Corner_Radius type:PVAttrTypeDouble value:@(view.layer.cornerRadius)]
        ]],
        [self sectionWithIdentifier:PVAttrSec_ViewLayer_Border attributes:@[
            [self attributeWithIdentifier:PVAttr_ViewLayer_Border_Width type:PVAttrTypeDouble value:@(view.layer.borderWidth)]
        ]],
        [self sectionWithIdentifier:PVAttrSec_ViewLayer_Tag attributes:@[
            [self attributeWithIdentifier:PVAttr_ViewLayer_Tag_Tag type:PVAttrTypeLong value:@(view.tag)]
        ]]
    ]]];

    return groups.copy;
}

- (PVAttributesGroup *)groupWithIdentifier:(PVAttrGroupIdentifier)identifier sections:(NSArray<PVAttributesSection *> *)sections {
    PVAttributesGroup *group = [[PVAttributesGroup alloc] init];
    group.identifier = identifier;
    group.attrSections = sections ?: @[];
    return group;
}

- (PVAttributesSection *)sectionWithIdentifier:(PVAttrSectionIdentifier)identifier attributes:(NSArray<PVAttribute *> *)attributes {
    PVAttributesSection *section = [[PVAttributesSection alloc] init];
    section.identifier = identifier;
    section.attributes = attributes ?: @[];
    return section;
}

- (PVAttribute *)attributeWithIdentifier:(PVAttrIdentifier)identifier type:(PVAttrType)type value:(id)value {
    PVAttribute *attribute = [[PVAttribute alloc] init];
    attribute.identifier = identifier;
    attribute.attrType = type;
    attribute.value = value;
    return attribute;
}

- (NSArray<NSString *> *)classChainForClass:(Class)cls {
    NSMutableArray<NSString *> *classNames = [NSMutableArray array];
    Class currentClass = cls;
    while (currentClass) {
        [classNames addObject:NSStringFromClass(currentClass)];
        currentClass = class_getSuperclass(currentClass);
    }
    return classNames.copy;
}

- (NSArray<NSString *> *)relationStringsForView:(UIView *)view {
    NSMutableArray<NSString *> *relations = [NSMutableArray array];
    [relations addObject:[NSString stringWithFormat:@"self: (%@ *) %p", NSStringFromClass(view.class), view]];
    if (view.superview) {
        [relations addObject:[NSString stringWithFormat:@"superview: (%@ *) %p", NSStringFromClass(view.superview.class), view.superview]];
    }
    if (view.window) {
        [relations addObject:[NSString stringWithFormat:@"window: (%@ *) %p", NSStringFromClass(view.window.class), view.window]];
    }
    if (view.layer) {
        [relations addObject:[NSString stringWithFormat:@"layer: (%@ *) %p", NSStringFromClass(view.layer.class), view.layer]];
    }
    return relations.copy;
}

- (id)inspectObjectForOid:(unsigned long)oid {
    id registeredObject = [self.objectRegistry objectForKey:@(oid)];
    if (registeredObject) {
        return registeredObject;
    }
    CALayer *layer = [self layerForOid:oid];
    if (layer) {
        return layer;
    }
    UIView *view = [self viewForOid:oid];
    if (view) {
        return view;
    }
    UIGestureRecognizer *recognizer = [self gestureRecognizerForOid:oid];
    if (recognizer) {
        return recognizer;
    }
    return nil;
}

- (UIView *)viewForOid:(unsigned long)oid {
    for (UIWindow *window in [self allUIKitWindows]) {
        UIView *matchedView = [self viewInView:window matchingOid:oid];
        if (matchedView) {
            return matchedView;
        }
    }
    return nil;
}

- (UIView *)viewInView:(UIView *)view matchingOid:(unsigned long)oid {
    if ((unsigned long)(uintptr_t)view == oid) {
        return view;
    }
    for (UIView *subview in view.subviews) {
        UIView *matchedView = [self viewInView:subview matchingOid:oid];
        if (matchedView) {
            return matchedView;
        }
    }
    return nil;
}

- (UIGestureRecognizer *)gestureRecognizerForOid:(unsigned long)oid {
    for (UIWindow *window in [self allUIKitWindows]) {
        UIGestureRecognizer *recognizer = [self gestureRecognizerInView:window matchingOid:oid];
        if (recognizer) {
            return recognizer;
        }
    }
    return nil;
}

- (UIGestureRecognizer *)gestureRecognizerInView:(UIView *)view matchingOid:(unsigned long)oid {
    for (UIGestureRecognizer *recognizer in view.gestureRecognizers) {
        if ((unsigned long)(uintptr_t)recognizer == oid) {
            return recognizer;
        }
    }
    for (UIView *subview in view.subviews) {
        UIGestureRecognizer *recognizer = [self gestureRecognizerInView:subview matchingOid:oid];
        if (recognizer) {
            return recognizer;
        }
    }
    return nil;
}

- (BOOL)setInvocation:(NSInvocation *)invocation argumentWithModification:(PVAttributeModification *)modification error:(NSError **)error {
    switch (modification.attrType) {
        case PVAttrTypeNone:
        case PVAttrTypeVoid:
        case PVAttrTypeEnumString:
        case PVAttrTypeShadow:
        case PVAttrTypeJson:
            if (error) {
                *error = PVInspectErr_Inner;
            }
            return NO;
        case PVAttrTypeChar: {
            char value = [(NSNumber *)modification.value charValue];
            [invocation setArgument:&value atIndex:2];
            break;
        }
        case PVAttrTypeInt:
        case PVAttrTypeEnumInt: {
            int value = [(NSNumber *)modification.value intValue];
            [invocation setArgument:&value atIndex:2];
            break;
        }
        case PVAttrTypeShort: {
            short value = [(NSNumber *)modification.value shortValue];
            [invocation setArgument:&value atIndex:2];
            break;
        }
        case PVAttrTypeLong:
        case PVAttrTypeEnumLong: {
            long value = [(NSNumber *)modification.value longValue];
            [invocation setArgument:&value atIndex:2];
            break;
        }
        case PVAttrTypeLongLong: {
            long long value = [(NSNumber *)modification.value longLongValue];
            [invocation setArgument:&value atIndex:2];
            break;
        }
        case PVAttrTypeUnsignedChar: {
            unsigned char value = [(NSNumber *)modification.value unsignedCharValue];
            [invocation setArgument:&value atIndex:2];
            break;
        }
        case PVAttrTypeUnsignedInt: {
            unsigned int value = [(NSNumber *)modification.value unsignedIntValue];
            [invocation setArgument:&value atIndex:2];
            break;
        }
        case PVAttrTypeUnsignedShort: {
            unsigned short value = [(NSNumber *)modification.value unsignedShortValue];
            [invocation setArgument:&value atIndex:2];
            break;
        }
        case PVAttrTypeUnsignedLong: {
            unsigned long value = [(NSNumber *)modification.value unsignedLongValue];
            [invocation setArgument:&value atIndex:2];
            break;
        }
        case PVAttrTypeUnsignedLongLong: {
            unsigned long long value = [(NSNumber *)modification.value unsignedLongLongValue];
            [invocation setArgument:&value atIndex:2];
            break;
        }
        case PVAttrTypeFloat: {
            float value = [(NSNumber *)modification.value floatValue];
            [invocation setArgument:&value atIndex:2];
            break;
        }
        case PVAttrTypeDouble: {
            double value = [(NSNumber *)modification.value doubleValue];
            [invocation setArgument:&value atIndex:2];
            break;
        }
        case PVAttrTypeBOOL: {
            BOOL value = [(NSNumber *)modification.value boolValue];
            [invocation setArgument:&value atIndex:2];
            break;
        }
        case PVAttrTypeSel: {
            SEL value = NSSelectorFromString(modification.value);
            [invocation setArgument:&value atIndex:2];
            break;
        }
        case PVAttrTypeClass: {
            Class value = NSClassFromString(modification.value);
            [invocation setArgument:&value atIndex:2];
            break;
        }
        case PVAttrTypeCGPoint: {
            CGPoint value = [(NSValue *)modification.value CGPointValue];
            [invocation setArgument:&value atIndex:2];
            break;
        }
        case PVAttrTypeCGVector: {
            CGVector value = [(NSValue *)modification.value CGVectorValue];
            [invocation setArgument:&value atIndex:2];
            break;
        }
        case PVAttrTypeCGSize: {
            CGSize value = [(NSValue *)modification.value CGSizeValue];
            [invocation setArgument:&value atIndex:2];
            break;
        }
        case PVAttrTypeCGRect: {
            CGRect value = [(NSValue *)modification.value CGRectValue];
            [invocation setArgument:&value atIndex:2];
            break;
        }
        case PVAttrTypeCGAffineTransform: {
            CGAffineTransform value = [(NSValue *)modification.value CGAffineTransformValue];
            [invocation setArgument:&value atIndex:2];
            break;
        }
        case PVAttrTypeUIEdgeInsets: {
            UIEdgeInsets value = [(NSValue *)modification.value UIEdgeInsetsValue];
            [invocation setArgument:&value atIndex:2];
            break;
        }
        case PVAttrTypeUIOffset: {
            UIOffset value = [(NSValue *)modification.value UIOffsetValue];
            [invocation setArgument:&value atIndex:2];
            break;
        }
        case PVAttrTypeCustomObj:
        case PVAttrTypeNSString: {
            NSObject *value = modification.value;
            [invocation setArgument:&value atIndex:2];
            [invocation retainArguments];
            break;
        }
        case PVAttrTypeUIColor: {
            UIColor *value = [UIColor pv_inspect_colorFromRGBAComponents:modification.value];
            [invocation setArgument:&value atIndex:2];
            [invocation retainArguments];
            break;
        }
    }
    return YES;
}

- (NSString *)descriptionFromInvocation:(NSInvocation *)invocation signature:(NSMethodSignature *)signature resultObject:(NSMutableDictionary *)resultObject {
    const char *returnType = signature.methodReturnType;
    if (strcmp(returnType, @encode(void)) == 0) {
        return PVInspectStringFlag_VoidReturn;
    }
    if (strcmp(returnType, @encode(BOOL)) == 0) {
        BOOL value = NO;
        [invocation getReturnValue:&value];
        return value ? @"YES" : @"NO";
    }
    if (strcmp(returnType, @encode(int)) == 0) {
        int value = 0;
        [invocation getReturnValue:&value];
        return [NSString stringWithFormat:@"%@", @(value)];
    }
    if (strcmp(returnType, @encode(long)) == 0) {
        long value = 0;
        [invocation getReturnValue:&value];
        return [NSString stringWithFormat:@"%@", @(value)];
    }
    if (strcmp(returnType, @encode(long long)) == 0) {
        long long value = 0;
        [invocation getReturnValue:&value];
        return [NSString stringWithFormat:@"%@", @(value)];
    }
    if (strcmp(returnType, @encode(unsigned int)) == 0) {
        unsigned int value = 0;
        [invocation getReturnValue:&value];
        return [NSString stringWithFormat:@"%@", @(value)];
    }
    if (strcmp(returnType, @encode(unsigned long)) == 0) {
        unsigned long value = 0;
        [invocation getReturnValue:&value];
        return [NSString stringWithFormat:@"%@", @(value)];
    }
    if (strcmp(returnType, @encode(unsigned long long)) == 0) {
        unsigned long long value = 0;
        [invocation getReturnValue:&value];
        return [NSString stringWithFormat:@"%@", @(value)];
    }
    if (strcmp(returnType, @encode(float)) == 0) {
        float value = 0;
        [invocation getReturnValue:&value];
        return [NSString stringWithFormat:@"%@", @(value)];
    }
    if (strcmp(returnType, @encode(double)) == 0) {
        double value = 0;
        [invocation getReturnValue:&value];
        return [NSString stringWithFormat:@"%@", @(value)];
    }
    if (strcmp(returnType, @encode(CGPoint)) == 0) {
        CGPoint value = CGPointZero;
        [invocation getReturnValue:&value];
        return NSStringFromCGPoint(value);
    }
    if (strcmp(returnType, @encode(CGSize)) == 0) {
        CGSize value = CGSizeZero;
        [invocation getReturnValue:&value];
        return NSStringFromCGSize(value);
    }
    if (strcmp(returnType, @encode(CGRect)) == 0) {
        CGRect value = CGRectZero;
        [invocation getReturnValue:&value];
        return NSStringFromCGRect(value);
    }
    if (returnType[0] == '@') {
        __unsafe_unretained id value = nil;
        [invocation getReturnValue:&value];
        if ([value isKindOfClass:NSObject.class]) {
            resultObject[@"object"] = [self identityForObject:value prefix:@"ios-object"];
        }
        return [value description] ?: @"nil";
    }
    return [NSString stringWithFormat:@"Return type %s is not supported.", returnType];
}

- (UIView *)viewForDisplayItemID:(NSString *)displayItemID {
    if ([displayItemID hasPrefix:@"ios-layer:"]) {
        unsigned long oid = strtoul([[displayItemID componentsSeparatedByString:@":"] lastObject].UTF8String, NULL, 16);
        CALayer *layer = [self layerForOid:oid];
        return layer.pv_inspect_hostView;
    }
    for (UIWindow *window in [self allUIKitWindows]) {
        UIView *matchedView = [self viewInView:window matchingDisplayItemID:displayItemID];
        if (matchedView) {
            return matchedView;
        }
    }
    return nil;
}

- (UIView *)viewInView:(UIView *)view matchingDisplayItemID:(NSString *)displayItemID {
    if ([[self identifierForObject:view prefix:@"ios-view"] isEqualToString:displayItemID]) {
        return view;
    }
    for (UIView *subview in view.subviews) {
        UIView *matchedView = [self viewInView:subview matchingDisplayItemID:displayItemID];
        if (matchedView) {
            return matchedView;
        }
    }
    return nil;
}

- (NSData *)imageDataForView:(UIView *)view includeSubviews:(BOOL)includeSubviews lowQuality:(BOOL)lowQuality {
    if (view.isHidden || CGRectIsEmpty(view.bounds) || ![self canCreateImageContextWithSize:view.bounds.size]) {
        return nil;
    }
    NSArray<UIView *> *hiddenSubviews = includeSubviews ? @[] : [self hideVisibleSubviewsOfView:view];
    CGFloat renderScale = [self renderScaleForView:view lowQuality:lowQuality];
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, renderScale);
    CGRect drawRect = CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height);
    BOOL drewHierarchy = [view drawViewHierarchyInRect:drawRect afterScreenUpdates:YES];
    if (!drewHierarchy) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (context) {
            [view.layer renderInContext:context];
        }
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self restoreHiddenSubviews:hiddenSubviews];

    return image ? UIImagePNGRepresentation(image) : nil;
}

- (NSData *)imageDataForLayer:(CALayer *)layer includeSublayers:(BOOL)includeSublayers lowQuality:(BOOL)lowQuality {
    if (layer.isHidden || CGRectIsEmpty(layer.bounds) || ![self canCreateImageContextWithSize:layer.bounds.size]) {
        return nil;
    }
    UIView *hostView = layer.pv_inspect_hostView;
    if (hostView) {
        return [self imageDataForView:hostView includeSubviews:includeSublayers lowQuality:lowQuality];
    }

    CGFloat screenScale = layer.contentsScale > 0 ? layer.contentsScale : 1;
    CGFloat renderScale = lowQuality ? 1 : 0;
    CGSize size = layer.bounds.size;
    CGFloat maxPixelLength = MAX(size.width * screenScale, size.height * screenScale);
    CGFloat maxAllowedPixelLength = 16384;
    if (maxPixelLength > maxAllowedPixelLength) {
        renderScale = MIN(screenScale * maxAllowedPixelLength / maxPixelLength, 1);
    }

    NSArray<CALayer *> *visibleSublayers = includeSublayers ? @[] : [self hideVisibleSublayersOfLayer:layer];
    UIGraphicsBeginImageContextWithOptions(size, NO, renderScale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context) {
        [layer renderInContext:context];
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self restoreHiddenSublayers:visibleSublayers];

    return image ? UIImagePNGRepresentation(image) : nil;
}

- (NSArray<CALayer *> *)hideVisibleSublayersOfLayer:(CALayer *)layer {
    NSMutableArray<CALayer *> *hiddenSublayers = [NSMutableArray array];
    for (CALayer *sublayer in layer.sublayers) {
        if (!sublayer.isHidden) {
            sublayer.hidden = YES;
            [hiddenSublayers addObject:sublayer];
        }
    }
    return hiddenSublayers.copy;
}

- (void)restoreHiddenSublayers:(NSArray<CALayer *> *)hiddenSublayers {
    for (CALayer *sublayer in hiddenSublayers) {
        sublayer.hidden = NO;
    }
}

- (NSArray<UIView *> *)hideVisibleSubviewsOfView:(UIView *)view {
    NSMutableArray<UIView *> *hiddenSubviews = [NSMutableArray array];
    for (UIView *subview in view.subviews) {
        if (!subview.isHidden) {
            subview.hidden = YES;
            [hiddenSubviews addObject:subview];
        }
    }
    return hiddenSubviews.copy;
}

- (void)restoreHiddenSubviews:(NSArray<UIView *> *)hiddenSubviews {
    for (UIView *subview in hiddenSubviews) {
        subview.hidden = NO;
    }
}

- (CGFloat)renderScaleForView:(UIView *)view lowQuality:(BOOL)lowQuality {
    CGFloat screenScale = view.traitCollection.displayScale;
    if (screenScale <= 0) {
        screenScale = 1;
    }
    CGFloat renderScale = lowQuality ? 1 : 0;
    CGSize size = view.bounds.size;
    CGFloat maxPixelLength = MAX(size.width * screenScale, size.height * screenScale);
    CGFloat maxAllowedPixelLength = 16384;
    if (maxPixelLength > maxAllowedPixelLength) {
        renderScale = MIN(screenScale * maxAllowedPixelLength / maxPixelLength, 1);
    }
    return renderScale;
}

- (BOOL)canCreateImageContextWithSize:(CGSize)size {
    return size.width > 0 && size.height > 0 && size.width <= 20000 && size.height <= 20000;
}

- (PVDisplayItem *)displayItemForView:(UIView *)view {
    return [self displayItemForLayer:view.layer];
}

- (PVDisplayItem *)displayItemForLayer:(CALayer *)layer {
    UIView *view = layer.pv_inspect_hostView;
    BOOL isFlutterHost = view != nil &&
        [self.flutterCoordinator isFlutterHostView:view];
    PVDisplayItem *item = [[PVDisplayItem alloc] init];
    item.objectID = [self identifierForObject:layer prefix:@"ios-layer"];
    item.displayName = NSStringFromClass(view ? view.class : layer.class);
    item.viewClassName = view ? NSStringFromClass(view.class) : @"";
    item.layerClassName = NSStringFromClass(layer.class);
    item.layerObject = [self identityForObject:layer prefix:@"ios-layer"];
    item.frame = layer.frame;
    item.bounds = layer.bounds;
    item.isHidden = layer.isHidden;
    item.hidden = layer.isHidden;
    item.alpha = layer.opacity;
    item.attributesGroupList = [PVAttrGroupsMaker attrGroupsForLayer:layer];
    // Flutter may paint all pixels into its own Metal-backed layer without
    // exposing UIKit subviews. Keep the host as a screenshot source when VM
    // Inspector is unavailable.
    item.shouldCaptureImage = isFlutterHost || [self shouldCaptureImageForLayer:layer];

    if (view) {
        item.viewObject = [self identityForObject:view prefix:@"ios-view"];
        item.backgroundColorText = [self colorTextForColor:view.backgroundColor];
        item.backgroundColor = view.backgroundColor;
        item.eventHandlers = [self eventHandlersForView:view];
        UIViewController *viewController = [self hostViewControllerForView:view];
        if (viewController) {
            item.hostViewControllerObject = [self identityForObject:viewController prefix:@"ios-view-controller"];
        }
    } else if (layer.backgroundColor) {
        UIColor *backgroundColor = [UIColor colorWithCGColor:layer.backgroundColor];
        item.backgroundColorText = [self colorTextForColor:backgroundColor];
        item.backgroundColor = backgroundColor;
    }

    PVCustomAttrGroupsMaker *maker = [[PVCustomAttrGroupsMaker alloc] initWithLayer:layer];
    [maker execute];
    item.customAttrGroupList = [maker getGroups] ?: @[];
    item.customDisplayTitle = [maker getCustomDisplayTitle];
    item.danceuiSource = [maker getDanceUISource];

    NSMutableArray<PVDisplayItem *> *children = [NSMutableArray arrayWithCapacity:layer.sublayers.count];
    NSArray<PVDisplayItem *> *flutterItems = view
        ? [self.flutterCoordinator virtualItemsForHostView:view] : @[];
    if (flutterItems.count == 0) {
        flutterItems = [self.flutterCoordinator virtualItemsForHostLayer:layer];
    }
    if (flutterItems.count) {
        item.flutterLoadState = PVFlutterLoadStateLoaded;
        NSLog(@"PV_FLUTTER_HIERARCHY_ATTACHED layer=%@ view=%@ rootItems=%@",
              layer, view, @(flutterItems.count));
        [children addObjectsFromArray:flutterItems];
    } else if (isFlutterHost) {
        // Return the normal UIKit hierarchy immediately with the Flutter host
        // as a placeholder. Its asynchronous detail response installs the
        // Inspector subtree after KKFlutterInspectorKit finishes loading it.
        item.flutterLoadState = PVFlutterLoadStateLoading;
    } else {
        for (CALayer *sublayer in layer.sublayers) {
            [children addObject:[self displayItemForLayer:sublayer]];
        }
    }
    [children addObjectsFromArray:[self customDisplayItemsForLayer:layer saveAttrSetter:YES]];
    item.subitems = children.copy;
    item.children = children.copy;
    return item;
}

- (PVObject *)identityForObject:(id)object prefix:(NSString *)prefix {
    [self registerObject:object];
    PVObject *identity = [[PVObject alloc] init];
    identity.oid = (unsigned long)(uintptr_t)object;
    identity.memoryAddress = [NSString stringWithFormat:@"%p", object];
    identity.classChainList = [self classChainForObject:object];
    identity.ivarTraces = [self ivarTracesForObject:object];
    identity.specialTrace = [self specialTraceForObject:object];
    return identity;
}

- (void)reloadIvarTraces {
    NSHashTable<NSObject *> *objects = [NSHashTable hashTableWithOptions:NSPointerFunctionsObjectPointerPersonality];
    for (UIWindow *window in [self allUIKitWindows]) {
        [self collectTraceObjectsFromLayer:window.layer intoTable:objects];
    }
    for (NSObject *object in objects) {
        object.lks_ivarTraces = nil;
    }
    for (NSObject *object in objects) {
        [self markIvarTracesForHostObject:object targetClass:object.class];
    }
}

- (void)collectTraceObjectsFromLayer:(CALayer *)layer intoTable:(NSHashTable<NSObject *> *)objects {
    [objects addObject:layer];
    UIView *view = layer.pv_inspect_hostView;
    if (view) {
        [objects addObject:view];
        UIViewController *viewController = [self hostViewControllerForView:view];
        if (viewController) {
            [objects addObject:viewController];
        }
        for (UIGestureRecognizer *recognizer in view.gestureRecognizers) {
            [objects addObject:recognizer];
        }
    }
    for (CALayer *sublayer in layer.sublayers.copy) {
        [self collectTraceObjectsFromLayer:sublayer intoTable:objects];
    }
}

- (void)markIvarTracesForHostObject:(NSObject *)hostObject targetClass:(Class)targetClass {
    if (!targetClass) {
        return;
    }
    NSString *className = NSStringFromClass(targetClass);
    for (NSString *prefix in @[@"NSObject", @"UIResponder", @"UIButton", @"UIButtonLabel"]) {
        if ([className hasPrefix:prefix]) {
            return;
        }
    }

    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList(targetClass, &count);
    for (unsigned int index = 0; index < count; index++) {
        Ivar ivar = ivars[index];
        const char *typeEncoding = ivar_getTypeEncoding(ivar);
        NSString *type = typeEncoding ? [NSString stringWithUTF8String:typeEncoding] : @"";
        if (![type hasPrefix:@"@\""] || type.length <= 3) {
            continue;
        }
        NSString *ivarClassName = [type substringWithRange:NSMakeRange(2, type.length - 3)];
        Class ivarClass = NSClassFromString(ivarClassName);
        if (![ivarClass isSubclassOfClass:UIView.class] &&
            ![ivarClass isSubclassOfClass:CALayer.class] &&
            ![ivarClass isSubclassOfClass:UIViewController.class] &&
            ![ivarClass isSubclassOfClass:UIGestureRecognizer.class]) {
            continue;
        }
        NSObject *referencedObject = object_getIvar(hostObject, ivar);
        if (![referencedObject isKindOfClass:NSObject.class]) {
            continue;
        }

        PVIvarTrace *trace = [[PVIvarTrace alloc] init];
        trace.hostObject = hostObject;
        trace.hostClassName = [self displayClassNameForClass:targetClass childClass:hostObject.class];
        const char *name = ivar_getName(ivar);
        trace.ivarName = name ? [NSString stringWithUTF8String:name] : @"";
        if ([self isInvalidIvarTrace:trace]) {
            continue;
        }
        if (hostObject == referencedObject) {
            trace.relation = PVIvarTraceRelationValue_Self;
        } else if ([hostObject isKindOfClass:UIView.class]) {
            CALayer *referencedLayer = [referencedObject isKindOfClass:CALayer.class] ? (CALayer *)referencedObject :
                ([referencedObject isKindOfClass:UIView.class] ? ((UIView *)referencedObject).layer : nil);
            if (referencedLayer.superlayer == ((UIView *)hostObject).layer) {
                trace.relation = @"superview";
            }
        }
        NSArray<PVIvarTrace *> *traces = referencedObject.lks_ivarTraces ?: @[];
        if (![traces containsObject:trace]) {
            referencedObject.lks_ivarTraces = [traces arrayByAddingObject:trace];
        }
    }
    free(ivars);
    [self markIvarTracesForHostObject:hostObject targetClass:class_getSuperclass(targetClass)];
}

- (BOOL)isInvalidIvarTrace:(PVIvarTrace *)trace {
    NSDictionary<NSString *, NSSet<NSString *> *> *invalid = @{
        @"UIView": [NSSet setWithObjects:@"_window", @"_viewDelegate", nil],
        @"UIViewController": [NSSet setWithObjects:@"_view", @"_parentViewController", nil]
    };
    return [invalid[trace.hostClassName] containsObject:trace.ivarName];
}

- (NSString *)displayClassNameForClass:(Class)targetClass childClass:(Class)childClass {
    NSString *targetName = NSStringFromClass(targetClass);
    NSString *childName = NSStringFromClass(childClass);
    return [targetName isEqualToString:childName] ? targetName : [NSString stringWithFormat:@"%@ : %@", childName, targetName];
}

- (NSArray<PVIvarTrace *> *)ivarTracesForObject:(NSObject *)object {
    NSMutableArray<PVIvarTrace *> *traces = [NSMutableArray array];
    if ([object isKindOfClass:CALayer.class]) {
        UIView *view = ((CALayer *)object).pv_inspect_hostView;
        UIViewController *viewController = view ? [self hostViewControllerForView:view] : nil;
        [traces addObjectsFromArray:viewController.lks_ivarTraces ?: @[]];
        [traces addObjectsFromArray:view.lks_ivarTraces ?: @[]];
    }
    [traces addObjectsFromArray:object.lks_ivarTraces ?: @[]];
    return traces.copy;
}

- (NSString *)specialTraceForObject:(NSObject *)object {
    UIView *view = [object isKindOfClass:UIView.class] ? (UIView *)object :
        ([object isKindOfClass:CALayer.class] ? ((CALayer *)object).pv_inspect_hostView : nil);
    if (!view) {
        return nil;
    }
    UIViewController *viewController = [self hostViewControllerForView:view];
    if (viewController.view == view) {
        return [NSString stringWithFormat:@"%@.view", NSStringFromClass(viewController.class)];
    }
    if ([view isKindOfClass:UIWindow.class]) {
        UIWindow *window = (UIWindow *)view;
        return window.isKeyWindow ? [NSString stringWithFormat:@"KeyWindow ( Level: %@ )", @(window.windowLevel)] :
            [NSString stringWithFormat:@"WindowLevel: %@", @(window.windowLevel)];
    }
    UITableViewCell *tableCell = [self ancestorOfView:view matchingClass:UITableViewCell.class];
    if (tableCell.backgroundView == view) {
        return @"cell.backgroundView";
    }
    if (tableCell.accessoryView == view) {
        return @"cell.accessoryView";
    }
    if ([view isKindOfClass:UITableViewCell.class]) {
        UITableView *tableView = [self ancestorOfView:view matchingClass:UITableView.class];
        NSIndexPath *indexPath = [tableView indexPathForCell:(UITableViewCell *)view];
        if (indexPath) {
            return [NSString stringWithFormat:@"{ sec:%@, row:%@ }", @(indexPath.section), @(indexPath.row)];
        }
    }
    if ([view isKindOfClass:UICollectionViewCell.class]) {
        UICollectionView *collectionView = [self ancestorOfView:view matchingClass:UICollectionView.class];
        NSIndexPath *indexPath = [collectionView indexPathForCell:(UICollectionViewCell *)view];
        if (indexPath) {
            return [NSString stringWithFormat:@"{ item:%@, sec:%@ }", @(indexPath.item), @(indexPath.section)];
        }
    }
    UITableViewHeaderFooterView *headerFooterView = [self ancestorOfView:view matchingClass:UITableViewHeaderFooterView.class];
    if (headerFooterView.textLabel == view) {
        return @"sectionHeaderFooter.textLabel";
    }
    if (headerFooterView.detailTextLabel == view) {
        return @"sectionHeaderFooter.detailTextLabel";
    }

    UITableView *tableView = [self ancestorOfView:view matchingClass:UITableView.class];
    for (NSInteger section = 0; section < tableView.numberOfSections; section++) {
        if ([tableView headerViewForSection:section] == view) {
            return [NSString stringWithFormat:@"sectionHeader { sec: %@ }", @(section)];
        }
        if ([tableView footerViewForSection:section] == view) {
            return [NSString stringWithFormat:@"sectionFooter { sec: %@ }", @(section)];
        }
    }

    UICollectionView *collectionView = [self ancestorOfView:view matchingClass:UICollectionView.class];
    if (collectionView.backgroundView == view) {
        return @"collectionView.backgroundView";
    }
    for (NSIndexPath *indexPath in [collectionView indexPathsForVisibleSupplementaryElementsOfKind:UICollectionElementKindSectionHeader]) {
        if ([collectionView supplementaryViewForElementKind:UICollectionElementKindSectionHeader atIndexPath:indexPath] == view) {
            return [NSString stringWithFormat:@"sectionHeader { sec:%@ }", @(indexPath.section)];
        }
    }
    for (NSIndexPath *indexPath in [collectionView indexPathsForVisibleSupplementaryElementsOfKind:UICollectionElementKindSectionFooter]) {
        if ([collectionView supplementaryViewForElementKind:UICollectionElementKindSectionFooter atIndexPath:indexPath] == view) {
            return [NSString stringWithFormat:@"sectionFooter { sec:%@ }", @(indexPath.section)];
        }
    }
    return nil;
}

- (__kindof UIView *)ancestorOfView:(UIView *)view matchingClass:(Class)targetClass {
    UIView *currentView = view.superview;
    while (currentView && ![currentView isKindOfClass:targetClass]) {
        currentView = currentView.superview;
    }
    return currentView;
}

- (unsigned long)registerObject:(id)object {
    if (!object) {
        return 0;
    }
    unsigned long oid = (unsigned long)(uintptr_t)object;
    [self.objectRegistry setObject:object forKey:@(oid)];
    return oid;
}

- (UIViewController *)hostViewControllerForView:(UIView *)view {
    UIResponder *responder = view;
    while ((responder = responder.nextResponder)) {
        if ([responder isKindOfClass:UIViewController.class]) {
            return (UIViewController *)responder;
        }
    }
    return nil;
}

- (NSArray<PVEventHandler *> *)eventHandlersForView:(UIView *)view {
    NSMutableArray<PVEventHandler *> *handlers = [NSMutableArray array];
    if ([view isKindOfClass:UIControl.class]) {
        [handlers addObjectsFromArray:[self targetActionHandlersForControl:(UIControl *)view]];
    }
    [handlers addObjectsFromArray:[self gestureHandlersForView:view]];
    return handlers.copy;
}

- (NSArray<PVEventHandler *> *)targetActionHandlersForControl:(UIControl *)control {
    static NSArray<NSNumber *> *events;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        events = @[@(UIControlEventTouchDown), @(UIControlEventTouchDownRepeat), @(UIControlEventTouchDragInside),
                   @(UIControlEventTouchDragOutside), @(UIControlEventTouchDragEnter), @(UIControlEventTouchDragExit),
                   @(UIControlEventTouchUpInside), @(UIControlEventTouchUpOutside), @(UIControlEventTouchCancel),
                   @(UIControlEventValueChanged), @(UIControlEventEditingDidBegin), @(UIControlEventEditingChanged),
                   @(UIControlEventEditingDidEnd), @(UIControlEventEditingDidEndOnExit), @(UIControlEventPrimaryActionTriggered)];
    });

    NSMutableArray<PVEventHandler *> *handlers = [NSMutableArray array];
    for (NSNumber *eventNumber in events) {
        UIControlEvents event = eventNumber.unsignedIntegerValue;
        NSMutableArray<PVStringTwoTuple *> *targetActions = [NSMutableArray array];
        for (id target in control.allTargets) {
            [self registerObject:target];
            for (NSString *action in [control actionsForTarget:target forControlEvent:event]) {
                [targetActions addObject:[PVStringTwoTuple tupleWithFirst:[self descriptionForObject:target] second:action]];
            }
        }
        if (targetActions.count) {
            PVEventHandler *handler = [[PVEventHandler alloc] init];
            handler.handlerType = PVEventHandlerTypeTargetAction;
            handler.eventName = [self nameForControlEvent:event];
            handler.targetActions = targetActions.copy;
            [handlers addObject:handler];
        }
    }
    return handlers.copy;
}

- (NSArray<PVEventHandler *> *)gestureHandlersForView:(UIView *)view {
    NSMutableArray<PVEventHandler *> *handlers = [NSMutableArray arrayWithCapacity:view.gestureRecognizers.count];
    for (UIGestureRecognizer *recognizer in view.gestureRecognizers) {
        PVEventHandler *handler = [[PVEventHandler alloc] init];
        handler.handlerType = PVEventHandlerTypeGesture;
        handler.eventName = NSStringFromClass(recognizer.class);
        handler.targetActions = [self targetActionsForGestureRecognizer:recognizer];
        handler.inheritedRecognizerName = [self inheritedRecognizerNameForRecognizer:recognizer];
        handler.gestureRecognizerIsEnabled = recognizer.enabled;
        handler.gestureRecognizerDelegator = recognizer.delegate ? [self descriptionForObject:recognizer.delegate] : nil;
        handler.recognizerIvarTraces = recognizer.lks_ivarTraces ?: @[];
        handler.recognizerOid = [self registerObject:recognizer];
        [handlers addObject:handler];
    }
    return handlers.copy;
}

- (NSArray<PVStringTwoTuple *> *)targetActionsForGestureRecognizer:(UIGestureRecognizer *)recognizer {
    @try {
        NSArray *targetBoxes = [recognizer valueForKey:@"_targets"];
        NSMutableArray<PVStringTwoTuple *> *targetActions = [NSMutableArray arrayWithCapacity:targetBoxes.count];
        for (id targetBox in targetBoxes) {
            id target = [targetBox valueForKey:@"_target"];
            Ivar actionIvar = class_getInstanceVariable([targetBox class], "_action");
            if (!target || !actionIvar) {
                continue;
            }
            SEL action = ((SEL (*)(id, Ivar))object_getIvar)(targetBox, actionIvar);
            [self registerObject:target];
            [targetActions addObject:[PVStringTwoTuple tupleWithFirst:[self descriptionForObject:target]
                                                               second:action ? NSStringFromSelector(action) : @"NULL"]];
        }
        return targetActions.copy;
    } @catch (NSException *exception) {
        NSLog(@"[PickView Server] Failed to inspect gesture targets: %@", exception.reason);
        return @[];
    }
}

- (NSString *)inheritedRecognizerNameForRecognizer:(UIGestureRecognizer *)recognizer {
    NSArray<Class> *baseClasses = @[UILongPressGestureRecognizer.class, UIScreenEdgePanGestureRecognizer.class,
                                    UIPanGestureRecognizer.class, UISwipeGestureRecognizer.class,
                                    UIRotationGestureRecognizer.class, UIPinchGestureRecognizer.class,
                                    UITapGestureRecognizer.class];
    for (Class baseClass in baseClasses) {
        if ([recognizer isMemberOfClass:baseClass]) {
            return nil;
        }
        if ([recognizer isKindOfClass:baseClass]) {
            return NSStringFromClass(baseClass);
        }
    }
    return @"UIGestureRecognizer";
}

- (NSString *)nameForControlEvent:(UIControlEvents)event {
    NSDictionary<NSNumber *, NSString *> *names = @{
        @(UIControlEventTouchDown): @"UIControlEventTouchDown", @(UIControlEventTouchDownRepeat): @"UIControlEventTouchDownRepeat",
        @(UIControlEventTouchDragInside): @"UIControlEventTouchDragInside", @(UIControlEventTouchDragOutside): @"UIControlEventTouchDragOutside",
        @(UIControlEventTouchDragEnter): @"UIControlEventTouchDragEnter", @(UIControlEventTouchDragExit): @"UIControlEventTouchDragExit",
        @(UIControlEventTouchUpInside): @"UIControlEventTouchUpInside", @(UIControlEventTouchUpOutside): @"UIControlEventTouchUpOutside",
        @(UIControlEventTouchCancel): @"UIControlEventTouchCancel", @(UIControlEventValueChanged): @"UIControlEventValueChanged",
        @(UIControlEventEditingDidBegin): @"UIControlEventEditingDidBegin", @(UIControlEventEditingChanged): @"UIControlEventEditingChanged",
        @(UIControlEventEditingDidEnd): @"UIControlEventEditingDidEnd", @(UIControlEventEditingDidEndOnExit): @"UIControlEventEditingDidEndOnExit",
        @(UIControlEventPrimaryActionTriggered): @"UIControlEventPrimaryActionTriggered"
    };
    return names[@(event)] ?: [NSString stringWithFormat:@"UIControlEvent(%lu)", (unsigned long)event];
}

- (NSString *)descriptionForObject:(id)object {
    return object ? [NSString stringWithFormat:@"<%@: %p>", NSStringFromClass([object class]), object] : @"nil";
}

- (NSArray<PVDisplayItem *> *)customDisplayItemsForLayer:(CALayer *)layer saveAttrSetter:(BOOL)saveAttrSetter {
    NSMutableArray<PVDisplayItem *> *items = [NSMutableArray array];
    NSMutableArray<NSString *> *selectorNames = [NSMutableArray arrayWithObjects:@"pickview_customDebugInfos", @"lookin_customDebugInfos", nil];
    for (NSInteger index = 0; index < 5; index++) {
        [selectorNames addObject:[NSString stringWithFormat:@"pickview_customDebugInfos_%ld", (long)index]];
        [selectorNames addObject:[NSString stringWithFormat:@"lookin_customDebugInfos_%ld", (long)index]];
    }
    for (id target in @[layer, layer.pv_inspect_hostView ?: NSNull.null]) {
        if (target == NSNull.null) {
            continue;
        }
        for (NSString *selectorName in selectorNames) {
            NSDictionary *rawInfo = [self dictionaryByInvokingSelectorName:selectorName target:target];
            [items addObjectsFromArray:[self customDisplayItemsFromRawArray:rawInfo[@"subviews"] saveAttrSetter:saveAttrSetter]];
        }
    }
    return items.copy;
}

- (NSArray<PVDisplayItem *> *)customDisplayItemsFromRawArray:(NSArray *)rawArray saveAttrSetter:(BOOL)saveAttrSetter {
    if (![rawArray isKindOfClass:NSArray.class]) {
        return @[];
    }
    NSMutableArray<PVDisplayItem *> *items = [NSMutableArray array];
    for (NSDictionary *rawItem in rawArray) {
        if (![rawItem isKindOfClass:NSDictionary.class] || ![rawItem[@"title"] isKindOfClass:NSString.class]) {
            continue;
        }
        PVDisplayItem *item = [[PVDisplayItem alloc] init];
        item.objectID = [NSString stringWithFormat:@"custom:%@", NSUUID.UUID.UUIDString];
        item.displayName = rawItem[@"title"];
        item.isHidden = NO;
        item.hidden = NO;
        item.alpha = 1;
        item.customInfo = [[PVCustomDisplayItemInfo alloc] init];
        item.customInfo.title = rawItem[@"title"];
        item.customInfo.subtitle = [rawItem[@"subtitle"] isKindOfClass:NSString.class] ? rawItem[@"subtitle"] : nil;
        item.customInfo.frameInWindow = [rawItem[@"frameInWindow"] isKindOfClass:NSValue.class] ? rawItem[@"frameInWindow"] : nil;
        item.customInfo.danceuiSource = rawItem[@"pickview_source"] ?: rawItem[@"lookin_source"];
        item.customAttrGroupList = [PVCustomAttrGroupsMaker makeGroupsFromRawProperties:rawItem[@"properties"] saveCustomSetter:saveAttrSetter] ?: @[];
        item.subitems = [self customDisplayItemsFromRawArray:rawItem[@"subviews"] saveAttrSetter:saveAttrSetter];
        item.children = item.subitems;
        [items addObject:item];
    }
    return items.copy;
}

- (NSDictionary *)dictionaryByInvokingSelectorName:(NSString *)selectorName target:(id)target {
    SEL selector = NSSelectorFromString(selectorName);
    if (![target respondsToSelector:selector]) {
        return @{};
    }
    NSMethodSignature *signature = [target methodSignatureForSelector:selector];
    if (signature.numberOfArguments != 2 || signature.methodReturnLength == 0) {
        return @{};
    }
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = target;
    invocation.selector = selector;
    [invocation invoke];
    __unsafe_unretained id result = nil;
    [invocation getReturnValue:&result];
    return [result isKindOfClass:NSDictionary.class] ? result : @{};
}

- (BOOL)shouldCaptureImageForLayer:(CALayer *)layer {
    if (![self classShouldCaptureObject:layer selectorNames:@[@"pickview_shouldCaptureImageOfLayer:", @"lookin_shouldCaptureImageOfLayer:"]]) {
        return NO;
    }
    UIView *view = layer.pv_inspect_hostView;
    if (view && ![self classShouldCaptureObject:view selectorNames:@[@"pickview_shouldCaptureImageOfView:", @"lookin_shouldCaptureImageOfView:"]]) {
        return NO;
    }
    for (id target in @[layer, layer.pv_inspect_hostView ?: NSNull.null]) {
        if (target == NSNull.null) continue;
        for (NSString *selectorName in @[@"pickview_shouldCaptureImage", @"lookin_shouldCaptureImage"]) {
            SEL selector = NSSelectorFromString(selectorName);
            if ([target respondsToSelector:selector]) {
                BOOL (*function)(id, SEL) = (BOOL (*)(id, SEL))[target methodForSelector:selector];
                if (function && !function(target, selector)) return NO;
            }
        }
    }
    return YES;
}

- (BOOL)classShouldCaptureObject:(id)object selectorNames:(NSArray<NSString *> *)selectorNames {
    for (NSString *selectorName in selectorNames) {
        SEL selector = NSSelectorFromString(selectorName);
        if (![NSObject respondsToSelector:selector]) {
            continue;
        }
        NSMethodSignature *signature = [NSObject methodSignatureForSelector:selector];
        if (signature.numberOfArguments != 3) {
            continue;
        }
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        invocation.target = NSObject.class;
        invocation.selector = selector;
        __unsafe_unretained id argument = object;
        [invocation setArgument:&argument atIndex:2];
        [invocation invoke];
        BOOL result = YES;
        [invocation getReturnValue:&result];
        if (!result) {
            return NO;
        }
    }
    return YES;
}

- (NSArray<NSString *> *)configuredCollapsedClassList {
    id value = [self classValueForSelectorNames:@[@"pickview_collapsedClassList", @"lookin_collapsedClassList"]];
    return [value isKindOfClass:NSArray.class] ? value : @[];
}

- (NSDictionary *)configuredColorAlias {
    id value = [self classValueForSelectorNames:@[@"pickview_colorAlias", @"lookin_colorAlias"]];
    return [value isKindOfClass:NSDictionary.class] ? value : @{};
}

- (id)classValueForSelectorNames:(NSArray<NSString *> *)selectorNames {
    for (NSString *selectorName in selectorNames) {
        SEL selector = NSSelectorFromString(selectorName);
        if ([NSObject respondsToSelector:selector]) {
            id (*function)(id, SEL) = (id (*)(id, SEL))[NSObject methodForSelector:selector];
            id value = function ? function(NSObject.class, selector) : nil;
            if (value) return value;
        }
    }
    return nil;
}

- (NSArray<NSString *> *)classChainForObject:(id)object {
    NSMutableArray<NSString *> *classes = [NSMutableArray array];
    Class currentClass = [object class];
    while (currentClass) {
        [classes addObject:NSStringFromClass(currentClass)];
        currentClass = class_getSuperclass(currentClass);
    }
    return classes.copy;
}

- (NSString *)identifierForObject:(id)object prefix:(NSString *)prefix {
    return [NSString stringWithFormat:@"%@:%p", prefix, object];
}

- (NSString *)colorTextForColor:(UIColor *)color {
    if (!color) {
        return @"";
    }

    CGFloat red = 0;
    CGFloat green = 0;
    CGFloat blue = 0;
    CGFloat alpha = 0;
    if (![color getRed:&red green:&green blue:&blue alpha:&alpha]) {
        return color.description ?: @"";
    }
    return [NSString stringWithFormat:@"rgba(%.0f, %.0f, %.0f, %.2f)", red * 255, green * 255, blue * 255, alpha];
}
#endif

- (NSError *)unsupportedPlatformError {
    return [self errorWithCode:PVErrorCodeUnsupportedEndpoint description:@"UIKit hierarchy provider is unavailable on this platform."];
}

- (NSError *)errorWithCode:(NSInteger)code description:(NSString *)description {
    return [NSError errorWithDomain:PVErrorDomain
                               code:code
                           userInfo:@{NSLocalizedDescriptionKey: description ?: @"PickView inspection failed."}];
}

@end

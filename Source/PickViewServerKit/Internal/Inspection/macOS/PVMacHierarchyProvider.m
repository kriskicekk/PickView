//
//  PVMacHierarchyProvider.m
//  PickViewServer
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVMacHierarchyProvider.h"

#import "PVAppInfo.h"
#import "PVAppInfoCollector.h"
#import "Color+PVInspect.h"
#import "PVAttribute.h"
#import "PVAttributeModification.h"
#import "PVAttributesGroup.h"
#import "PVAttributesSection.h"
#import "PVCustomAttrModification.h"
#import "PVCustomAttrSetterManager.h"
#import "PVDisplayItem.h"
#import "PVDisplayItemDetail.h"
#import "PVErrorCode.h"
#import "PVEventHandler.h"
#import "PVHierarchyInfo.h"
#import "PVInspectionDefines.h"
#import "PVObject.h"
#import "PVStaticAsyncUpdateTask.h"
#import "PVTuple.h"
#import "PVWindowInfo.h"

#import <objc/runtime.h>
#import <TargetConditionals.h>

#if !TARGET_OS_IPHONE && TARGET_OS_OSX
#import <AppKit/AppKit.h>
#import <QuartzCore/QuartzCore.h>
#endif

@interface PVMacHierarchyProvider ()
@property (nonatomic, strong) NSMapTable<NSNumber *, id> *objectRegistry;
@end

@implementation PVMacHierarchyProvider

- (instancetype)init {
    self = [super init];
    if (self) {
        _objectRegistry = [NSMapTable strongToWeakObjectsMapTable];
    }
    return self;
}

- (NSArray<PVWindowInfo *> *)allWindows {
#if !TARGET_OS_IPHONE && TARGET_OS_OSX
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
#if !TARGET_OS_IPHONE && TARGET_OS_OSX
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
                                 userInfo:@{NSLocalizedDescriptionKey: @"AppKit hierarchy provider is unavailable on this platform."}];
    }
    return nil;
#endif
}

- (NSArray<PVDisplayItemDetail *> *)detailsForDisplayItemIDs:(NSArray<NSString *> *)displayItemIDs
                                              needsSoloImage:(BOOL)needsSoloImage
                                             needsGroupImage:(BOOL)needsGroupImage
                                             lowImageQuality:(BOOL)lowImageQuality {
#if !TARGET_OS_IPHONE && TARGET_OS_OSX
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
#if !TARGET_OS_IPHONE && TARGET_OS_OSX
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
#if !TARGET_OS_IPHONE && TARGET_OS_OSX
    if (!NSThread.isMainThread) {
        __block PVDisplayItemDetail *detail = nil;
        __block NSError *innerError = nil;
        dispatch_sync(dispatch_get_main_queue(), ^{
            detail = [self modifyAttributeOnMainThread:modification error:&innerError];
        });
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
    if (!modification.customSetterID.length) {
        if (error) *error = PVInspectErr_Inner;
        return NO;
    }
    PVCustomAttrSetterManager *manager = [PVCustomAttrSetterManager sharedInstance];
    switch (modification.attrType) {
        case PVAttrTypeNSString: {
            PVStringSetter setter = [manager getStringSetterWithID:modification.customSetterID];
            if (!setter) break;
            ((PVStringSetter)setter)(modification.value);
            return YES;
        }
        case PVAttrTypeDouble: {
            PVNumberSetter setter = [manager getNumberSetterWithID:modification.customSetterID];
            if (!setter) break;
            ((PVNumberSetter)setter)(modification.value);
            return YES;
        }
        case PVAttrTypeBOOL: {
            PVBoolSetter setter = [manager getBoolSetterWithID:modification.customSetterID];
            if (!setter) break;
            ((PVBoolSetter)setter)([modification.value boolValue]);
            return YES;
        }
        case PVAttrTypeUIColor: {
            PVColorSetter setter = [manager getColorSetterWithID:modification.customSetterID];
            if (!setter) break;
            NSColor *color = modification.value ? [NSColor pv_inspect_colorFromRGBAComponents:modification.value] : nil;
            ((PVColorSetter)setter)(color);
            return YES;
        }
        case PVAttrTypeEnumString: {
            PVEnumSetter setter = [manager getEnumSetterWithID:modification.customSetterID];
            if (!setter) break;
            ((PVEnumSetter)setter)(modification.value);
            return YES;
        }
        case PVAttrTypeCGRect: {
            PVRectSetter setter = [manager getRectSetterWithID:modification.customSetterID];
            if (!setter) break;
            ((PVRectSetter)setter)([modification.value rectValue]);
            return YES;
        }
        case PVAttrTypeCGSize: {
            PVSizeSetter setter = [manager getSizeSetterWithID:modification.customSetterID];
            if (!setter) break;
            ((PVSizeSetter)setter)([modification.value sizeValue]);
            return YES;
        }
        case PVAttrTypeCGPoint: {
            PVPointSetter setter = [manager getPointSetterWithID:modification.customSetterID];
            if (!setter) break;
            ((PVPointSetter)setter)([modification.value pointValue]);
            return YES;
        }
        case PVAttrTypeUIEdgeInsets: {
            PVInsetsSetter setter = [manager getInsetsSetterWithID:modification.customSetterID];
            if (!setter) break;
            ((PVInsetsSetter)setter)([modification.value edgeInsetsValue]);
            return YES;
        }
        default:
            break;
    }
    if (error) *error = PVInspectErr_ObjNotFound;
    return NO;
}

- (PVObject *)objectWithOid:(unsigned long)oid error:(NSError **)error {
#if !TARGET_OS_IPHONE && TARGET_OS_OSX
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
#if !TARGET_OS_IPHONE && TARGET_OS_OSX
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
    id object = [self objectForOid:oid];
    if (![object isKindOfClass:NSImageView.class]) {
        if (error) *error = PVInspectErr_ObjNotFound;
        return nil;
    }
    NSImage *image = ((NSImageView *)object).image;
    return image.TIFFRepresentation;
}

- (NSArray<NSString *> *)selectorNamesForClassName:(NSString *)className hasArg:(BOOL)hasArg error:(NSError **)error {
    Class targetClass = NSClassFromString(className);
    if (!targetClass) {
        if (error) {
            NSString *message = [NSString stringWithFormat:@"Didn't find the class named \"%@\".", className ?: @""];
            *error = PVInspectErrorMake(message, @"");
        }
        return nil;
    }

    NSMutableArray<NSString *> *names = [NSMutableArray array];
    Class currentClass = targetClass;
    while (currentClass) {
        unsigned int methodCount = 0;
        Method *methods = class_copyMethodList(currentClass, &methodCount);
        for (unsigned int index = 0; index < methodCount; index++) {
            NSString *selectorName = NSStringFromSelector(method_getName(methods[index]));
            if (!hasArg && [selectorName containsString:@":"]) {
                continue;
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
#if !TARGET_OS_IPHONE && TARGET_OS_OSX
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
    id object = [self objectForOid:oid];
    if (![object isKindOfClass:NSGestureRecognizer.class]) {
        if (error) *error = PVInspectErr_ObjNotFound;
        return nil;
    }
    ((NSGestureRecognizer *)object).enabled = enabled;
    return @(((NSGestureRecognizer *)object).enabled);
}

#if !TARGET_OS_IPHONE && TARGET_OS_OSX
- (NSArray<PVWindowInfo *> *)allWindowsOnMainThread {
    NSArray<NSWindow *> *windows = NSApplication.sharedApplication.windows.copy ?: @[];
    NSMutableArray<PVWindowInfo *> *infos = [NSMutableArray arrayWithCapacity:windows.count];
    for (NSWindow *window in windows) {
        [infos addObject:[self windowInfoForWindow:window]];
    }
    return infos.copy;
}

- (PVHierarchyInfo *)hierarchyForWindowIDOnMainThread:(NSString *)windowID error:(NSError **)error {
    NSWindow *window = [self windowForIdentifier:windowID];
    if (!window) {
        if (error) {
            *error = [NSError errorWithDomain:PVErrorDomain
                                         code:PVErrorCodeUnknown
                                     userInfo:@{NSLocalizedDescriptionKey: @"Window not found."}];
        }
        return nil;
    }

    PVHierarchyInfo *info = [[PVHierarchyInfo alloc] init];
    info.appInfo = [PVAppInfoCollector currentInfoWithImages:NO localIdentifiers:@[]];
    info.serverVersion = info.appInfo.serverVersion;
    info.windowInfo = [self windowInfoForWindow:window];
    info.rootItems = @[[self displayItemForWindow:window]];
    return info;
}

- (NSWindow *)windowForIdentifier:(NSString *)windowID {
    NSArray<NSWindow *> *windows = NSApplication.sharedApplication.windows.copy ?: @[];
    if (!windowID.length) {
        return NSApplication.sharedApplication.keyWindow ?: NSApplication.sharedApplication.mainWindow ?: windows.firstObject;
    }

    for (NSWindow *window in windows) {
        if ([[self identifierForObject:window prefix:@"mac-window"] isEqualToString:windowID]) {
            return window;
        }
    }
    return nil;
}

- (PVWindowInfo *)windowInfoForWindow:(NSWindow *)window {
    PVWindowInfo *info = [[PVWindowInfo alloc] init];
    info.windowID = [self identifierForObject:window prefix:@"mac-window"];
    info.title = window.title ?: NSStringFromClass(window.class);
    info.className = NSStringFromClass(window.class);
    info.frame = window.frame;
    info.keyWindow = window.isKeyWindow;
    info.mainWindow = window.isMainWindow;
    info.visible = window.isVisible;
    info.level = window.level;
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

        id object = [self objectForDisplayItemID:displayItemID];
        PVDisplayItemDetail *detail = [[PVDisplayItemDetail alloc] init];
        detail.displayItemID = displayItemID;
        detail.displayItemOid = (unsigned long)(uintptr_t)object;
        if (!object) {
            detail.failureCode = -1;
            [details addObject:detail];
            continue;
        }

        if ([object isKindOfClass:NSWindow.class]) {
            NSWindow *window = object;
            detail.frame = window.frame;
            detail.bounds = CGRectMake(0, 0, window.frame.size.width, window.frame.size.height);
            detail.hidden = !window.isVisible;
            detail.alpha = window.alphaValue;
            detail.attributesGroupList = [self attributeGroupsForWindow:window];
            if (needsGroupImage) {
                detail.groupImageData = [self imageDataForView:window.contentView includeSubviews:YES lowQuality:lowImageQuality];
                detail.groupScreenshot = detail.groupImageData.length ? [[NSImage alloc] initWithData:detail.groupImageData] : nil;
            }
        } else if ([object isKindOfClass:NSView.class]) {
            NSView *view = object;
            detail.frame = view.frame;
            detail.bounds = view.bounds;
            detail.hidden = view.isHidden;
            detail.alpha = view.alphaValue;
            detail.attributesGroupList = [self attributeGroupsForView:view];
            [self applyCustomInfoToDetail:detail object:view];
            if (needsSoloImage) {
                detail.soloImageData = [self imageDataForView:view includeSubviews:NO lowQuality:lowImageQuality];
                detail.soloScreenshot = detail.soloImageData.length ? [[NSImage alloc] initWithData:detail.soloImageData] : nil;
            }
            if (needsGroupImage) {
                detail.groupImageData = [self imageDataForView:view includeSubviews:YES lowQuality:lowImageQuality];
                detail.groupScreenshot = detail.groupImageData.length ? [[NSImage alloc] initWithData:detail.groupImageData] : nil;
            }
        }
        [details addObject:detail];
    }
    return details.copy;
}

- (NSArray<PVDisplayItemDetail *> *)detailsForTaskPackagesOnMainThread:(NSArray<PVStaticAsyncUpdateTasksPackage *> *)packages
                                                        lowImageQuality:(BOOL)lowImageQuality {
    NSMutableArray<PVDisplayItemDetail *> *details = [NSMutableArray array];
    NSMutableSet<NSNumber *> *attrGroupsSyncedOids = [NSMutableSet set];

    for (PVStaticAsyncUpdateTasksPackage *package in packages) {
        for (PVStaticAsyncUpdateTask *task in package.tasks) {
            PVDisplayItemDetail *detail = [[PVDisplayItemDetail alloc] init];
            detail.displayItemOid = task.oid;

            id object = [self objectForOid:task.oid];
            if (!object) {
                detail.failureCode = -1;
                [details addObject:detail];
                continue;
            }

            if ([object isKindOfClass:NSWindow.class]) {
                NSWindow *window = object;
                detail.displayItemID = [self identifierForObject:window prefix:@"mac-window"];
                detail.frame = window.frame;
                detail.bounds = CGRectMake(0, 0, window.frame.size.width, window.frame.size.height);
                detail.hidden = !window.isVisible;
                detail.alpha = window.alphaValue;
                detail.frameValue = task.needBasisVisualInfo ? [NSValue valueWithRect:detail.frame] : nil;
                detail.boundsValue = task.needBasisVisualInfo ? [NSValue valueWithRect:detail.bounds] : nil;
                detail.hiddenValue = task.needBasisVisualInfo ? @(detail.hidden) : nil;
                detail.alphaValue = task.needBasisVisualInfo ? @(detail.alpha) : nil;
                if ([self shouldMakeAttributesFromTask:task syncedOids:attrGroupsSyncedOids]) {
                    detail.attributesGroupList = [self attributeGroupsForWindow:window];
                    [attrGroupsSyncedOids addObject:@(task.oid)];
                }
                if (task.taskType == PVStaticAsyncUpdateTaskTypeGroupScreenshot) {
                    detail.groupImageData = [self imageDataForView:window.contentView includeSubviews:YES lowQuality:lowImageQuality];
                    detail.groupScreenshot = detail.groupImageData.length ? [[NSImage alloc] initWithData:detail.groupImageData] : nil;
                }
                if (task.needSubitems) {
                    detail.subitems = window.contentView ? @[[self displayItemForView:window.contentView]] : @[];
                }
            } else if ([object isKindOfClass:NSView.class]) {
                NSView *view = object;
                detail.displayItemID = [self identifierForObject:view prefix:@"mac-view"];
                detail.frame = view.frame;
                detail.bounds = view.bounds;
                detail.hidden = view.isHidden;
                detail.alpha = view.alphaValue;
                detail.frameValue = task.needBasisVisualInfo ? [NSValue valueWithRect:view.frame] : nil;
                detail.boundsValue = task.needBasisVisualInfo ? [NSValue valueWithRect:view.bounds] : nil;
                detail.hiddenValue = task.needBasisVisualInfo ? @(view.isHidden) : nil;
                detail.alphaValue = task.needBasisVisualInfo ? @(view.alphaValue) : nil;
                if ([self shouldMakeAttributesFromTask:task syncedOids:attrGroupsSyncedOids]) {
                    detail.attributesGroupList = [self attributeGroupsForView:view];
                    [self applyCustomInfoToDetail:detail object:view];
                    [attrGroupsSyncedOids addObject:@(task.oid)];
                }
                if (task.taskType == PVStaticAsyncUpdateTaskTypeSoloScreenshot) {
                    detail.soloImageData = [self imageDataForView:view includeSubviews:NO lowQuality:lowImageQuality];
                    detail.soloScreenshot = detail.soloImageData.length ? [[NSImage alloc] initWithData:detail.soloImageData] : nil;
                } else if (task.taskType == PVStaticAsyncUpdateTaskTypeGroupScreenshot) {
                    detail.groupImageData = [self imageDataForView:view includeSubviews:YES lowQuality:lowImageQuality];
                    detail.groupScreenshot = detail.groupImageData.length ? [[NSImage alloc] initWithData:detail.groupImageData] : nil;
                }
                if (task.needSubitems) {
                    NSMutableArray<PVDisplayItem *> *subitems = [NSMutableArray arrayWithCapacity:view.subviews.count];
                    for (NSView *subview in view.subviews) {
                        [subitems addObject:[self displayItemForView:subview]];
                    }
                    detail.subitems = subitems.copy;
                }
            }
            [details addObject:detail];
        }
    }
    return details.copy;
}

- (PVDisplayItemDetail *)modifyAttributeOnMainThread:(PVAttributeModification *)modification error:(NSError **)error {
    id receiver = [self objectForOid:modification.targetOid];
    if (!receiver) {
        if (error) *error = PVInspectErr_ObjNotFound;
        return nil;
    }

    SEL selector = modification.setterSelector;
    if ([receiver isKindOfClass:NSView.class] && selector == NSSelectorFromString(@"setAlpha:")) {
        selector = @selector(setAlphaValue:);
    }
    if (!selector || ![receiver respondsToSelector:selector]) {
        if (error) *error = PVInspectErr_Inner;
        return nil;
    }

    NSMethodSignature *signature = [receiver methodSignatureForSelector:selector];
    if (signature.numberOfArguments != 3) {
        if (error) *error = PVInspectErr_Inner;
        return nil;
    }
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = receiver;
    invocation.selector = selector;
    if (![self setInvocation:invocation argumentWithModification:modification error:error]) {
        return nil;
    }

    @try {
        [invocation invoke];
    } @catch (NSException *exception) {
        if (error) {
            *error = [NSError errorWithDomain:PVInspectErrorDomain
                                         code:PVInspectErrCode_Exception
                                     userInfo:@{NSLocalizedDescriptionKey: @"The modification may have failed.",
                                                NSLocalizedRecoverySuggestionErrorKey: exception.reason ?: @""}];
        }
        return nil;
    }

    if ([receiver isKindOfClass:NSView.class]) {
        [(NSView *)receiver layoutSubtreeIfNeeded];
    }
    [CATransaction flush];
    return [self detailForObject:receiver oid:modification.targetOid];
}

- (BOOL)setInvocation:(NSInvocation *)invocation argumentWithModification:(PVAttributeModification *)modification error:(NSError **)error {
    switch (modification.attrType) {
        case PVAttrTypeChar: { char value = [modification.value charValue]; [invocation setArgument:&value atIndex:2]; break; }
        case PVAttrTypeInt:
        case PVAttrTypeEnumInt: { int value = [modification.value intValue]; [invocation setArgument:&value atIndex:2]; break; }
        case PVAttrTypeShort: { short value = [modification.value shortValue]; [invocation setArgument:&value atIndex:2]; break; }
        case PVAttrTypeLong:
        case PVAttrTypeEnumLong: { long value = [modification.value longValue]; [invocation setArgument:&value atIndex:2]; break; }
        case PVAttrTypeLongLong: { long long value = [modification.value longLongValue]; [invocation setArgument:&value atIndex:2]; break; }
        case PVAttrTypeUnsignedChar: { unsigned char value = [modification.value unsignedCharValue]; [invocation setArgument:&value atIndex:2]; break; }
        case PVAttrTypeUnsignedInt: { unsigned int value = [modification.value unsignedIntValue]; [invocation setArgument:&value atIndex:2]; break; }
        case PVAttrTypeUnsignedShort: { unsigned short value = [modification.value unsignedShortValue]; [invocation setArgument:&value atIndex:2]; break; }
        case PVAttrTypeUnsignedLong: { unsigned long value = [modification.value unsignedLongValue]; [invocation setArgument:&value atIndex:2]; break; }
        case PVAttrTypeUnsignedLongLong: { unsigned long long value = [modification.value unsignedLongLongValue]; [invocation setArgument:&value atIndex:2]; break; }
        case PVAttrTypeFloat: { float value = [modification.value floatValue]; [invocation setArgument:&value atIndex:2]; break; }
        case PVAttrTypeDouble: { double value = [modification.value doubleValue]; [invocation setArgument:&value atIndex:2]; break; }
        case PVAttrTypeBOOL: { BOOL value = [modification.value boolValue]; [invocation setArgument:&value atIndex:2]; break; }
        case PVAttrTypeSel: { SEL value = NSSelectorFromString(modification.value); [invocation setArgument:&value atIndex:2]; break; }
        case PVAttrTypeClass: { Class value = NSClassFromString(modification.value); [invocation setArgument:&value atIndex:2]; break; }
        case PVAttrTypeCGPoint: { CGPoint value = [modification.value pointValue]; [invocation setArgument:&value atIndex:2]; break; }
        case PVAttrTypeCGSize: { CGSize value = [modification.value sizeValue]; [invocation setArgument:&value atIndex:2]; break; }
        case PVAttrTypeCGRect: { CGRect value = [modification.value rectValue]; [invocation setArgument:&value atIndex:2]; break; }
        case PVAttrTypeCGAffineTransform: { CGAffineTransform value = CGAffineTransformIdentity; [modification.value getValue:&value size:sizeof(value)]; [invocation setArgument:&value atIndex:2]; break; }
        case PVAttrTypeUIEdgeInsets: { NSEdgeInsets value = [modification.value edgeInsetsValue]; [invocation setArgument:&value atIndex:2]; break; }
        case PVAttrTypeCustomObj:
        case PVAttrTypeNSString: { id value = modification.value; [invocation setArgument:&value atIndex:2]; [invocation retainArguments]; break; }
        case PVAttrTypeUIColor: { NSColor *value = [NSColor pv_inspect_colorFromRGBAComponents:modification.value]; [invocation setArgument:&value atIndex:2]; [invocation retainArguments]; break; }
        default:
            if (error) *error = PVInspectErr_Inner;
            return NO;
    }
    return YES;
}

- (PVDisplayItemDetail *)detailForObject:(id)object oid:(unsigned long)oid {
    PVDisplayItemDetail *detail = [[PVDisplayItemDetail alloc] init];
    detail.displayItemOid = oid;
    if ([object isKindOfClass:NSWindow.class]) {
        NSWindow *window = object;
        detail.frameValue = [NSValue valueWithRect:window.frame];
        detail.boundsValue = [NSValue valueWithRect:NSMakeRect(0, 0, window.frame.size.width, window.frame.size.height)];
        detail.hiddenValue = @(!window.isVisible);
        detail.alphaValue = @(window.alphaValue);
        detail.attributesGroupList = [self attributeGroupsForWindow:window];
    } else if ([object isKindOfClass:NSView.class]) {
        NSView *view = object;
        detail.frameValue = [NSValue valueWithRect:view.frame];
        detail.boundsValue = [NSValue valueWithRect:view.bounds];
        detail.hiddenValue = @(view.isHidden);
        detail.alphaValue = @(view.alphaValue);
        detail.attributesGroupList = [self attributeGroupsForView:view];
        [self applyCustomInfoToDetail:detail object:view];
    } else if ([object isKindOfClass:CALayer.class]) {
        CALayer *layer = object;
        detail.frameValue = [NSValue valueWithRect:layer.frame];
        detail.boundsValue = [NSValue valueWithRect:layer.bounds];
        detail.hiddenValue = @(layer.isHidden);
        detail.alphaValue = @(layer.opacity);
        detail.attributesGroupList = [self attributeGroupsForObject:layer layer:layer frame:layer.frame bounds:layer.bounds hidden:layer.isHidden alpha:layer.opacity interaction:YES tag:0 relationLines:@[]];
    }
    return detail;
}

- (PVObject *)objectWithOidOnMainThread:(unsigned long)oid error:(NSError **)error {
    id object = [self objectForOid:oid];
    if (!object) {
        if (error) {
            *error = PVInspectErr_ObjNotFound;
        }
        return nil;
    }
    return [self identityForObject:object prefix:@"mac-object"];
}

- (NSArray<PVAttributesGroup *> *)attributesForObjectWithOidOnMainThread:(unsigned long)oid error:(NSError **)error {
    id object = [self objectForOid:oid];
    if ([object isKindOfClass:NSWindow.class]) {
        return [self attributeGroupsForWindow:object];
    }
    if ([object isKindOfClass:NSView.class]) {
        return [self attributeGroupsForView:object];
    }
    if (error) {
        *error = PVInspectErr_ObjNotFound;
    }
    return nil;
}

- (NSDictionary *)invokeMethodWithOidOnMainThread:(unsigned long)oid text:(NSString *)text error:(NSError **)error {
    NSObject *target = [self objectForOid:oid];
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
    if (strcmp(returnType, @encode(unsigned long)) == 0) {
        unsigned long value = 0;
        [invocation getReturnValue:&value];
        return [NSString stringWithFormat:@"%@", @(value)];
    }
    if (strcmp(returnType, @encode(CGRect)) == 0) {
        CGRect value = CGRectZero;
        [invocation getReturnValue:&value];
        return NSStringFromRect(value);
    }
    if (returnType[0] == '@') {
        __unsafe_unretained id value = nil;
        [invocation getReturnValue:&value];
        if ([value isKindOfClass:NSObject.class]) {
            resultObject[@"object"] = [self identityForObject:value prefix:@"mac-object"];
        }
        return [value description] ?: @"nil";
    }
    return [NSString stringWithFormat:@"Return type %s is not supported.", returnType];
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

- (id)objectForOid:(unsigned long)oid {
    id registeredObject = [self.objectRegistry objectForKey:@(oid)];
    if (registeredObject) {
        return registeredObject;
    }
    for (NSWindow *window in NSApplication.sharedApplication.windows.copy ?: @[]) {
        if ((unsigned long)(uintptr_t)window == oid) {
            return window;
        }
        NSView *view = [self viewInView:window.contentView matchingOid:oid];
        if (view) {
            return view;
        }
    }
    return nil;
}

- (NSView *)viewInView:(NSView *)view matchingOid:(unsigned long)oid {
    if ((unsigned long)(uintptr_t)view == oid || (view.layer && (unsigned long)(uintptr_t)view.layer == oid)) {
        return view;
    }
    for (NSView *subview in view.subviews) {
        NSView *matchedView = [self viewInView:subview matchingOid:oid];
        if (matchedView) {
            return matchedView;
        }
    }
    return nil;
}

- (NSArray<PVAttributesGroup *> *)attributeGroupsForWindow:(NSWindow *)window {
    if (!window) {
        return @[];
    }

    CGRect bounds = CGRectMake(0, 0, window.frame.size.width, window.frame.size.height);
    return [self attributeGroupsForObject:window
                                    layer:nil
                                    frame:window.frame
                                   bounds:bounds
                                   hidden:!window.isVisible
                                    alpha:window.alphaValue
                              interaction:YES
                                      tag:0
                            relationLines:[self relationStringsForWindow:window]];
}

- (NSArray<PVAttributesGroup *> *)attributeGroupsForView:(NSView *)view {
    if (!view) {
        return @[];
    }

    return [self attributeGroupsForObject:view
                                    layer:view.layer
                                    frame:view.frame
                                   bounds:view.bounds
                                   hidden:view.isHidden
                                    alpha:view.alphaValue
                              interaction:YES
                                      tag:0
                            relationLines:[self relationStringsForView:view]];
}

- (NSArray<PVAttributesGroup *> *)attributeGroupsForObject:(NSObject *)object
                                                     layer:(CALayer *)layer
                                                     frame:(CGRect)frame
                                                    bounds:(CGRect)bounds
                                                    hidden:(BOOL)hidden
                                                     alpha:(CGFloat)alpha
                                               interaction:(BOOL)interaction
                                                       tag:(NSInteger)tag
                                             relationLines:(NSArray<NSString *> *)relationLines {
    NSMutableArray<PVAttributesGroup *> *groups = [NSMutableArray array];
    [groups addObject:[self groupWithIdentifier:PVAttrGroup_Class sections:@[
        [self sectionWithIdentifier:PVAttrSec_Class_Class attributes:@[
            [self attributeWithIdentifier:PVAttr_Class_Class_Class
                                     type:PVAttrTypeCustomObj
                                    value:@[[self classChainForClass:object.class]]]
        ]]
    ]]];
    [groups addObject:[self groupWithIdentifier:PVAttrGroup_Relation sections:@[
        [self sectionWithIdentifier:PVAttrSec_Relation_Relation attributes:@[
            [self attributeWithIdentifier:PVAttr_Relation_Relation_Relation
                                     type:PVAttrTypeCustomObj
                                    value:relationLines ?: @[]]
        ]]
    ]]];
    [groups addObject:[self groupWithIdentifier:PVAttrGroup_Layout sections:@[
        [self sectionWithIdentifier:PVAttrSec_Layout_Frame attributes:@[
            [self attributeWithIdentifier:PVAttr_Layout_Frame_Frame type:PVAttrTypeCGRect value:[NSValue valueWithRect:frame]]
        ]],
        [self sectionWithIdentifier:PVAttrSec_Layout_Bounds attributes:@[
            [self attributeWithIdentifier:PVAttr_Layout_Bounds_Bounds type:PVAttrTypeCGRect value:[NSValue valueWithRect:bounds]]
        ]],
        [self sectionWithIdentifier:PVAttrSec_Layout_Position attributes:@[
            [self attributeWithIdentifier:PVAttr_Layout_Position_Position type:PVAttrTypeCGPoint value:[NSValue valueWithPoint:(layer ? layer.position : CGPointZero)]]
        ]],
        [self sectionWithIdentifier:PVAttrSec_Layout_AnchorPoint attributes:@[
            [self attributeWithIdentifier:PVAttr_Layout_AnchorPoint_AnchorPoint type:PVAttrTypeCGPoint value:[NSValue valueWithPoint:(layer ? layer.anchorPoint : CGPointZero)]]
        ]]
    ]]];
    [groups addObject:[self groupWithIdentifier:PVAttrGroup_ViewLayer sections:@[
        [self sectionWithIdentifier:PVAttrSec_ViewLayer_Visibility attributes:@[
            [self attributeWithIdentifier:PVAttr_ViewLayer_Visibility_Hidden type:PVAttrTypeBOOL value:@(hidden)],
            [self attributeWithIdentifier:PVAttr_ViewLayer_Visibility_Opacity type:PVAttrTypeDouble value:@(alpha)]
        ]],
        [self sectionWithIdentifier:PVAttrSec_ViewLayer_InterationAndMasks attributes:@[
            [self attributeWithIdentifier:PVAttr_ViewLayer_InterationAndMasks_Interaction type:PVAttrTypeBOOL value:@(interaction)],
            [self attributeWithIdentifier:PVAttr_ViewLayer_InterationAndMasks_MasksToBounds type:PVAttrTypeBOOL value:@(layer.masksToBounds)]
        ]],
        [self sectionWithIdentifier:PVAttrSec_ViewLayer_Corner attributes:@[
            [self attributeWithIdentifier:PVAttr_ViewLayer_Corner_Radius type:PVAttrTypeDouble value:@(layer.cornerRadius)]
        ]],
        [self sectionWithIdentifier:PVAttrSec_ViewLayer_Border attributes:@[
            [self attributeWithIdentifier:PVAttr_ViewLayer_Border_Width type:PVAttrTypeDouble value:@(layer.borderWidth)]
        ]],
        [self sectionWithIdentifier:PVAttrSec_ViewLayer_Tag attributes:@[
            [self attributeWithIdentifier:PVAttr_ViewLayer_Tag_Tag type:PVAttrTypeLong value:@(tag)]
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

- (NSArray<NSString *> *)relationStringsForWindow:(NSWindow *)window {
    NSMutableArray<NSString *> *relations = [NSMutableArray array];
    [relations addObject:[NSString stringWithFormat:@"self: (%@ *) %p", NSStringFromClass(window.class), window]];
    if (window.contentView) {
        [relations addObject:[NSString stringWithFormat:@"contentView: (%@ *) %p", NSStringFromClass(window.contentView.class), window.contentView]];
    }
    return relations.copy;
}

- (NSArray<NSString *> *)relationStringsForView:(NSView *)view {
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

- (id)objectForDisplayItemID:(NSString *)displayItemID {
    for (NSWindow *window in NSApplication.sharedApplication.windows.copy ?: @[]) {
        if ([[self identifierForObject:window prefix:@"mac-window"] isEqualToString:displayItemID]) {
            return window;
        }
        NSView *matchedView = [self viewInView:window.contentView matchingDisplayItemID:displayItemID];
        if (matchedView) {
            return matchedView;
        }
    }
    return nil;
}

- (NSView *)viewInView:(NSView *)view matchingDisplayItemID:(NSString *)displayItemID {
    if (!view) {
        return nil;
    }
    if ([[self identifierForObject:view prefix:@"mac-view"] isEqualToString:displayItemID]) {
        return view;
    }
    for (NSView *subview in view.subviews) {
        NSView *matchedView = [self viewInView:subview matchingDisplayItemID:displayItemID];
        if (matchedView) {
            return matchedView;
        }
    }
    return nil;
}

- (NSData *)imageDataForView:(NSView *)view includeSubviews:(BOOL)includeSubviews lowQuality:(BOOL)lowQuality {
    if (!view || view.isHidden || CGRectIsEmpty(view.bounds) || ![self canCreateImageContextWithSize:view.bounds.size]) {
        return nil;
    }
    if (!includeSubviews && !view.subviews.count) {
        return nil;
    }

    NSArray<NSView *> *hiddenSubviews = includeSubviews ? @[] : [self hideVisibleSubviewsOfView:view];
    NSBitmapImageRep *rep = [view bitmapImageRepForCachingDisplayInRect:view.bounds];
    if (!rep) {
        [self restoreHiddenSubviews:hiddenSubviews];
        return nil;
    }

    [view cacheDisplayInRect:view.bounds toBitmapImageRep:rep];
    [self restoreHiddenSubviews:hiddenSubviews];
    return [rep representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
}

- (NSArray<NSView *> *)hideVisibleSubviewsOfView:(NSView *)view {
    NSMutableArray<NSView *> *hiddenSubviews = [NSMutableArray array];
    for (NSView *subview in view.subviews) {
        if (!subview.isHidden) {
            subview.hidden = YES;
            [hiddenSubviews addObject:subview];
        }
    }
    return hiddenSubviews.copy;
}

- (void)restoreHiddenSubviews:(NSArray<NSView *> *)hiddenSubviews {
    for (NSView *subview in hiddenSubviews) {
        subview.hidden = NO;
    }
}

- (BOOL)canCreateImageContextWithSize:(CGSize)size {
    return size.width > 0 && size.height > 0 && size.width <= 20000 && size.height <= 20000;
}

- (PVDisplayItem *)displayItemForWindow:(NSWindow *)window {
    PVDisplayItem *item = [[PVDisplayItem alloc] init];
    item.objectID = [self identifierForObject:window prefix:@"mac-window"];
    item.displayName = window.title.length ? window.title : NSStringFromClass(window.class);
    item.viewClassName = NSStringFromClass(window.class);
    item.frame = window.frame;
    item.bounds = CGRectMake(0, 0, window.frame.size.width, window.frame.size.height);
    item.hidden = !window.isVisible;
    item.alpha = window.alphaValue;
    item.viewObject = [self identityForObject:window prefix:@"mac-window"];
    item.layerObject = [self identityForObject:window prefix:@"mac-window"];
    item.attributesGroupList = [self attributeGroupsForWindow:window];
    item.shouldCaptureImage = YES;

    if (window.contentView) {
        item.children = @[[self displayItemForView:window.contentView]];
    }
    return item;
}

- (PVDisplayItem *)displayItemForView:(NSView *)view {
    PVDisplayItem *item = [[PVDisplayItem alloc] init];
    item.objectID = [self identifierForObject:view prefix:@"mac-view"];
    item.displayName = NSStringFromClass(view.class);
    item.viewClassName = NSStringFromClass(view.class);
    item.layerClassName = view.layer ? NSStringFromClass(view.layer.class) : @"";
    item.viewObject = [self identityForObject:view prefix:@"mac-view"];
    if (view.layer) {
        item.layerObject = [self identityForObject:view.layer prefix:@"mac-layer"];
    }
    item.frame = view.frame;
    item.bounds = view.bounds;
    item.hidden = view.isHidden;
    item.alpha = view.alphaValue;
    item.backgroundColorText = [self colorTextForView:view];
    if (view.layer.backgroundColor) {
        item.backgroundColor = [NSColor colorWithCGColor:view.layer.backgroundColor];
    }
    item.attributesGroupList = [self attributeGroupsForView:view];
    NSDictionary *customInfo = [self customInfoForObjects:view.layer ? @[view, view.layer] : @[view] saveAttrSetter:YES];
    item.customAttrGroupList = customInfo[@"groups"] ?: @[];
    item.customDisplayTitle = customInfo[@"title"];
    item.danceuiSource = customInfo[@"source"];
    item.eventHandlers = [self eventHandlersForView:view];
    item.shouldCaptureImage = YES;

    NSMutableArray<PVDisplayItem *> *children = [NSMutableArray arrayWithCapacity:view.subviews.count];
    for (NSView *subview in view.subviews) {
        [children addObject:[self displayItemForView:subview]];
    }
    item.children = children.copy;
    return item;
}

- (NSArray<PVEventHandler *> *)eventHandlersForView:(NSView *)view {
    NSMutableArray<PVEventHandler *> *handlers = [NSMutableArray array];
    if ([view isKindOfClass:NSControl.class]) {
        NSControl *control = (NSControl *)view;
        if (control.target && control.action) {
            [self registerObject:control.target];
            PVEventHandler *handler = [[PVEventHandler alloc] init];
            handler.handlerType = PVEventHandlerTypeTargetAction;
            handler.eventName = @"NSControlAction";
            handler.targetActions = @[[PVStringTwoTuple tupleWithFirst:[self descriptionForObject:control.target]
                                                                 second:NSStringFromSelector(control.action)]];
            [handlers addObject:handler];
        }
    }
    for (NSGestureRecognizer *recognizer in view.gestureRecognizers) {
        PVEventHandler *handler = [[PVEventHandler alloc] init];
        handler.handlerType = PVEventHandlerTypeGesture;
        handler.eventName = NSStringFromClass(recognizer.class);
        handler.gestureRecognizerIsEnabled = recognizer.enabled;
        handler.gestureRecognizerDelegator = recognizer.delegate ? [self descriptionForObject:recognizer.delegate] : nil;
        handler.recognizerIvarTraces = @[];
        handler.recognizerOid = [self registerObject:recognizer];
        id target = recognizer.target;
        if (target && recognizer.action) {
            [self registerObject:target];
            handler.targetActions = @[[PVStringTwoTuple tupleWithFirst:[self descriptionForObject:target]
                                                                 second:NSStringFromSelector(recognizer.action)]];
        }
        [handlers addObject:handler];
    }
    return handlers.copy;
}

- (void)applyCustomInfoToDetail:(PVDisplayItemDetail *)detail object:(id)object {
    NSDictionary *customInfo = [self customInfoForObjects:object ? @[object] : @[] saveAttrSetter:YES];
    detail.customAttrGroupList = customInfo[@"groups"] ?: @[];
    detail.customDisplayTitle = customInfo[@"title"];
    detail.danceUISource = customInfo[@"source"];
}

- (NSDictionary *)customInfoForObjects:(NSArray *)objects saveAttrSetter:(BOOL)saveAttrSetter {
    NSMutableArray<PVAttributesGroup *> *groups = [NSMutableArray array];
    NSString *customTitle = nil;
    NSString *source = nil;
    NSMutableArray<NSString *> *selectorNames = [NSMutableArray arrayWithObjects:@"pickview_customDebugInfos", @"lookin_customDebugInfos", nil];
    for (NSInteger index = 0; index < 5; index++) {
        [selectorNames addObject:[NSString stringWithFormat:@"pickview_customDebugInfos_%ld", (long)index]];
        [selectorNames addObject:[NSString stringWithFormat:@"lookin_customDebugInfos_%ld", (long)index]];
    }
    for (id object in objects) {
        for (NSString *selectorName in selectorNames) {
            NSDictionary *rawInfo = [self dictionaryByInvokingSelectorName:selectorName target:object];
            if (!rawInfo.count) continue;
            if ([rawInfo[@"title"] isKindOfClass:NSString.class]) customTitle = rawInfo[@"title"];
            NSString *rawSource = rawInfo[@"pickview_source"] ?: rawInfo[@"lookin_source"];
            if ([rawSource isKindOfClass:NSString.class]) source = rawSource;
            [groups addObjectsFromArray:[self customGroupsFromRawProperties:rawInfo[@"properties"] saveAttrSetter:saveAttrSetter]];
        }
    }
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithObject:groups.copy forKey:@"groups"];
    if (customTitle) result[@"title"] = customTitle;
    if (source) result[@"source"] = source;
    return result.copy;
}

- (NSDictionary *)dictionaryByInvokingSelectorName:(NSString *)selectorName target:(id)target {
    SEL selector = NSSelectorFromString(selectorName);
    if (![target respondsToSelector:selector]) return @{};
    NSMethodSignature *signature = [target methodSignatureForSelector:selector];
    if (signature.numberOfArguments != 2 || signature.methodReturnLength == 0) return @{};
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = target;
    invocation.selector = selector;
    [invocation invoke];
    __unsafe_unretained id value = nil;
    [invocation getReturnValue:&value];
    return [value isKindOfClass:NSDictionary.class] ? value : @{};
}

- (NSArray<PVAttributesGroup *> *)customGroupsFromRawProperties:(NSArray *)rawProperties saveAttrSetter:(BOOL)saveAttrSetter {
    if (![rawProperties isKindOfClass:NSArray.class]) return @[];
    NSMutableDictionary<NSString *, NSMutableArray<PVAttribute *> *> *attributesBySection = [NSMutableDictionary dictionary];
    for (NSDictionary *rawAttribute in rawProperties) {
        NSString *section = nil;
        PVAttribute *attribute = [self customAttributeFromRawDictionary:rawAttribute saveAttrSetter:saveAttrSetter section:&section];
        if (!attribute) continue;
        section = section.length ? section : @"Custom";
        if (!attributesBySection[section]) attributesBySection[section] = [NSMutableArray array];
        [attributesBySection[section] addObject:attribute];
    }

    NSMutableArray<PVAttributesGroup *> *groups = [NSMutableArray array];
    [attributesBySection enumerateKeysAndObjectsUsingBlock:^(NSString *sectionTitle, NSMutableArray<PVAttribute *> *attributes, BOOL *stop) {
        PVAttributesGroup *group = [[PVAttributesGroup alloc] init];
        group.identifier = PVAttrGroup_UserCustom;
        group.userCustomTitle = sectionTitle;
        NSMutableArray<PVAttributesSection *> *sections = [NSMutableArray array];
        for (PVAttribute *attribute in attributes) {
            PVAttributesSection *section = [[PVAttributesSection alloc] init];
            section.identifier = PVAttrSec_UserCustom;
            section.attributes = @[attribute];
            [sections addObject:section];
        }
        group.attrSections = sections.copy;
        [groups addObject:group];
    }];
    [groups sortUsingComparator:^NSComparisonResult(PVAttributesGroup *first, PVAttributesGroup *second) {
        return [first.userCustomTitle compare:second.userCustomTitle];
    }];
    return groups.copy;
}

- (PVAttribute *)customAttributeFromRawDictionary:(NSDictionary *)raw
                                    saveAttrSetter:(BOOL)saveAttrSetter
                                           section:(NSString **)section {
    if (![raw isKindOfClass:NSDictionary.class] || ![raw[@"title"] isKindOfClass:NSString.class] || ![raw[@"valueType"] isKindOfClass:NSString.class]) return nil;
    if (section) *section = [raw[@"section"] isKindOfClass:NSString.class] ? raw[@"section"] : @"Custom";
    NSString *type = [raw[@"valueType"] lowercaseString];
    id value = raw[@"value"];
    id setter = raw[@"retainedSetter"];
    PVAttribute *attribute = [[PVAttribute alloc] init];
    attribute.identifier = PVAttr_UserCustom;
    attribute.displayTitle = raw[@"title"];

    if ([type isEqualToString:@"string"] && (!value || [value isKindOfClass:NSString.class])) {
        attribute.attrType = PVAttrTypeNSString;
        attribute.value = value;
        if (saveAttrSetter && setter) attribute.customSetterID = [self saveCustomSetter:setter type:attribute.attrType];
    } else if ([type isEqualToString:@"number"] && [value isKindOfClass:NSNumber.class]) {
        attribute.attrType = PVAttrTypeDouble;
        attribute.value = value;
        if (saveAttrSetter && setter) attribute.customSetterID = [self saveCustomSetter:setter type:attribute.attrType];
    } else if ([type isEqualToString:@"bool"] && [value isKindOfClass:NSNumber.class]) {
        attribute.attrType = PVAttrTypeBOOL;
        attribute.value = value;
        if (saveAttrSetter && setter) attribute.customSetterID = [self saveCustomSetter:setter type:attribute.attrType];
    } else if ([type isEqualToString:@"color"] && (!value || [value isKindOfClass:NSColor.class])) {
        attribute.attrType = PVAttrTypeUIColor;
        attribute.value = [(NSColor *)value pv_inspect_rgbaComponents];
        if (saveAttrSetter && setter) attribute.customSetterID = [self saveCustomSetter:setter type:attribute.attrType];
    } else if ([type isEqualToString:@"rect"] && [value isKindOfClass:NSValue.class]) {
        attribute.attrType = PVAttrTypeCGRect;
        attribute.value = value;
        if (saveAttrSetter && setter) attribute.customSetterID = [self saveCustomSetter:setter type:attribute.attrType];
    } else if ([type isEqualToString:@"size"] && [value isKindOfClass:NSValue.class]) {
        attribute.attrType = PVAttrTypeCGSize;
        attribute.value = value;
        if (saveAttrSetter && setter) attribute.customSetterID = [self saveCustomSetter:setter type:attribute.attrType];
    } else if ([type isEqualToString:@"point"] && [value isKindOfClass:NSValue.class]) {
        attribute.attrType = PVAttrTypeCGPoint;
        attribute.value = value;
        if (saveAttrSetter && setter) attribute.customSetterID = [self saveCustomSetter:setter type:attribute.attrType];
    } else if ([type isEqualToString:@"insets"] && [value isKindOfClass:NSValue.class]) {
        attribute.attrType = PVAttrTypeUIEdgeInsets;
        attribute.value = value;
        if (saveAttrSetter && setter) attribute.customSetterID = [self saveCustomSetter:setter type:attribute.attrType];
    } else if ([type isEqualToString:@"enum"] && [value isKindOfClass:NSString.class]) {
        attribute.attrType = PVAttrTypeEnumString;
        attribute.value = value;
        attribute.extraValue = [raw[@"allEnumCases"] isKindOfClass:NSArray.class] ? raw[@"allEnumCases"] : nil;
        if (saveAttrSetter && setter) attribute.customSetterID = [self saveCustomSetter:setter type:attribute.attrType];
    } else if ([type isEqualToString:@"json"] && [value isKindOfClass:NSString.class]) {
        attribute.attrType = PVAttrTypeJson;
        attribute.value = value;
    } else {
        return nil;
    }
    return attribute;
}

- (NSString *)saveCustomSetter:(id)setter type:(PVAttrType)type {
    NSString *identifier = NSUUID.UUID.UUIDString;
    PVCustomAttrSetterManager *manager = [PVCustomAttrSetterManager sharedInstance];
    switch (type) {
        case PVAttrTypeNSString: [manager saveStringSetter:setter uniqueID:identifier]; break;
        case PVAttrTypeDouble: [manager saveNumberSetter:setter uniqueID:identifier]; break;
        case PVAttrTypeBOOL: [manager saveBoolSetter:setter uniqueID:identifier]; break;
        case PVAttrTypeUIColor: [manager saveColorSetter:setter uniqueID:identifier]; break;
        case PVAttrTypeEnumString: [manager saveEnumSetter:setter uniqueID:identifier]; break;
        case PVAttrTypeCGRect: [manager saveRectSetter:setter uniqueID:identifier]; break;
        case PVAttrTypeCGSize: [manager saveSizeSetter:setter uniqueID:identifier]; break;
        case PVAttrTypeCGPoint: [manager savePointSetter:setter uniqueID:identifier]; break;
        case PVAttrTypeUIEdgeInsets: [manager saveInsetsSetter:setter uniqueID:identifier]; break;
        default: return nil;
    }
    return identifier;
}

- (unsigned long)registerObject:(id)object {
    if (!object) return 0;
    unsigned long oid = (unsigned long)(uintptr_t)object;
    [self.objectRegistry setObject:object forKey:@(oid)];
    return oid;
}

- (NSString *)descriptionForObject:(id)object {
    return object ? [NSString stringWithFormat:@"<%@: %p>", NSStringFromClass([object class]), object] : @"nil";
}

- (PVObject *)identityForObject:(id)object prefix:(NSString *)prefix {
    if (object) {
        [self.objectRegistry setObject:object forKey:@((unsigned long)(uintptr_t)object)];
    }
    PVObject *identity = [[PVObject alloc] init];
    identity.oid = (unsigned long)(uintptr_t)object;
    identity.memoryAddress = [NSString stringWithFormat:@"%p", object];
    identity.classChainList = [self classChainForObject:object];
    return identity;
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

- (NSString *)colorTextForView:(NSView *)view {
    if (!view.layer.backgroundColor) {
        return @"";
    }

    NSColor *color = [NSColor colorWithCGColor:view.layer.backgroundColor];
    NSColor *rgbColor = [color colorUsingColorSpace:NSColorSpace.sRGBColorSpace];
    if (!rgbColor) {
        return color.description ?: @"";
    }
    return [NSString stringWithFormat:@"rgba(%.0f, %.0f, %.0f, %.2f)",
            rgbColor.redComponent * 255,
            rgbColor.greenComponent * 255,
            rgbColor.blueComponent * 255,
            rgbColor.alphaComponent];
}
#endif

- (NSError *)unsupportedPlatformError {
    return [NSError errorWithDomain:PVErrorDomain
                               code:PVErrorCodeUnsupportedEndpoint
                           userInfo:@{NSLocalizedDescriptionKey: @"AppKit hierarchy provider is unavailable on this platform."}];
}

@end

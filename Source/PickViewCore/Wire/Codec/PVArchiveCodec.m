//
//  PVArchiveCodec.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVArchiveCodec.h"

#import "PVDisplayItem.h"
#import "PVDisplayItemDetail.h"
#import "PVDisplayItemDetailRequest.h"
#import "PVHierarchyInfo.h"
#import "PVObjectIdentity.h"
#import "PVRequestAttachment.h"
#import "PVResponseAttachment.h"
#import "PVWindowInfo.h"

@implementation PVArchiveCodec

+ (NSData *)archivedDataWithObject:(id<NSSecureCoding>)object error:(NSError **)error {
    if (!object) {
        return nil;
    }
    return [NSKeyedArchiver archivedDataWithRootObject:object requiringSecureCoding:YES error:error];
}

+ (id)unarchivedObjectFromData:(NSData *)data
                allowedClasses:(NSSet<Class> *)allowedClasses
                         error:(NSError **)error {
    if (!data.length) {
        return nil;
    }
    NSSet<Class> *classes = allowedClasses.count ? allowedClasses : [self defaultAllowedClasses];
    return [NSKeyedUnarchiver unarchivedObjectOfClasses:classes fromData:data error:error];
}

+ (NSSet<Class> *)defaultAllowedClasses {
    static NSSet<Class> *classes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableSet<Class> *allowedClasses = [NSMutableSet setWithObjects:
                                               NSArray.class,
                                               NSMutableArray.class,
                                               NSDictionary.class,
                                               NSMutableDictionary.class,
                                               NSString.class,
                                               NSMutableString.class,
                                               NSNumber.class,
                                               NSData.class,
                                               NSDate.class,
                                               NSError.class,
                                               NSNull.class,
                                               NSSet.class,
                                               NSMutableSet.class,
                                               NSValue.class,
                                               PVRequestAttachment.class,
                                               PVResponseAttachment.class,
                                               PVWindowInfo.class,
                                               PVHierarchyInfo.class,
                                               PVDisplayItem.class,
                                               PVDisplayItemDetail.class,
                                               PVDisplayItemDetailRequest.class,
                                               PVObjectIdentity.class,
                                               nil];
        NSArray<NSString *> *pickviewClassNames = @[
            @"PVAppInfo",
            @"PVAttribute",
            @"PVAttributeModification",
            @"PVAttributesGroup",
            @"PVAttributesSection",
            @"PVAutoLayoutConstraint",
            @"PVConnectionAttachment",
            @"PVConnectionResponseAttachment",
            @"PVCustomAttrModification",
            @"PVCustomDisplayItemInfo",
            @"PVDashboardBlueprint",
            @"PVEventHandler",
            @"PVHierarchyFile",
            @"PVIvarTrace",
            @"PVObject",
            @"PVStaticAsyncUpdateTask",
            @"PVStaticAsyncUpdateTasksPackage",
            @"PVTuple",
            @"PVTwoTuple",
            @"PVStringTwoTuple",
            @"PVIntegerTwoTuple",
            @"PVDoubleTwoTuple",
            @"PVWeakContainer",
            @"NSColor",
            @"UIColor",
            @"NSImage",
            @"UIImage"
        ];
        for (NSString *className in pickviewClassNames) {
            Class cls = NSClassFromString(className);
            if (cls) {
                [allowedClasses addObject:cls];
            }
        }
        classes = allowedClasses.copy;
    });
    return classes;
}

@end

//
//  PVHierarchyProvider.h
//  PickViewServer
//
//  Created by kris cheng on 2026/7/9.
//

#ifndef PVHierarchyProvider_h
#define PVHierarchyProvider_h

#import <Foundation/Foundation.h>

@class PVHierarchyInfo;
@class PVDisplayItemDetail;
@class PVAttributeModification;
@class PVAttributesGroup;
@class PVCustomAttrModification;
@class PVObject;
@class PVStaticAsyncUpdateTasksPackage;
@class PVWindowInfo;

NS_ASSUME_NONNULL_BEGIN

@protocol PVHierarchyProvider <NSObject>

- (NSArray<PVWindowInfo *> *)allWindows;
- (nullable PVHierarchyInfo *)hierarchyForWindowID:(NSString *)windowID error:(NSError * _Nullable * _Nullable)error;
- (NSArray<PVDisplayItemDetail *> *)detailsForDisplayItemIDs:(NSArray<NSString *> *)displayItemIDs
                                              needsSoloImage:(BOOL)needsSoloImage
                                             needsGroupImage:(BOOL)needsGroupImage
                                             lowImageQuality:(BOOL)lowImageQuality;
- (NSArray<PVDisplayItemDetail *> *)detailsForTaskPackages:(NSArray<PVStaticAsyncUpdateTasksPackage *> *)packages
                                           lowImageQuality:(BOOL)lowImageQuality;
- (nullable PVDisplayItemDetail *)modifyAttribute:(PVAttributeModification *)modification
                                            error:(NSError * _Nullable * _Nullable)error;
- (BOOL)modifyCustomAttribute:(PVCustomAttrModification *)modification
                        error:(NSError * _Nullable * _Nullable)error;
- (nullable PVObject *)objectWithOid:(unsigned long)oid error:(NSError * _Nullable * _Nullable)error;
- (nullable NSArray<PVAttributesGroup *> *)attributesForObjectWithOid:(unsigned long)oid
                                                                error:(NSError * _Nullable * _Nullable)error;
- (nullable NSData *)imageDataForImageViewWithOid:(unsigned long)oid error:(NSError * _Nullable * _Nullable)error;
- (nullable NSArray<NSString *> *)selectorNamesForClassName:(NSString *)className
                                                     hasArg:(BOOL)hasArg
                                                      error:(NSError * _Nullable * _Nullable)error;
- (nullable NSDictionary *)invokeMethodWithOid:(unsigned long)oid
                                          text:(NSString *)text
                                         error:(NSError * _Nullable * _Nullable)error;
- (nullable NSNumber *)modifyGestureRecognizerWithOid:(unsigned long)oid
                                              enabled:(BOOL)enabled
                                                error:(NSError * _Nullable * _Nullable)error;

@end

NS_ASSUME_NONNULL_END

#endif /* PVHierarchyProvider_h */

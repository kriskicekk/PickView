//
//  PVHierarchyInfo.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#ifndef PVHierarchyInfo_h
#define PVHierarchyInfo_h

#import <Foundation/Foundation.h>

@class PVAppInfo;
@class PVDisplayItem;
@class PVWindowInfo;

NS_ASSUME_NONNULL_BEGIN

@interface PVHierarchyInfo : NSObject <NSSecureCoding, NSCopying>

@property (nonatomic, strong, nullable) PVWindowInfo *windowInfo;
@property (nonatomic, copy) NSArray<PVDisplayItem *> *rootItems;
@property (nonatomic, copy) NSArray<PVDisplayItem *> *displayItems;
@property (nonatomic, copy) NSDictionary<NSString *, id> *colorAlias;
@property (nonatomic, copy) NSArray<NSString *> *collapsedClassList;
@property (nonatomic, strong, nullable) PVAppInfo *appInfo;
@property (nonatomic, assign) int serverVersion;

@end

NS_ASSUME_NONNULL_END

#endif /* PVHierarchyInfo_h */

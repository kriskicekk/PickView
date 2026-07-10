//
//  PVHierarchyFile.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import <Foundation/Foundation.h>

@class PVHierarchyInfo;

@interface PVHierarchyFile : NSObject <NSSecureCoding>

/// 记录创建该文件的 PickViewServer 的版本
@property(nonatomic, assign) int serverVersion;

@property(nonatomic, strong) PVHierarchyInfo *hierarchyInfo;

@property(nonatomic, copy) NSDictionary<NSNumber *, NSData *> *soloScreenshots;
@property(nonatomic, copy) NSDictionary<NSNumber *, NSData *> *groupScreenshots;

/// 验证 file 的版本之类的是否和当前 PickView 客户端匹配，如果没有问题则返回 nil，如果有问题则返回 error
+ (NSError *)verifyHierarchyFile:(PVHierarchyFile *)file;

@end


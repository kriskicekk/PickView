//
//  LKStaticHierarchyDataSource.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "PickViewDefines.h"
#import "LKHierarchyDataSource.h"

@class PickViewDisplayItemDetail, PickViewStaticDisplayItem, PickViewAppInfo;

@interface LKStaticHierarchyDataSource : LKHierarchyDataSource

+ (instancetype)sharedInstance;

@property(nonatomic, strong, readonly) PickViewAppInfo *appInfo;

#pragma mark - Signal

/// 某些 item 的 frame 发生改变
@property(nonatomic, strong, readonly) RACSubject *itemsDidChangeFrame;

- (void)modifyWithDisplayItemDetail:(PickViewDisplayItemDetail *)detail;

@end

//
//  PVDetailStaticHierarchyDataSource.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVInspectionDefines.h"
#import "PVDetailHierarchyDataSource.h"

@class PVDisplayItemDetail, PVDisplayItem, PVAppInfo;

@interface PVDetailStaticHierarchyDataSource : PVDetailHierarchyDataSource

+ (instancetype)sharedInstance;

@property(nonatomic, strong, readonly) PVAppInfo *appInfo;

#pragma mark - Signal

/// 某些 item 的 frame 发生改变
@property(nonatomic, strong, readonly) RACSubject *itemsDidChangeFrame;

- (void)modifyWithDisplayItemDetail:(PVDisplayItemDetail *)detail;

@end

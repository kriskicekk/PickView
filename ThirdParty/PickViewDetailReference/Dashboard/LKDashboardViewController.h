//
//  LKDashboardViewController.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import <Cocoa/Cocoa.h>

@class LKHierarchyDataSource, LKStaticHierarchyDataSource, PVAttribute, LKReadHierarchyDataSource;

@interface LKDashboardViewController : LKBaseViewController

- (instancetype)initWithStaticDataSource:(LKStaticHierarchyDataSource *)dataSource;

- (instancetype)initWithReadDataSource:(LKReadHierarchyDataSource *)dataSource;

- (LKHierarchyDataSource *)currentDataSource;

- (RACSignal *)modifyAttribute:(PVAttribute *)attribute newValue:(id)newValue;

/// 如果为 YES 则表示当前使用的是 StaticDataSource 而非 ReadDataSource
@property(nonatomic, assign, readonly) BOOL isStaticMode;

@end

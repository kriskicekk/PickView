//
//  LKHierarchyController.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "LKBaseViewController.h"
#import "LKHierarchyView.h"

@class LKHierarchyDataSource;

@interface LKHierarchyController : LKBaseViewController <LKHierarchyViewDelegate>

- (instancetype)initWithDataSource:(LKHierarchyDataSource *)dataSource;

@property(nonatomic, strong, readonly) LKHierarchyDataSource *dataSource;

@property(nonatomic, strong, readonly) LKHierarchyView *hierarchyView;

- (NSView *)currentSelectedRowView;

@end

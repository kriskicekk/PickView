//
//  LKPreviewController.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "LKBaseViewController.h"

@class LKHierarchyDataSource, LKStaticViewController;

@interface LKPreviewController : LKBaseViewController

- (instancetype)initWithDataSource:(LKHierarchyDataSource *)dataSource;

@property(nonatomic, weak) LKStaticViewController *staticViewController;

@end

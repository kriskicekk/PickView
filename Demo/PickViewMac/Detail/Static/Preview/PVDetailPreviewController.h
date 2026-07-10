//
//  PVDetailPreviewController.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailBaseViewController.h"

@class PVDetailHierarchyDataSource, PVDetailStaticViewController;

@interface PVDetailPreviewController : PVDetailBaseViewController

- (instancetype)initWithDataSource:(PVDetailHierarchyDataSource *)dataSource;

@property(nonatomic, weak) PVDetailStaticViewController *staticViewController;

@end

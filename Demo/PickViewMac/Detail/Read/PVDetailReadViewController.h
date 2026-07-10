//
//  PVDetailReadViewController.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailBaseViewController.h"

@class PVHierarchyFile, PVDetailPreferenceManager, PVDetailReadHierarchyDataSource, PVDetailHierarchyView;

@interface PVDetailReadViewController : PVDetailBaseViewController

- (instancetype)initWithFile:(PVHierarchyFile *)file preferenceManager:(PVDetailPreferenceManager *)manager;

@property(nonatomic, strong) PVDetailReadHierarchyDataSource *hierarchyDataSource;

/// 获取当前的 hierarchyView
- (PVDetailHierarchyView *)currentHierarchyView;

@end

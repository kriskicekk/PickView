//
//  PVDetailHierarchyController.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailBaseViewController.h"
#import "PVDetailHierarchyView.h"

@class PVDetailHierarchyDataSource;

@interface PVDetailHierarchyController : PVDetailBaseViewController <PVDetailHierarchyViewDelegate>

- (instancetype)initWithDataSource:(PVDetailHierarchyDataSource *)dataSource;

@property(nonatomic, strong, readonly) PVDetailHierarchyDataSource *dataSource;

@property(nonatomic, strong, readonly) PVDetailHierarchyView *hierarchyView;

- (NSView *)currentSelectedRowView;

@end

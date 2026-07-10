//
//  PVDetailConsoleViewController.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailBaseViewController.h"

@class PVObject, PVDetailHierarchyDataSource;

@interface PVDetailConsoleViewController : PVDetailBaseViewController

- (instancetype)initWithHierarchyDataSource:(PVDetailHierarchyDataSource *)dataSource;

@property(nonatomic, assign) BOOL isControllerShowing;

- (void)submitWithObj:(PVObject *)obj text:(NSString *)text;

@end

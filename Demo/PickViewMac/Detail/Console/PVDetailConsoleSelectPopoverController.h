//
//  PVDetailConsoleSelectPopoverController.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailBaseViewController.h"

@class PVDetailConsoleDataSource;

@interface PVDetailConsoleSelectPopoverController : PVDetailBaseViewController

- (instancetype)initWithDataSource:(PVDetailConsoleDataSource *)dataSource;

- (CGFloat)bestHeight;

- (void)reRender;

@property(nonatomic, copy) void (^needShowError)(NSError *error);
@property(nonatomic, copy) void (^needClose)(void);

@end

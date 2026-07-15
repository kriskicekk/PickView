//
//  PVDetailConsoleInputRowView.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailTableRowView.h"

@class PVDetailConsoleDataSource;

@interface PVDetailConsoleInputRowView : PVDetailTableRowView

- (instancetype)initWithDataSource:(PVDetailConsoleDataSource *)dataSource;

- (void)makeTextFieldAsFirstResponder;

@end

//
//  LKHierarchyHandlersPopoverItemView.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "LKBaseView.h"

@class PickViewEventHandler;

@interface LKHierarchyHandlersPopoverItemView : LKBaseView

/// read 模式下的 editable 需要传入 NO
- (instancetype)initWithEventHandler:(PickViewEventHandler *)handler editable:(BOOL)editable;

@property(nonatomic, assign) BOOL needTopBorder;

@end

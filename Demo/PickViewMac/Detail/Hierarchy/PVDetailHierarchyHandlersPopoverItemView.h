//
//  PVDetailHierarchyHandlersPopoverItemView.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailBaseView.h"

@class PVEventHandler;

@interface PVDetailHierarchyHandlersPopoverItemView : PVDetailBaseView

/// read 模式下的 editable 需要传入 NO
- (instancetype)initWithEventHandler:(PVEventHandler *)handler editable:(BOOL)editable;

@property(nonatomic, assign) BOOL needTopBorder;

@end

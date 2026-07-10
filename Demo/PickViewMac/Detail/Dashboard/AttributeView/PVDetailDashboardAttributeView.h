//
//  PVDetailDashboardAttributeView.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVAttribute.h"
#import "PVInspectionDefines.h"
#import "PVAttributesGroup.h"

@class PVDisplayItem, PVDetailDashboardAttributeValueView, PVDetailDashboardViewController;

@interface PVDetailDashboardAttributeView : PVDetailBaseView

@property(nonatomic, strong) PVAttribute *attribute;

@property(nonatomic, strong) id valueView;

@property(nonatomic, weak) PVDetailDashboardViewController *dashboardViewController;

- (BOOL)canEdit;

@end

/// 除了下面这两个方法外，子类还需要继承重写 sizeThatFits: 方法
@interface PVDetailDashboardAttributeView (NSSubclassingHooks)

/// 方法实现应该是读取 self.attribute 并渲染
- (void)renderWithAttribute;

/// 每行可以摆放该 AttrView 的数量，返回 1 则表示独占一行，返回 0 表示宽度根据内容的变化而变化。子类不重写则默认为 1
- (NSUInteger)numberOfColumnsOccupied;

@end

//
//  PVDetailDashboardAttributeStringArrayView.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailDashboardAttributeView.h"

@interface PVDetailDashboardAttributeStringArrayView : PVDetailDashboardAttributeView

/// 子类必须实现该方法
- (NSArray<NSString *> *)stringListWithAttribute:(PVAttribute *)attribute;

@end

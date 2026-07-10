//
//  LKDashboardAttributeStringArrayView.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "LKDashboardAttributeView.h"

@interface LKDashboardAttributeStringArrayView : LKDashboardAttributeView

/// 子类必须实现该方法
- (NSArray<NSString *> *)stringListWithAttribute:(PVAttribute *)attribute;

@end

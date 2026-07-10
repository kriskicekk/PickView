//
//  NSSet+PVInspect.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVInspectionDefines.h"



#import "TargetConditionals.h"
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#elif TARGET_OS_MAC
#import <Appkit/Appkit.h>
#endif

@interface NSSet<__covariant ValueType> (PickView)

- (NSSet *)pv_inspect_map:(id (^)(ValueType obj))block;

- (ValueType)pv_inspect_firstFiltered:(BOOL (^)(ValueType obj))block;

- (NSSet<ValueType> *)pv_inspect_filter:(BOOL (^)(ValueType obj))block;


/**
 是否有任何一个元素满足某条件
 @note 元素将被依次传入 block 里，如果任何一个 block 返回 YES，则该方法返回 YES。如果所有 block 均返回 NO，则该方法返回 NO。
 */
- (BOOL)pv_inspect_any:(BOOL (^)(ValueType obj))block;

@end


//
//  NSArray+PVInspect.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVInspectionDefines.h"



#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface NSArray<__covariant ValueType> (PickView)

/**
 初始化一个新的 NSArray 并返回，新数组的长度为 count，如果当前数组长度比 count 小则会补充新元素（被补充的元素由 addBlock 返回），如果当前数组长度比 count 大则会舍弃多余的元素，被舍弃的元素会作为参数传入 removeBlock。最终，新数组的所有元素均会作为参数被传入 doBlock。
 */
- (NSArray<ValueType> *)pv_inspect_resizeWithCount:(NSUInteger)count add:(ValueType (^)(NSUInteger idx))addBlock remove:(void (^)(NSUInteger idx, ValueType obj))removeBlock doNext:(void (^)(NSUInteger idx, ValueType obj))doBlock __attribute__((warn_unused_result));

+ (NSArray *)pv_inspect_arrayWithCount:(NSUInteger)count block:(id (^)(NSUInteger idx))block;

/**
 检查 index 位置是否有元素存在
 */
- (BOOL)pv_inspect_hasIndex:(NSInteger)index;

- (NSArray *)pv_inspect_map:(id (^)(NSUInteger idx, ValueType value))block;

- (NSArray<ValueType> *)pv_inspect_filter:(BOOL (^)( ValueType obj))block;

- (ValueType)pv_inspect_firstFiltered:(BOOL (^)(ValueType obj))block;

/// 返回最后一个 block 返回 YES 的元素
- (ValueType)pv_inspect_lastFiltered:(BOOL (^)(ValueType obj))block;

- (id)pv_inspect_reduce:(id (^)(id accumulator, NSUInteger idx, ValueType obj))block;

- (CGFloat)pv_inspect_reduceCGFloat:(CGFloat (^)(CGFloat accumulator, NSUInteger idx, ValueType obj))block initialAccumlator:(CGFloat)initialAccumlator;
- (NSInteger)pv_inspect_reduceInteger:(NSInteger (^)(NSInteger accumulator, NSUInteger idx, ValueType obj))block initialAccumlator:(NSInteger)initialAccumlator;

- (BOOL)pv_inspect_all:(BOOL (^)(ValueType obj))block;

- (BOOL)pv_inspect_any:(BOOL (^)(ValueType obj))block;

- (NSArray<ValueType> *)pv_inspect_arrayByRemovingObject:(ValueType)obj;

- (NSArray<ValueType> *)pv_inspect_nonredundantArray;

- (ValueType)pv_inspect_safeObjectAtIndex:(NSInteger)idx;

/// 字符串长度从短到长，即 length 小的字符串的 idx 更小
- (NSArray<ValueType> *)pv_inspect_sortedArrayByStringLength;

@end

@interface NSMutableArray<ValueType> (PickView)

/**
 如果当前数组长度比 count 小则会补充新元素（被补充的元素由 addBlock 返回），如果当前数组长度比 count 大则多余的元素会被作为参数传入 notDequeued。然后从 idx 为 0 算起，前 count 个元素会被作为参数传入 doBlock
 */
- (void)pv_inspect_dequeueWithCount:(NSUInteger)count add:(ValueType (^)(NSUInteger idx))addBlock notDequeued:(void (^)(NSUInteger idx, ValueType obj))notDequeuedBlock doNext:(void (^)(NSUInteger idx, ValueType obj))doBlock;

- (void)pv_inspect_removeObjectsPassingTest:(BOOL (^)(NSUInteger idx, ValueType obj))block;

@end


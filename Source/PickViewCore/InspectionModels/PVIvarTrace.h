//
//  PVIvarTrace.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import <Foundation/Foundation.h>

extern NSString *const PVIvarTraceRelationValue_Self;

/// 如果 hostClassName 和 ivarName 均 equal，则认为两个 PVIvarTrace 对象彼此 equal
/// 比如 A 是 B 的 superview，且 A 的 "_stageView" 指向 B，则 B 会有一个 PVIvarTrace：hostType 为 “superview”，hostClassName 为 A 的 class，ivarName 为 “_stageView”
@interface PVIvarTrace : NSObject <NSSecureCoding, NSCopying>

/// 该值可能是 "superview"、"superlayer"、“self” 或 nil
@property(nonatomic, copy) NSString *relation;

@property(nonatomic, copy) NSString *hostClassName;

@property(nonatomic, copy) NSString *ivarName;

#pragma mark - No Coding

#if TARGET_OS_IPHONE
@property(nonatomic, weak) id hostObject;
#endif

@end

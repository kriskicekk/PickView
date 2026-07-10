//
//  PVObject.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import <Foundation/Foundation.h>

@class PVObjectIvar, PVIvarTrace;

@interface PVObject : NSObject <NSSecureCoding, NSCopying>

@property(nonatomic, assign) unsigned long oid;

@property(nonatomic, copy) NSString *memoryAddress;

/**
 比如有一个 UILabel 对象，则它的 classChainList 为 @[@"UILabel", @"UIView", @"UIResponder", @"NSObject"]，而它的 ivarList 长度为 4，idx 从小到大分别是 UILabel 层级的 ivars, UIView 层级的 ivars.....
 */
@property(nonatomic, copy) NSArray<NSString *> *classChainList;

@property(nonatomic, copy) NSString *specialTrace;

@property(nonatomic, copy) NSArray<PVIvarTrace *> *ivarTraces;

@property(nonatomic, copy, readonly) NSString *objectID;
@property(nonatomic, copy, readonly) NSString *className;
@property(nonatomic, copy, readonly) NSArray<NSString *> *classChain;

/// 没有 demangle，会包含 Swift Module Name
/// 在 PickView 的展示中，绝大多数情况下应该使用 lk_demangledSwiftName
- (NSString *)rawClassName;

@end

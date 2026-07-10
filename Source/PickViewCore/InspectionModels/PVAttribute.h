//
//  PVAttribute.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVAttrIdentifiers.h"
#import "PVCodingValueType.h"
#import "PVAttrType.h"

@class PVDisplayItem;

@interface PVAttribute : NSObject <NSSecureCoding, NSCopying>

@property(nonatomic, copy) PVAttrIdentifier identifier;

/// 只有 Custom Attr 才有该属性
@property(nonatomic, copy) NSString *displayTitle;

/// 标识 value 的具体类型（如 double / NSString /...）
@property(nonatomic, assign) PVAttrType attrType;

/// 具体的值，需配合 attrType 属性来解析它
/// 对于 String、Color 等 attyType，该属性可能为 nil
@property(nonatomic, strong) id value;

/// 额外信息，大部分情况下它是 nil
/// 当 attyType 为 PVAttrTypeEnumString 时，extraValue 是一个 [String] 且保存了 allEnumCases
@property(nonatomic, strong) id extraValue;

/// 仅 Custom Attr 可能有该属性
/// 对于有 retainedSetter 的 Custom Attr，它的 setter 会以 customSetterID 作为 key 被保存到 LKS_CustomAttrSetterManager 里，后续可以通过这个 uniqueID 重新把 setter 从 LKS_CustomAttrSetterManager 里取出来并调用
@property(nonatomic, copy) NSString *customSetterID;

/// 服务端已解析出的内建属性修改目标。为 0 时客户端继续使用旧版 Blueprint 路由。
@property(nonatomic, assign) unsigned long modificationTargetOid;

/// 与 modificationTargetOid 配套的单参数 setter 名称。
@property(nonatomic, copy) NSString *modificationSetterName;

#pragma mark - 以下属性不会参与 encode/decode

/// 标识该 PVAttribute 对象隶属于哪一个 PVDisplayItem
@property(nonatomic, weak) PVDisplayItem *targetDisplayItem;

- (BOOL)isUserCustom;

@end

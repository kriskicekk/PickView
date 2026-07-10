//
//  PVAttrType.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

typedef NS_ENUM(NSInteger, PVAttrType) {
    PVAttrTypeNone,
    PVAttrTypeVoid,
    PVAttrTypeChar,
    PVAttrTypeInt,
    PVAttrTypeShort,
    PVAttrTypeLong,
    PVAttrTypeLongLong,
    PVAttrTypeUnsignedChar,
    PVAttrTypeUnsignedInt,
    PVAttrTypeUnsignedShort,
    PVAttrTypeUnsignedLong,
    PVAttrTypeUnsignedLongLong,
    PVAttrTypeFloat,
    PVAttrTypeDouble,
    PVAttrTypeBOOL,
    PVAttrTypeSel,
    PVAttrTypeClass,
    PVAttrTypeCGPoint,
    PVAttrTypeCGVector,
    PVAttrTypeCGSize,
    PVAttrTypeCGRect,
    PVAttrTypeCGAffineTransform,
    PVAttrTypeUIEdgeInsets,
    PVAttrTypeUIOffset,
    PVAttrTypeNSString,
    PVAttrTypeEnumInt,
    PVAttrTypeEnumLong,
    /// value 实际为 RGBA 数组，即 @[NSNumber, NSNumber, NSNumber, NSNumber]，NSNumber 范围是 0 ~ 1
    PVAttrTypeUIColor,
    /// 业务需要根据具体的 AttrIdentifier 来解析
    PVAttrTypeCustomObj,
    
    PVAttrTypeEnumString,
    PVAttrTypeShadow,
    PVAttrTypeJson
};


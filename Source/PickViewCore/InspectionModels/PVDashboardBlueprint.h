//
//  PVDashboardBlueprint.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import <Foundation/Foundation.h>
#import "PVAttrIdentifiers.h"
#import "PVAttrType.h"

/**
 该对象定义了：
 - 每一个 Attr 的信息
 - 哪些 GroupID, SectionID, AttrID 是合法的
 - 这些 ID 的父子顺序，比如 PVAttrGroup_Frame 包含哪些 Section
 - 这些 ID 展示顺序（比如哪个 Group 在前、哪个 Group 在后）
 */
@interface PVDashboardBlueprint : NSObject

+ (NSArray<PVAttrGroupIdentifier> *)groupIDs;

+ (NSArray<PVAttrSectionIdentifier> *)sectionIDsForGroupID:(PVAttrGroupIdentifier)groupID;

+ (NSArray<PVAttrIdentifier> *)attrIDsForSectionID:(PVAttrSectionIdentifier)sectionID;

/// 返回包含目标 attr 的 groupID 和 sectionID
+ (void)getHostGroupID:(inout PVAttrGroupIdentifier *)groupID sectionID:(inout PVAttrSectionIdentifier *)sectionID fromAttrID:(PVAttrIdentifier)attrID;

/// 返回某个 group 的标题
+ (NSString *)groupTitleWithGroupID:(PVAttrGroupIdentifier)groupID;

/// 返回某个 section 的标题，nil 则表示不显示标题
+ (NSString *)sectionTitleWithSectionID:(PVAttrSectionIdentifier)secID;

/// 当某个 PVAttribute 确定是 NSObject 类型时，该方法返回它具体是什么对象，比如 UIColor 等
+ (PVAttrType)objectAttrTypeWithAttrID:(PVAttrIdentifier)attrID;

/// 返回某个 PVAttribute 代表的属性是哪一个类拥有的，比如 PVAttrSec_UILabel_TextColor 是 UILabel 才有的
+ (NSString *)classNameWithAttrID:(PVAttrIdentifier)attrID;

+ (BOOL)isWindowPropertyWithAttrID:(PVAttrIdentifier)attrID;

/// 一个 attr 要么属于 UIView 要么属于 CALayer，如果它属于 UIView 那么该方法返回 YES
+ (BOOL)isUIViewPropertyWithAttrID:(PVAttrIdentifier)attrID;

/// 如果某个 attribute 是 enum，则这里会返回相应的 enum 的名称（如 @"NSTextAlignment"），进而可通过这个名称查询可用的枚举值列表
+ (NSString *)enumListNameWithAttrID:(PVAttrIdentifier)attrID;

/// 如果返回 YES，则说明用户在 PV 里修改了该 Attribute 的值后，应该重新拉取和更新相关图层的位置、截图等信息
+ (BOOL)needPatchAfterModificationWithAttrID:(PVAttrIdentifier)attrID;

/// 完整的名字
+ (NSString *)fullTitleWithAttrID:(PVAttrIdentifier)attrID;

/// 在某些 textField 和 checkbox 里会显示这里返回的 title
+ (NSString *)briefTitleWithAttrID:(PVAttrIdentifier)attrID;

/// 获取 getter 方法
+ (SEL)getterWithAttrID:(PVAttrIdentifier)attrID;

/// 获取 setter 方法
+ (SEL)setterWithAttrID:(PVAttrIdentifier)attrID;

/// 获取 “hideIfNil” 的值。如果为 YES，则当读取 getter 获取的 value 为 nil 时，PV 不会传输该 attr
/// 如果为 NO，则即使 value 为 nil 也会传输（比如 label 的 text 属性，即使它是 nil 我们也要显示，所以它的 hideIfNil 应该为 NO）
+ (BOOL)hideIfNilWithAttrID:(PVAttrIdentifier)attrID;

/// 该属性需要的最低的 iOS 版本，比如 safeAreaInsets 从 iOS 11.0 开始出现，则该方法返回 11，如果返回 0 则表示不限制 iOS 版本（注意 PV 项目仅支持 iOS 8.0+）
+ (NSInteger)minAvailableOSVersionWithAttrID:(PVAttrIdentifier)attrID;

@end

//
//  PVDisplayItem+PVClient.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDisplayItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface PVDisplayItem (PVClient)

/// 该 item 在左侧 hierarchy 中显示的字符串，通常是类名
- (NSString *)title;

- (NSString *)subtitle;

/// Recognizes Flutter items from both the current wire model and older servers
/// that only supplied a Flutter reference or the virtual object identifier.
- (BOOL)pv_isFlutterItem;

/// 返回 soloScreenshot 或 groupScreenshot
- (NSImage *)appropriateScreenshot;

/// className 以 “UI”、“CA” 等开头时认为是系统类，该属性将返回 YES
@property(nonatomic, assign, readonly) BOOL representedForSystemClass;

- (BOOL)isUserCustom;

/// 是否有能力显示图层框
- (BOOL)hasPreviewBoxAbility;

- (BOOL)hasValidFrameToRoot;

/// 当 hasValidFrameToRoot 返回 NO 时，该方法返回的值无意义
- (CGRect)calculateFrameToRoot;

/// 在 string 这个搜索词下，如果该 displayItem 应该被搜索到，则该方法返回 YES。
/// string 字段不能为 nil 或空字符串
- (BOOL)isMatchedWithSearchString:(NSString *)string;

/// 遍历自身和所有上级元素
- (void)enumerateSelfAndAncestors:(void (^)(PVDisplayItem *item, BOOL *stop))block;

- (void)enumerateAncestors:(void (^)(PVDisplayItem *item, BOOL *stop))block;

/// 遍历自身后所有下级元素
- (void)enumerateSelfAndChildren:(void (^)(PVDisplayItem *item))block;

- (BOOL)itemIsKindOfClassWithName:(NSString *)className;
- (BOOL)itemIsKindOfClassesWithNames:(NSSet<NSString *> *)classNames;

- (unsigned long)bestObjectOidPreferView:(BOOL)preferView;
- (NSArray<NSNumber *> *)availableObjectOidsPreferView:(BOOL)preferView;

@end

NS_ASSUME_NONNULL_END

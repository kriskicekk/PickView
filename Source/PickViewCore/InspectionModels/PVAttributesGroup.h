//
//  PVAttributesGroup.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import <Foundation/Foundation.h>
#import "PVAttrIdentifiers.h"

@class PVAttributesSection;

/**
 In PickView, a PVAttributesGroup instance will be rendered as a property card.
 
 When isUserCustom is false: two PVAttributesGroup instances will be regard as equal when they has the same PVAttrGroupIdentifier.
 When isUserCustom is true: two PVAttributesGroup instances will be regard as equal when they has the same title.
 当 isUserCustom 为 false 时：若两个 attrGroup 有相同的 PVAttrGroupIdentifier，则 isEqual: 返回 YES
 */
@interface PVAttributesGroup : NSObject <NSSecureCoding, NSCopying>

/// 只有在 identifier 为 custom 时，才存在该值
@property(nonatomic, copy) NSString *userCustomTitle;

@property(nonatomic, copy) PVAttrGroupIdentifier identifier;

@property(nonatomic, copy) NSArray<PVAttributesSection *> *attrSections;

/// 如果是 custom 则返回 userCustomTitle，如果不是 custom 则返回 identifier
- (NSString *)uniqueKey;

- (BOOL)isUserCustom;

@end


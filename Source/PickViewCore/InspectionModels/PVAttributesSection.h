//
//  PVAttributesSection.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import <Foundation/Foundation.h>
#import "PVAttrIdentifiers.h"

@class PVAttribute;

typedef NS_ENUM (NSInteger, PVAttributesSectionStyle) {
    PVAttributesSectionStyleDefault,    // 每个 attr 独占一行
    PVAttributesSectionStyle0,  // frame 等卡片使用，前 4 个 attr 每行两个，之后每个 attr 在同一排，每个宽度为 1/4
    PVAttributesSectionStyle1,  // 第一个 attr 在第一排靠左，第二个 attr 在第一排靠右，之后的 attr 每个独占一行
    PVAttributesSectionStyle2   // 第一排独占一行，剩下的在同一行且均分宽度
};

@interface PVAttributesSection : NSObject <NSSecureCoding, NSCopying>

@property(nonatomic, copy) PVAttrSectionIdentifier identifier;

@property(nonatomic, copy) NSArray<PVAttribute *> *attributes;

- (BOOL)isUserCustom;

@end


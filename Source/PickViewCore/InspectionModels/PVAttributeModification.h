//
//  PVAttributeModification.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import <Foundation/Foundation.h>
#import "PVAttrType.h"

@interface PVAttributeModification : NSObject <NSSecureCoding>

@property(nonatomic, assign) unsigned long targetOid;

@property(nonatomic, assign) SEL setterSelector;
@property(nonatomic, assign) SEL getterSelector;

@property(nonatomic, assign) PVAttrType attrType;
@property(nonatomic, strong) id value;

/// 1.0.4 开始加入这个参数
@property(nonatomic, copy) NSString *clientReadableVersion;

@end


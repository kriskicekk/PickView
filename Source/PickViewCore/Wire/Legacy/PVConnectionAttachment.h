//
//  PVConnectionAttachment.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import <Foundation/Foundation.h>
#import "PVCodingValueType.h"

@interface PVConnectionAttachment : NSObject <NSSecureCoding>

@property(nonatomic, assign) PVCodingValueType dataType;

@property(nonatomic, strong) id data;

@end


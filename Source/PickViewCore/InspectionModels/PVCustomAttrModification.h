//
//  PVCustomAttrModification.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import <Foundation/Foundation.h>
#import "PVAttrType.h"

@interface PVCustomAttrModification : NSObject <NSSecureCoding>

@property(nonatomic, assign) PVAttrType attrType;
@property(nonatomic, copy) NSString *customSetterID;
@property(nonatomic, strong) id value;

@end


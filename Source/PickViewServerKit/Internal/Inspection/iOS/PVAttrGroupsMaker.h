//
//  PVAttrGroupsMaker.h
//  PickViewServer
//
//  Created by kris cheng on 2026/7/9.
//

#import <Foundation/Foundation.h>

@class CALayer;
@class PVAttributesGroup;

NS_ASSUME_NONNULL_BEGIN

@interface PVAttrGroupsMaker : NSObject

+ (NSArray<PVAttributesGroup *> *)attrGroupsForLayer:(CALayer *)layer;

@end

NS_ASSUME_NONNULL_END

//
//  PVInspectionObjectFactory.h
//  PickViewServer
//
//  Created by kris cheng on 2026/7/10.
//

#import <Foundation/Foundation.h>

#import "PVAutoLayoutConstraint.h"

@class PVAutoLayoutConstraint, PVObject;

NS_ASSUME_NONNULL_BEGIN

@interface PVInspectionObjectFactory : NSObject

+ (PVObject *)objectForObject:(nullable NSObject *)object;

#if TARGET_OS_IPHONE
+ (PVAutoLayoutConstraint *)constraintForConstraint:(NSLayoutConstraint *)constraint
                                         isEffective:(BOOL)isEffective
                                       firstItemType:(PVConstraintItemType)firstItemType
                                      secondItemType:(PVConstraintItemType)secondItemType;
#endif

@end

NS_ASSUME_NONNULL_END

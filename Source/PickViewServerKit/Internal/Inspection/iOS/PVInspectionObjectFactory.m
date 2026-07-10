//
//  PVInspectionObjectFactory.m
//  PickViewServer
//
//  Created by kris cheng on 2026/7/10.
//

#import "PVInspectionObjectFactory.h"

#import "PVAutoLayoutConstraint.h"
#import "PVObject.h"

#import <objc/runtime.h>

@implementation PVInspectionObjectFactory

+ (PVObject *)objectForObject:(NSObject *)object {
    PVObject *result = [[PVObject alloc] init];
    result.oid = (unsigned long)(uintptr_t)object;
    result.memoryAddress = object ? [NSString stringWithFormat:@"%p", object] : nil;
    NSMutableArray<NSString *> *classNames = [NSMutableArray array];
    for (Class objectClass = object.class; objectClass; objectClass = class_getSuperclass(objectClass)) {
        [classNames addObject:NSStringFromClass(objectClass)];
    }
    result.classChainList = classNames.copy;
    result.ivarTraces = @[];
    return result;
}

#if TARGET_OS_IPHONE
+ (PVAutoLayoutConstraint *)constraintForConstraint:(NSLayoutConstraint *)constraint
                                         isEffective:(BOOL)isEffective
                                       firstItemType:(PVConstraintItemType)firstItemType
                                      secondItemType:(PVConstraintItemType)secondItemType {
    PVAutoLayoutConstraint *result = [[PVAutoLayoutConstraint alloc] init];
    result.effective = isEffective;
    result.active = constraint.active;
    result.shouldBeArchived = constraint.shouldBeArchived;
    result.firstItem = [self objectForObject:constraint.firstItem];
    result.firstItemType = firstItemType;
    result.firstAttribute = constraint.firstAttribute;
    result.relation = constraint.relation;
    result.secondItem = [self objectForObject:constraint.secondItem];
    result.secondItemType = secondItemType;
    result.secondAttribute = constraint.secondAttribute;
    result.multiplier = constraint.multiplier;
    result.constant = constraint.constant;
    result.priority = constraint.priority;
    result.identifier = constraint.identifier;
    return result;
}
#endif

@end

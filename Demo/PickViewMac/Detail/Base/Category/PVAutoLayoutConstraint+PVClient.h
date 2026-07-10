//
//  PVAutoLayoutConstraint+PVClient.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVAutoLayoutConstraint.h"

@interface PVAutoLayoutConstraint (PVClient)

+ (NSString *)descriptionWithItemObject:(PVObject *)object type:(PVConstraintItemType)type detailed:(BOOL)detailed;
+ (NSString *)descriptionWithAttributeInt:(NSInteger)attribute;
+ (NSString *)symbolWithRelation:(NSLayoutRelation)relation;
+ (NSString *)descriptionWithRelation:(NSLayoutRelation)relation;

@end

//
//  PickViewAutoLayoutConstraint+PickViewClient.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "PickViewAutoLayoutConstraint.h"

@interface PickViewAutoLayoutConstraint (PickViewClient)

+ (NSString *)descriptionWithItemObject:(PickViewObject *)object type:(PickViewConstraintItemType)type detailed:(BOOL)detailed;
+ (NSString *)descriptionWithAttributeInt:(NSInteger)attribute;
+ (NSString *)symbolWithRelation:(NSLayoutRelation)relation;
+ (NSString *)descriptionWithRelation:(NSLayoutRelation)relation;

@end

//
//  LKJSONAttributeItem.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import <Foundation/Foundation.h>

@interface LKJSONAttributeItem : NSObject

@property(nonatomic, copy) NSString *titleText;
@property(nonatomic, copy) NSString *desc;
@property(nonatomic, assign) BOOL expanded;
@property(nonatomic, assign) NSUInteger indentation;

@property(nonatomic, strong) NSArray<LKJSONAttributeItem *> *subItems;

- (NSArray<LKJSONAttributeItem *> *)flatItems;

@end

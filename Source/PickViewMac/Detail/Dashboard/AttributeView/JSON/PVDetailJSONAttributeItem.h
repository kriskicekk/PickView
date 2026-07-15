//
//  PVDetailJSONAttributeItem.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import <Foundation/Foundation.h>

@interface PVDetailJSONAttributeItem : NSObject

@property(nonatomic, copy) NSString *titleText;
@property(nonatomic, copy) NSString *desc;
@property(nonatomic, assign) BOOL expanded;
@property(nonatomic, assign) NSUInteger indentation;

@property(nonatomic, strong) NSArray<PVDetailJSONAttributeItem *> *subItems;

- (NSArray<PVDetailJSONAttributeItem *> *)flatItems;

@end

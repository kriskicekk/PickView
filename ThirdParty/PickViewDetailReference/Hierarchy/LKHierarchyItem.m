//
//  LKHierarchyItem.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "LKHierarchyItem.h"

@interface LKHierarchyItem ()

@property(nonatomic, assign, readwrite) NSUInteger indentation;
@property(nonatomic, weak, readwrite) LKHierarchyItem *superItem;

@end

@implementation LKHierarchyItem

- (NSArray<LKHierarchyItem *> *)flatItems {
    NSMutableArray<LKHierarchyItem *> *array = [NSMutableArray array];
    
    [array addObject:self];
    
    if (self.status == LKHierarchyItemStatusExpanded) {
        [self.subItems enumerateObjectsUsingBlock:^(LKHierarchyItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.indentation = self.indentation + 1;
            [array addObjectsFromArray:[obj flatItems]];
        }];
    }
    
    return array.copy;
}

+ (NSArray<LKHierarchyItem *> *)flatItemsFromRootItems:(NSArray<LKHierarchyItem *> *)items {
    NSMutableArray<LKHierarchyItem *> *resultItems = [NSMutableArray array];
    [items enumerateObjectsUsingBlock:^(LKHierarchyItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [resultItems addObjectsFromArray:[obj flatItems]];
    }];
    return resultItems.copy;
}

@end

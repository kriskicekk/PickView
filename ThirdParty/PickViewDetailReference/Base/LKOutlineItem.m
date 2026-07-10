//
//  LKOutlineItem.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "LKOutlineItem.h"

@interface LKOutlineItem ()

@property(nonatomic, assign, readwrite) NSUInteger indentation;

@end

@implementation LKOutlineItem

- (void)setSubItems:(NSArray<LKOutlineItem *> *)subItems {
    _subItems = subItems.copy;
    if (subItems) {
        self.status = LKOutlineItemStatusCollapsed;
    } else {
        self.status = LKOutlineItemStatusNotExpandable;
    }
}

- (NSArray<LKOutlineItem *> *)flatItems {
    NSMutableArray<LKOutlineItem *> *array = [NSMutableArray array];
    
    [array addObject:self];
    
    if (self.status == LKOutlineItemStatusExpanded) {
        [self.subItems enumerateObjectsUsingBlock:^(LKOutlineItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.indentation = self.indentation + 1;
            [array addObjectsFromArray:[obj flatItems]];
        }];
    }
    
    return array.copy;
}

+ (NSArray<LKOutlineItem *> *)flatItemsFromRootItems:(NSArray<LKOutlineItem *> *)items {
    NSMutableArray<LKOutlineItem *> *resultItems = [NSMutableArray array];
    [items enumerateObjectsUsingBlock:^(LKOutlineItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [resultItems addObjectsFromArray:[obj flatItems]];
    }];
    return resultItems.copy;
}

@end

//
//  PVDetailHierarchyItem.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailHierarchyItem.h"

@interface PVDetailHierarchyItem ()

@property(nonatomic, assign, readwrite) NSUInteger indentation;
@property(nonatomic, weak, readwrite) PVDetailHierarchyItem *superItem;

@end

@implementation PVDetailHierarchyItem

- (NSArray<PVDetailHierarchyItem *> *)flatItems {
    NSMutableArray<PVDetailHierarchyItem *> *array = [NSMutableArray array];
    
    [array addObject:self];
    
    if (self.status == PVDetailHierarchyItemStatusExpanded) {
        [self.subItems enumerateObjectsUsingBlock:^(PVDetailHierarchyItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.indentation = self.indentation + 1;
            [array addObjectsFromArray:[obj flatItems]];
        }];
    }
    
    return array.copy;
}

+ (NSArray<PVDetailHierarchyItem *> *)flatItemsFromRootItems:(NSArray<PVDetailHierarchyItem *> *)items {
    NSMutableArray<PVDetailHierarchyItem *> *resultItems = [NSMutableArray array];
    [items enumerateObjectsUsingBlock:^(PVDetailHierarchyItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [resultItems addObjectsFromArray:[obj flatItems]];
    }];
    return resultItems.copy;
}

@end

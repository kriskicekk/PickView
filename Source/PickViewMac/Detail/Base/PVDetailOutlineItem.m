//
//  PVDetailOutlineItem.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailOutlineItem.h"

@interface PVDetailOutlineItem ()

@property(nonatomic, assign, readwrite) NSUInteger indentation;

@end

@implementation PVDetailOutlineItem

- (void)setSubItems:(NSArray<PVDetailOutlineItem *> *)subItems {
    _subItems = subItems.copy;
    if (subItems) {
        self.status = PVDetailOutlineItemStatusCollapsed;
    } else {
        self.status = PVDetailOutlineItemStatusNotExpandable;
    }
}

- (NSArray<PVDetailOutlineItem *> *)flatItems {
    NSMutableArray<PVDetailOutlineItem *> *array = [NSMutableArray array];
    
    [array addObject:self];
    
    if (self.status == PVDetailOutlineItemStatusExpanded) {
        [self.subItems enumerateObjectsUsingBlock:^(PVDetailOutlineItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.indentation = self.indentation + 1;
            [array addObjectsFromArray:[obj flatItems]];
        }];
    }
    
    return array.copy;
}

+ (NSArray<PVDetailOutlineItem *> *)flatItemsFromRootItems:(NSArray<PVDetailOutlineItem *> *)items {
    NSMutableArray<PVDetailOutlineItem *> *resultItems = [NSMutableArray array];
    [items enumerateObjectsUsingBlock:^(PVDetailOutlineItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [resultItems addObjectsFromArray:[obj flatItems]];
    }];
    return resultItems.copy;
}

@end

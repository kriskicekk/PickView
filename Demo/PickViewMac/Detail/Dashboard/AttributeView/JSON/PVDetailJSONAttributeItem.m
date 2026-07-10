//
//  PVDetailJSONAttributeItem.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailJSONAttributeItem.h"

@implementation PVDetailJSONAttributeItem

- (instancetype)init {
    self = [super init];
    if (self) {
        self.expanded = YES;
        self.subItems = [NSMutableArray array];
    }
    return self;
}

- (NSArray<PVDetailJSONAttributeItem *> *)flatItems {
    NSMutableArray<PVDetailJSONAttributeItem *> *array = [NSMutableArray array];
    
    [array addObject:self];
    
    if (self.expanded) {
        [self.subItems enumerateObjectsUsingBlock:^(PVDetailJSONAttributeItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.indentation = self.indentation + 1;
            [array addObjectsFromArray:[obj flatItems]];
        }];
    }
    
    return array;
}

@end

//
//  PVDetailDashboardSectionViewPool.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailDashboardSectionViewPool.h"
#import "PVAttributesSection+PVClient.h"
#import "PVAttribute.h"

@interface PVDetailDashboardSectionViewPool ()

/// 已经被使用的 views，不可以再 dequeue 了
@property(nonatomic, strong) NSMutableSet<PVDetailDashboardSectionView *> *dequeuedViews;
/// 无论是否 dequeue，都会保存在这里
@property(nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<PVDetailDashboardSectionView *> *> *cache;

@end

@implementation PVDetailDashboardSectionViewPool

- (instancetype)init {
    self = [super init];
    if (self) {
        self.dequeuedViews = [NSMutableSet set];
        self.cache = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)recycleAll {
    [self.dequeuedViews removeAllObjects];
}

- (PVDetailDashboardSectionView *)dequeViewForSection:(PVAttributesSection *)section {
    NSString *key = [self cacheKeyForSection:section];
    if (!self.cache[key]) {
        self.cache[key] = [NSMutableArray array];
    }
    for (PVDetailDashboardSectionView *v in self.cache[key]) {
        if ([self.dequeuedViews containsObject:v]) {
            continue;
        }
        [self.dequeuedViews addObject:v];
        return v;
    }
    PVDetailDashboardSectionView *newView = [PVDetailDashboardSectionView new];
    [self.dequeuedViews addObject:newView];
    [self.cache[key] addObject:newView];
    return newView;
}

- (NSString *)cacheKeyForSection:(PVAttributesSection *)section {
    if (!section.isUserCustom) {
        return [section identifier];
    }
    NSString *key = [[section.attributes pv_inspect_map:^id(NSUInteger idx, PVAttribute *value) {
        return value.displayTitle;
    }] componentsJoinedByString:@","];
    return key;
}

@end

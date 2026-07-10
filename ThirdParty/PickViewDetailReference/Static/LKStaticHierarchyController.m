//
//  LKStaticHierarchyController.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "LKStaticHierarchyController.h"
#import "LKStaticHierarchyDataSource.h"
#import "PickViewDisplayItem.h"

@implementation LKStaticHierarchyController

#pragma mark - LKHierarchyViewDelegate

- (void)hierarchyView:(LKHierarchyView *)view needToCancelPreviewOfItem:(PickViewDisplayItem *)item {
    item.noPreview = YES;
    [((LKStaticHierarchyDataSource *)self.dataSource).itemDidChangeNoPreview sendNext:nil];
}

- (void)hierarchyView:(LKHierarchyView *)view needToShowPreviewOfItem:(PickViewDisplayItem *)item {
    [item enumerateSelfAndAncestors:^(PickViewDisplayItem *item, BOOL *stop) {
        if (item.noPreview) {
            item.noPreview = NO;
        }
    }];
    [((LKStaticHierarchyDataSource *)self.dataSource).itemDidChangeNoPreview sendNext:nil];
}

@end

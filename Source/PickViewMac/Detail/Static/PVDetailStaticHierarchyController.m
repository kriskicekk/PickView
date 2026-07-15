//
//  PVDetailStaticHierarchyController.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailStaticHierarchyController.h"
#import "PVDetailStaticHierarchyDataSource.h"
#import "PVDisplayItem.h"

@implementation PVDetailStaticHierarchyController

#pragma mark - PVDetailHierarchyViewDelegate

- (void)hierarchyView:(PVDetailHierarchyView *)view needToCancelPreviewOfItem:(PVDisplayItem *)item {
    item.noPreview = YES;
    [((PVDetailStaticHierarchyDataSource *)self.dataSource).itemDidChangeNoPreview sendNext:nil];
}

- (void)hierarchyView:(PVDetailHierarchyView *)view needToShowPreviewOfItem:(PVDisplayItem *)item {
    [item enumerateSelfAndAncestors:^(PVDisplayItem *item, BOOL *stop) {
        if (item.noPreview) {
            item.noPreview = NO;
        }
    }];
    [((PVDetailStaticHierarchyDataSource *)self.dataSource).itemDidChangeNoPreview sendNext:nil];
}

@end

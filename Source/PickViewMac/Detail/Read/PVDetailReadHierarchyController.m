//
//  PVDetailReadHierarchyController.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailReadHierarchyController.h"
#import "PVDetailReadHierarchyDataSource.h"
#import "PVDisplayItem.h"

@interface PVDetailReadHierarchyController ()

@end

@implementation PVDetailReadHierarchyController

- (void)hierarchyView:(PVDetailHierarchyView *)view needToCancelPreviewOfItem:(PVDisplayItem *)item {
    item.noPreview = YES;
    [((PVDetailReadHierarchyDataSource *)self.dataSource).itemDidChangeNoPreview sendNext:nil];
}

- (void)hierarchyView:(PVDetailHierarchyView *)view needToShowPreviewOfItem:(PVDisplayItem *)item {
    [item enumerateSelfAndAncestors:^(PVDisplayItem *item, BOOL *stop) {
        if (item.noPreview) {
            item.noPreview = NO;
        }
    }];
    [((PVDetailReadHierarchyDataSource *)self.dataSource).itemDidChangeNoPreview sendNext:nil];
}

@end

//
//  PVDetailHierarchyDataSource+KeyDown.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailHierarchyDataSource+KeyDown.h"
#import "PVDisplayItem.h"

@implementation PVDetailHierarchyDataSource (KeyDown)

- (BOOL)keyDown:(NSEvent *)event {
    PVDisplayItem *currentItem = self.selectedItem;
    NSInteger selectedRowIdx = [self.displayingFlatItems indexOfObject:self.selectedItem];
    if (selectedRowIdx == NSNotFound) {
        return false;
    }

    switch (event.keyCode) {
        case 125: {  // down
            PVDisplayItem *willSelectedItem = [self.displayingFlatItems pv_inspect_safeObjectAtIndex:selectedRowIdx + 1];
            if (willSelectedItem) {
                self.selectedItem = willSelectedItem;
                return true;
            }
        } break;
        case 126: { // up
            PVDisplayItem *willSelectedItem = [self.displayingFlatItems pv_inspect_safeObjectAtIndex:selectedRowIdx - 1];
            if (willSelectedItem) {
                self.selectedItem = willSelectedItem;
                return true;
            }
        } break;
        case 123: { // left
            if (currentItem.isExpandable && currentItem.isExpanded) {
                [self collapseItem:currentItem];
                return true;
            } else if (currentItem.superItem && [self.displayingFlatItems indexOfObject:currentItem.superItem] != NSNotFound) {
                [self collapseItem:currentItem.superItem];
                self.selectedItem = currentItem.superItem;
                return true;
            }
        } break;
        case 124: { // right
            if (currentItem.isExpandable && !currentItem.isExpanded) {
                [self expandItem:self.selectedItem];
                return true;
            } else {
                NSArray<PVDisplayItem *> *displayItems = self.displayingFlatItems.copy;
                for (NSInteger i = selectedRowIdx + 1; i < displayItems.count; i++) {
                    PVDisplayItem *next = displayItems[i];
                    if (!next.inHiddenHierarchy) {
                        self.selectedItem = next;
                        return true;
                    }
                }
            }
        } break;
        default:
            break;
    }

    return false;
}
@end

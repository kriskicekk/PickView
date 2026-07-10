//
//  LKHierarchyDataSource+KeyDown.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "LKHierarchyDataSource+KeyDown.h"
#import "PickViewDisplayItem.h"

@implementation LKHierarchyDataSource (KeyDown)

- (BOOL)keyDown:(NSEvent *)event {
    PickViewDisplayItem *currentItem = self.selectedItem;
    NSInteger selectedRowIdx = [self.displayingFlatItems indexOfObject:self.selectedItem];
    if (selectedRowIdx == NSNotFound) {
        return false;
    }

    switch (event.keyCode) {
        case 125: {  // down
            PickViewDisplayItem *willSelectedItem = [self.displayingFlatItems pickview_safeObjectAtIndex:selectedRowIdx + 1];
            if (willSelectedItem) {
                self.selectedItem = willSelectedItem;
                return true;
            }
        } break;
        case 126: { // up
            PickViewDisplayItem *willSelectedItem = [self.displayingFlatItems pickview_safeObjectAtIndex:selectedRowIdx - 1];
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
                NSArray<PickViewDisplayItem *> *displayItems = self.displayingFlatItems.copy;
                for (NSInteger i = selectedRowIdx + 1; i < displayItems.count; i++) {
                    PickViewDisplayItem *next = displayItems[i];
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

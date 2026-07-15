//
//  PVDetailHierarchyController.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailHierarchyController.h"
#import "PVDetailHierarchyDataSource.h"
#import "PVDisplayItem.h"
#import "PVDetailTableView.h"
#import "PVDetailTutorialManager.h"
#import "PVDetailHierarchyDataSource+KeyDown.h"
#import "PVDetailPreferenceManager.h"

@interface PVDetailHierarchyController ()

@end

@implementation PVDetailHierarchyController

- (instancetype)initWithDataSource:(PVDetailHierarchyDataSource *)dataSource {
    PVDetailHierarchyView *hierarchyView = [[PVDetailHierarchyView alloc] initWithDataSource:dataSource];
    hierarchyView.delegate = self;
    if (self = [self initWithContainerView:hierarchyView]) {
        _dataSource = dataSource;
        _hierarchyView = hierarchyView;
    }
    return self;
}

- (void)viewDidAppear {
    [super viewDidAppear];
    if (!TutorialMng.hasAlreadyShowedTipsThisLaunch && !TutorialMng.copyTitle) {
        NSView *selectedView = [self currentSelectedRowView];
        if (selectedView) {
            TutorialMng.hasAlreadyShowedTipsThisLaunch = YES;
            [TutorialMng showPopoverOfView:selectedView text:NSLocalizedString(@"You can copy ivar or class name in right-cick menu.", nil) learned:^{
                TutorialMng.copyTitle = YES;
            }];
        }
    }
    if (!TutorialMng.hasAlreadyShowedTipsThisLaunch && !TutorialMng.eventsHandler) {
        // 第一个 row 一般是 UIWindow，上面肯定是有手势的
        PVDetailHierarchyRowView *rowView = [self.hierarchyView.tableView.tableView rowViewAtRow:0 makeIfNecessary:NO];
        if (![rowView isKindOfClass:[PVDetailHierarchyRowView class]]) {
            return;
        }
        if (rowView.displayItem.eventHandlers.count && rowView.eventHandlerButton) {
            TutorialMng.hasAlreadyShowedTipsThisLaunch = YES;
            TutorialMng.eventsHandler = YES;
            [TutorialMng showPopoverOfView:rowView.eventHandlerButton text:@"这个蓝色图标表示存在 GestureRecognizer 等事件处理器，可点击这个蓝色图标查看详情" learned:^{
                TutorialMng.eventsHandler = YES;
            }];
        }
    }
}

- (NSView *)makeContainerView {
    PVDetailHierarchyView *hierarchyView = [[PVDetailHierarchyView alloc] init];
    hierarchyView.delegate = self;
    _hierarchyView = hierarchyView;
    return hierarchyView;
}

- (NSView *)currentSelectedRowView {
    NSInteger row = [self.dataSource.displayingFlatItems indexOfObject:self.dataSource.selectedItem];
    if (row == NSNotFound) {
//        NSAssert(NO, @"PVDetailHierarchyController, currentSelectedRowView, NSNotFound");
        return nil;
    }
    return [self.hierarchyView.tableView.tableView rowViewAtRow:row makeIfNecessary:NO];
}

- (BOOL)acceptsFirstResponder {
    return true;
}


- (void)keyDown:(NSEvent *)event {
    if ([self.dataSource keyDown:event]) {
        return;
    }

    [super keyDown:event];
}

#pragma mark - <PVDetailHierarchyViewDelegate>

- (void)hierarchyView:(PVDetailHierarchyView *)view didSelectItem:(PVDisplayItem *)item {
    self.dataSource.selectedItem = item;
}

- (void)hierarchyView:(PVDetailHierarchyView *)view didDoubleClickItem:(PVDisplayItem *)item {
    BOOL hasShowedAsk = [PVDetailPreferenceManager popupToAskDoubleClickBehaviorIfNeededWithWindow:self.view.window];
    if (hasShowedAsk) {
        return;
    }

    PVDoubleClickBehavior behavior = [[PVDetailPreferenceManager mainManager] doubleClickBehavior];
    if (behavior == PVDoubleClickBehaviorCollapse) {
        if (!item.isExpandable) {
            return;
        }
        if (item.isExpanded) {
            [self.dataSource collapseItem:item];
        } else {
            [self.dataSource expandItem:item];
        }

    } else if (behavior == PVDoubleClickBehaviorFocus) {
        [self.dataSource focusDisplayItem:item];
        
    } else {
        NSAssert(NO, @"");
    }
}

/// 注意这里 item 可能为 nil
- (void)hierarchyView:(PVDetailHierarchyView *)view didHoverAtItem:(PVDisplayItem *)item {
    self.dataSource.hoveredItem = item;
}

- (void)hierarchyView:(PVDetailHierarchyView *)view needToCollapseItem:(PVDisplayItem *)item {
    [self.dataSource collapseItem:item];
}

- (void)hierarchyView:(PVDetailHierarchyView *)view needToCollapseChildrenOfItem:(PVDisplayItem *)item {
    [self.dataSource collapseAllChildrenOfItem:item];
}

- (void)hierarchyView:(PVDetailHierarchyView *)view needToExpandItem:(PVDisplayItem *)item recursively:(BOOL)recursively {
    if (recursively) {
        [self.dataSource expandItemsRootedByItem:item];
    } else {
        [self.dataSource expandItem:item];
    }
}

- (void)hierarchyView:(PVDetailHierarchyView *)view didInputSearchString:(NSString *)string {
    NSLog(@"search string:%@", string);
    if (string.length) {
        [self.dataSource searchWithString:string];
    } else {
        [self.dataSource endSearch];
        if (self.dataSource.selectedItem) {
            // 结束搜索，滚动到选中的 item
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.hierarchyView scrollToMakeItemVisible:self.dataSource.selectedItem];
            });
        }
    }
}

@end

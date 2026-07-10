//
//  PVDetailHierarchyView.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailBaseView.h"
#import "PVDetailHierarchyRowView.h"

@class PVDetailHierarchyView, PVDetailTableView, PVDetailHierarchyDataSource;

@protocol PVDetailHierarchyViewDelegate <NSObject>

- (void)hierarchyView:(PVDetailHierarchyView *)view didSelectItem:(PVDisplayItem *)item;

- (void)hierarchyView:(PVDetailHierarchyView *)view didDoubleClickItem:(PVDisplayItem *)item;

- (void)hierarchyView:(PVDetailHierarchyView *)view didHoverAtItem:(PVDisplayItem *)item;

- (void)hierarchyView:(PVDetailHierarchyView *)view needToExpandItem:(PVDisplayItem *)item recursively:(BOOL)recursively;

- (void)hierarchyView:(PVDetailHierarchyView *)view needToCollapseItem:(PVDisplayItem *)item;

- (void)hierarchyView:(PVDetailHierarchyView *)view needToCollapseChildrenOfItem:(PVDisplayItem *)item;

/// 在底部的搜索框里输入了文字，string 可能为空字符串或 nil
/// 当用户通过搜索框的关闭按钮、ESC 等方式手动结束搜索时，该方法同样会被调用，参数是 nil
- (void)hierarchyView:(PVDetailHierarchyView *)view didInputSearchString:(NSString *)string;

@optional

- (void)hierarchyView:(PVDetailHierarchyView *)view needToCancelPreviewOfItem:(PVDisplayItem *)item;

- (void)hierarchyView:(PVDetailHierarchyView *)view needToShowPreviewOfItem:(PVDisplayItem *)item;

@end

@interface PVDetailHierarchyView : PVDetailBaseView

- (instancetype)initWithDataSource:(PVDetailHierarchyDataSource *)dataSource;

@property(nonatomic, strong, readonly) PVDetailTableView *tableView;

@property(nonatomic, strong) PVDetailHierarchyDataSource *dataSource;
          
@property(nonatomic, weak) id<PVDetailHierarchyViewDelegate> delegate;

- (void)scrollToMakeItemVisible:(PVDisplayItem *)item;

- (void)updateGuidesWithHoveredItem:(PVDisplayItem *)item;

/// 激活搜索框
- (void)activateSearchBar;

@end

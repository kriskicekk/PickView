//
//  LKHierarchyView.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "LKBaseView.h"
#import "LKHierarchyRowView.h"

@class LKHierarchyView, LKTableView, LKHierarchyDataSource;

@protocol LKHierarchyViewDelegate <NSObject>

- (void)hierarchyView:(LKHierarchyView *)view didSelectItem:(PickViewDisplayItem *)item;

- (void)hierarchyView:(LKHierarchyView *)view didDoubleClickItem:(PickViewDisplayItem *)item;

- (void)hierarchyView:(LKHierarchyView *)view didHoverAtItem:(PickViewDisplayItem *)item;

- (void)hierarchyView:(LKHierarchyView *)view needToExpandItem:(PickViewDisplayItem *)item recursively:(BOOL)recursively;

- (void)hierarchyView:(LKHierarchyView *)view needToCollapseItem:(PickViewDisplayItem *)item;

- (void)hierarchyView:(LKHierarchyView *)view needToCollapseChildrenOfItem:(PickViewDisplayItem *)item;

/// 在底部的搜索框里输入了文字，string 可能为空字符串或 nil
/// 当用户通过搜索框的关闭按钮、ESC 等方式手动结束搜索时，该方法同样会被调用，参数是 nil
- (void)hierarchyView:(LKHierarchyView *)view didInputSearchString:(NSString *)string;

@optional

- (void)hierarchyView:(LKHierarchyView *)view needToCancelPreviewOfItem:(PickViewDisplayItem *)item;

- (void)hierarchyView:(LKHierarchyView *)view needToShowPreviewOfItem:(PickViewDisplayItem *)item;

@end

@interface LKHierarchyView : LKBaseView

- (instancetype)initWithDataSource:(LKHierarchyDataSource *)dataSource;

@property(nonatomic, strong, readonly) LKTableView *tableView;

@property(nonatomic, strong) LKHierarchyDataSource *dataSource;
          
@property(nonatomic, weak) id<LKHierarchyViewDelegate> delegate;

- (void)scrollToMakeItemVisible:(PickViewDisplayItem *)item;

- (void)updateGuidesWithHoveredItem:(PickViewDisplayItem *)item;

/// 激活搜索框
- (void)activateSearchBar;

@end

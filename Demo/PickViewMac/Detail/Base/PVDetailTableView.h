//
//  PVDetailTableView.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import <Cocoa/Cocoa.h>

@class PVDetailTableView;

@protocol PVDetailTableViewDelegate <NSTableViewDelegate>

@optional

/// 以下方法的 row 均可能为 -1
- (void)tableView:(PVDetailTableView *)tableView didSelectRow:(NSInteger)row;
- (void)tableView:(PVDetailTableView *)tableView didHoverAtRow:(NSInteger)row;
- (void)tableView:(PVDetailTableView *)tableView didDoubleClickAtRow:(NSInteger)row;
// 点击了空白处
- (void)tableViewDidClickBlankArea:(PVDetailTableView *)tableView;

@end

@protocol PVDetailTableViewDataSource <NSTableViewDataSource>

@end

@interface PVDetailTableView : NSScrollView

@property(nonatomic, strong, readonly) NSTableView *tableView;

/// 默认为 YES
@property(nonatomic, assign) BOOL canScrollHorizontally;

@property(nonatomic, weak) id<PVDetailTableViewDelegate> delegate;
@property(nonatomic, weak) id<PVDetailTableViewDataSource> dataSource;

/// 默认为 YES
@property(nonatomic, assign) BOOL adjustsSelectionAutomatically;
/// 默认为 YES
@property(nonatomic, assign) BOOL adjustsHoverAutomatically;

- (void)reloadData;

/// reloadData 但是仍维持原本的滚动条位置（上面的 reloadData 会重置 offset）
- (void)reloadDataWithOffset;

- (void)scrollRowToVisible:(NSInteger)row;

@end

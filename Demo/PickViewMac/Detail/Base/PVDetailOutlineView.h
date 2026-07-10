//
//  PVDetailOutlineView.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailBaseView.h"

@class PVDetailOutlineView, PVDetailOutlineItem, PVDetailOutlineRowView, PVDetailTableView;

@protocol PVDetailOutlineViewDelegate <NSObject>

- (void)outlineView:(PVDetailOutlineView *)view configureRowView:(PVDetailOutlineRowView *)rowView withItem:(PVDetailOutlineItem *)item;

@end

@interface PVDetailOutlineView : PVDetailBaseView

/// aClass 必须是 PVDetailOutlineRowView 或 PVDetailOutlineRowView 的 subclass
- (instancetype)initWithRowViewClass:(Class)aClass NS_DESIGNATED_INITIALIZER;

@property(nonatomic, strong) NSArray<PVDetailOutlineItem *> *items;

@property(nonatomic, weak) id<PVDetailOutlineViewDelegate> delegate;

/// 默认为 24
@property(nonatomic, assign) CGFloat itemHeight;

@property(nonatomic, strong, readonly) PVDetailTableView *tableView;

@property(nonatomic, copy, readonly) NSArray<PVDetailOutlineItem *> *displayingItems;

@end

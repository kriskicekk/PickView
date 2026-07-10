//
//  LKOutlineView.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "LKBaseView.h"

@class LKOutlineView, LKOutlineItem, LKOutlineRowView, LKTableView;

@protocol LKOutlineViewDelegate <NSObject>

- (void)outlineView:(LKOutlineView *)view configureRowView:(LKOutlineRowView *)rowView withItem:(LKOutlineItem *)item;

@end

@interface LKOutlineView : LKBaseView

/// aClass 必须是 LKOutlineRowView 或 LKOutlineRowView 的 subclass
- (instancetype)initWithRowViewClass:(Class)aClass NS_DESIGNATED_INITIALIZER;

@property(nonatomic, strong) NSArray<LKOutlineItem *> *items;

@property(nonatomic, weak) id<LKOutlineViewDelegate> delegate;

/// 默认为 24
@property(nonatomic, assign) CGFloat itemHeight;

@property(nonatomic, strong, readonly) LKTableView *tableView;

@property(nonatomic, copy, readonly) NSArray<LKOutlineItem *> *displayingItems;

@end

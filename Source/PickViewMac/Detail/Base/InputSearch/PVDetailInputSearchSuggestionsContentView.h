//
//  PVDetailInputSearchSuggestionsContentView.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailBaseView.h"

@class PVDetailInputSearchSuggestionItem;

@interface PVDetailInputSearchSuggestionsContentView : PVDetailBaseView

@property(nonatomic, copy) NSArray<PVDetailInputSearchSuggestionItem *> *items;

@property(nonatomic, strong, readonly) NSTableView *tableView;

- (PVDetailInputSearchSuggestionItem *)currentSelectedItem;

- (NSSize)bestSize;

@end

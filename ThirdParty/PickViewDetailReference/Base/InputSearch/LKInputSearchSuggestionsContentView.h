//
//  LKInputSearchSuggestionsContentView.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "LKBaseView.h"

@class LKInputSearchSuggestionItem;

@interface LKInputSearchSuggestionsContentView : LKBaseView

@property(nonatomic, copy) NSArray<LKInputSearchSuggestionItem *> *items;

@property(nonatomic, strong, readonly) NSTableView *tableView;

- (LKInputSearchSuggestionItem *)currentSelectedItem;

- (NSSize)bestSize;

@end

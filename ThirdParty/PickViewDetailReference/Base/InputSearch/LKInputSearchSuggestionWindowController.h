//
//  LKInputSearchSuggestionWindowController.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "LKWindowController.h"

@class LKInputSearchSuggestionsContentView;

@interface LKInputSearchSuggestionWindowController : LKWindowController

@property(nonatomic, strong) LKInputSearchSuggestionsContentView *suggestionsView;

@end

//
//  PVDetailInputSearchSuggestionWindowController.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailWindowController.h"

@class PVDetailInputSearchSuggestionsContentView;

@interface PVDetailInputSearchSuggestionWindowController : PVDetailWindowController

@property(nonatomic, strong) PVDetailInputSearchSuggestionsContentView *suggestionsView;

@end

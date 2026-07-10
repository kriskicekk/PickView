//
//  PVDetailInputSearchView.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailBaseView.h"

@class PVDetailInputSearchSuggestionItem, PVDetailInputSearchView;

@protocol PVDetailInputSearchViewDelegate <NSObject>

- (NSArray<PVDetailInputSearchSuggestionItem *> *)inputSearchView:(PVDetailInputSearchView *)view suggestionsForString:(NSString *)string;

- (void)inputSearchView:(PVDetailInputSearchView *)view submitText:(NSString *)text;

@end

@interface PVDetailInputSearchView : PVDetailBaseView

- (instancetype)initWithThrottleTime:(CGFloat)throttleTime;

@property(nonatomic, assign) CGFloat horizontalInset;

@property(nonatomic, strong, readonly) NSTextField *textField;

- (void)clearContentAndSuggestions;

@property(nonatomic, weak) id<PVDetailInputSearchViewDelegate> delegate;

@end

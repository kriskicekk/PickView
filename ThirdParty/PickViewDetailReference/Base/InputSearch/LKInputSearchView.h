//
//  LKInputSearchView.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "LKBaseView.h"

@class LKInputSearchSuggestionItem, LKInputSearchView;

@protocol LKInputSearchViewDelegate <NSObject>

- (NSArray<LKInputSearchSuggestionItem *> *)inputSearchView:(LKInputSearchView *)view suggestionsForString:(NSString *)string;

- (void)inputSearchView:(LKInputSearchView *)view submitText:(NSString *)text;

@end

@interface LKInputSearchView : LKBaseView

- (instancetype)initWithThrottleTime:(CGFloat)throttleTime;

@property(nonatomic, assign) CGFloat horizontalInset;

@property(nonatomic, strong, readonly) NSTextField *textField;

- (void)clearContentAndSuggestions;

@property(nonatomic, weak) id<LKInputSearchViewDelegate> delegate;

@end

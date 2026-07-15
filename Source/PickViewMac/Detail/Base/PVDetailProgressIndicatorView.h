//
//  PVDetailProgressIndicatorView.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailBaseView.h"

extern const CGFloat InitialIndicatorProgressWhenFetchHierarchy;

@interface PVDetailProgressIndicatorView : PVDetailBaseView

@property(nonatomic, assign, readonly) CGFloat progress;

- (void)resetToZero;

/// 默认 duration 为 0.3
- (void)animateToProgress:(CGFloat)progress;

- (void)animateToProgress:(CGFloat)progress duration:(NSTimeInterval)duration;

- (void)finishWithCompletion:(void (^)(void))completionBlock;

@end

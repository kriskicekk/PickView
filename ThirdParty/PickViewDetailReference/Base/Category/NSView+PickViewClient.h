//
//  NSView+PickViewClient.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import <Cocoa/Cocoa.h>

@interface NSView (PickViewClient)

@property(nonatomic, assign, readonly) BOOL isVisible;

@property(nonatomic, copy) NSString *backgroundColorName;

/// 将一个 view 作为自己的 subview 并且放到最底部
- (void)lk_insertSubviewAtBottom:(NSView *)view;

- (void)showDebugBorder;

@end

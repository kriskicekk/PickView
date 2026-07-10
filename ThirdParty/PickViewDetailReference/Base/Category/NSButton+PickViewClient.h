//
//  NSButton+PickViewClient.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

@interface NSButton (PickViewClient)

/// size 已经被设置好
+ (instancetype)lk_normalButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action;

/// 只有图片的按钮，没有 border。可以手动设置高度与宽度。
+ (instancetype)lk_buttonWithImage:(NSImage *)image target:(id)target action:(SEL)action;

@end

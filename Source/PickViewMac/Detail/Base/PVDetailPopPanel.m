//
//  PVDetailPopPanel.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailPopPanel.h"

@implementation PVDetailPopPanel

- (instancetype)initWithSize:(NSSize)size {
    // 如果不是 NSWindowStyleMaskNonactivatingPanel 的话，当显示该 window 时点击别的 app，整个 PickView 窗口都会被隐藏，不知道为什么
    if (self = [super initWithContentRect:NSMakeRect(0, 0, size.width, size.height) styleMask:NSWindowStyleMaskNonactivatingPanel backing:NSBackingStoreBuffered defer:YES]) {
        PVDetailBaseView *contentView = [PVDetailBaseView new];
        contentView.layer.cornerRadius = 6;
        contentView.layer.borderWidth = 1;
        contentView.didChangeAppearanceBlock = ^(PVDetailBaseView *view, BOOL isDarkMode) {
            view.backgroundColor = isDarkMode ? PVColorMake(44, 44, 44) : PVColorMake(236, 236, 236);
            view.layer.borderColor = isDarkMode ? SeparatorDarkModeColor.CGColor : SeparatorLightModeColor.CGColor;
        };
        self.contentView = contentView;
        self.backgroundColor = [NSColor clearColor];
    }
    return self;
}

// 如果没有这一句，window 里的输入框将无法触发编辑
- (BOOL)canBecomeKeyWindow {
    return YES;
}

@end

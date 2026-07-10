//
//  LKSplitView.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "LKSplitView.h"

@implementation LKSplitView {
    BOOL _hasLayouted;
}

- (CGFloat)dividerThickness {
    return 0;
}

//- (NSColor *)dividerColor {
//    BOOL isDarkMode = self.effectiveAppearance.lk_isDarkMode;
//    if (isDarkMode) {
//        return [NSColor blackColor];
//    } else {
//        return [NSColor colorWithWhite:0 alpha:.1];
//    }
//}

- (void)layout {
    [super layout];
    
    if (!_hasLayouted) {
        if (self.didFinishFirstLayout) {
            self.didFinishFirstLayout(self);
        }
        _hasLayouted = YES;
    }
}

@end

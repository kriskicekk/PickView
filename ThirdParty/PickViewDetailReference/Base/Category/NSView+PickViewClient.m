//
//  NSView+PickViewClient.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "NSView+PickViewClient.h"

@implementation NSView (PickViewClient)

- (BOOL)isVisible {
    return !self.hidden && self.alphaValue > 0;
}

- (NSString *)backgroundColorName {
    return [self pickview_getBindObjectForKey:@"lk_backgroundColorName"];
}

- (void)setBackgroundColorName:(NSString *)backgroundColorName {
    [self pickview_bindObject:backgroundColorName forKey:@"lk_backgroundColorName"];
    if (!backgroundColorName) {
        self.layer.backgroundColor = nil;
    } else {
        self.layer.backgroundColor = [NSColor colorNamed:backgroundColorName].CGColor;        
    }
}

- (void)showDebugBorder {
    self.layer.borderWidth = 1;
    self.layer.borderColor = [NSColor whiteColor].CGColor;
}

- (void)lk_insertSubviewAtBottom:(NSView *)view {
    if (self.subviews.count) {
        [self addSubview:view positioned:NSWindowBelow relativeTo:self.subviews.firstObject];
    } else {
        [self addSubview:view];
    }
}

@end

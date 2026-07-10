//
//  NSView+PVClient.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "NSView+PVClient.h"

@implementation NSView (PVClient)

- (BOOL)isVisible {
    return !self.hidden && self.alphaValue > 0;
}

- (NSString *)backgroundColorName {
    return [self pv_inspect_getBindObjectForKey:@"lk_backgroundColorName"];
}

- (void)setBackgroundColorName:(NSString *)backgroundColorName {
    [self pv_inspect_bindObject:backgroundColorName forKey:@"lk_backgroundColorName"];
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

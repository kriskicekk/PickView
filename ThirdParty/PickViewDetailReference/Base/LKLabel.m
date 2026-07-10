//
//  LKLabel.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "LKLabel.h"

@interface LKLabel ()

@end

@implementation LKLabel

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        self.wantsLayer = YES;
        self.backgroundColor = [NSColor clearColor];
        [self setBezeled:NO];
        [self setDrawsBackground:YES];
        [self setEditable:NO];
        [self setSelectable:NO];
        
        [self _updateColors];
    }
    return self;
}

- (void)setStringValue:(NSString *)stringValue {
    // 不做保护的话，传入 nil 会 crash
    stringValue = stringValue ? : @"";
    [super setStringValue:stringValue];
}

- (void)viewDidChangeEffectiveAppearance {
    [super viewDidChangeEffectiveAppearance];
    [self _updateColors];
}

- (void)setTextColors:(LKTwoColors *)textColors {
    _textColors = textColors;
    [self _updateColors];
}

- (void)setBackgroundColors:(LKTwoColors *)backgroundColors {
    _backgroundColors = backgroundColors;
    [self _updateColors];
}

- (void)_updateColors {
    if (self.textColors) {
        self.textColor = self.textColors.color;
    }
    if (self.backgroundColors) {
        self.backgroundColor = self.backgroundColors.color;
    }
}

@end

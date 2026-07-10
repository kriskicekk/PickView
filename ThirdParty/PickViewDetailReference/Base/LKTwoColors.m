//
//  LKTwoColors.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "LKTwoColors.h"

@implementation LKTwoColors

+ (instancetype)colorsWithColorInLightMode:(NSColor *)colorInLightMode colorInDarkMode:(NSColor *)colorInDarkMode {
    LKTwoColors *colors = [LKTwoColors new];
    colors.colorInLightMode = colorInLightMode;
    colors.colorInDarkMode = colorInDarkMode;
    return colors;
}

- (NSColor *)color {
    BOOL isDarkMode = [NSApp effectiveAppearance].lk_isDarkMode;
    if (isDarkMode) {
        return self.colorInDarkMode;
    } else {
        return self.colorInLightMode;
    }
}

@end

//
//  PVDetailTwoColors.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailTwoColors.h"

@implementation PVDetailTwoColors

+ (instancetype)colorsWithColorInLightMode:(NSColor *)colorInLightMode colorInDarkMode:(NSColor *)colorInDarkMode {
    PVDetailTwoColors *colors = [PVDetailTwoColors new];
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

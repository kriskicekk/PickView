//
//  NSAppearance+PVClient.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "NSAppearance+PVClient.h"

@implementation NSAppearance (macOS)

- (BOOL)lk_isDarkMode {
    if (__builtin_available(macOS 10.14, *)) {
        if ([self.name isEqualToString:NSAppearanceNameDarkAqua]
            || [self.name isEqualToString:NSAppearanceNameVibrantDark]
            || [self.name isEqualToString:NSAppearanceNameAccessibilityHighContrastDarkAqua]
            || [self.name isEqualToString:NSAppearanceNameAccessibilityHighContrastVibrantDark]) {
            return YES;
        }
        return NO;
    } else {
        return NO;
    }
}

@end

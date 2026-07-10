//
//  Color+PVInspect.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "Image+PVInspect.h"

#if TARGET_OS_IPHONE

@implementation UIColor (PickView)

- (NSArray<NSNumber *> *)pv_inspect_rgbaComponents {
    CGFloat r, g, b, a;
    CGColorRef cgColor = self.CGColor;
    const CGFloat *components = CGColorGetComponents(cgColor);
    if (CGColorGetNumberOfComponents(cgColor) == 4) {
        r = components[0];
        g = components[1];
        b = components[2];
        a = components[3];
    } else if (CGColorGetNumberOfComponents(cgColor) == 2) {
        r = components[0];
        g = components[0];
        b = components[0];
        a = components[1];
    } else if (CGColorGetNumberOfComponents(cgColor) == 1) {
        r = components[0];
        g = components[0];
        b = components[0];
        a = components[0];
    } else {
        r = 0;
        g = 0;
        b = 0;
        a = 0;
        NSAssert(NO, @"");
    }
    return @[@(r), @(g), @(b), @(a)];
}

+ (instancetype)pv_inspect_colorFromRGBAComponents:(NSArray<NSNumber *> *)components {
    if (!components) {
        return nil;
    }
    if (components.count != 4) {
        NSAssert(NO, @"");
        return nil;
    }
    return [UIColor colorWithRed:components[0].doubleValue
                           green:components[1].doubleValue
                            blue:components[2].doubleValue
                           alpha:components[3].doubleValue];
}

@end

#elif TARGET_OS_MAC

@implementation NSColor (PickView)

+ (instancetype)pv_inspect_colorFromRGBAComponents:(NSArray<NSNumber *> *)components {
    if (!components) {
        return nil;
    }
    if (components.count != 4) {
        NSAssert(NO, @"");
        return nil;
    }
    NSColor *color = [NSColor colorWithRed:components[0].doubleValue green:components[1].doubleValue blue:components[2].doubleValue alpha:components[3].doubleValue];
    return color;
}

- (NSArray<NSNumber *> *)pv_inspect_rgbaComponents {
    NSColor *rgbColor = [self colorUsingColorSpace:NSColorSpace.sRGBColorSpace];
    CGFloat r, g, b, a;
    [rgbColor getRed:&r green:&g blue:&b alpha:&a];
    NSArray<NSNumber *> *rgba = @[@(r), @(g), @(b), @(a)];
    return rgba;
}

@end

#endif

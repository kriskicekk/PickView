//
//  NSString+PVInspect.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "NSString+PVInspect.h"

@implementation NSString (PickView)

+ (NSString *)pv_inspect_stringFromDouble:(double)doubleValue decimal:(NSUInteger)decimal {
    NSString *formatString = [NSString stringWithFormat:@"%%.%@f", @(decimal)];
    NSString *string = [NSString stringWithFormat:formatString, doubleValue];
    for (int i = 0; i < decimal; i++) {
        if ([[string substringFromIndex:string.length - 1] isEqualToString:@"0"]) {
            string = [string substringToIndex:string.length - 1];
        }
    }
    if ([[string substringFromIndex:string.length - 1] isEqualToString:@"."]) {
        string = [string substringToIndex:string.length - 1];
    }
    return string;
}

+ (NSString *)pv_inspect_stringFromInset:(PVInsets)insets {
    return [NSString stringWithFormat:@"{%@, %@, %@, %@}",
            [NSString pv_inspect_stringFromDouble:insets.top decimal:2],
            [NSString pv_inspect_stringFromDouble:insets.left decimal:2],
            [NSString pv_inspect_stringFromDouble:insets.bottom decimal:2],
            [NSString pv_inspect_stringFromDouble:insets.right decimal:2]];
}

+ (NSString *)pv_inspect_stringFromSize:(CGSize)size {
    return [NSString stringWithFormat:@"{%@, %@}",
            [NSString pv_inspect_stringFromDouble:size.width decimal:2],
            [NSString pv_inspect_stringFromDouble:size.height decimal:2]];
}


+ (NSString *)pv_inspect_stringFromPoint:(CGPoint)point {
    return [NSString stringWithFormat:@"{%@, %@}",
            [NSString pv_inspect_stringFromDouble:point.x decimal:2],
            [NSString pv_inspect_stringFromDouble:point.y decimal:2]];
}

+ (NSString *)pv_inspect_stringFromRect:(CGRect)rect {
    return [NSString stringWithFormat:@"{%@, %@, %@, %@}",
            [NSString pv_inspect_stringFromDouble:rect.origin.x decimal:2],
            [NSString pv_inspect_stringFromDouble:rect.origin.y decimal:2],
            [NSString pv_inspect_stringFromDouble:rect.size.width decimal:2],
            [NSString pv_inspect_stringFromDouble:rect.size.height decimal:2]];
}

+ (NSString *)pv_inspect_rgbaStringFromColor:(PVColor *)color {
    if (!color) {
        return @"nil";
    }
    
#if TARGET_OS_IPHONE
    UIColor *rgbColor = color;
#elif TARGET_OS_MAC
    NSColor *rgbColor = [color colorUsingColorSpace:NSColorSpace.sRGBColorSpace];
#endif
    
    CGFloat r, g, b, a;
    [rgbColor getRed:&r green:&g blue:&b alpha:&a];
    
    NSString *colorDesc;
    if (a >= 1) {
        colorDesc = [NSString stringWithFormat:@"(%.0f, %.0f, %.0f)", r * 255, g * 255, b * 255];
    } else {
        colorDesc = [NSString stringWithFormat:@"(%.0f, %.0f, %.0f, %@)", r * 255, g * 255, b * 255, [NSString pv_inspect_stringFromDouble:a decimal:2]];
        
    }
    
    return colorDesc;
}

- (NSString *)pv_inspect_safeInitWithUTF8String:(const char *)string {
    if (NULL != string) {
        return [self initWithUTF8String:string];
    }
    return nil;
}

- (NSInteger)pv_inspect_numbericOSVersion {
    if (self.length == 0) {
        NSAssert(NO, @"");
        return 0;
    }
    NSArray *versionArr = [self componentsSeparatedByString:@"."];
    if (versionArr.count != 3) {
        NSAssert(NO, @"");
        return 0;
    }
    
    NSInteger numbericOSVersion = 0;
    NSInteger pos = 0;
    
    while ([versionArr count] > pos && pos < 3) {
        numbericOSVersion += ([[versionArr objectAtIndex:pos] integerValue] * pow(10, (4 - pos * 2)));
        pos++;
    }
    
    return numbericOSVersion;
}


@end


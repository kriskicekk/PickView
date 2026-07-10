//
//  NSString+PVInspect.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVInspectionDefines.h"



#import <Foundation/Foundation.h>

@interface NSString (PickView)

/**
 把 CGFloat 转成字符串，最多保留 3 位小数，转换后末尾的 0 会被删除
 如：1.2341 => @"1.234", 2.1002 => @"2.1", 3.000 => @"3"
 */
+ (NSString *)pv_inspect_stringFromDouble:(double)doubleValue decimal:(NSUInteger)decimal;

+ (NSString *)pv_inspect_stringFromRect:(CGRect)rect;

+ (NSString *)pv_inspect_stringFromInset:(PVInsets)insets;

+ (NSString *)pv_inspect_stringFromSize:(CGSize)size;

+ (NSString *)pv_inspect_stringFromPoint:(CGPoint)point;

+ (NSString *)pv_inspect_rgbaStringFromColor:(PVColor *)color;

- (NSString *)pv_inspect_safeInitWithUTF8String:(const char *)string;

/// 把 1.2.3 这种 String 版本号转换成数字，可用于大小比较，如 110205 代表 11.2.5 版本
- (NSInteger)pv_inspect_numbericOSVersion;

@end


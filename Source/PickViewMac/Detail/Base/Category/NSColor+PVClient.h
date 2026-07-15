//
//  NSColor+PVClient.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import <Cocoa/Cocoa.h>

@interface NSColor (PVClient)

/**
 如果 alpha 为 1 则返回诸如 (15, 17, 19) 这样的格式
 如果 alpha 小于 1 则返回诸如 (15, 17, 19, 0.5) 这样的格式
 */
- (NSString *)rgbaString;

- (NSString *)hexString;

- (NSArray<NSNumber *> *)lk_rgbaComponents;

+ (instancetype)lk_colorFromRGBAComponents:(NSArray<NSNumber *> *)components;

@end

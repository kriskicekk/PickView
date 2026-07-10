//
//  Color+PVInspect.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import <Foundation/Foundation.h>
#import <TargetConditionals.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>

@interface UIColor (PickView)

+ (instancetype)pv_inspect_colorFromRGBAComponents:(NSArray<NSNumber *> *)components;

- (NSArray<NSNumber *> *)pv_inspect_rgbaComponents;

@end

#elif TARGET_OS_OSX
#import <AppKit/AppKit.h>

@interface NSColor (PickView)

+ (instancetype)pv_inspect_colorFromRGBAComponents:(NSArray<NSNumber *> *)components;

- (NSArray<NSNumber *> *)pv_inspect_rgbaComponents;

@end

#endif

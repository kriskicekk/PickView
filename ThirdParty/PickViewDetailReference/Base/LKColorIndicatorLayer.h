//
//  LKColorIndicatorLayer.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import <AppKit/AppKit.h>

/// 当 backgroundColor
@interface LKColorIndicatorLayer : CALayer

/// 默认为 (0, 0, 0)
@property(nonatomic, strong) NSColor *color;

+ (NSImage *)imageWithColor:(NSColor *)color shapeSize:(NSSize)shapeSize insets:(NSEdgeInsets)insets;

@end

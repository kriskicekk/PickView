//
//  NSControl+PickViewClient.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "NSControl+PickViewClient.h"
#import <AppKit/AppKit.h>

@implementation NSControl (PickViewClient)

- (CGFloat)heightForWidth:(CGFloat)width {
    return [self sizeThatFits:NSMakeSize(width, CGFLOAT_MAX)].height;
}

- (CGFloat)bestHeight {
    return [self sizeThatFits:NSSizeMax].height;
}

- (CGFloat)bestWidth {
    return [self sizeThatFits:NSSizeMax].width;
}

- (NSSize)bestSize {
    return [self sizeThatFits:NSSizeMax];
}

@end

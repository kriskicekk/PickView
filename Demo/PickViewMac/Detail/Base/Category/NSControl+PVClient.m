//
//  NSControl+PVClient.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "NSControl+PVClient.h"
#import <AppKit/AppKit.h>

@implementation NSControl (PVClient)

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

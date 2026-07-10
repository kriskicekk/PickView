//
//  NSArray+PVClient.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "NSArray+PVClient.h"
#import <AppKit/AppKit.h>

@implementation NSArray (PVClient)

- (NSArray *)lk_visibleViews {
    NSArray *newArray = [self pv_inspect_filter:^BOOL(id obj) {
        if ([obj isKindOfClass:[NSView class]]) {
            return ![((NSView *)obj) isHidden];
        } else {
            NSAssert(NO, @"");
            return NO;
        }
    }];
    return newArray;
}

@end

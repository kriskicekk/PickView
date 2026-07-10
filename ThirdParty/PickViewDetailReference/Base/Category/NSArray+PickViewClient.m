//
//  NSArray+PickViewClient.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "NSArray+PickViewClient.h"
#import <AppKit/AppKit.h>

@implementation NSArray (PickViewClient)

- (NSArray *)lk_visibleViews {
    NSArray *newArray = [self pickview_filter:^BOOL(id obj) {
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

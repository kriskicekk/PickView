//
//  PickViewCustomDisplayItemInfo+PickViewClient.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "PickViewCustomDisplayItemInfo+PickViewClient.h"

@implementation PickViewCustomDisplayItemInfo (PickViewClient)

- (BOOL)hasValidFrame {
    if (!self.frameInWindow) {
        return NO;
    }
    CGRect rect = [self.frameInWindow rectValue];
    BOOL valid = [LKHelper validateFrame:rect];
    return valid;
}

@end

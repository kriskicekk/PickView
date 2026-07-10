//
//  NSString+PickViewClient.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "NSString+PickViewClient.h"
#import <AppKit/AppKit.h>


@implementation NSString (PickViewClient)

- (NSString *)lk_capitalizedString {
    if (self.length) {
        return [NSString stringWithFormat:@"%@%@", [self substringToIndex:1].uppercaseString, [self substringFromIndex:1]];        
    }
    return nil;
}

@end

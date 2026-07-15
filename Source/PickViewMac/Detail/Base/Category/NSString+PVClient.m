//
//  NSString+PVClient.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "NSString+PVClient.h"
#import <AppKit/AppKit.h>


@implementation NSString (PVClient)

- (NSString *)lk_capitalizedString {
    if (self.length) {
        return [NSString stringWithFormat:@"%@%@", [self substringToIndex:1].uppercaseString, [self substringFromIndex:1]];        
    }
    return nil;
}

@end

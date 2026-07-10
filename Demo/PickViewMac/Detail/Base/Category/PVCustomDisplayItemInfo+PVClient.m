//
//  PVCustomDisplayItemInfo+PVClient.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVCustomDisplayItemInfo+PVClient.h"

@implementation PVCustomDisplayItemInfo (PVClient)

- (BOOL)hasValidFrame {
    if (!self.frameInWindow) {
        return NO;
    }
    CGRect rect = [self.frameInWindow rectValue];
    BOOL valid = [PVDetailHelper validateFrame:rect];
    return valid;
}

@end

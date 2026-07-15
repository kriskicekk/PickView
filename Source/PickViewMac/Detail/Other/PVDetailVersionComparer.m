//
//  PVDetailVersionComparer.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailVersionComparer.h"
#import "NSString+PVInspect.h"

@implementation PVDetailVersionComparer

+ (BOOL)compareWithNewest:(NSString *)latest user:(NSString *)user {
    return [self compareWithExpectedVersion:latest realVersion:user];
}

+ (BOOL)compareWithExpectedVersion:(NSString *)expectedVersion realVersion:(NSString *)realVersion {
    NSInteger expectedNumber = [expectedVersion pv_inspect_numbericOSVersion];
    NSInteger realNumber = [realVersion pv_inspect_numbericOSVersion];
    if (expectedNumber == 0 || realNumber == 0) {
        NSAssert(NO, @"");
        return NO;
    }
    if (realNumber >= expectedNumber) {
        return YES;
    }
    return NO;
}

@end

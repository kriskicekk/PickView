//
//  PVUtils.m
//  PickView
//
//  Created by kris cheng on 2026/7/7.
//

#import "PVUtils.h"

#import <TargetConditionals.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

@implementation PVUtils

+ (NSString *)bundleID {
    return NSBundle.mainBundle.bundleIdentifier ?: @"";
}

+ (NSString *)appName {
    NSBundle *bundle = NSBundle.mainBundle;
    NSString *displayName = [bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    if (displayName.length) {
        return displayName;
    }

    NSString *bundleName = [bundle objectForInfoDictionaryKey:@"CFBundleName"];
    if (bundleName.length) {
        return bundleName;
    }

    NSString *executableName = [bundle objectForInfoDictionaryKey:@"CFBundleExecutable"];
    if (executableName.length) {
        return executableName;
    }

    return @"Unknown";
}

+ (NSString *)deviceName {
#if TARGET_OS_IPHONE
    return UIDevice.currentDevice.name ?: @"";
#elif TARGET_OS_OSX
    NSString *localizedName = NSHost.currentHost.localizedName;
    if (localizedName.length) {
        return localizedName;
    }

    NSString *hostName = NSHost.currentHost.name;
    if (hostName.length) {
        return hostName;
    }

    return NSProcessInfo.processInfo.hostName ?: @"";
#else
    return @"";
#endif
}

+ (NSString *)systemVersion {
#if TARGET_OS_IPHONE
    return UIDevice.currentDevice.systemVersion ?: @"";
#else
    return NSProcessInfo.processInfo.operatingSystemVersionString ?: @"";
#endif
}

+ (NSComparisonResult)compareVersion:(NSString *)version toVersion:(NSString *)otherVersion {
    NSArray<NSString *> *components = [version componentsSeparatedByString:@"."];
    NSArray<NSString *> *otherComponents = [otherVersion componentsSeparatedByString:@"."];
    NSUInteger count = MAX(components.count, otherComponents.count);

    for (NSUInteger index = 0; index < count; index++) {
        NSInteger value = index < components.count ? components[index].integerValue : 0;
        NSInteger otherValue = index < otherComponents.count ? otherComponents[index].integerValue : 0;
        if (value < otherValue) {
            return NSOrderedAscending;
        }
        if (value > otherValue) {
            return NSOrderedDescending;
        }
    }

    return NSOrderedSame;
}

@end

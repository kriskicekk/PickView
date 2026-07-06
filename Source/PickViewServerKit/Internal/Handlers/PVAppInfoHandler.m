//
//  PVAppInfoHandler.m
//  PickViewServer
//
//  Created by kris cheng on 2026/7/6.
//

#import "PVAppInfoHandler.h"
#import "PVRequestType.h"
#import "PVKitVersion.h"
#import <TargetConditionals.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

@implementation PVAppInfoHandler

- (BOOL)canHandleRequestType:(uint32_t)type {
    return type == PVRequestTypePing || type == PVRequestTypeAppInfo;
}

- (void)handleRequestType:(uint32_t)type payload:(NSData *)payload completion:(void (^)(NSData * _Nullable, NSError * _Nullable))completion {
    NSDictionary *response = nil;
    if (type == PVRequestTypePing) {
        response = @{
            @"protocolVersion": @(PVProtocolVersion),
            @"supportedMin": @(PVSupportedPeerVersionMin),
            @"supportedMax": @(PVSupportedPeerVersionMax)
        };
    } else {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *displayName = [bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"] ?: [bundle objectForInfoDictionaryKey:@"CFBundleName"] ?: @"Unknown";
        NSString *bundleID = bundle.bundleIdentifier ?: @"";
        NSMutableDictionary *info = [@{
            @"appName": displayName,
            @"bundleIdentifier": bundleID,
            @"protocolVersion": @(PVProtocolVersion)
        } mutableCopy];
#if TARGET_OS_IPHONE
        info[@"deviceName"] = UIDevice.currentDevice.name ?: @"";
        info[@"systemVersion"] = UIDevice.currentDevice.systemVersion ?: @"";
#endif
        response = info;
    }

    NSData *data = [NSPropertyListSerialization dataWithPropertyList:response format:NSPropertyListBinaryFormat_v1_0 options:0 error:nil];
    if (completion) completion(data, nil);
}

@end

//
//  PickViewServerConfiguration.m
//  PickViewServer
//
//  Created by kris cheng on 2026/7/6.
//

#import "PickViewServerConfiguration.h"
#import "PVPortConstant.h"
#import <TargetConditionals.h>

@implementation PickViewServerConfiguration

+ (instancetype)defaultConfiguration {
    PickViewServerConfiguration *configuration = [[PickViewServerConfiguration alloc] init];
    configuration.portStart = PVDefaultPortStart;
    configuration.portEnd = PVDefaultPortEnd;
    configuration.enableLocalLoopback = YES;
#if TARGET_OS_SIMULATOR
    configuration.enableLANTransport = NO;
#else
    configuration.enableLANTransport = YES;
#endif
    configuration.lanServiceName = [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleDisplayName"] ?: [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleName"] ?: @"PickView";
    configuration.enableMessageHandler = YES;
    configuration.enableAppInfoHandler = YES;
    configuration.enableHierarchyHandler = YES;
    return configuration;
}

@end


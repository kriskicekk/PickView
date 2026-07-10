//
//  PickViewClientConfiguration.m
//  PickViewClient
//
//  Created by kris cheng on 2026/7/6.
//

#import "PickViewClientConfiguration.h"

@implementation PickViewClientConfiguration

+ (instancetype)defaultConfiguration {
    PickViewClientConfiguration *configuration = [[PickViewClientConfiguration alloc] init];
    configuration.enableUSBDiscovery = YES;
    configuration.enableLoopbackDiscovery = YES;
    configuration.enableLANDiscovery = YES;
    configuration.preferUSBTransport = YES;
    configuration.scanInterval = 2.0;
    return configuration;
}

@end

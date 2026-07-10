//
//  PVLoopbackEndpoint.m
//  PickView
//
//  Created by kris cheng on 2026/7/6.
//

#import "PVLoopbackEndpoint.h"

@implementation PVLoopbackEndpoint

- (instancetype)initWithHost:(NSString *)host port:(int)port {
    self = [super init];
    if (self) {
        _host = [host copy];
        _port = port;
    }
    return self;
}

- (NSString *)identifier {
    return [NSString stringWithFormat:@"loopback:%@:%d", self.host, self.port];
}

- (NSString *)displayName {
    return [NSString stringWithFormat:@"Local App %@:%d", self.host, self.port];
}

- (PVEndpointTransportType)transportType {
    return PVEndpointTransportTypeLocalLoopback;
}

- (PVEndpointPriority)priority {
    return PVEndpointPriorityMid;
}

@end

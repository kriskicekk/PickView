//
//  PVSimulatorEndpoint.m
//  PickView
//
//  Created by kris cheng on 2026/7/6.
//

#import "PVSimulatorEndpoint.h"

@implementation PVSimulatorEndpoint

- (instancetype)initWithHost:(NSString *)host port:(int)port {
    self = [super init];
    if (self) {
        _host = [host copy];
        _port = port;
    }
    return self;
}

- (NSString *)identifier {
    return [NSString stringWithFormat:@"simulator:%@:%d", self.host, self.port];
}

- (NSString *)displayName {
    return [NSString stringWithFormat:@"Simulator %@:%d", self.host, self.port];
}

- (PVEndpointTransportType)transportType {
    return PVEndpointTransportTypeLocalLoopback;
}

- (PVEndpointPriority)priority {
    return PVEndpointPriorityMid;
}

@end

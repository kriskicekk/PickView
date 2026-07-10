//
//  PVSimulatorEndpointDiscoverer.m
//  PickView
//
//  Created by kris cheng on 2026/7/6.
//

#import "PVSimulatorEndpointDiscoverer.h"
#import "PVSimulatorEndpoint.h"
#import "PVEndpointDiscovererDelegate.h"
#import "PVPortConstant.h"

@interface PVSimulatorEndpointDiscoverer ()
@property (nonatomic, assign) int startPort;
@property (nonatomic, assign) int endPort;
@property (nonatomic, strong) NSArray<PVSimulatorEndpoint *> *endpoints;
@end

@implementation PVSimulatorEndpointDiscoverer

- (instancetype)init {
    return [self initWithPortRangeStart:PVDefaultPortStart end:PVDefaultPortEnd];
}

- (instancetype)initWithPortRangeStart:(int)startPort end:(int)endPort {
    self = [super init];
    if (self) {
        _startPort = startPort;
        _endPort = endPort;
    }
    return self;
}

- (void)start {
    NSMutableArray<PVSimulatorEndpoint *> *endpoints = [NSMutableArray array];
    for (int port = self.startPort; port <= self.endPort; port++) {
        PVSimulatorEndpoint *endpoint = [[PVSimulatorEndpoint alloc] initWithHost:@"127.0.0.1" port:port];
        [endpoints addObject:endpoint];
        [self.delegate discoverer:self didFindEndpoint:endpoint];
    }
    self.endpoints = endpoints;
}

- (void)stop {
    for (PVSimulatorEndpoint *endpoint in self.endpoints) {
        [self.delegate discoverer:self didRemoveEndpoint:endpoint];
    }
    self.endpoints = @[];
}

@end

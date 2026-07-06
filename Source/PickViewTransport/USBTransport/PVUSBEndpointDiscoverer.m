//
//  PVUSBEndpointDiscoverer.m
//  PickView
//
//  Created by kris cheng on 2026/7/6.
//

#import "PVUSBEndpointDiscoverer.h"

#import "PVEndpointDiscovererDelegate.h"
#import "PVPortConstant.h"
#import "PVUSBEndpoint.h"

#import <PeerTalk/PTUSBHub.h>

@interface PVUSBEndpointDiscoverer ()

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSArray<PVUSBEndpoint *> *> *endpointsByDeviceID;

@end

@implementation PVUSBEndpointDiscoverer

- (instancetype)init {
    self = [super init];
    if (self) {
        _endpointsByDeviceID = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)start {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(handleDeviceDidAttach:) name:PTUSBDeviceDidAttachNotification object:PTUSBHub.sharedHub];
    [center addObserver:self selector:@selector(handleDeviceDidDetach:) name:PTUSBDeviceDidDetachNotification object:PTUSBHub.sharedHub];
    [PTUSBHub sharedHub];
}

- (void)stop {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.endpointsByDeviceID removeAllObjects];
}

- (void)handleDeviceDidAttach:(NSNotification *)notification {
    NSNumber *deviceID = notification.userInfo[PTUSBHubNotificationKeyDeviceID];
    NSDictionary *properties = notification.userInfo[PTUSBHubNotificationKeyProperties];
    NSString *serialNumber = properties[@"SerialNumber"];
    if (!deviceID) {
        return;
    }

    NSMutableArray<PVUSBEndpoint *> *endpoints = [NSMutableArray array];
    for (int port = PVDefaultPortStart; port <= PVDefaultPortEnd; port++) {
        PVUSBEndpoint *endpoint = [[PVUSBEndpoint alloc] initWithDeviceID:deviceID port:port serialNumber:serialNumber];
        [endpoints addObject:endpoint];
        [self.delegate discoverer:self didFindEndpoint:endpoint];
    }
    self.endpointsByDeviceID[deviceID] = endpoints;
}

- (void)handleDeviceDidDetach:(NSNotification *)notification {
    NSNumber *deviceID = notification.userInfo[PTUSBHubNotificationKeyDeviceID];
    if (!deviceID) {
        return;
    }

    NSArray<PVUSBEndpoint *> *endpoints = self.endpointsByDeviceID[deviceID];
    [self.endpointsByDeviceID removeObjectForKey:deviceID];
    for (PVUSBEndpoint *endpoint in endpoints) {
        [self.delegate discoverer:self didRemoveEndpoint:endpoint];
    }
}

@end


//
//  PVUSBEndpoint.m
//  PickView
//
//  Created by kris cheng on 2026/7/6.
//

#import "PVUSBEndpoint.h"

@implementation PVUSBEndpoint

- (instancetype)initWithDeviceID:(NSNumber *)deviceID
                            port:(int)port
                    serialNumber:(NSString *)serialNumber {
    self = [super init];
    if (self) {
        _deviceID = deviceID;
        _port = port;
        _serialNumber = [serialNumber copy];
    }
    return self;
}

- (NSString *)identifier {
    return [NSString stringWithFormat:@"usb:%@:%d", self.deviceID, self.port];
}

- (NSString *)displayName {
    if (self.serialNumber.length) {
        return [NSString stringWithFormat:@"USB %@:%d", self.serialNumber, self.port];
    } else {
        return [NSString stringWithFormat:@"USB device %@:%d", self.deviceID, self.port];
    }
}

- (PVEndpointTransportType)transportType {
    return PVEndpointTransportTypeUSB;
}

- (PVEndpointPriority)priority {
    return PVEndpointPriorityHigh;
}

@end

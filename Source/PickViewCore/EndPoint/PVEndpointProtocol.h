//
//  PVEndpointProtocol.h
//  PickView
//
//  Created by kris cheng on 2026/7/6.
//

#ifndef PVEndpointProtocol_h
#define PVEndpointProtocol_h

#import <Foundation/Foundation.h>
#import "PVEndpointPriority.h"

typedef NS_ENUM(NSUInteger, PVEndpointTransportType) {
    PVEndpointTransportTypeUSB = 1,
    PVEndpointTransportTypeLocalLoopback = 2,
    PVEndpointTransportTypeLAN = 3
};

@protocol PVEndpointProtocol <NSObject>

@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, copy, readonly) NSString *displayName;
@property (nonatomic, assign, readonly) PVEndpointTransportType transportType;
@property (nonatomic, assign, readonly) PVEndpointPriority priority;

@end

#endif /* PVEndpointProtocol_h */

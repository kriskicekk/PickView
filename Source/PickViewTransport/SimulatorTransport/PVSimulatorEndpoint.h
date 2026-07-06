//
//  PVSimulatorEndpoint.h
//  PickView
//
//  Created by kris cheng on 2026/7/6.
//

#ifndef PVSimulatorEndpoint_h
#define PVSimulatorEndpoint_h

#import "PVEndpointProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface PVSimulatorEndpoint : NSObject <PVEndpointProtocol>

@property (nonatomic, assign, readonly) int port;
@property (nonatomic, copy, readonly) NSString *host;

- (instancetype)initWithHost:(NSString *)host port:(int)port NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

#endif /* PVSimulatorEndpoint_h */

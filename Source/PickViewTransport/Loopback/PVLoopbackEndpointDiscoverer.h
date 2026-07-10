//
//  PVLoopbackEndpointDiscoverer.h
//  PickView
//
//  Created by kris cheng on 2026/7/6.
//

#ifndef PVLoopbackEndpointDiscoverer_h
#define PVLoopbackEndpointDiscoverer_h

#import "PVEndpointDiscovererProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface PVLoopbackEndpointDiscoverer : NSObject <PVEndpointDiscovererProtocol>

@property (nonatomic, weak, nullable) id<PVEndpointDiscovererDelegate> delegate;

- (instancetype)initWithPortRangeStart:(int)startPort end:(int)endPort;
- (instancetype)init;

@end

NS_ASSUME_NONNULL_END

#endif /* PVLoopbackEndpointDiscoverer_h */

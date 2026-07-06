//
//  PVEndpointDiscovererProtocol.h
//  PickView
//
//  Created by kris cheng on 2026/7/6.
//

#ifndef PVEndpointDiscovererProtocol_h
#define PVEndpointDiscovererProtocol_h

#import <Foundation/Foundation.h>

@protocol PVEndpointDiscovererDelegate;

NS_ASSUME_NONNULL_BEGIN

@protocol PVEndpointDiscovererProtocol <NSObject>

@property (nonatomic, weak, nullable) id<PVEndpointDiscovererDelegate> delegate;

- (void)start;
- (void)stop;

@end

NS_ASSUME_NONNULL_END

#endif /* PVEndpointDiscovererProtocol_h */

//
//  PVEndpointDiscovererDelegate.h
//  PickView
//
//  Created by kris cheng on 2026/7/6.
//

#ifndef PVEndpointDiscovererDelegate_h
#define PVEndpointDiscovererDelegate_h

#import <Foundation/Foundation.h>

@protocol PVEndpointProtocol;
@protocol PVEndpointDiscovererProtocol;

NS_ASSUME_NONNULL_BEGIN

@protocol PVEndpointDiscovererDelegate <NSObject>

- (void)discoverer:(id<PVEndpointDiscovererProtocol>)discoverer
  didFindEndpoint:(id<PVEndpointProtocol>)endpoint;

- (void)discoverer:(id<PVEndpointDiscovererProtocol>)discoverer
didRemoveEndpoint:(id<PVEndpointProtocol>)endpoint;

@end

NS_ASSUME_NONNULL_END

#endif /* PVEndpointDiscovererDelegate_h */

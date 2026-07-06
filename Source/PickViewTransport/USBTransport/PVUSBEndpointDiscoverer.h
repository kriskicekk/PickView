//
//  PVUSBEndpointDiscoverer.h
//  PickView
//
//  Created by kris cheng on 2026/7/6.
//

#ifndef PVUSBEndpointDiscoverer_h
#define PVUSBEndpointDiscoverer_h

#import "PVEndpointDiscovererProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface PVUSBEndpointDiscoverer : NSObject <PVEndpointDiscovererProtocol>

@property (nonatomic, weak, nullable) id<PVEndpointDiscovererDelegate> delegate;

@end

NS_ASSUME_NONNULL_END

#endif /* PVUSBEndpointDiscoverer_h */

//
//  PVLocalTCPConnection.h
//  PickViewServer
//
//  Created by kris cheng on 2026/7/6.
//

#ifndef PVLocalTCPConnection_h
#define PVLocalTCPConnection_h

#import "PVPeerTalkConnection.h"

@class PTChannel;

NS_ASSUME_NONNULL_BEGIN

@interface PVLocalTCPConnection : PVPeerTalkConnection

- (instancetype)initWithAcceptedChannel:(PTChannel *)channel;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

#endif /* PVLocalTCPConnection_h */

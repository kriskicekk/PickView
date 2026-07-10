//
//  PVLoopbackConnection.h
//  PickView
//
//  Created by kris cheng on 2026/7/6.
//

#ifndef PVLoopbackConnection_h
#define PVLoopbackConnection_h

#import "PVPeerTalkConnection.h"

@class PTChannel;
@class PVLoopbackEndpoint;

NS_ASSUME_NONNULL_BEGIN

@interface PVLoopbackConnection : PVPeerTalkConnection

- (instancetype)initWithEndpoint:(PVLoopbackEndpoint *)endpoint NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithAcceptedChannel:(PTChannel *)channel NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

#endif /* PVLoopbackConnection_h */

//
//  PVPeerTalkConnection.h
//  PickViewTransport
//
//  Created by kris cheng on 2026/7/10.
//

#import "PVConnection.h"

@class PTChannel;

NS_ASSUME_NONNULL_BEGIN

@interface PVPeerTalkConnection : PVConnection

@property(nonatomic, strong, nullable) PTChannel *channel;

- (void)cleanupChannel;

@end

NS_ASSUME_NONNULL_END

//
//  PVConnectionInternal.h
//  PickView
//
//  Created by kris cheng on 2026/7/6.
//

#ifndef PVConnectionInternal_h
#define PVConnectionInternal_h

#import "PVConnection.h"

#import <PeerTalk/PTChannel.h>

NS_ASSUME_NONNULL_BEGIN

@interface PVConnection () <PTChannelDelegate>

@property (nonatomic, assign, readwrite) PVConnectionState state;
@property (nonatomic, strong, nullable) PTChannel *channel;

- (void)cleanupChannel;

@end

NS_ASSUME_NONNULL_END

#endif /* PVConnectionInternal_h */

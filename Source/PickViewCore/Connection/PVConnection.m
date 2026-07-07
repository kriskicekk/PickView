//
//  PVConnection.m
//  PickView
//
//  Created by kris cheng on 2026/7/6.
//

#import "PVConnection.h"
#import "PVConnectionDelegate.h"
#import "PVConnectionState.h"
#import "PVFrame.h"

#import <PeerTalk/PTChannel.h>

@interface PVConnection () <PTChannelDelegate>

@end

@implementation PVConnection

- (instancetype)init {
    self = [super init];
    if (self) {
        _state = PVConnectionStateIdle;
    }
    return self;
}

- (void)close {
    if (self.state == PVConnectionStateClosed || self.state == PVConnectionStateClosing) {
        return;
    }

    _state = PVConnectionStateClosing;
    [self cleanupChannel];
    _state = PVConnectionStateClosed;
}

- (void)cleanupChannel {
    PTChannel *channel = self.channel;
    if (!channel) {
        return;
    }

    self.channel = nil;
    channel.delegate = nil;
    [channel close];
}

- (void)dealloc {
    [self cleanupChannel];
}

- (void)connectWithCompletion:(nonnull void (^)(NSError * _Nullable))completion {}
- (void)sendFrame:(nonnull PVFrame *)frame completion:(nullable void (^)(NSError * _Nullable))completion {}

#pragma mark - PTChannelDelegate

- (BOOL)ioFrameChannel:(PTChannel *)channel shouldAcceptFrameOfType:(uint32_t)type tag:(uint32_t)tag payloadSize:(uint32_t)payloadSize {
    return channel == self.channel;
}

- (void)ioFrameChannel:(PTChannel *)channel didReceiveFrameOfType:(uint32_t)type tag:(uint32_t)tag payload:(NSData *)payload {
    PVFrame *frame = [[PVFrame alloc] initWithType:type tag:tag payload:payload];
    if ([self.delegate respondsToSelector:@selector(connection:didReceiveFrame:)]) {
        [self.delegate connection:self didReceiveFrame:frame];
    }
}

- (void)ioFrameChannel:(PTChannel *)channel didEndWithError:(NSError *)error {
    if (channel != self.channel) {
        return;
    }

    self.channel = nil;
    channel.delegate = nil;
    _state = error ? PVConnectionStateFailed : PVConnectionStateClosed;
    if ([self.delegate respondsToSelector:@selector(connection:didCloseWithError:)]) {
        [self.delegate connection:self didCloseWithError:error];
    }
}

@end

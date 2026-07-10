//
//  PVPeerTalkConnection.m
//  PickViewTransport
//
//  Created by kris cheng on 2026/7/10.
//

#import "PVPeerTalkConnection.h"

#import "PVConnectionDelegate.h"
#import "PVFrame.h"

#import <PeerTalk/PTChannel.h>

@interface PVPeerTalkConnection () <PTChannelDelegate>
@end

@implementation PVPeerTalkConnection

- (void)close {
    if (self.state == PVConnectionStateClosed || self.state == PVConnectionStateClosing) {
        return;
    }
    [self updateState:PVConnectionStateClosing];
    [self cleanupChannel];
    [self updateState:PVConnectionStateClosed];
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

- (BOOL)ioFrameChannel:(PTChannel *)channel
shouldAcceptFrameOfType:(uint32_t)type
                   tag:(uint32_t)tag
           payloadSize:(uint32_t)payloadSize {
    return channel == self.channel;
}

- (void)ioFrameChannel:(PTChannel *)channel
 didReceiveFrameOfType:(uint32_t)type
                   tag:(uint32_t)tag
               payload:(NSData *)payload {
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
    [self updateState:error ? PVConnectionStateFailed : PVConnectionStateClosed];
    if ([self.delegate respondsToSelector:@selector(connection:didCloseWithError:)]) {
        [self.delegate connection:self didCloseWithError:error];
    }
}

@end

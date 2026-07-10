//
//  PVLoopbackConnection.m
//  PickView
//
//  Created by kris cheng on 2026/7/6.
//

#import "PVLoopbackConnection.h"

#import "PVConnectionDelegate.h"
#import "PVErrorCode.h"
#import "PVFrame.h"
#import "PVLoopbackEndpoint.h"

#import <PeerTalk/PTChannel.h>

@implementation PVLoopbackConnection

- (instancetype)initWithEndpoint:(PVLoopbackEndpoint *)endpoint {
    self = [super init];
    if (self) {
        self.endpoint = endpoint;
    }
    return self;
}

- (instancetype)initWithAcceptedChannel:(PTChannel *)channel {
    self = [super init];
    if (self) {
        self.channel = channel;
        self.channel.delegate = (id<PTChannelDelegate>)self;
        [self updateState:PVConnectionStateConnected];
    }
    return self;
}

- (NSString *)connectionIdentifier {
    if (self.endpoint) {
        return self.endpoint.identifier;
    }
    return [NSString stringWithFormat:@"loopback:accepted:%p", self.channel];
}

- (void)connectWithCompletion:(void (^)(NSError * _Nullable))completion {
    if (self.state == PVConnectionStateConnected || self.state == PVConnectionStateConnecting) {
        if (completion) completion(nil);
        return;
    }

    PVLoopbackEndpoint *endpoint = (PVLoopbackEndpoint *)self.endpoint;
    if (!endpoint) {
        if (completion) {
            NSError *error = [NSError errorWithDomain:PVErrorDomain
                                                 code:PVErrorCodeUnsupportedEndpoint
                                             userInfo:@{NSLocalizedDescriptionKey: @"Loopback endpoint is missing."}];
            completion(error);
        }
        return;
    }

    [self updateState:PVConnectionStateConnecting];
    PTChannel *channel = [PTChannel channelWithDelegate:(id<PTChannelDelegate>)self];
    self.channel = channel;
    [channel connectToPort:endpoint.port IPv4Address:INADDR_LOOPBACK callback:^(NSError *error, PTAddress *address) {
        if (error) {
            [self cleanupChannel];
            [self updateState:PVConnectionStateFailed];
            if (completion) completion(error);
            return;
        }

        [self updateState:PVConnectionStateConnected];
        if ([self.delegate respondsToSelector:@selector(connectionDidOpen:)]) {
            [self.delegate connectionDidOpen:self];
        }
        if (completion) completion(nil);
    }];
}

- (void)sendFrame:(PVFrame *)frame completion:(void (^)(NSError * _Nullable))completion {
    if (self.state != PVConnectionStateConnected) {
        if (completion) {
            NSError *error = [NSError errorWithDomain:PVErrorDomain
                                                 code:PVErrorCodeDisconnected
                                             userInfo:@{NSLocalizedDescriptionKey: @"Loopback connection is not connected."}];
            completion(error);
        }
        return;
    }

    [self.channel sendFrameOfType:frame.type tag:frame.tag withPayload:frame.payload callback:completion];
}

- (void)close {
    [super close];
}

@end

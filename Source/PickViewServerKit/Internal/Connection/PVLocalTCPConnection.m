//
//  PVLocalTCPConnection.m
//  PickViewServer
//
//  Created by kris cheng on 2026/7/6.
//

#import "PVLocalTCPConnection.h"
#import "../../../PickViewCore/Connection/PVConnectionInternal.h"
#import "PVFrame.h"
#import "PVErrorCode.h"
#import "PVConnectionDelegate.h"
#import <PeerTalk/PTChannel.h>

@implementation PVLocalTCPConnection

- (instancetype)initWithAcceptedChannel:(PTChannel *)channel {
    self = [super init];
    if (self) {
        self.channel = channel;
        self.channel.delegate = self;
        self.state = PVConnectionStateConnected;
    }
    return self;
}

- (NSString *)connectionIdentifier {
    return [NSString stringWithFormat:@"local:%p", self.channel];
}

- (void)connectWithCompletion:(void (^)(NSError * _Nullable))completion {
    if (completion) completion(nil);
}

- (void)sendFrame:(PVFrame *)frame completion:(void (^)(NSError * _Nullable))completion {
    if (self.state != PVConnectionStateConnected) {
        if (completion) {
            NSError *error = [NSError errorWithDomain:PVErrorDomain code:PVErrorCodeDisconnected userInfo:@{NSLocalizedDescriptionKey: @"Local connection is not connected."}];
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

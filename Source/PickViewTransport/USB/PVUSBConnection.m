//
//  PVUSBConnection.m
//  PickView
//
//  Created by kris cheng on 2026/7/6.
//

#import "PVUSBConnection.h"
#import "PVUSBEndpoint.h"
#import "PVFrame.h"
#import "PVErrorCode.h"
#import "PVConnectionDelegate.h"

#import <PeerTalk/PTChannel.h>
#import <PeerTalk/PTUSBHub.h>

@implementation PVUSBConnection

- (instancetype)initWithEndpoint:(PVUSBEndpoint *)endpoint {
    self = [super init];
    if (self) {
        self.endpoint = endpoint;
    }
    return self;
}

- (NSString *)connectionIdentifier {
    return self.endpoint.identifier;
}

- (void)connectWithCompletion:(void (^)(NSError * _Nullable))completion {
    if (self.state == PVConnectionStateConnected || self.state == PVConnectionStateConnecting) {
        if (completion) completion(nil);
        return;
    }

    [self updateState:PVConnectionStateConnecting];
    PTChannel *channel = [PTChannel channelWithDelegate:(id<PTChannelDelegate>)self];
    self.channel = channel;
    PVUSBEndpoint *endpoint = (PVUSBEndpoint *)self.endpoint;
    [channel connectToPort:endpoint.port overUSBHub:PTUSBHub.sharedHub deviceID:endpoint.deviceID callback:^(NSError *error) {
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
            NSError *error = [NSError errorWithDomain:PVErrorDomain code:PVErrorCodeDisconnected userInfo:@{NSLocalizedDescriptionKey: @"USB connection is not connected."}];
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

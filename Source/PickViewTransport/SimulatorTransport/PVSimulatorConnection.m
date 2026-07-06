//
//  PVSimulatorConnection.m
//  PickView
//
//  Created by kris cheng on 2026/7/6.
//

#import "PVSimulatorConnection.h"
#import "../../PickViewCore/Connection/PVConnectionInternal.h"
#import "PVSimulatorEndpoint.h"
#import "PVFrame.h"
#import "PVErrorCode.h"
#import "PVConnectionDelegate.h"

#import <PeerTalk/PTChannel.h>

@interface PVSimulatorConnection ()
@property (nonatomic, strong) PVSimulatorEndpoint *endpoint;
@end

@implementation PVSimulatorConnection

- (instancetype)initWithEndpoint:(PVSimulatorEndpoint *)endpoint {
    self = [super init];
    if (self) {
        _endpoint = endpoint;
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

    self.state = PVConnectionStateConnecting;
    self.channel = [PTChannel channelWithDelegate:self];
    [self.channel connectToPort:self.endpoint.port IPv4Address:INADDR_LOOPBACK callback:^(NSError *error, PTAddress *address) {
        if (error) {
            [self cleanupChannel];
            self.state = PVConnectionStateFailed;
            if (completion) completion(error);
            return;
        }

        self.state = PVConnectionStateConnected;
        if ([self.delegate respondsToSelector:@selector(connectionDidOpen:)]) {
            [self.delegate connectionDidOpen:self];
        }
        if (completion) completion(nil);
    }];
}

- (void)sendFrame:(PVFrame *)frame completion:(void (^)(NSError * _Nullable))completion {
    if (self.state != PVConnectionStateConnected) {
        if (completion) {
            NSError *error = [NSError errorWithDomain:PVErrorDomain code:PVErrorCodeDisconnected userInfo:@{NSLocalizedDescriptionKey: @"Simulator connection is not connected."}];
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

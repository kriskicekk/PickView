//
//  PVConnection.m
//  PickView
//
//  Created by kris cheng on 2026/7/6.
//

#import "PVConnection.h"
#import "PVConnectionState.h"

@implementation PVConnection

- (instancetype)init {
    self = [super init];
    if (self) {
        [self updateState:PVConnectionStateIdle];
    }
    return self;
}

- (void)close {
    if (self.state == PVConnectionStateClosed || self.state == PVConnectionStateClosing) {
        return;
    }

    [self updateState:PVConnectionStateClosing];
    [self updateState:PVConnectionStateClosed];
}

- (void)updateState:(PVConnectionState)state {
    _state = state;
}

- (void)connectWithCompletion:(nonnull void (^)(NSError * _Nullable))completion {}
- (void)sendFrame:(nonnull PVFrame *)frame completion:(nullable void (^)(NSError * _Nullable))completion {}

@end

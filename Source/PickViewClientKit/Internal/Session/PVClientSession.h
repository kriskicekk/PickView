//
//  PVClientSession.h
//  PickViewClient
//
//  Created by kris cheng on 2026/7/6.
//

#ifndef PVClientSession_h
#define PVClientSession_h

#import "PVConnectionDelegate.h"

@class PVFrame;
@protocol PVConnectionProtocol;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PVClientSessionState) {
    PVClientSessionStateIdle,
    PVClientSessionStateConnecting,
    PVClientSessionStateHandshaking,
    PVClientSessionStateReady,
    PVClientSessionStateDisconnected,
    PVClientSessionStateFailed
};

@interface PVClientSession : NSObject <PVConnectionDelegate>

@property (nonatomic, strong, readonly) id<PVConnectionProtocol> connection;
@property (nonatomic, assign, readonly) PVClientSessionState state;

- (instancetype)initWithConnection:(id<PVConnectionProtocol>)connection;
- (void)openWithCompletion:(void (^)(NSError * _Nullable error))completion;
- (void)sendRequestType:(uint32_t)type
                payload:(nullable NSData *)payload
        timeoutInterval:(NSTimeInterval)timeoutInterval
             completion:(void (^)(NSData * _Nullable payload, NSError * _Nullable error))completion;
- (void)sendPushType:(uint32_t)type payload:(nullable NSData *)payload completion:(nullable void (^)(NSError * _Nullable error))completion;
- (void)close;

@end

NS_ASSUME_NONNULL_END

#endif /* PVClientSession_h */

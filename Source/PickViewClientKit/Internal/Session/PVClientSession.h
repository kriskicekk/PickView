//
//  PVClientSession.h
//  PickViewClient
//
//  Created by kris cheng on 2026/7/6.
//

#ifndef PVClientSession_h
#define PVClientSession_h

#import "PVConnectionDelegate.h"

@class PVClientSession;
@class PVFrame;
@class PVPeerIdentity;
@protocol PVConnectionProtocol;
@protocol PVEndpointProtocol;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PVClientSessionState) {
    PVClientSessionStateIdle,
    PVClientSessionStateConnecting,
    PVClientSessionStateHandshaking,
    PVClientSessionStateReady,
    PVClientSessionStateBlocked,
    PVClientSessionStateDisconnected,
    PVClientSessionStateFailed
};

@protocol PVClientSessionDelegate <NSObject>

@optional
- (void)clientSession:(PVClientSession *)session didCloseWithError:(nullable NSError *)error;

@end

@interface PVClientSession : NSObject <PVConnectionDelegate>

@property (nonatomic, weak, nullable) id<PVClientSessionDelegate> delegate;
@property (nonatomic, strong, readonly) id<PVConnectionProtocol> connection;
@property (nonatomic, assign) PVClientSessionState state;
@property (nonatomic, strong, readonly, nullable) PVPeerIdentity *peerIdentity;
@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, strong, readonly) id<PVEndpointProtocol> endpoint;

- (instancetype)initWithConnection:(id<PVConnectionProtocol>)connection;
- (void)openWithCompletion:(void (^)(NSError * _Nullable error))completion;
- (void)sendRequestType:(uint32_t)type
                payload:(nullable NSData *)payload
        timeoutInterval:(NSTimeInterval)timeoutInterval
             completion:(void (^)(NSData * _Nullable payload, NSError * _Nullable error))completion;
- (void)sendPushType:(uint32_t)type payload:(nullable NSData *)payload completion:(nullable void (^)(NSError * _Nullable error))completion;
- (void)cancelPendingRequestsWithType:(uint32_t)type;
- (void)close;

@end

NS_ASSUME_NONNULL_END

#endif /* PVClientSession_h */

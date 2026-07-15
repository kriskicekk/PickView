//
//  PVServerSession.h
//  PickViewServer
//
//  Created by kris cheng on 2026/7/6.
//

#ifndef PVServerSession_h
#define PVServerSession_h

#import "PVConnectionDelegate.h"

@class PVServerSession;
@class PVPeerIdentity;
@protocol PVConnectionProtocol;
@protocol PVRequestHandlerProtocol;

NS_ASSUME_NONNULL_BEGIN

typedef void (^PVServerSessionAuthorizationDecision)(BOOL accepted);
typedef void (^PVServerSessionAuthorizationHandler)(
    PVPeerIdentity *peerIdentity,
    PVServerSessionAuthorizationDecision decision);

@protocol PVServerSessionDelegate <NSObject>

@optional
- (void)serverSession:(PVServerSession *)session didCloseWithError:(nullable NSError *)error;

@end

@interface PVServerSession : NSObject <PVConnectionDelegate>

@property (nonatomic, weak, nullable) id<PVServerSessionDelegate> delegate;
@property (nonatomic, strong, readonly) id<PVConnectionProtocol> connection;
@property (nonatomic, strong, readonly) id<PVRequestHandlerProtocol> requestHandler;

- (instancetype)initWithConnection:(id<PVConnectionProtocol>)connection
                     requestHandler:(id<PVRequestHandlerProtocol>)requestHandler
              requiresAuthorization:(BOOL)requiresAuthorization
               authorizationHandler:(nullable PVServerSessionAuthorizationHandler)authorizationHandler;
- (void)start;
- (void)close;

@end

NS_ASSUME_NONNULL_END

#endif /* PVServerSession_h */

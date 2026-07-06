//
//  PVServerSession.h
//  PickViewServer
//
//  Created by kris cheng on 2026/7/6.
//

#ifndef PVServerSession_h
#define PVServerSession_h

#import "PVConnectionDelegate.h"

@protocol PVConnectionProtocol;
@protocol PVRequestHandlerProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface PVServerSession : NSObject <PVConnectionDelegate>

@property (nonatomic, strong, readonly) id<PVConnectionProtocol> connection;
@property (nonatomic, strong, readonly) id<PVRequestHandlerProtocol> requestHandler;

- (instancetype)initWithConnection:(id<PVConnectionProtocol>)connection requestHandler:(id<PVRequestHandlerProtocol>)requestHandler;
- (void)start;
- (void)close;

@end

NS_ASSUME_NONNULL_END

#endif /* PVServerSession_h */

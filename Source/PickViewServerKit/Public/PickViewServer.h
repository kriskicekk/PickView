//
//  PickViewServer.h
//  PickViewServer
//
//  Created by kris cheng on 2026/7/6.
//

#ifndef PickViewServer_h
#define PickViewServer_h

#import <Foundation/Foundation.h>

@class PickViewServer;
@class PickViewServerConfiguration;
@protocol PVRequestHandlerProtocol;

NS_ASSUME_NONNULL_BEGIN

@protocol PickViewServerDelegate <NSObject>

@optional
- (void)pickViewServer:(PickViewServer *)server didStartListeningOnPort:(int)port;
- (void)pickViewServer:(PickViewServer *)server didFailToStartWithError:(NSError *)error;
- (void)pickViewServer:(PickViewServer *)server didAcceptConnectionWithIdentifier:(NSString *)identifier;
- (void)pickViewServer:(PickViewServer *)server didReceiveMessage:(NSString *)message;

@end

@interface PickViewServer : NSObject

@property (class, nonatomic, readonly) PickViewServer *sharedServer;
@property (nonatomic, weak, nullable) id<PickViewServerDelegate> delegate;
@property (nonatomic, assign, readonly, getter=isRunning) BOOL running;

- (void)start;
- (void)startWithConfiguration:(nullable PickViewServerConfiguration *)configuration;
- (void)stop;
- (void)registerHandler:(id<PVRequestHandlerProtocol>)handler;

@end

NS_ASSUME_NONNULL_END

#endif /* PickViewServer_h */

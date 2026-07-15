//
//  PVClientSessionManager.h
//  PickViewClient
//
//  Created by kris cheng on 2026/7/7.
//

#ifndef PVClientSessionManager_h
#define PVClientSessionManager_h

#import <Foundation/Foundation.h>
#import "PVEndpointProtocol.h"

@class PVClientSession;
@class PVClientSessionManager;

NS_ASSUME_NONNULL_BEGIN

@protocol PVClientSessionManagerDelegate <NSObject>

@optional
- (void)clientSessionManagerDidUpdateSessions:(PVClientSessionManager *)sessionManager;

@end

@interface PVClientSessionManager : NSObject

@property (nonatomic, weak, nullable) id<PVClientSessionManagerDelegate> delegate;

@property (nonatomic, copy, readonly) NSArray<PVClientSession *> *allSessions;
@property (nonatomic, copy, readonly) NSArray<PVClientSession *> *lanSessions;
@property (nonatomic, copy, readonly) NSArray<PVClientSession *> *usbSessions;
@property (nonatomic, copy, readonly) NSArray<id<PVEndpointProtocol>> *allEndpoints;
@property (nonatomic, copy, readonly) NSArray<id<PVEndpointProtocol>> *lanEndpoints;

- (void)clear;

- (void)addSession:(PVClientSession *)session;
- (void)closeAndRemoveSession:(PVClientSession *)session;
- (void)removeClosedSession:(PVClientSession *)session;
- (nullable PVClientSession *)sessionForEndpointIdentifier:(NSString *)endpointIdentifier;

- (void)addEndpoint:(id<PVEndpointProtocol>)endpoint;
- (void)removeEndpointForIdentifier:(NSString *)endpointIdentifier;
- (void)forgetEndpointForIdentifier:(NSString *)endpointIdentifier;
- (nullable id<PVEndpointProtocol>)endpointForIdentifier:(NSString *)endpointIdentifier;

- (void)markEndpointConnectingWithIdentifier:(NSString *)endpointIdentifier;
- (void)removeConnectingEndpointWithIdentifier:(NSString *)endpointIdentifier;
- (BOOL)isEndpointConnectingWithIdentifier:(NSString *)endpointIdentifier;

- (void)markEndpointConnectedWithIdentifier:(NSString *)endpointIdentifier;
- (void)removeConnectedEndpointWithIdentifier:(NSString *)endpointIdentifier;
- (BOOL)isEndpointConnectedWithIdentifier:(NSString *)endpointIdentifier;

- (void)clearEndpointStateForIdentifier:(NSString *)endpointIdentifier;

- (PVClientSession *)findLanSessionByPeerIdentityUUID:(NSString *)uuid;
- (PVClientSession *)findUSBSessionByPeerIdentityUUID:(NSString *)uuid;

@end

NS_ASSUME_NONNULL_END

#endif /* PVClientSessionManager_h */

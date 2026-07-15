//
//  PickViewClient.h
//  PickViewClient
//
//  Created by kris cheng on 2026/7/6.
//

#ifndef PickViewClient_h
#define PickViewClient_h

#import <Foundation/Foundation.h>
#import "PVEndpointProtocol.h"

@class PickViewClient;
@class PickViewClientConfiguration;
@class PVClientSessionManager;
@class PVDisplayItemDetail;
@class PVHierarchyInfo;
@class PVWindowInfo;

NS_ASSUME_NONNULL_BEGIN

@protocol PickViewClientDelegate <NSObject>

@optional
- (void)pickViewClient:(PickViewClient *)client didUpdateStatus:(NSString *)status;
- (void)pickViewClient:(PickViewClient *)client didLogMessage:(NSString *)message;
- (void)pickViewClient:(PickViewClient *)client didConnectEndpoint:(id<PVEndpointProtocol>)endpoint;
- (void)pickViewClient:(PickViewClient *)client didFailToConnectEndpoint:(id<PVEndpointProtocol>)endpoint error:(NSError *)error;
- (void)pickViewClient:(PickViewClient *)client didDisconnectEndpoint:(id<PVEndpointProtocol>)endpoint reason:(NSString *)reason;
- (void)pickViewClient:(PickViewClient *)client didReceiveEcho:(NSString *)echo fromEndpoint:(id<PVEndpointProtocol>)endpoint;
- (void)pickViewClientDidUpdateLANSessions:(PickViewClient *)client;
- (void)pickViewClient:(PickViewClient *)client didReceiveWindowInfos:(NSArray<PVWindowInfo *> *)windowInfos endpointIdentifier:(NSString *)endpointIdentifier;
- (void)pickViewClient:(PickViewClient *)client didReceiveHierarchy:(PVHierarchyInfo *)hierarchy endpointIdentifier:(NSString *)endpointIdentifier;
- (void)pickViewClient:(PickViewClient *)client didReceiveDisplayItemDetails:(NSArray<PVDisplayItemDetail *> *)details endpointIdentifier:(NSString *)endpointIdentifier;
- (void)pickViewClient:(PickViewClient *)client didFailInspectionRequestForEndpointIdentifier:(NSString *)endpointIdentifier error:(NSError *)error;

@end

@interface PickViewClient : NSObject

@property (class, nonatomic, readonly) PickViewClient *sharedClient;
@property (nonatomic, weak, nullable) id<PickViewClientDelegate> delegate;
@property (nonatomic, strong, readonly) PVClientSessionManager *sessionManager;

- (void)startScanning;
- (void)startScanningWithConfiguration:(nullable PickViewClientConfiguration *)configuration;
- (void)scanNow;
- (void)connectToLANEndpointIdentifier:(NSString *)endpointIdentifier;
- (void)requestWindowListForEndpointIdentifier:(NSString *)endpointIdentifier;
- (void)requestHierarchyForEndpointIdentifier:(NSString *)endpointIdentifier windowIdentifier:(nullable NSString *)windowIdentifier;
- (void)requestHierarchyDetailsForEndpointIdentifier:(NSString *)endpointIdentifier displayItemIdentifiers:(NSArray<NSString *> *)displayItemIdentifiers;
- (void)stop;

@end

NS_ASSUME_NONNULL_END

#endif /* PickViewClient_h */

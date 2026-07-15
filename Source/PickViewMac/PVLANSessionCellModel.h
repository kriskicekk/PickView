//
//  PVLANSessionCellModel.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/7.
//

#ifndef PVLANSessionCellModel_h
#define PVLANSessionCellModel_h

#import <Foundation/Foundation.h>
#import "PVClientSession.h"

@protocol PVEndpointProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface PVLANSessionCellModel : NSObject

@property (nonatomic, strong, readonly) id<PVEndpointProtocol> endpoint;
@property (nonatomic, strong, readonly, nullable) PVClientSession *session;
@property (nonatomic, copy, readonly) NSString *endpointIdentifier;
@property (nonatomic, copy, readonly) NSString *LANNameText;
@property (nonatomic, copy, readonly) NSString *deviceInfoText;
@property (nonatomic, copy, readonly) NSString *buttonTitle;
@property (nonatomic, assign, readonly) BOOL buttonEnabled;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithEndpoint:(id<PVEndpointProtocol>)endpoint
                          session:(nullable PVClientSession *)session
                       connecting:(BOOL)connecting
    connectedEndpointIdentifier:(nullable NSString *)connectedEndpointIdentifier NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END

#endif /* PVLANSessionCellModel_h */

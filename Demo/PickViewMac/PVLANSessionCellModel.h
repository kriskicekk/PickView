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

NS_ASSUME_NONNULL_BEGIN

@interface PVLANSessionCellModel : NSObject

@property (nonatomic, strong, readonly) PVClientSession *session;
@property (nonatomic, copy, readonly) NSString *endpointIdentifier;
@property (nonatomic, copy, readonly) NSString *deviceNameText;
@property (nonatomic, copy, readonly) NSString *appNameText;
@property (nonatomic, copy, readonly) NSString *bundleIDText;
@property (nonatomic, copy, readonly) NSString *peerIDText;
@property (nonatomic, copy, readonly) NSString *protocolVersionText;
@property (nonatomic, copy, readonly) NSString *statusText;
@property (nonatomic, copy, readonly) NSString *buttonTitle;
@property (nonatomic, assign, readonly) BOOL buttonEnabled;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithSession:(PVClientSession *)session
    connectedEndpointIdentifier:(nullable NSString *)connectedEndpointIdentifier NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END

#endif /* PVLANSessionCellModel_h */

//
//  PVUSBEndpoint.h
//  PickView
//
//  Created by kris cheng on 2026/7/6.
//

#ifndef PVUSBEndpoint_h
#define PVUSBEndpoint_h

#import "PVEndpointProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface PVUSBEndpoint : NSObject <PVEndpointProtocol>

@property (nonatomic, strong, readonly) NSNumber *deviceID;
@property (nonatomic, assign, readonly) int port;
@property (nonatomic, copy, readonly, nullable) NSString *serialNumber;

- (instancetype)initWithDeviceID:(NSNumber *)deviceID
                            port:(int)port
                    serialNumber:(nullable NSString *)serialNumber NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

#endif /* PVUSBEndpoint_h */

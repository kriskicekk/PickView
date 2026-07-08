//
//  PVUSBConnection.h
//  PickView
//
//  Created by kris cheng on 2026/7/6.
//

#ifndef PVUSBConnection_h
#define PVUSBConnection_h

#import "PVConnection.h"

@class PVUSBEndpoint;

NS_ASSUME_NONNULL_BEGIN

@interface PVUSBConnection : PVConnection

- (instancetype)initWithEndpoint:(PVUSBEndpoint *)endpoint NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

#endif /* PVUSBConnection_h */

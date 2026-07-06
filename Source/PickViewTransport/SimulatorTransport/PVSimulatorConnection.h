//
//  PVSimulatorConnection.h
//  PickView
//
//  Created by kris cheng on 2026/7/6.
//

#ifndef PVSimulatorConnection_h
#define PVSimulatorConnection_h

#import "PVConnection.h"

@class PVSimulatorEndpoint;

NS_ASSUME_NONNULL_BEGIN

@interface PVSimulatorConnection : PVConnection

@property (nonatomic, strong, readonly) PVSimulatorEndpoint *endpoint;

- (instancetype)initWithEndpoint:(PVSimulatorEndpoint *)endpoint NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

#endif /* PVSimulatorConnection_h */

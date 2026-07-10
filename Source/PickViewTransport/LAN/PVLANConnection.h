#import <Foundation/Foundation.h>
#import <Network/Network.h>
#import "PVConnection.h"

@class PVLANEndpoint;

NS_ASSUME_NONNULL_BEGIN

@interface PVLANConnection : PVConnection <PVConnectionProtocol>

- (instancetype)initWithEndpoint:(PVLANEndpoint *)endpoint;
- (instancetype)initWithAcceptedConnection:(nw_connection_t)connection;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

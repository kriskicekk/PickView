#import <Foundation/Foundation.h>
#import <Network/Network.h>
#import "PVEndpointProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface PVLANEndpoint : NSObject <PVEndpointProtocol>

@property (nonatomic, strong, readonly) nw_endpoint_t networkEndpoint;
@property (nonatomic, copy, readonly) NSString *serviceName;
@property (nonatomic, copy, readonly) NSString *serviceType;
@property (nonatomic, copy, readonly) NSString *serviceDomain;

- (instancetype)initWithNetworkEndpoint:(nw_endpoint_t)networkEndpoint;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

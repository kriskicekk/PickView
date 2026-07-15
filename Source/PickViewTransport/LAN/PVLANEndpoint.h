#import <Foundation/Foundation.h>
#import <Network/Network.h>
#import "PVEndpointProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface PVLANEndpoint : NSObject <PVEndpointProtocol>

@property (nonatomic, strong, readonly) nw_endpoint_t networkEndpoint;
@property (nonatomic, copy, readonly) NSString *serviceName;
@property (nonatomic, copy, readonly) NSString *serviceType;
@property (nonatomic, copy, readonly) NSString *serviceDomain;
@property (nonatomic, copy, readonly, nullable) NSString *deviceName;
@property (nonatomic, copy, readonly, nullable) NSString *systemVersion;

- (instancetype)initWithNetworkEndpoint:(nw_endpoint_t)networkEndpoint;
- (instancetype)initWithNetworkEndpoint:(nw_endpoint_t)networkEndpoint
                              deviceName:(nullable NSString *)deviceName
                           systemVersion:(nullable NSString *)systemVersion NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

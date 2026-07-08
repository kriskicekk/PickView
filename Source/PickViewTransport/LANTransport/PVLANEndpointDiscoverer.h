#import <Foundation/Foundation.h>
#import "PVEndpointDiscovererProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface PVLANEndpointDiscoverer : NSObject <PVEndpointDiscovererProtocol>

@property (nonatomic, weak, nullable) id<PVEndpointDiscovererDelegate> delegate;

@end

NS_ASSUME_NONNULL_END

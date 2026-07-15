#import "PVLANEndpoint.h"

#import <string.h>

static NSString *PVLANStringFromCString(const char *value, NSString *fallback) {
    if (!value || !strlen(value)) {
        return fallback;
    }
    return [NSString stringWithUTF8String:value] ?: fallback;
}

@implementation PVLANEndpoint

- (instancetype)initWithNetworkEndpoint:(nw_endpoint_t)networkEndpoint {
    return [self initWithNetworkEndpoint:networkEndpoint
                              deviceName:nil
                           systemVersion:nil];
}

- (instancetype)initWithNetworkEndpoint:(nw_endpoint_t)networkEndpoint
                              deviceName:(NSString *)deviceName
                           systemVersion:(NSString *)systemVersion {
    self = [super init];
    if (self) {
        _networkEndpoint = networkEndpoint;
        _deviceName = [deviceName copy];
        _systemVersion = [systemVersion copy];

        if (nw_endpoint_get_type(networkEndpoint) == nw_endpoint_type_bonjour_service) {
            _serviceName = [PVLANStringFromCString(nw_endpoint_get_bonjour_service_name(networkEndpoint), @"PickView") copy];
            _serviceType = [PVLANStringFromCString(nw_endpoint_get_bonjour_service_type(networkEndpoint), @"_pickview._tcp") copy];
            _serviceDomain = [PVLANStringFromCString(nw_endpoint_get_bonjour_service_domain(networkEndpoint), @"local") copy];
        } else {
            _serviceName = [networkEndpoint.description copy] ?: @"PickView";
            _serviceType = @"";
            _serviceDomain = @"";
        }
    }
    return self;
}

- (NSString *)identifier {
    return [NSString stringWithFormat:@"lan:%@:%@:%@", self.serviceName, self.serviceType, self.serviceDomain];
}

- (NSString *)displayName {
    return self.serviceName;
}

- (PVEndpointTransportType)transportType {
    return PVEndpointTransportTypeLAN;
}

- (PVEndpointPriority)priority {
    return PVEndpointPriorityLow;
}

@end

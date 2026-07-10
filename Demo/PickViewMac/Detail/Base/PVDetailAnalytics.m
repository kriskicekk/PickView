#import "PVDetailPrefix.h"
#import "PVDetailAnalytics.h"

@implementation PVDetailAnalytics

+ (void)trackEvent:(NSString *)event {
}

+ (void)trackEvent:(NSString *)event withProperties:(NSDictionary *)properties {
}

@end

@implementation PVDetailAppCenter

static BOOL PVDetailAppCenterEnabled = NO;

+ (BOOL)isEnabled {
    return PVDetailAppCenterEnabled;
}

+ (void)setEnabled:(BOOL)enabled {
    PVDetailAppCenterEnabled = enabled;
}

@end

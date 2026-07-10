#import <Foundation/Foundation.h>

@interface PVDetailAnalytics : NSObject

+ (void)trackEvent:(NSString *)event;
+ (void)trackEvent:(NSString *)event withProperties:(NSDictionary *)properties;

@end

@interface PVDetailAppCenter : NSObject

@property (class, nonatomic, assign, getter=isEnabled) BOOL enabled;

@end

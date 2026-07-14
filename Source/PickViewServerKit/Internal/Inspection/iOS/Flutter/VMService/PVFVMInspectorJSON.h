#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PVFVMInspectorJSON : NSObject

+ (id)normalizedPayloadFromResponse:(NSDictionary *)response;
+ (nullable NSString *)nodeIDFromDictionary:(NSDictionary *)dictionary;
+ (nullable NSString *)firstIsolateIDFromVMResponse:(NSDictionary *)response;
+ (nullable NSNumber *)numberFromValue:(nullable id)value;
+ (NSString *)prettyJSONStringForObject:(id)object;
+ (void)printCompleteJSONString:(NSString *)json;

@end

NS_ASSUME_NONNULL_END

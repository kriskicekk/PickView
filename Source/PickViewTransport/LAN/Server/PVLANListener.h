#import <Foundation/Foundation.h>
#import "PVListenerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface PVLANListener : NSObject <PVListenerProtocol>

@property (nonatomic, weak, nullable) id<PVListenerDelegate> delegate;
@property (nonatomic, assign, readonly) int listeningPort;
@property (nonatomic, copy, readonly) NSString *serviceName;
@property (nonatomic, copy, readonly, nullable) NSString *deviceName;
@property (nonatomic, copy, readonly, nullable) NSString *systemVersion;
@property (nonatomic, readonly) NSString *listeningInfo;

- (instancetype)initWithServiceName:(NSString *)serviceName;
- (instancetype)initWithServiceName:(NSString *)serviceName
                          deviceName:(nullable NSString *)deviceName
                       systemVersion:(nullable NSString *)systemVersion NS_DESIGNATED_INITIALIZER;
- (instancetype)init;

@end

NS_ASSUME_NONNULL_END

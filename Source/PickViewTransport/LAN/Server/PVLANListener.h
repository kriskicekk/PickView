#import <Foundation/Foundation.h>
#import "PVListenerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface PVLANListener : NSObject <PVListenerProtocol>

@property (nonatomic, weak, nullable) id<PVListenerDelegate> delegate;
@property (nonatomic, assign, readonly) int listeningPort;
@property (nonatomic, copy, readonly) NSString *serviceName;
@property (nonatomic, readonly) NSString *listeningInfo;

- (instancetype)initWithServiceName:(NSString *)serviceName;
- (instancetype)init;

@end

NS_ASSUME_NONNULL_END

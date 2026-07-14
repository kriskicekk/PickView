#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^PVFVMServiceCompletion)(NSDictionary *_Nullable response,
                                     NSError *_Nullable error);

@interface PVFVMServiceClient : NSObject

@property(nonatomic, readonly) NSURL *webSocketURL;

- (nullable instancetype)initWithServiceURI:(NSString *)serviceURI
                                      error:(NSError **)error
    NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
- (void)connect;
- (void)close;
- (void)callMethod:(NSString *)method
            params:(nullable NSDictionary *)params
        completion:(PVFVMServiceCompletion)completion;

@end

NS_ASSUME_NONNULL_END

//
//  PVInspectionRequestClient.h
//  PickViewClient
//
//  Created by kris cheng on 2026/7/10.
//

#import <Foundation/Foundation.h>

@class PVClientSession;

NS_ASSUME_NONNULL_BEGIN

typedef void (^PVInspectionRequestCompletion)(id _Nullable data, BOOL finished, NSError * _Nullable error);

@interface PVInspectionRequestClient : NSObject

- (instancetype)initWithSession:(PVClientSession *)session NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

- (void)sendRequestType:(uint32_t)type
                 object:(nullable id<NSSecureCoding>)object
        timeoutInterval:(NSTimeInterval)timeoutInterval
              completion:(PVInspectionRequestCompletion)completion;

- (void)sendRequestType:(uint32_t)type
                payload:(nullable NSData *)payload
        timeoutInterval:(NSTimeInterval)timeoutInterval
              completion:(PVInspectionRequestCompletion)completion;

- (void)cancelRequestType:(uint32_t)requestType pushType:(uint32_t)pushType;

@end

NS_ASSUME_NONNULL_END

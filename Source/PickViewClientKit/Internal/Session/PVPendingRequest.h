//
//  PVPendingRequest.h
//  PickViewClient
//
//  Created by kris cheng on 2026/7/6.
//

#ifndef PVPendingRequest_h
#define PVPendingRequest_h

#import <Foundation/Foundation.h>

typedef void (^PVPendingRequestCompletion)(NSData * _Nullable payload, NSError * _Nullable error);

NS_ASSUME_NONNULL_BEGIN

@interface PVPendingRequest : NSObject

@property (nonatomic, assign) uint32_t type;
@property (nonatomic, assign) uint32_t tag;
@property (nonatomic, assign) NSTimeInterval timeoutInterval;
@property (nonatomic, copy) PVPendingRequestCompletion completion;

- (instancetype)initWithType:(uint32_t)type
                         tag:(uint32_t)tag
             timeoutInterval:(NSTimeInterval)timeoutInterval
                  completion:(PVPendingRequestCompletion)completion;

@end

NS_ASSUME_NONNULL_END

#endif /* PVPendingRequest_h */

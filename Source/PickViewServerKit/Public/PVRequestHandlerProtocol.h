//
//  PVRequestHandlerProtocol.h
//  PickViewServer
//
//  Created by kris cheng on 2026/7/6.
//

#ifndef PVRequestHandlerProtocol_h
#define PVRequestHandlerProtocol_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PVRequestHandlerProtocol <NSObject>

- (BOOL)canHandleRequestType:(uint32_t)type;
- (void)handleRequestType:(uint32_t)type
                  payload:(nullable NSData *)payload
               completion:(nullable void (^)(NSData * _Nullable responsePayload, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END

#endif /* PVRequestHandlerProtocol_h */

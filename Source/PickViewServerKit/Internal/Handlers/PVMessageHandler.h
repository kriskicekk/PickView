//
//  PVMessageHandler.h
//  PickViewServer
//
//  Created by kris cheng on 2026/7/6.
//

#ifndef PVMessageHandler_h
#define PVMessageHandler_h

#import "PVRequestHandlerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^PVMessageReceiveBlock)(NSString *message);

@interface PVMessageHandler : NSObject <PVRequestHandlerProtocol>

- (instancetype)initWithReceiveBlock:(nullable PVMessageReceiveBlock)receiveBlock NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

#endif /* PVMessageHandler_h */

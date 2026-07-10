//
//  PVCompositeRequestHandler.h
//  PickViewServer
//
//  Created by kris cheng on 2026/7/6.
//

#ifndef PVCompositeRequestHandler_h
#define PVCompositeRequestHandler_h

#import "PVRequestHandlerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface PVCompositeRequestHandler : NSObject <PVRequestHandlerProtocol>

- (instancetype)initWithHandlers:(NSArray<id<PVRequestHandlerProtocol>> *)handlers;
- (void)addHandler:(id<PVRequestHandlerProtocol>)handler;

@end

NS_ASSUME_NONNULL_END

#endif /* PVCompositeRequestHandler_h */

//
//  PVLocalLoopbackListener.h
//  PickViewServer
//
//  Created by kris cheng on 2026/7/6.
//

#ifndef PVLocalLoopbackListener_h
#define PVLocalLoopbackListener_h

#import "PVListenerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface PVLocalLoopbackListener : NSObject <PVListenerProtocol>

@property (nonatomic, weak, nullable) id<PVListenerDelegate> delegate;
@property (nonatomic, assign, readonly) int listeningPort;

- (instancetype)initWithPortRangeStart:(int)startPort end:(int)endPort;
- (instancetype)init;

@end

NS_ASSUME_NONNULL_END

#endif /* PVLocalLoopbackListener_h */

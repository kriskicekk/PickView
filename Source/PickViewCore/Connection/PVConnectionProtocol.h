//
//  PVConnectionProtocol.h
//  PickView
//
//  Created by kris cheng on 2026/7/6.
//

#ifndef PVConnectionProtocol_h
#define PVConnectionProtocol_h

#import <Foundation/Foundation.h>
#import "PVConnectionState.h"

@class PVFrame;
@protocol PVConnectionDelegate;

NS_ASSUME_NONNULL_BEGIN

@protocol PVConnectionProtocol <NSObject>

@property (nonatomic, copy, readonly) NSString *connectionIdentifier;
@property (nonatomic, assign, readonly) PVConnectionState state;
@property (nonatomic, weak, nullable) id<PVConnectionDelegate> delegate;

- (void)connectWithCompletion:(void (^)(NSError * _Nullable error))completion;
- (void)sendFrame:(PVFrame *)frame completion:(nullable void (^)(NSError * _Nullable error))completion;
- (void)close;

@end

NS_ASSUME_NONNULL_END

#endif /* PVConnectionProtocol_h */

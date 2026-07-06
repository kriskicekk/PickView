//
//  PVConnectionDelegate.h
//  PickView
//
//  Created by kris cheng on 2026/7/6.
//

#ifndef PVConnectionDelegate_h
#define PVConnectionDelegate_h

#import <Foundation/Foundation.h>

@class PVFrame;
@protocol PVConnectionProtocol;

NS_ASSUME_NONNULL_BEGIN

@protocol PVConnectionDelegate <NSObject>

@optional
- (void)connectionDidOpen:(id<PVConnectionProtocol>)connection;
- (void)connection:(id<PVConnectionProtocol>)connection didReceiveFrame:(PVFrame *)frame;
- (void)connection:(id<PVConnectionProtocol>)connection didCloseWithError:(nullable NSError *)error;

@end

NS_ASSUME_NONNULL_END

#endif /* PVConnectionDelegate_h */

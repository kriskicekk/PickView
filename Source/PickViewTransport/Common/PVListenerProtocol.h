//
//  PVListenerProtocol.h
//  PickViewServer
//
//  Created by kris cheng on 2026/7/6.
//

#ifndef PVListenerProtocol_h
#define PVListenerProtocol_h

#import <Foundation/Foundation.h>

@protocol PVConnectionProtocol;
@protocol PVListenerProtocol;

NS_ASSUME_NONNULL_BEGIN

@protocol PVListenerDelegate <NSObject>

- (void)listener:(id<PVListenerProtocol>)listener didAcceptConnection:(id<PVConnectionProtocol>)connection;

- (void)listener:(id<PVListenerProtocol>)listener closeConnection:(id<PVConnectionProtocol>)connection;

@end

@protocol PVListenerProtocol <NSObject>

@property (nonatomic, weak, nullable) id<PVListenerDelegate> delegate;

- (void)startWithCompletion:(void (^)(NSError * _Nullable error))completion;
- (void)stop;

@end

NS_ASSUME_NONNULL_END

#endif /* PVListenerProtocol_h */

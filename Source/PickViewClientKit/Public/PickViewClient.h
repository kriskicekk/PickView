//
//  PickViewClient.h
//  PickViewClient
//
//  Created by kris cheng on 2026/7/6.
//

#ifndef PickViewClient_h
#define PickViewClient_h

#import <Foundation/Foundation.h>

@class PickViewClient;
@class PickViewClientConfiguration;

NS_ASSUME_NONNULL_BEGIN

@interface PickViewClient : NSObject

@property (class, nonatomic, readonly) PickViewClient *sharedClient;
//@property (nonatomic, weak, nullable) id<PickViewClientDelegate> delegate;

- (void)startScanning;
- (void)startScanningWithConfiguration:(nullable PickViewClientConfiguration *)configuration;
- (void)scanNow;
- (void)connectToLANEndpointIdentifier:(NSString *)endpointIdentifier;
- (void)stop;

@end

NS_ASSUME_NONNULL_END

#endif /* PickViewClient_h */

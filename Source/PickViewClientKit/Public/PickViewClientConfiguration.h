//
//  PickViewClientConfiguration.h
//  PickViewClient
//
//  Created by kris cheng on 2026/7/6.
//

#ifndef PickViewClientConfiguration_h
#define PickViewClientConfiguration_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PickViewClientConfiguration : NSObject

@property (nonatomic, assign) BOOL enableUSBDiscovery;
@property (nonatomic, assign) BOOL enableSimulatorDiscovery;
@property (nonatomic, assign) BOOL enableLANDiscovery;
@property (nonatomic, assign) BOOL preferUSBTransport;
@property (nonatomic, assign) NSTimeInterval scanInterval;

+ (instancetype)defaultConfiguration;

@end

NS_ASSUME_NONNULL_END

#endif /* PickViewClientConfiguration_h */

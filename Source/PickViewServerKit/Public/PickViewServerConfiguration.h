//
//  PickViewServerConfiguration.h
//  PickViewServer
//
//  Created by kris cheng on 2026/7/6.
//

#ifndef PickViewServerConfiguration_h
#define PickViewServerConfiguration_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PickViewServerConfiguration : NSObject

@property (nonatomic, assign) int portStart;
@property (nonatomic, assign) int portEnd;
@property (nonatomic, assign) BOOL enableLocalLoopback;
@property (nonatomic, assign) BOOL enableLANTransport;
@property (nonatomic, copy) NSString *lanServiceName;
@property (nonatomic, assign) BOOL enableMessageHandler;
@property (nonatomic, assign) BOOL enableAppInfoHandler;
@property (nonatomic, assign) BOOL enableHierarchyHandler;

+ (instancetype)defaultConfiguration;

@end

NS_ASSUME_NONNULL_END

#endif /* PickViewServerConfiguration_h */

//
//  PVUtils.h
//  PickView
//
//  Created by kris cheng on 2026/7/7.
//

#ifndef PVUtils_h
#define PVUtils_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PVUtils : NSObject

+ (NSString *)bundleID;
+ (NSString *)appName;
+ (NSString *)deviceName;
+ (NSString *)systemVersion;
+ (NSComparisonResult)compareVersion:(NSString *)version toVersion:(NSString *)otherVersion;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

#endif /* PVUtils_h */

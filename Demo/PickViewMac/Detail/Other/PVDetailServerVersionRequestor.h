//
//  PVDetailServerVersionRequestor.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PVDetailServerVersionRequestor : NSObject

+ (instancetype)shared;

- (void)preload;
- (NSString *)query;

@end

NS_ASSUME_NONNULL_END

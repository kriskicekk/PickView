//
//  PVAppInfoCollector.h
//  PickViewServer
//
//  Created by kris cheng on 2026/7/10.
//

#import <Foundation/Foundation.h>

@class PVAppInfo;

NS_ASSUME_NONNULL_BEGIN

@interface PVAppInfoCollector : NSObject

+ (PVAppInfo *)currentInfoWithImages:(BOOL)needImages
                    localIdentifiers:(NSArray<NSNumber *> *)localIdentifiers;

@end

NS_ASSUME_NONNULL_END

//
//  LKPerformanceReporter.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LKPerformanceReporter : NSObject

+ (instancetype)sharedInstance;

- (void)willStartReload;

- (void)didFetchHierarchy;

- (void)didComplete;

@end

NS_ASSUME_NONNULL_END

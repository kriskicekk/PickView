//
//  PVDetailMessageManager.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const PVDetailMessage_Jobs;
extern NSString *const PVDetailMessage_NewServerVersion;
extern NSString *const PVDetailMessage_SwiftSubspec;

@interface PVDetailMessageManager : NSObject

+ (instancetype)sharedInstance;

- (void)addMessage:(NSString *)message;

- (void)removeMessage:(NSString *)message;

- (NSArray<NSString *> *)queryMessages;

#if DEBUG
- (void)reset;
#endif

@end

NS_ASSUME_NONNULL_END

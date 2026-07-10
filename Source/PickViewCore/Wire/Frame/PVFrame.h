//
//  PVFrame.h
//  PickView
//
//  Created by kris cheng on 2026/7/6.
//

#ifndef PVFrame_h
#define PVFrame_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PVFrame : NSObject

@property (nonatomic, assign, readonly) uint32_t version;
@property (nonatomic, assign, readonly) uint32_t type;
@property (nonatomic, assign, readonly) uint32_t tag;
@property (nonatomic, copy, readonly, nullable) NSData *payload;

- (instancetype)initWithType:(uint32_t)type
                         tag:(uint32_t)tag
                     payload:(nullable NSData *)payload;

- (instancetype)initWithVersion:(uint32_t)version
                           type:(uint32_t)type
                            tag:(uint32_t)tag
                        payload:(nullable NSData *)payload NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

#endif /* PVFrame_h */

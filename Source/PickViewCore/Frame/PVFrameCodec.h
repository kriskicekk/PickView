//
//  PVFrameCodec.h
//  PickView
//
//  Created by kris cheng on 2026/7/6.
//

#ifndef PVFrameCodec_h
#define PVFrameCodec_h

#import <Foundation/Foundation.h>

@class PVFrame;

NS_ASSUME_NONNULL_BEGIN

@interface PVFrameCodec : NSObject

+ (NSData *)dataWithFrame:(PVFrame *)frame;
+ (nullable PVFrame *)frameWithData:(NSData *)data error:(NSError **)error;
+ (NSUInteger)headerLength;
+ (NSUInteger)payloadLengthFromHeaderData:(NSData *)headerData error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END

#endif /* PVFrameCodec_h */

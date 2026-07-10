//
//  PVRequestAttachment.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#ifndef PVRequestAttachment_h
#define PVRequestAttachment_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PVRequestAttachment : NSObject <NSSecureCoding>

@property (nonatomic, strong, nullable) id<NSSecureCoding> data;

+ (instancetype)attachmentWithData:(nullable id<NSSecureCoding>)data;

@end

NS_ASSUME_NONNULL_END

#endif /* PVRequestAttachment_h */

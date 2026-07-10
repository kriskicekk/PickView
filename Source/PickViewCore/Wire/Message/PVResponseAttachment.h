//
//  PVResponseAttachment.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#ifndef PVResponseAttachment_h
#define PVResponseAttachment_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PVResponseAttachment : NSObject <NSSecureCoding>

@property (nonatomic, strong, nullable) id<NSSecureCoding> data;
@property (nonatomic, strong, nullable) NSError *error;
@property (nonatomic, assign) NSUInteger dataTotalCount;
@property (nonatomic, assign) NSUInteger currentDataCount;

+ (instancetype)attachmentWithData:(nullable id<NSSecureCoding>)data;
+ (instancetype)attachmentWithError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END

#endif /* PVResponseAttachment_h */

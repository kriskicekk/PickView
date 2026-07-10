//
//  PVArchiveCodec.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#ifndef PVArchiveCodec_h
#define PVArchiveCodec_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PVArchiveCodec : NSObject

+ (nullable NSData *)archivedDataWithObject:(id<NSSecureCoding>)object error:(NSError * _Nullable * _Nullable)error;
+ (nullable id)unarchivedObjectFromData:(NSData *)data
                         allowedClasses:(NSSet<Class> *)allowedClasses
                                  error:(NSError * _Nullable * _Nullable)error;
+ (NSSet<Class> *)defaultAllowedClasses;

@end

NS_ASSUME_NONNULL_END

#endif /* PVArchiveCodec_h */

//
//  PVPeerIdentity.h
//  PickView
//
//  Created by kris cheng on 2026/7/7.
//

#ifndef PVPeerIdentity_h
#define PVPeerIdentity_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PVPeerIdentity : NSObject

@property (nonatomic, copy, readonly) NSString *uuid;

@property (nonatomic, copy, readonly) NSString *bundleID;

@property (nonatomic, copy, readonly) NSString *deviceName;

@property (nonatomic, copy, readonly) NSString *appName;

@property (nonatomic, copy, readonly) NSString *systemVersion;

@property (nonatomic, copy, readonly) NSString *protocolVersion;

@property (nonatomic, copy, readonly) NSString *supportedPeerVersionMin;

@property (nonatomic, copy, readonly) NSString *supportedPeerVersionMax;

+ (instancetype)localIdentityWithProtocolVersion:(NSString *)protocolVersion
                          supportedPeerVersionMin:(NSString *)supportedPeerVersionMin
                          supportedPeerVersionMax:(NSString *)supportedPeerVersionMax;
+ (nullable instancetype)identityWithData:(NSData *)data error:(NSError * _Nullable * _Nullable)error;
+ (instancetype)identityWithDictionary:(NSDictionary<NSString *, id> *)dictionary;
- (instancetype)initWithDictionary:(NSDictionary<NSString *, id> *)dictionary;
- (NSDictionary<NSString *, id> *)dictionaryRepresentation;
- (nullable NSData *)encodedData;

@end

NS_ASSUME_NONNULL_END

#endif /* PVPeerIdentity_h */

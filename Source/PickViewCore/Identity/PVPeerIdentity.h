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

typedef NS_ENUM(NSInteger, PVPeerPlatform) {
    PVPeerPlatformUnknown = 0,
    PVPeerPlatformIOSDevice = 1,
    PVPeerPlatformIOSSimulator = 2,
    PVPeerPlatformMacOS = 3
};

typedef NS_ENUM(NSInteger, PVPeerUIFramework) {
    PVPeerUIFrameworkUnknown = 0,
    PVPeerUIFrameworkUIKit = 1,
    PVPeerUIFrameworkAppKit = 2
};

typedef NS_OPTIONS(NSUInteger, PVPeerCapability) {
    PVPeerCapabilityHierarchy = 1 << 0,
    PVPeerCapabilityScreenshots = 1 << 1,
    PVPeerCapabilityAttributeReading = 1 << 2,
    PVPeerCapabilityAttributeModification = 1 << 3,
    PVPeerCapabilityCustomAttributes = 1 << 4,
    PVPeerCapabilityMethodInvocation = 1 << 5,
    PVPeerCapabilityGestureModification = 1 << 6,
    PVPeerCapabilityImageExtraction = 1 << 7,
    PVPeerCapabilityAutoLayout = 1 << 8
};

@interface PVPeerIdentity : NSObject

@property (nonatomic, copy, readonly) NSString *uuid;

@property (nonatomic, copy, readonly) NSString *bundleID;

@property (nonatomic, copy, readonly) NSString *deviceName;

@property (nonatomic, copy, readonly) NSString *appName;

@property (nonatomic, copy, readonly) NSString *systemVersion;

@property (nonatomic, assign, readonly) PVPeerPlatform platform;

@property (nonatomic, assign, readonly) BOOL isMacOSPlatform;

@property (nonatomic, assign, readonly) PVPeerUIFramework uiFramework;

/// 0 表示旧版本 Peer 未声明能力，客户端应按兼容模式处理。
@property (nonatomic, assign, readonly) PVPeerCapability capabilities;

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

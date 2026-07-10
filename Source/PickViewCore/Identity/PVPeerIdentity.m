//
//  PVPeerIdentity.m
//  PickView
//
//  Created by kris cheng on 2026/7/7.
//

#import "PVPeerIdentity.h"
#import "PVErrorCode.h"
#import "PVPeerIdentityConstant.h"
#import "PVUtils.h"

@interface PVPeerIdentity()

@property (nonatomic, copy) NSString *uuid;

@property (nonatomic, copy) NSString *bundleID;

@property (nonatomic, copy) NSString *deviceName;

@property (nonatomic, copy) NSString *appName;

@property (nonatomic, copy) NSString *systemVersion;

@property (nonatomic, copy) NSString *protocolVersion;

@property (nonatomic, copy) NSString *supportedPeerVersionMin;

@property (nonatomic, copy) NSString *supportedPeerVersionMax;

@end

@implementation PVPeerIdentity

static NSString *PVPeerIdentityStringFromObject(id object) {
    if ([object isKindOfClass:NSString.class]) {
        return object;
    }

    if ([object isKindOfClass:NSNumber.class]) {
        return [(NSNumber *)object stringValue];
    }

    return @"";
}

static void PVPeerIdentityAssignError(NSError **error, NSString *reason) {
    if (!error) {
        return;
    }

    *error = [NSError errorWithDomain:PVErrorDomain
                                 code:PVErrorCodeUnknown
                             userInfo:@{NSLocalizedDescriptionKey: reason}];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _uuid = [[NSUUID UUID].UUIDString copy];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary<NSString *, id> *)dictionary {
    self = [super init];
    if (self) {
        NSString *uuid = PVPeerIdentityStringFromObject(dictionary[PVPeerIdentityPeerIDKey]);
        if (!uuid.length) {
            uuid = PVPeerIdentityStringFromObject(dictionary[@"uuid"]);
        }

        _uuid = [uuid copy];
        _bundleID = [PVPeerIdentityStringFromObject(dictionary[PVPeerIdentityBundleIDKey]) copy];
        _deviceName = [PVPeerIdentityStringFromObject(dictionary[PVPeerIdentityDeviceNameKey]) copy];
        _appName = [PVPeerIdentityStringFromObject(dictionary[PVPeerIdentityAppNameKey]) copy];
        _systemVersion = [PVPeerIdentityStringFromObject(dictionary[PVPeerIdentitySystemVersionKey]) copy];
        _protocolVersion = [PVPeerIdentityStringFromObject(dictionary[PVPeerIdentityProtocolVersionKey]) copy];
        _supportedPeerVersionMin = [PVPeerIdentityStringFromObject(dictionary[PVPeerIdentitySupportedPeerMinKey]) copy];
        _supportedPeerVersionMax = [PVPeerIdentityStringFromObject(dictionary[PVPeerIdentitySupportedPeerMaxKey]) copy];
    }
    return self;
}

+ (instancetype)localIdentityWithProtocolVersion:(NSString *)protocolVersion
                          supportedPeerVersionMin:(NSString *)supportedPeerVersionMin
                          supportedPeerVersionMax:(NSString *)supportedPeerVersionMax {
    static NSString *sharedPeerID;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPeerID = NSUUID.UUID.UUIDString;
    });

    PVPeerIdentity *identity = [[PVPeerIdentity alloc] init];
    identity.uuid = sharedPeerID;
    identity.bundleID = PVUtils.bundleID;
    identity.deviceName = PVUtils.deviceName;
    identity.appName = PVUtils.appName;
    identity.systemVersion = PVUtils.systemVersion;
    identity.protocolVersion = protocolVersion;
    identity.supportedPeerVersionMin = supportedPeerVersionMin;
    identity.supportedPeerVersionMax = supportedPeerVersionMax;
    return identity;
}

+ (instancetype)identityWithDictionary:(NSDictionary<NSString *, id> *)dictionary {
    return [[self alloc] initWithDictionary:dictionary];
}

+ (instancetype)identityWithData:(NSData *)data error:(NSError * _Nullable * _Nullable)error {
    if (!data.length) {
        PVPeerIdentityAssignError(error, @"Missing peer identity payload.");
        return nil;
    }

    NSError *serializationError = nil;
    id object = [NSPropertyListSerialization propertyListWithData:data
                                                          options:NSPropertyListImmutable
                                                           format:nil
                                                            error:&serializationError];
    if (!object) {
        if (error) {
            *error = serializationError ?: [NSError errorWithDomain:PVErrorDomain
                                                               code:PVErrorCodeUnknown
                                                           userInfo:@{NSLocalizedDescriptionKey: @"Failed to decode peer identity payload."}];
        }
        return nil;
    }

    if (![object isKindOfClass:NSDictionary.class]) {
        PVPeerIdentityAssignError(error, @"Peer identity payload is not a dictionary.");
        return nil;
    }

    return [self identityWithDictionary:(NSDictionary *)object];
}

- (NSDictionary<NSString *, id> *)dictionaryRepresentation {
    return @{
        PVPeerIdentityPeerIDKey: self.uuid ?: @"",
        PVPeerIdentityBundleIDKey: self.bundleID ?: @"",
        PVPeerIdentityDeviceNameKey: self.deviceName ?: @"",
        PVPeerIdentityAppNameKey: self.appName ?: @"",
        PVPeerIdentitySystemVersionKey: self.systemVersion ?: @"",
        PVPeerIdentityProtocolVersionKey: self.protocolVersion ?: @"",
        PVPeerIdentitySupportedPeerMinKey: self.supportedPeerVersionMin ?: @"",
        PVPeerIdentitySupportedPeerMaxKey: self.supportedPeerVersionMax ?: @""
    };
}

- (NSData *)encodedData {
    return [NSPropertyListSerialization dataWithPropertyList:[self dictionaryRepresentation]
                                                      format:NSPropertyListBinaryFormat_v1_0
                                                     options:0
                                                       error:nil];
}

@end

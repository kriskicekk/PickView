//
//  PVAppInfo.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVAppInfo.h"
#import "Image+PVInspect.h"

#import <TargetConditionals.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

static NSString * const CodingKey_AppIcon = @"1";
static NSString * const CodingKey_Screenshot = @"2";
static NSString * const CodingKey_DeviceDescription = @"3";
static NSString * const CodingKey_OsDescription = @"4";
static NSString * const CodingKey_AppName = @"5";
static NSString * const CodingKey_ScreenWidth = @"6";
static NSString * const CodingKey_ScreenHeight = @"7";
static NSString * const CodingKey_DeviceType = @"8";

@implementation PVAppInfo

- (id)copyWithZone:(NSZone *)zone {
    PVAppInfo *newAppInfo = [[PVAppInfo allocWithZone:zone] init];
    newAppInfo.appIcon = self.appIcon;
    newAppInfo.screenshot = self.screenshot;
    newAppInfo.appName = self.appName;
    newAppInfo.deviceDescription = self.deviceDescription;
    newAppInfo.osDescription = self.osDescription;
    newAppInfo.osMainVersion = self.osMainVersion;
    newAppInfo.deviceType = self.deviceType;
    newAppInfo.screenWidth = self.screenWidth;
    newAppInfo.screenHeight = self.screenHeight;
    newAppInfo.screenScale = self.screenScale;
    newAppInfo.appInfoIdentifier = self.appInfoIdentifier;
    newAppInfo.shouldUseCache = self.shouldUseCache;
    newAppInfo.serverVersion = self.serverVersion;
    newAppInfo.serverReadableVersion = self.serverReadableVersion;
    newAppInfo.swiftEnabledInPickViewServer = self.swiftEnabledInPickViewServer;
    newAppInfo.appBundleIdentifier = self.appBundleIdentifier;
#if !TARGET_OS_IPHONE
    newAppInfo.cachedTimestamp = self.cachedTimestamp;
#endif
    return newAppInfo;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        
        self.serverVersion = [aDecoder decodeIntForKey:@"serverVersion"];
        self.serverReadableVersion = [aDecoder decodeObjectForKey:@"serverReadableVersion"];
        self.swiftEnabledInPickViewServer = [aDecoder decodeIntForKey:@"swiftEnabledInPickViewServer"];
        NSData *screenshotData = [aDecoder decodeObjectForKey:CodingKey_Screenshot];
        self.screenshot = [[PVImage alloc] initWithData:screenshotData];
        
        NSData *appIconData = [aDecoder decodeObjectForKey:CodingKey_AppIcon];
        self.appIcon = [[PVImage alloc] initWithData:appIconData];
        
        self.appName = [aDecoder decodeObjectForKey:CodingKey_AppName];
        self.appBundleIdentifier = [aDecoder decodeObjectForKey:@"appBundleIdentifier"];
        self.deviceDescription = [aDecoder decodeObjectForKey:CodingKey_DeviceDescription];
        self.osDescription = [aDecoder decodeObjectForKey:CodingKey_OsDescription];
        self.osMainVersion = [aDecoder decodeIntegerForKey:@"osMainVersion"];
        self.deviceType = [aDecoder decodeIntegerForKey:CodingKey_DeviceType];
        self.screenWidth = [aDecoder decodeDoubleForKey:CodingKey_ScreenWidth];
        self.screenHeight = [aDecoder decodeDoubleForKey:CodingKey_ScreenHeight];
        self.screenScale = [aDecoder decodeDoubleForKey:@"screenScale"];
        self.appInfoIdentifier = [aDecoder decodeIntegerForKey:@"appInfoIdentifier"];
        self.shouldUseCache = [aDecoder decodeBoolForKey:@"shouldUseCache"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInt:self.serverVersion forKey:@"serverVersion"];
    [aCoder encodeObject:self.serverReadableVersion forKey:@"serverReadableVersion"];
    [aCoder encodeInt:self.swiftEnabledInPickViewServer forKey:@"swiftEnabledInPickViewServer"];
    
    [aCoder encodeObject:[self.screenshot pv_inspect_data] forKey:CodingKey_Screenshot];
    [aCoder encodeObject:[self.appIcon pv_inspect_data] forKey:CodingKey_AppIcon];
    
    [aCoder encodeObject:self.appName forKey:CodingKey_AppName];
    [aCoder encodeObject:self.appBundleIdentifier forKey:@"appBundleIdentifier"];
    [aCoder encodeObject:self.deviceDescription forKey:CodingKey_DeviceDescription];
    [aCoder encodeObject:self.osDescription forKey:CodingKey_OsDescription];
    [aCoder encodeInteger:self.osMainVersion forKey:@"osMainVersion"];
    [aCoder encodeInteger:self.deviceType forKey:CodingKey_DeviceType];
    [aCoder encodeDouble:self.screenWidth forKey:CodingKey_ScreenWidth];
    [aCoder encodeDouble:self.screenHeight forKey:CodingKey_ScreenHeight];
    [aCoder encodeDouble:self.screenScale forKey:@"screenScale"];
    [aCoder encodeInteger:self.appInfoIdentifier forKey:@"appInfoIdentifier"];
    [aCoder encodeBool:self.shouldUseCache forKey:@"shouldUseCache"];
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    if (![object isKindOfClass:[PVAppInfo class]]) {
        return NO;
    }
    if ([self isEqualToAppInfo:object]) {
        return YES;
    }
    return NO;
}

- (NSUInteger)hash {
    return self.appName.hash ^ self.deviceDescription.hash ^ self.osDescription.hash ^ self.deviceType;
}

- (BOOL)isEqualToAppInfo:(PVAppInfo *)info {
    if (!info) {
        return NO;
    }
    if ([self.appName isEqualToString:info.appName] && [self.deviceDescription isEqualToString:info.deviceDescription] && [self.osDescription isEqualToString:info.osDescription] && self.deviceType == info.deviceType) {
        return YES;
    }
    return NO;
}

+ (NSInteger)getAppInfoIdentifier {
    static dispatch_once_t onceToken;
    static NSInteger identifier = 0;
    dispatch_once(&onceToken,^{
        identifier = [[NSDate date] timeIntervalSince1970];
    });
    return identifier;
}

@end

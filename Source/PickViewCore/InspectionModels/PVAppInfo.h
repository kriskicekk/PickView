//
//  PVAppInfo.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVInspectionDefines.h"

typedef NS_ENUM(NSInteger, PVAppInfoDevice) {
    PVAppInfoDeviceSimulator,
    PVAppInfoDeviceIPad,
    PVAppInfoDeviceOthers,
    PVAppInfoDeviceMac
};

@interface PVAppInfo : NSObject <NSSecureCoding, NSCopying>

/// 每次启动 app 时都会随机生成一个 appInfoIdentifier 直到 app 被 kill 掉
@property(nonatomic, assign) NSUInteger appInfoIdentifier;
/// mac 端应该先读取该属性，如果为 YES 则表示应该使用之前保存的旧 appInfo 对象即可
@property(nonatomic, assign) BOOL shouldUseCache;
/// PickViewServer 的版本
@property(nonatomic, assign) int serverVersion;
/// 类似 "1.1.9"，只在 1.2.3 以及之后的 PickViewServer 版本里有值
@property(nonatomic, copy) NSString *serverReadableVersion;
/// 如果 iOS 侧使用了 SPM 或引入了 Swift Subspec，则该属性为 1
/// 如果 iOS 侧没使用，则该属性为 -1
/// 如果不知道，则该属性为 0
@property(nonatomic, assign) int swiftEnabledInPickViewServer;
/// app 的当前截图
@property(nonatomic, strong) PVImage *screenshot;
/// 可能为 nil，比如新建的 iOS 空项目
@property(nonatomic, strong) PVImage *appIcon;
/// @"微信读书"
@property(nonatomic, copy) NSString *appName;
/// hughkli.pickview
@property(nonatomic, copy) NSString *appBundleIdentifier;
/// @"iPhone X"
@property(nonatomic, copy) NSString *deviceDescription;
/// @"12.1"
@property(nonatomic, copy) NSString *osDescription;
/// 返回 os 的主版本号，比如 iOS 12.1 的设备将返回 12，iOS 13.2.1 的设备将返回 13
@property(nonatomic, assign) NSUInteger osMainVersion;
/// 设备类型
@property(nonatomic, assign) PVAppInfoDevice deviceType;
/// 屏幕的宽度
@property(nonatomic, assign) double screenWidth;
/// 屏幕的高度
@property(nonatomic, assign) double screenHeight;
/// 是几倍的屏幕
@property(nonatomic, assign) double screenScale;

- (BOOL)isEqualToAppInfo:(PVAppInfo *)info;
+ (NSInteger)getAppInfoIdentifier;

#if !TARGET_OS_IPHONE
@property(nonatomic, assign) NSTimeInterval cachedTimestamp;
#endif

@end

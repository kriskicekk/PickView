//
//  PVAppInfoCollector.m
//  PickViewServer
//
//  Created by kris cheng on 2026/7/10.
//

#import "PVAppInfoCollector.h"

#import "PVAppInfo.h"
#import "PVInspectionDefines.h"

#import <TargetConditionals.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <AppKit/AppKit.h>
#endif

@implementation PVAppInfoCollector

+ (PVAppInfo *)currentInfoWithImages:(BOOL)needImages localIdentifiers:(NSArray<NSNumber *> *)localIdentifiers {
    if (!NSThread.isMainThread) {
        __block PVAppInfo *info = nil;
        dispatch_sync(dispatch_get_main_queue(), ^{
            info = [self currentInfoWithImages:needImages localIdentifiers:localIdentifiers];
        });
        return info;
    }

    NSInteger identifier = [PVAppInfo getAppInfoIdentifier];
    if ([localIdentifiers containsObject:@(identifier)]) {
        PVAppInfo *cachedInfo = [[PVAppInfo alloc] init];
        cachedInfo.appInfoIdentifier = identifier;
        cachedInfo.shouldUseCache = YES;
        return cachedInfo;
    }

#if TARGET_OS_IPHONE
    return [self currentIOSInfoWithImages:needImages identifier:identifier];
#else
    return [self currentMacInfoWithImages:needImages identifier:identifier];
#endif
}

#if TARGET_OS_IPHONE

+ (PVAppInfo *)currentIOSInfoWithImages:(BOOL)needImages identifier:(NSInteger)identifier {
    NSDictionary *bundleInfo = NSBundle.mainBundle.infoDictionary;
    NSString *displayName = bundleInfo[@"CFBundleDisplayName"];
    NSString *bundleName = bundleInfo[@"CFBundleName"];

    PVAppInfo *info = [[PVAppInfo alloc] init];
    info.serverReadableVersion = PV_INSPECT_SERVER_READABLE_VERSION;
#ifdef PICKVIEW_SERVER_SWIFT_ENABLED
    info.swiftEnabledInPickViewServer = 1;
#else
    info.swiftEnabledInPickViewServer = -1;
#endif
    info.appInfoIdentifier = identifier;
    info.appName = displayName.length ? displayName : bundleName;
    info.deviceDescription = UIDevice.currentDevice.name;
    info.appBundleIdentifier = NSBundle.mainBundle.bundleIdentifier;
    if (TARGET_OS_SIMULATOR) {
        info.deviceType = PVAppInfoDeviceSimulator;
    } else if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        info.deviceType = PVAppInfoDeviceIPad;
    } else {
        info.deviceType = PVAppInfoDeviceOthers;
    }
    info.osDescription = UIDevice.currentDevice.systemVersion;
    info.osMainVersion = [UIDevice.currentDevice.systemVersion componentsSeparatedByString:@"."].firstObject.integerValue;

    UIWindow *window = [self keyWindow];
    UIScreen *screen = window.windowScene.screen;
    if (!screen) {
        for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if ([scene isKindOfClass:UIWindowScene.class]) {
                screen = ((UIWindowScene *)scene).screen;
                break;
            }
        }
    }
    info.screenWidth = screen.bounds.size.width;
    info.screenHeight = screen.bounds.size.height;
    info.screenScale = screen ? screen.scale : 1;
    if (needImages) {
        info.screenshot = [self screenshotForWindow:window];
        info.appIcon = [self appIcon];
    }
    return info;
}

+ (UIWindow *)keyWindow {
    if (@available(iOS 13.0, *)) {
        UIWindow *fallbackWindow = nil;
        for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if (![scene isKindOfClass:UIWindowScene.class]) {
                continue;
            }
            UIWindowScene *windowScene = (UIWindowScene *)scene;
            if (windowScene.activationState == UISceneActivationStateUnattached) {
                continue;
            }
            for (UIWindow *window in windowScene.windows) {
                if (window.isKeyWindow) {
                    return window;
                }
                if (!fallbackWindow && !window.isHidden && window.alpha > 0 && !CGRectIsEmpty(window.bounds)) {
                    fallbackWindow = window;
                }
            }
        }
        return fallbackWindow;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return UIApplication.sharedApplication.keyWindow;
#pragma clang diagnostic pop
}

+ (UIImage *)screenshotForWindow:(UIWindow *)window {
    if (!window || CGRectIsEmpty(window.bounds)) {
        return nil;
    }
    UIGraphicsBeginImageContextWithOptions(window.bounds.size, YES, 0.4);
    [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)appIcon {
#if TARGET_OS_TV
    return nil;
#else
    NSString *imageName = [NSBundle.mainBundle.infoDictionary[@"CFBundleIcons"][@"CFBundlePrimaryIcon"][@"CFBundleIconFiles"] lastObject];
    return imageName.length ? [UIImage imageNamed:imageName] : nil;
#endif
}

#else

+ (PVAppInfo *)currentMacInfoWithImages:(BOOL)needImages identifier:(NSInteger)identifier {
    NSDictionary *bundleInfo = NSBundle.mainBundle.infoDictionary;
    NSString *displayName = bundleInfo[@"CFBundleDisplayName"];
    NSString *bundleName = bundleInfo[@"CFBundleName"];

    PVAppInfo *info = [[PVAppInfo alloc] init];
    info.appInfoIdentifier = identifier;
    info.appName = displayName.length ? displayName : bundleName ?: @"PickView";
    info.appBundleIdentifier = NSBundle.mainBundle.bundleIdentifier ?: @"";
    info.deviceDescription = NSHost.currentHost.localizedName ?: @"Mac";
    info.osDescription = NSProcessInfo.processInfo.operatingSystemVersionString ?: @"";
    info.osMainVersion = (NSUInteger)NSProcessInfo.processInfo.operatingSystemVersion.majorVersion;
    info.deviceType = PVAppInfoDeviceMac;
    NSScreen *screen = NSScreen.mainScreen;
    info.screenWidth = screen.frame.size.width;
    info.screenHeight = screen.frame.size.height;
    info.screenScale = screen.backingScaleFactor ?: 1;
    info.serverReadableVersion = PV_INSPECT_SERVER_READABLE_VERSION;
    info.swiftEnabledInPickViewServer = 0;
    if (needImages) {
        info.appIcon = NSApp.applicationIconImage;
        info.screenshot = [self screenshotForPreviewWindow];
    }
    return info;
}

+ (NSImage *)screenshotForPreviewWindow {
    NSWindow *window = [self previewWindow];
    NSView *view = window.contentView;
    if (!view || CGRectIsEmpty(view.bounds)) {
        return nil;
    }
    [view layoutSubtreeIfNeeded];
    [view displayIfNeeded];
    NSBitmapImageRep *rep = [view bitmapImageRepForCachingDisplayInRect:view.bounds];
    if (!rep) {
        return nil;
    }
    [view cacheDisplayInRect:view.bounds toBitmapImageRep:rep];
    NSImage *image = [[NSImage alloc] initWithSize:view.bounds.size];
    [image addRepresentation:rep];
    return image;
}

+ (NSWindow *)previewWindow {
    NSApplication *application = NSApplication.sharedApplication;
    for (NSWindow *window in @[application.keyWindow ?: NSNull.null, application.mainWindow ?: NSNull.null]) {
        if ([window isKindOfClass:NSWindow.class] && [self canCaptureWindow:window requireVisible:NO]) {
            return window;
        }
    }

    for (NSWindow *window in application.orderedWindows) {
        if ([self canCaptureWindow:window requireVisible:YES]) {
            return window;
        }
    }
    for (NSWindow *window in application.windows) {
        if ([self canCaptureWindow:window requireVisible:NO]) {
            return window;
        }
    }
    return nil;
}

+ (BOOL)canCaptureWindow:(NSWindow *)window requireVisible:(BOOL)requireVisible {
    if (!window.contentView || CGRectIsEmpty(window.contentView.bounds)) {
        return NO;
    }
    if (requireVisible && (!window.isVisible || window.isMiniaturized || window.alphaValue <= 0)) {
        return NO;
    }
    return YES;
}

#endif

@end

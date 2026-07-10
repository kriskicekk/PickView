//
//  PVUIKitAttributeAccessors.h
//  PickViewServer
//
//  Created by kris cheng on 2026/7/9.
//

#import <Foundation/Foundation.h>

#import <TargetConditionals.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>

@interface UIView (PVUIKitAttributeAccessorsRebuild)

+ (void)pv_lks_rebuildGlobalInvolvedRawConstraintsWithWindows:(NSArray<UIWindow *> *)windows;

@end
#endif

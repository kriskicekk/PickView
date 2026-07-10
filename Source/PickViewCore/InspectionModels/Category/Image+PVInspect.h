//
//  Image+PVInspect.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import <Foundation/Foundation.h>
#import <TargetConditionals.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>

@interface UIImage (PVInspect)

- (NSData *)pv_inspect_data;

@end

#elif TARGET_OS_OSX
#import <AppKit/AppKit.h>

@interface NSImage (PVInspect)

- (NSData *)pv_inspect_data;

@end

#endif

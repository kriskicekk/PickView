//
//  PVDetailWindowToolbarAppButton.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import <AppKit/AppKit.h>

@class PVAppInfo;

@interface PVDetailWindowToolbarAppButton : NSButton

@property(nonatomic, strong) PVAppInfo *appInfo;

@end

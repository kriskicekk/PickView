//
//  PVDetailLaunchWindowController.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailLaunchWindowController.h"
#import "PVDetailLaunchViewController.h"
#import "PVDetailWindow.h"

@interface PVDetailLaunchWindowController ()

@end

@implementation PVDetailLaunchWindowController

- (instancetype)init {
    PVDetailWindow *window = [[PVDetailWindow alloc] initWithContentRect:NSMakeRect(0, 0, 252, 400) styleMask:NSWindowStyleMaskTitled|NSWindowStyleMaskClosable|NSWindowStyleMaskMiniaturizable|NSWindowStyleMaskFullSizeContentView backing:NSBackingStoreBuffered defer:YES];
    window.backgroundColor = [NSColor clearColor];
    window.titlebarAppearsTransparent = YES;
    window.movableByWindowBackground = YES;
    [window center];

    if (self = [self initWithWindow:window]) {
        _launchViewController = [[PVDetailLaunchViewController alloc] initWithWindow:window];
        window.contentView = self.launchViewController.view;
        self.contentViewController = self.launchViewController;
    }
    return self;
}

@end

//
//  PVDetailJSONAttributeWindowController.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailJSONAttributeWindowController.h"
#import "PVDetailJSONAttributeViewController.h"
#import "PVDetailWindow.h"

@interface PVDetailJSONAttributeWindowController ()

@end

@implementation PVDetailJSONAttributeWindowController

- (instancetype)init {
    PVDetailWindow *window = [[PVDetailWindow alloc] initWithContentRect:NSMakeRect(0, 0, 600, 320) styleMask:NSWindowStyleMaskTitled|NSWindowStyleMaskClosable|NSWindowStyleMaskMiniaturizable|NSWindowStyleMaskResizable|NSWindowStyleMaskFullSizeContentView backing:NSBackingStoreBuffered defer:YES];
    window.movableByWindowBackground = YES;
    window.titleVisibility = NSWindowTitleHidden;
    window.minSize = CGSizeMake(200, 200);
    [window center];
    
    if (self = [self initWithWindow:window]) {
        PVDetailJSONAttributeViewController *vc = [PVDetailJSONAttributeViewController new];
        window.contentView = vc.view;
        self.contentViewController = vc;
    }
    return self;
}

@end

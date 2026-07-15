//
//  PVDetailAboutWindowController.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailAboutWindowController.h"
#import "PVDetailAboutViewController.h"
#import "PVDetailWindow.h"

@interface PVDetailAboutWindowController ()

@end

@implementation PVDetailAboutWindowController

- (instancetype)init {
    CGFloat width = 500;
    CGFloat height = width * 0.54;
    
    PVDetailWindow *window = [[PVDetailWindow alloc] initWithContentRect:NSMakeRect(0, 0, width, height) styleMask:NSWindowStyleMaskTitled|NSWindowStyleMaskClosable backing:NSBackingStoreBuffered defer:YES];
    window.movableByWindowBackground = YES;
    [window center];
    
    if (self = [self initWithWindow:window]) {
        PVDetailAboutViewController *vc = [PVDetailAboutViewController new];
        window.contentView = vc.view;
        self.contentViewController = vc;
    }
    return self;
}



@end

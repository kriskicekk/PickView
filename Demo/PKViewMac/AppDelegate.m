//
//  AppDelegate.m
//  PKViewMac
//
//  Created by kris cheng on 2026/7/5.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSRect frame = NSMakeRect(0, 0, 520, 360);
    NSWindowStyleMask styleMask = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable;
    self.window = [[NSWindow alloc] initWithContentRect:frame
                                              styleMask:styleMask
                                                backing:NSBackingStoreBuffered
                                                  defer:NO];
    self.window.title = @"PKView Mac Demo";
    [self.window center];

    NSViewController *viewController = [[NSViewController alloc] init];
    NSView *contentView = [[NSView alloc] initWithFrame:frame];
    viewController.view = contentView;

    NSTextField *label = [NSTextField labelWithString:@"PKView Mac Demo"];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.font = [NSFont systemFontOfSize:24 weight:NSFontWeightSemibold];
    [contentView addSubview:label];

    [NSLayoutConstraint activateConstraints:@[
        [label.centerXAnchor constraintEqualToAnchor:contentView.centerXAnchor],
        [label.centerYAnchor constraintEqualToAnchor:contentView.centerYAnchor]
    ]];

    self.window.contentViewController = viewController;
    [self.window makeKeyAndOrderFront:nil];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}


@end

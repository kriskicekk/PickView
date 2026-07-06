//
//  AppDelegate.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/5.
//

#import "AppDelegate.h"
#import "PickViewClientKit.h"

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
    self.window.title = @"PickView Mac Demo";
    [self.window center];

    NSViewController *viewController = [[NSViewController alloc] init];
    NSView *contentView = [[NSView alloc] initWithFrame:frame];
    viewController.view = contentView;

    NSTextField *label = [NSTextField labelWithString:@"PickView Mac Demo"];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.font = [NSFont systemFontOfSize:24 weight:NSFontWeightSemibold];
    [contentView addSubview:label];

    NSTextField *statusLabel = [NSTextField labelWithString:@"Client scanning..."];
    statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    statusLabel.font = [NSFont systemFontOfSize:14 weight:NSFontWeightRegular];
    statusLabel.textColor = NSColor.secondaryLabelColor;
    [contentView addSubview:statusLabel];

    [NSLayoutConstraint activateConstraints:@[
        [label.centerXAnchor constraintEqualToAnchor:contentView.centerXAnchor],
        [label.centerYAnchor constraintEqualToAnchor:contentView.centerYAnchor constant:-12],
        [statusLabel.centerXAnchor constraintEqualToAnchor:contentView.centerXAnchor],
        [statusLabel.topAnchor constraintEqualToAnchor:label.bottomAnchor constant:12]
    ]];

    self.window.contentViewController = viewController;
    [self.window makeKeyAndOrderFront:nil];

    [[PickViewClient sharedClient] startScanning];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    [[PickViewClient sharedClient] stop];
}

- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

@end

//
//  AppDelegate.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/5.
//

#import "AppDelegate.h"

#import "PVClientWindowController.h"

@interface AppDelegate ()

@property (nonatomic, strong) PVClientWindowController *clientWindowController;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    self.clientWindowController = [[PVClientWindowController alloc] init];
    [self.clientWindowController start];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    [self.clientWindowController stop];
}

- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

@end

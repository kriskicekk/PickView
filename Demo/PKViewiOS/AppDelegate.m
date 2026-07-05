//
//  AppDelegate.m
//  PKView
//
//  Created by kris cheng on 2026/7/5.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];

    UIViewController *viewController = [[UIViewController alloc] init];
    viewController.view.backgroundColor = UIColor.systemBackgroundColor;

    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.text = @"PKView iOS Demo";
    label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
    label.textColor = UIColor.labelColor;
    label.textAlignment = NSTextAlignmentCenter;
    [viewController.view addSubview:label];

    [NSLayoutConstraint activateConstraints:@[
        [label.centerXAnchor constraintEqualToAnchor:viewController.view.centerXAnchor],
        [label.centerYAnchor constraintEqualToAnchor:viewController.view.centerYAnchor]
    ]];

    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
    return YES;
}


@end

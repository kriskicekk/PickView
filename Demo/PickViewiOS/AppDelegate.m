//
//  AppDelegate.m
//  PickViewiOS
//
//  Created by kris cheng on 2026/7/5.
//

#import "AppDelegate.h"
#import "PickViewServerKit.h"

@interface AppDelegate () <PickViewServerDelegate>

@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UITextView *logView;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self installWindow];
    [self startPickViewServer];
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[PickViewServer sharedServer] stop];
}

- (void)installWindow {
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];

    UIViewController *viewController = [[UIViewController alloc] init];
    viewController.view.backgroundColor = UIColor.systemBackgroundColor;

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.text = @"PickView iOS Demo";
    titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
    titleLabel.textColor = UIColor.labelColor;

    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.statusLabel.text = @"Starting PickView server...";
    self.statusLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.statusLabel.textColor = UIColor.secondaryLabelColor;
    self.statusLabel.numberOfLines = 0;

    self.logView = [[UITextView alloc] init];
    self.logView.translatesAutoresizingMaskIntoConstraints = NO;
    self.logView.editable = NO;
    self.logView.font = [UIFont monospacedSystemFontOfSize:13 weight:UIFontWeightRegular];
    self.logView.layer.borderColor = UIColor.separatorColor.CGColor;
    self.logView.layer.borderWidth = 1;
    self.logView.text = @"";

    [viewController.view addSubview:titleLabel];
    [viewController.view addSubview:self.statusLabel];
    [viewController.view addSubview:self.logView];

    UILayoutGuide *guide = viewController.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.topAnchor constraintEqualToAnchor:guide.topAnchor constant:24],
        [titleLabel.leadingAnchor constraintEqualToAnchor:guide.leadingAnchor constant:20],
        [titleLabel.trailingAnchor constraintEqualToAnchor:guide.trailingAnchor constant:-20],

        [self.statusLabel.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:12],
        [self.statusLabel.leadingAnchor constraintEqualToAnchor:titleLabel.leadingAnchor],
        [self.statusLabel.trailingAnchor constraintEqualToAnchor:titleLabel.trailingAnchor],

        [self.logView.topAnchor constraintEqualToAnchor:self.statusLabel.bottomAnchor constant:16],
        [self.logView.leadingAnchor constraintEqualToAnchor:titleLabel.leadingAnchor],
        [self.logView.trailingAnchor constraintEqualToAnchor:titleLabel.trailingAnchor],
        [self.logView.bottomAnchor constraintEqualToAnchor:guide.bottomAnchor constant:-20]
    ]];

    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
}

- (void)startPickViewServer {
    PickViewServer *server = [PickViewServer sharedServer];
    server.delegate = self;
    [server start];
}

- (void)appendLog:(NSString *)line {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *nextLine = [NSString stringWithFormat:@"%@\n", line ?: @""];
        self.logView.text = [self.logView.text stringByAppendingString:nextLine];
        [self.logView scrollRangeToVisible:NSMakeRange(self.logView.text.length, 0)];
    });
}

#pragma mark - PickViewServerDelegate

- (void)pickViewServer:(PickViewServer *)server didStartListeningOnPort:(int)port {
    self.statusLabel.text = [NSString stringWithFormat:@"Listening on 127.0.0.1:%d", port];
    [self appendLog:[NSString stringWithFormat:@"listening on 127.0.0.1:%d", port]];
}

- (void)pickViewServer:(PickViewServer *)server didFailToStartWithError:(NSError *)error {
    self.statusLabel.text = @"PickView server failed.";
    [self appendLog:[NSString stringWithFormat:@"listen error: %@", error.localizedDescription]];
}

- (void)pickViewServer:(PickViewServer *)server didAcceptConnectionWithIdentifier:(NSString *)identifier {
    [self appendLog:[NSString stringWithFormat:@"accepted connection: %@", identifier ?: @""]];
}

- (void)pickViewServer:(PickViewServer *)server didReceiveMessage:(NSString *)message {
    [self appendLog:[NSString stringWithFormat:@"message: %@", message ?: @""]];
}

@end

//
//  AppDelegate.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/5.
//

#import "AppDelegate.h"
#import "PickViewClientKit.h"
#import "PVLANEndpoint.h"
#import "PVLANSessionCellModel.h"

@interface AppDelegate () <NSTableViewDataSource, NSTableViewDelegate, PickViewClientDelegate>

@property (nonatomic, strong) NSTextField *statusLabel;
@property (nonatomic, strong) NSTableView *lanTableView;
@property (nonatomic, strong) NSButton *connectionStateButton;
@property (nonatomic, strong) NSTextView *logView;
@property (nonatomic, copy) NSArray<PVLANSessionCellModel *> *lanCellModels;
@property (nonatomic, copy, nullable) NSString *connectedLANEndpointIdentifier;

@end

@implementation AppDelegate

- (instancetype)init {
    self = [super init];
    if (self) {
        _lanCellModels = @[];
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSRect frame = NSMakeRect(0, 0, 1080, 560);
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

    NSTextField *titleLabel = [NSTextField labelWithString:@"PickView Mac Demo"];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.font = [NSFont systemFontOfSize:20 weight:NSFontWeightSemibold];
    [contentView addSubview:titleLabel];

    self.statusLabel = [NSTextField labelWithString:@"Waiting for USB device, simulator, or LAN service..."];
    self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.statusLabel.font = [NSFont systemFontOfSize:13 weight:NSFontWeightRegular];
    self.statusLabel.textColor = NSColor.secondaryLabelColor;
    [contentView addSubview:self.statusLabel];

    NSButton *scanButton = [NSButton buttonWithTitle:@"Scan" target:self action:@selector(scanKnownEndpoints)];
    scanButton.translatesAutoresizingMaskIntoConstraints = NO;
    scanButton.bezelStyle = NSBezelStyleRounded;
    [contentView addSubview:scanButton];

    self.connectionStateButton = [NSButton buttonWithTitle:@"LAN Disconnected" target:nil action:nil];
    self.connectionStateButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.connectionStateButton.bezelStyle = NSBezelStyleRounded;
    self.connectionStateButton.enabled = NO;
    [contentView addSubview:self.connectionStateButton];

    NSScrollView *lanScrollView = [[NSScrollView alloc] init];
    lanScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    lanScrollView.hasVerticalScroller = YES;
    lanScrollView.borderType = NSBezelBorder;
    [contentView addSubview:lanScrollView];

    self.lanTableView = [[NSTableView alloc] init];
    self.lanTableView.delegate = self;
    self.lanTableView.dataSource = self;
    self.lanTableView.rowHeight = 32;
    self.lanTableView.usesAlternatingRowBackgroundColors = YES;
    self.lanTableView.target = self;
    self.lanTableView.doubleAction = @selector(connectSelectedLANEndpoint);
    lanScrollView.documentView = self.lanTableView;

    NSTableColumn *deviceColumn = [[NSTableColumn alloc] initWithIdentifier:@"deviceName"];
    deviceColumn.title = @"Device";
    deviceColumn.width = 160;
    [self.lanTableView addTableColumn:deviceColumn];

    NSTableColumn *appColumn = [[NSTableColumn alloc] initWithIdentifier:@"appName"];
    appColumn.title = @"App";
    appColumn.width = 130;
    [self.lanTableView addTableColumn:appColumn];

    NSTableColumn *bundleColumn = [[NSTableColumn alloc] initWithIdentifier:@"bundleIdentifier"];
    bundleColumn.title = @"Bundle ID";
    bundleColumn.width = 260;
    [self.lanTableView addTableColumn:bundleColumn];

    NSTableColumn *peerColumn = [[NSTableColumn alloc] initWithIdentifier:@"peerIdentifier"];
    peerColumn.title = @"Peer ID";
    peerColumn.width = 250;
    [self.lanTableView addTableColumn:peerColumn];

    NSTableColumn *versionColumn = [[NSTableColumn alloc] initWithIdentifier:@"protocolVersion"];
    versionColumn.title = @"Protocol";
    versionColumn.width = 80;
    [self.lanTableView addTableColumn:versionColumn];

    NSTableColumn *statusColumn = [[NSTableColumn alloc] initWithIdentifier:@"status"];
    statusColumn.title = @"Status";
    statusColumn.width = 110;
    [self.lanTableView addTableColumn:statusColumn];

    NSTableColumn *actionColumn = [[NSTableColumn alloc] initWithIdentifier:@"action"];
    actionColumn.title = @"";
    actionColumn.width = 120;
    [self.lanTableView addTableColumn:actionColumn];

    NSScrollView *logScrollView = [[NSScrollView alloc] init];
    logScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    logScrollView.hasVerticalScroller = YES;
    logScrollView.borderType = NSBezelBorder;
    [contentView addSubview:logScrollView];

    self.logView = [[NSTextView alloc] init];
    self.logView.editable = NO;
    self.logView.font = [NSFont monospacedSystemFontOfSize:12 weight:NSFontWeightRegular];
    logScrollView.documentView = self.logView;

    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.topAnchor constraintEqualToAnchor:contentView.topAnchor constant:24],
        [titleLabel.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:24],
        [self.connectionStateButton.centerYAnchor constraintEqualToAnchor:titleLabel.centerYAnchor],
        [self.connectionStateButton.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-24],
        [scanButton.centerYAnchor constraintEqualToAnchor:titleLabel.centerYAnchor],
        [scanButton.trailingAnchor constraintEqualToAnchor:self.connectionStateButton.leadingAnchor constant:-8],
        [self.statusLabel.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:10],
        [self.statusLabel.leadingAnchor constraintEqualToAnchor:titleLabel.leadingAnchor],
        [self.statusLabel.trailingAnchor constraintEqualToAnchor:self.connectionStateButton.trailingAnchor],
        [lanScrollView.topAnchor constraintEqualToAnchor:self.statusLabel.bottomAnchor constant:16],
        [lanScrollView.leadingAnchor constraintEqualToAnchor:titleLabel.leadingAnchor],
        [lanScrollView.trailingAnchor constraintEqualToAnchor:self.connectionStateButton.trailingAnchor],
        [lanScrollView.heightAnchor constraintEqualToConstant:150],
        [logScrollView.topAnchor constraintEqualToAnchor:lanScrollView.bottomAnchor constant:16],
        [logScrollView.leadingAnchor constraintEqualToAnchor:titleLabel.leadingAnchor],
        [logScrollView.trailingAnchor constraintEqualToAnchor:self.connectionStateButton.trailingAnchor],
        [logScrollView.bottomAnchor constraintEqualToAnchor:contentView.bottomAnchor constant:-24]
    ]];

    self.window.contentViewController = viewController;
    [self.window makeKeyAndOrderFront:nil];

    PickViewClient.sharedClient.delegate = self;
    [PickViewClient.sharedClient startScanning];
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

- (void)scanKnownEndpoints {
    [PickViewClient.sharedClient scanNow];
}

- (void)connectSelectedLANEndpoint {
    NSInteger selectedRow = self.lanTableView.selectedRow;
    if (selectedRow < 0 || selectedRow >= (NSInteger)self.lanCellModels.count) {
        return;
    }

    PVLANSessionCellModel *model = self.lanCellModels[(NSUInteger)selectedRow];
    if (model.buttonEnabled) {
        [PickViewClient.sharedClient connectToLANEndpointIdentifier:model.endpointIdentifier];
    }
}

- (BOOL)isSelectedLANEndpointConnected {
    NSInteger selectedRow = self.lanTableView.selectedRow;
    if (selectedRow < 0 || selectedRow >= (NSInteger)self.lanCellModels.count) {
        return NO;
    }

    PVLANSessionCellModel *model = self.lanCellModels[(NSUInteger)selectedRow];
    return [model.endpointIdentifier isEqualToString:self.connectedLANEndpointIdentifier];
}

- (void)updateLANConnectionControls {
    self.connectionStateButton.title = self.connectedLANEndpointIdentifier.length ? @"LAN Connected" : @"LAN Disconnected";
}

- (void)appendLog:(NSString *)line {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *nextLine = [NSString stringWithFormat:@"%@\n", line ?: @""];
        self.logView.string = [self.logView.string stringByAppendingString:nextLine];
        [self.logView scrollRangeToVisible:NSMakeRange(self.logView.string.length, 0)];
    });
}

- (void)reloadLANCellModelsWithClient:(PickViewClient *)client {
    NSMutableArray<PVLANSessionCellModel *> *cellModels = [NSMutableArray array];
    for (PVClientSession *session in client.sessionManager.lanSessions) {
        PVLANSessionCellModel *cellModel = [[PVLANSessionCellModel alloc] initWithSession:session connectedEndpointIdentifier:self.connectedLANEndpointIdentifier];
        [cellModels addObject:cellModel];
    }
    self.lanCellModels = cellModels.copy;

    BOOL stillHasConnectedEndpoint = NO;
    for (PVLANSessionCellModel *cellModel in self.lanCellModels) {
        if ([cellModel.endpointIdentifier isEqualToString:self.connectedLANEndpointIdentifier]) {
            stillHasConnectedEndpoint = YES;
            break;
        }
    }
    if (!stillHasConnectedEndpoint) {
        self.connectedLANEndpointIdentifier = nil;
    }
    if (!self.connectedLANEndpointIdentifier.length) {
        NSMutableArray<PVLANSessionCellModel *> *refreshedCellModels = [NSMutableArray array];
        for (PVLANSessionCellModel *cellModel in self.lanCellModels) {
            PVLANSessionCellModel *refreshedCellModel = [[PVLANSessionCellModel alloc] initWithSession:cellModel.session connectedEndpointIdentifier:self.connectedLANEndpointIdentifier];
            [refreshedCellModels addObject:refreshedCellModel];
        }
        self.lanCellModels = refreshedCellModels.copy;
    }
    [self.lanTableView reloadData];
    [self updateLANConnectionControls];
}

- (NSString *)displayValueForLANCellModel:(PVLANSessionCellModel *)cellModel columnIdentifier:(NSString *)identifier {
    if ([identifier isEqualToString:@"deviceName"]) {
        return cellModel.deviceNameText;
    }
    if ([identifier isEqualToString:@"appName"]) {
        return cellModel.appNameText;
    }
    if ([identifier isEqualToString:@"bundleIdentifier"]) {
        return cellModel.bundleIDText;
    }
    if ([identifier isEqualToString:@"peerIdentifier"]) {
        return cellModel.peerIDText;
    }
    if ([identifier isEqualToString:@"protocolVersion"]) {
        return cellModel.protocolVersionText;
    }
    if ([identifier isEqualToString:@"status"]) {
        return cellModel.statusText;
    }
    return @"";
}

- (void)connectLANButtonClicked:(NSButton *)sender {
    NSInteger row = sender.tag;
    if (row < 0 || row >= (NSInteger)self.lanCellModels.count) {
        return;
    }

    PVLANSessionCellModel *model = self.lanCellModels[(NSUInteger)row];
    if (model.buttonEnabled) {
        [PickViewClient.sharedClient connectToLANEndpointIdentifier:model.endpointIdentifier];
    }
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return (NSInteger)self.lanCellModels.count;
}

#pragma mark - NSTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    PVLANSessionCellModel *cellModel = self.lanCellModels[(NSUInteger)row];
    if ([tableColumn.identifier isEqualToString:@"action"]) {
        NSButton *button = [tableView makeViewWithIdentifier:@"actionButton" owner:self];
        if (!button) {
            button = [NSButton buttonWithTitle:@"" target:self action:@selector(connectLANButtonClicked:)];
            button.identifier = @"actionButton";
            button.bezelStyle = NSBezelStyleRounded;
        }

        button.target = self;
        button.action = @selector(connectLANButtonClicked:);
        button.tag = row;
        button.title = cellModel.buttonTitle;
        button.enabled = cellModel.buttonEnabled;
        return button;
    }

    NSTableCellView *cell = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    if (!cell) {
        cell = [[NSTableCellView alloc] initWithFrame:NSZeroRect];
        cell.identifier = tableColumn.identifier;

        NSTextField *textField = [NSTextField labelWithString:@""];
        textField.translatesAutoresizingMaskIntoConstraints = NO;
        textField.lineBreakMode = NSLineBreakByTruncatingMiddle;
        cell.textField = textField;
        [cell addSubview:textField];

        [NSLayoutConstraint activateConstraints:@[
            [textField.leadingAnchor constraintEqualToAnchor:cell.leadingAnchor constant:8],
            [textField.trailingAnchor constraintEqualToAnchor:cell.trailingAnchor constant:-8],
            [textField.centerYAnchor constraintEqualToAnchor:cell.centerYAnchor]
        ]];
    }

    cell.textField.stringValue = [self displayValueForLANCellModel:cellModel columnIdentifier:tableColumn.identifier];
    return cell;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    [self updateLANConnectionControls];
}

#pragma mark - PickViewClientDelegate

- (void)pickViewClient:(PickViewClient *)client didUpdateStatus:(NSString *)status {
    self.statusLabel.stringValue = status ?: @"";
}

- (void)pickViewClient:(PickViewClient *)client didLogMessage:(NSString *)message {
    [self appendLog:message];
}

- (void)pickViewClient:(PickViewClient *)client didConnectEndpoint:(id<PVEndpointProtocol>)endpoint {
    self.statusLabel.stringValue = [NSString stringWithFormat:@"Connected: %@", endpoint.displayName];
    if ([endpoint isKindOfClass:PVLANEndpoint.class]) {
        self.connectedLANEndpointIdentifier = endpoint.identifier;
        [self updateLANConnectionControls];
        [self reloadLANCellModelsWithClient:client];
    }
}

- (void)pickViewClient:(PickViewClient *)client didDisconnectEndpoint:(id<PVEndpointProtocol>)endpoint reason:(NSString *)reason {
    if ([endpoint.identifier isEqualToString:self.connectedLANEndpointIdentifier]) {
        self.connectedLANEndpointIdentifier = nil;
    }
    self.statusLabel.stringValue = reason.length ? reason : [NSString stringWithFormat:@"Disconnected: %@", endpoint.displayName];
    [self appendLog:self.statusLabel.stringValue];
    [self updateLANConnectionControls];
    [self reloadLANCellModelsWithClient:client];
}

- (void)pickViewClient:(PickViewClient *)client didReceiveEcho:(NSString *)echo fromEndpoint:(id<PVEndpointProtocol>)endpoint {
    [self appendLog:[NSString stringWithFormat:@"received echo from %@: %@", endpoint.displayName, echo ?: @""]];
}

- (void)pickViewClientDidUpdateLANSessions:(PickViewClient *)client {
    [self reloadLANCellModelsWithClient:client];
}

@end

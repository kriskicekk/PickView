//
//  PVWorkspaceViewController.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVWorkspaceViewController.h"

#import "PVSplitView.h"
#import "PVDashboardCardView.h"
#import "PVPreviewSceneView.h"

static CGFloat const PVWorkspaceHierarchyWidth = 350.0;
static CGFloat const PVWorkspaceHierarchyMinWidth = 200.0;
static CGFloat const PVWorkspaceDashboardWidth = 260.0;
static CGFloat const PVWorkspaceSearchHeight = 25.0;

@interface PVWorkspaceViewController () <NSSplitViewDelegate>

@property (nonatomic, strong, readwrite) NSTableView *windowTableView;
@property (nonatomic, strong, readwrite) NSOutlineView *hierarchyOutlineView;
@property (nonatomic, strong, readwrite) PVPreviewSceneView *previewSceneView;
@property (nonatomic, strong, readwrite) NSTextField *detailPreviewLabel;
@property (nonatomic, strong, readwrite) NSMutableDictionary<NSString *, NSTextField *> *inspectorValueLabels;
@property (nonatomic, strong) PVSplitView *mainSplitView;
@property (nonatomic, strong) NSView *splitTopView;

@end

@implementation PVWorkspaceViewController

- (instancetype)init {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _inspectorValueLabels = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)loadView {
    NSView *view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 1000, 700)];
    view.wantsLayer = YES;
    view.layer.backgroundColor = NSColor.controlBackgroundColor.CGColor;
    self.view = view;
    [self buildViews];
}

- (void)buildViews {
    self.mainSplitView = [[PVSplitView alloc] init];
    self.mainSplitView.translatesAutoresizingMaskIntoConstraints = NO;
    self.mainSplitView.arrangesAllSubviews = NO;
    self.mainSplitView.vertical = YES;
    self.mainSplitView.dividerStyle = NSSplitViewDividerStyleThin;
    self.mainSplitView.delegate = self;
    self.mainSplitView.didFinishFirstLayout = ^(PVSplitView *view) {
        CGFloat x = MIN(MAX(PVWorkspaceHierarchyWidth, view.bounds.size.width * 0.3), 700.0);
        [view setPosition:x ofDividerAtIndex:0];
    };
    [self.view addSubview:self.mainSplitView];

    NSView *hierarchyContainerView = [self sidebarContainerView];
    NSView *contentContainerView = [self plainContainerViewWithColor:NSColor.controlBackgroundColor];
    [self.mainSplitView addArrangedSubview:hierarchyContainerView];
    [self.mainSplitView addArrangedSubview:contentContainerView];

    [NSLayoutConstraint activateConstraints:@[
        [self.mainSplitView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.mainSplitView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.mainSplitView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.mainSplitView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [hierarchyContainerView.widthAnchor constraintEqualToConstant:PVWorkspaceHierarchyWidth]
    ]];

    [self buildHierarchyAreaInView:hierarchyContainerView];
    [self buildPreviewAndDashboardInView:contentContainerView];
}

- (void)buildHierarchyAreaInView:(NSView *)containerView {
    self.windowTableView = [[NSTableView alloc] init];
    self.windowTableView.headerView = nil;
    self.windowTableView.rowHeight = 28;

    NSTableColumn *windowTitleColumn = [[NSTableColumn alloc] initWithIdentifier:@"windowTitle"];
    windowTitleColumn.title = @"Window";
    windowTitleColumn.width = PVWorkspaceHierarchyWidth - 28.0;
    [self.windowTableView addTableColumn:windowTitleColumn];

    NSScrollView *hierarchyScrollView = [self borderlessScrollView];
    [containerView addSubview:hierarchyScrollView];

    self.hierarchyOutlineView = [[NSOutlineView alloc] init];
    self.hierarchyOutlineView.headerView = nil;
    self.hierarchyOutlineView.rowHeight = 28;
    if (@available(macOS 11.0, *)) {
        self.hierarchyOutlineView.style = NSTableViewStyleSourceList;
    }
    hierarchyScrollView.documentView = self.hierarchyOutlineView;

    NSTableColumn *hierarchyColumn = [[NSTableColumn alloc] initWithIdentifier:@"hierarchy"];
    hierarchyColumn.title = @"View Tree";
    hierarchyColumn.width = PVWorkspaceHierarchyWidth - 28.0;
    [self.hierarchyOutlineView addTableColumn:hierarchyColumn];
    self.hierarchyOutlineView.outlineTableColumn = hierarchyColumn;

    NSView *searchView = [self hierarchySearchView];
    [containerView addSubview:searchView];

    [NSLayoutConstraint activateConstraints:@[
        [hierarchyScrollView.topAnchor constraintEqualToAnchor:containerView.topAnchor],
        [hierarchyScrollView.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor],
        [hierarchyScrollView.trailingAnchor constraintEqualToAnchor:containerView.trailingAnchor],
        [hierarchyScrollView.bottomAnchor constraintEqualToAnchor:searchView.topAnchor],

        [searchView.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor],
        [searchView.trailingAnchor constraintEqualToAnchor:containerView.trailingAnchor],
        [searchView.bottomAnchor constraintEqualToAnchor:containerView.bottomAnchor],
        [searchView.heightAnchor constraintEqualToConstant:PVWorkspaceSearchHeight]
    ]];
}

- (void)buildPreviewAndDashboardInView:(NSView *)containerView {
    self.splitTopView = [self plainContainerViewWithColor:NSColor.whiteColor];
    [containerView addSubview:self.splitTopView];

    NSView *dashboardView = [self plainContainerViewWithColor:NSColor.windowBackgroundColor];
    dashboardView.wantsLayer = YES;
    dashboardView.layer.borderColor = NSColor.separatorColor.CGColor;
    dashboardView.layer.borderWidth = 1.0;
    [self.splitTopView addSubview:dashboardView];

    self.previewSceneView = [[PVPreviewSceneView alloc] initWithFrame:NSZeroRect];
    self.previewSceneView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.splitTopView addSubview:self.previewSceneView];

    self.detailPreviewLabel = [NSTextField labelWithString:@""];
    self.detailPreviewLabel.hidden = YES;
    self.detailPreviewLabel.font = [NSFont systemFontOfSize:12 weight:NSFontWeightRegular];
    self.detailPreviewLabel.textColor = NSColor.secondaryLabelColor;

    NSView *searchView = [self dashboardSearchView];
    [dashboardView addSubview:searchView];

    NSScrollView *inspectorScrollView = [self borderlessScrollView];
    [dashboardView addSubview:inspectorScrollView];

    NSStackView *inspectorStack = [[NSStackView alloc] init];
    inspectorStack.translatesAutoresizingMaskIntoConstraints = NO;
    inspectorStack.orientation = NSUserInterfaceLayoutOrientationVertical;
    inspectorStack.alignment = NSLayoutAttributeLeading;
    inspectorStack.spacing = 10.0;
    inspectorScrollView.documentView = inspectorStack;

    NSArray<PVDashboardCardView *> *cards = @[
        [[PVDashboardCardView alloc] initWithTitle:@"Class" rows:@[
            @[@"View", @"class"],
            @[@"Layer", @"layer"],
            @[@"Object", @"object"]
        ]],
        [[PVDashboardCardView alloc] initWithTitle:@"Layout" rows:@[
            @[@"Frame", @"frame"],
            @[@"Bounds", @"bounds"]
        ]],
        [[PVDashboardCardView alloc] initWithTitle:@"View / Layer" rows:@[
            @[@"Hidden", @"hidden"],
            @[@"Alpha", @"alpha"]
        ]]
    ];
    for (PVDashboardCardView *card in cards) {
        [inspectorStack addArrangedSubview:card];
        [card.widthAnchor constraintEqualToAnchor:inspectorStack.widthAnchor].active = YES;
    }
    NSArray<NSString *> *keys = @[@"class", @"layer", @"object", @"frame", @"bounds", @"hidden", @"alpha"];
    for (PVDashboardCardView *card in cards) {
        for (NSString *key in keys) {
            NSTextField *label = [card valueLabelForKey:key];
            if (label) {
                self.inspectorValueLabels[key] = label;
            }
        }
    }

    [NSLayoutConstraint activateConstraints:@[
        [self.splitTopView.topAnchor constraintEqualToAnchor:containerView.topAnchor],
        [self.splitTopView.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor],
        [self.splitTopView.trailingAnchor constraintEqualToAnchor:containerView.trailingAnchor],
        [self.splitTopView.bottomAnchor constraintEqualToAnchor:containerView.bottomAnchor],

        [dashboardView.topAnchor constraintEqualToAnchor:self.splitTopView.topAnchor],
        [dashboardView.trailingAnchor constraintEqualToAnchor:self.splitTopView.trailingAnchor],
        [dashboardView.bottomAnchor constraintEqualToAnchor:self.splitTopView.bottomAnchor],
        [dashboardView.widthAnchor constraintEqualToConstant:PVWorkspaceDashboardWidth],

        [self.previewSceneView.topAnchor constraintEqualToAnchor:self.splitTopView.topAnchor],
        [self.previewSceneView.leadingAnchor constraintEqualToAnchor:self.splitTopView.leadingAnchor],
        [self.previewSceneView.trailingAnchor constraintEqualToAnchor:self.splitTopView.trailingAnchor],
        [self.previewSceneView.bottomAnchor constraintEqualToAnchor:self.splitTopView.bottomAnchor],

        [searchView.topAnchor constraintEqualToAnchor:dashboardView.topAnchor constant:12],
        [searchView.leadingAnchor constraintEqualToAnchor:dashboardView.leadingAnchor constant:12],
        [searchView.trailingAnchor constraintEqualToAnchor:dashboardView.trailingAnchor constant:-12],
        [searchView.heightAnchor constraintEqualToConstant:32],

        [inspectorScrollView.topAnchor constraintEqualToAnchor:searchView.bottomAnchor constant:12],
        [inspectorScrollView.leadingAnchor constraintEqualToAnchor:dashboardView.leadingAnchor constant:10],
        [inspectorScrollView.trailingAnchor constraintEqualToAnchor:dashboardView.trailingAnchor constant:-10],
        [inspectorScrollView.bottomAnchor constraintEqualToAnchor:dashboardView.bottomAnchor constant:-14],

        [inspectorStack.topAnchor constraintEqualToAnchor:inspectorScrollView.contentView.topAnchor],
        [inspectorStack.leadingAnchor constraintEqualToAnchor:inspectorScrollView.contentView.leadingAnchor],
        [inspectorStack.trailingAnchor constraintEqualToAnchor:inspectorScrollView.contentView.trailingAnchor],
        [inspectorStack.widthAnchor constraintEqualToAnchor:inspectorScrollView.contentView.widthAnchor]
    ]];
}

- (NSView *)plainContainerViewWithColor:(NSColor *)color {
    NSView *view = [[NSView alloc] init];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    view.wantsLayer = YES;
    view.layer.backgroundColor = color.CGColor;
    return view;
}

- (NSView *)sidebarContainerView {
    NSVisualEffectView *view = [[NSVisualEffectView alloc] init];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    view.material = NSVisualEffectMaterialSidebar;
    view.blendingMode = NSVisualEffectBlendingModeWithinWindow;
    view.state = NSVisualEffectStateActive;
    return view;
}

- (NSScrollView *)borderlessScrollView {
    NSScrollView *scrollView = [[NSScrollView alloc] init];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    scrollView.hasVerticalScroller = YES;
    scrollView.borderType = NSNoBorder;
    return scrollView;
}

- (NSTextField *)sidebarLabelWithTitle:(NSString *)title {
    NSTextField *label = [NSTextField labelWithString:title ?: @""];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.font = [NSFont systemFontOfSize:11 weight:NSFontWeightSemibold];
    label.textColor = NSColor.secondaryLabelColor;
    return label;
}

- (NSView *)hierarchySearchView {
    NSView *view = [[NSView alloc] init];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    view.wantsLayer = YES;
    view.layer.borderWidth = 1.0;
    view.layer.borderColor = NSColor.separatorColor.CGColor;

    NSImageView *iconView = [[NSImageView alloc] init];
    iconView.translatesAutoresizingMaskIntoConstraints = NO;
    iconView.image = [NSImage imageNamed:@"icon_search"];
    iconView.contentTintColor = NSColor.secondaryLabelColor;
    [view addSubview:iconView];

    NSTextField *textField = [NSTextField labelWithString:@"Filter"];
    textField.translatesAutoresizingMaskIntoConstraints = NO;
    textField.font = [NSFont systemFontOfSize:13.0 weight:NSFontWeightRegular];
    textField.textColor = NSColor.secondaryLabelColor;
    [view addSubview:textField];

    [NSLayoutConstraint activateConstraints:@[
        [iconView.leadingAnchor constraintEqualToAnchor:view.leadingAnchor constant:10.0],
        [iconView.centerYAnchor constraintEqualToAnchor:view.centerYAnchor],
        [iconView.widthAnchor constraintEqualToConstant:14.0],
        [iconView.heightAnchor constraintEqualToConstant:14.0],

        [textField.leadingAnchor constraintEqualToAnchor:iconView.trailingAnchor constant:7.0],
        [textField.trailingAnchor constraintEqualToAnchor:view.trailingAnchor constant:-10.0],
        [textField.centerYAnchor constraintEqualToAnchor:view.centerYAnchor]
    ]];

    return view;
}

- (NSView *)dashboardSearchView {
    NSView *view = [[NSView alloc] init];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    view.wantsLayer = YES;
    view.layer.cornerRadius = 6.0;
    view.layer.borderWidth = 1.0;
    view.layer.borderColor = NSColor.separatorColor.CGColor;

    NSImageView *iconView = [[NSImageView alloc] init];
    iconView.translatesAutoresizingMaskIntoConstraints = NO;
    iconView.image = [NSImage imageNamed:@"icon_search"];
    iconView.contentTintColor = NSColor.secondaryLabelColor;
    [view addSubview:iconView];

    NSTextField *textField = [NSTextField labelWithString:@"properties or methods"];
    textField.translatesAutoresizingMaskIntoConstraints = NO;
    textField.font = [NSFont systemFontOfSize:13.0 weight:NSFontWeightRegular];
    textField.textColor = NSColor.secondaryLabelColor;
    [view addSubview:textField];

    NSButton *addButton = [NSButton buttonWithImage:[NSImage imageNamed:NSImageNameAddTemplate] target:nil action:nil];
    addButton.translatesAutoresizingMaskIntoConstraints = NO;
    addButton.bezelStyle = NSBezelStyleTexturedRounded;
    addButton.enabled = NO;
    [view addSubview:addButton];

    [NSLayoutConstraint activateConstraints:@[
        [iconView.leadingAnchor constraintEqualToAnchor:view.leadingAnchor constant:12.0],
        [iconView.centerYAnchor constraintEqualToAnchor:view.centerYAnchor],
        [iconView.widthAnchor constraintEqualToConstant:15.0],
        [iconView.heightAnchor constraintEqualToConstant:15.0],

        [textField.leadingAnchor constraintEqualToAnchor:iconView.trailingAnchor constant:8.0],
        [textField.centerYAnchor constraintEqualToAnchor:view.centerYAnchor],
        [textField.trailingAnchor constraintLessThanOrEqualToAnchor:addButton.leadingAnchor constant:-8.0],

        [addButton.trailingAnchor constraintEqualToAnchor:view.trailingAnchor constant:-3.0],
        [addButton.centerYAnchor constraintEqualToAnchor:view.centerYAnchor],
        [addButton.widthAnchor constraintEqualToConstant:42.0]
    ]];

    return view;
}

- (void)setWindowListHidden:(BOOL)hidden {
}

#pragma mark - NSSplitViewDelegate

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview {
    return NO;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex {
    return PVWorkspaceHierarchyMinWidth;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex {
    return MAX(splitView.bounds.size.width - PVWorkspaceDashboardWidth - 100.0, PVWorkspaceHierarchyMinWidth);
}

@end

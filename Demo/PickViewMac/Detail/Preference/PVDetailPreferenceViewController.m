//
//  PVDetailPreferenceViewController.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailPreferenceViewController.h"
#import "PVDetailPreferenceManager.h"
#import "PVDetailPreferenceSwitchView.h"
#import "PVDetailPreferencePopupView.h"
#import "PVDetailNavigationManager.h"
#import "PVDetailMessageManager.h"

@interface PVDetailPreferenceViewController ()

@property(nonatomic, strong) PVDetailPreferencePopupView *view_doubleClick;
@property(nonatomic, strong) PVDetailPreferencePopupView *view_appearance;
@property(nonatomic, strong) PVDetailPreferencePopupView *view_colorFormat;
@property(nonatomic, strong) PVDetailPreferenceSwitchView *view_enableLog;
@property(nonatomic, strong) PVDetailPreferencePopupView *view_contrast;

//@property(nonatomic, strong) NSButton *debugButton;
@property(nonatomic, strong) NSButton *resetButton;

@end

@implementation PVDetailPreferenceViewController

- (void)setView:(NSView *)view {
    [super setView:view];
    
    CGFloat controlX = IsEnglish ? 94 : 84;
    
//    PVDetailPreferenceManager *manager = [PVDetailPreferenceManager mainManager];
//    
//    @weakify(self);
    self.view_colorFormat = [[PVDetailPreferencePopupView alloc] initWithTitle:NSLocalizedString(@"Color Format", nil) messages:@[NSLocalizedString(@"Color will be displayed in format like (255, 12, 34, 0.5). Alpha value is between 0 and 1.", nil), NSLocalizedString(@"Color will be displayed in format like #7e7e7eff. The components are #RRGGBBAA.", nil)] options:@[@"RGBA", @"HEX"]];
    self.view_colorFormat.buttonX = controlX;
    self.view_colorFormat.didChange = ^(NSUInteger selectedIndex) {
        [PVDetailPreferenceManager mainManager].rgbaFormat = (selectedIndex == 0 ? YES : NO);
    };
    [self.view addSubview:self.view_colorFormat];
    
    NSString *contrastTips = NSLocalizedString(@"Adjust this option to use a deeper layer selection color.", nil);
    self.view_contrast = [[PVDetailPreferencePopupView alloc] initWithTitle:NSLocalizedString(@"Image contrast", nil) messages:@[contrastTips, contrastTips, contrastTips] options:@[NSLocalizedString(@"Normal", nil), NSLocalizedString(@"Medium", nil), NSLocalizedString(@"High", nil)]];
    self.view_contrast.buttonX = controlX;
    self.view_contrast.didChange = ^(NSUInteger selectedIndex) {
        [PVDetailPreferenceManager mainManager].imageContrastLevel = selectedIndex;
    };
    [self.view addSubview:self.view_contrast];
    
    self.view_appearance = [[PVDetailPreferencePopupView alloc] initWithTitle:NSLocalizedString(@"Appearance", nil) message:nil options:@[NSLocalizedString(@"Dark Mode", nil), NSLocalizedString(@"Light Mode", nil), NSLocalizedString(@"System Default", nil)]];
    self.view_appearance.buttonX = controlX;
    self.view_appearance.didChange = ^(NSUInteger selectedIndex) {
        [PVDetailPreferenceManager mainManager].appearanceType = selectedIndex;
    };
    [self.view addSubview:self.view_appearance];
    
    self.view_doubleClick = [[PVDetailPreferencePopupView alloc] initWithTitle:NSLocalizedString(@"Double click", nil) message:nil options:@[NSLocalizedString(@"Expand or collapse layer", nil), NSLocalizedString(@"Focus on layer", nil)]];
    self.view_doubleClick.buttonX = controlX;
    self.view_doubleClick.didChange = ^(NSUInteger selectedIndex) {
        [PVDetailPreferenceManager mainManager].doubleClickBehavior = selectedIndex;
    };
    [self.view addSubview:self.view_doubleClick];
    
    self.view_enableLog = [[PVDetailPreferenceSwitchView alloc] initWithTitle:NSLocalizedString(@"Share analytics with PickView", nil) message:NSLocalizedString(@"Help to improve PickView by automatically sending diagnostics and usage data.", nil)];
    self.view_enableLog.didChange = ^(BOOL isChecked) {
        [PVDetailPreferenceManager mainManager].enableReport = isChecked;
    };
    [self.view addSubview:self.view_enableLog];
    
//    self.debugButton = [NSButton lk_normalButtonWithTitle:@"Debug" target:self action:@selector(_handleDebugButton)];
//    [self.view addSubview:self.debugButton];
    
    self.resetButton = [NSButton lk_normalButtonWithTitle:NSLocalizedString(@"Reset", nil) target:self action:@selector(_handleResetButton)];
    [self.view addSubview:self.resetButton];
    
    [self renderFromPreferenceManager];
}

- (void)renderFromPreferenceManager {
    PVDetailPreferenceManager *manager = [PVDetailPreferenceManager mainManager];
    
    if (manager.rgbaFormat) {
        self.view_colorFormat.selectedIndex = 0;
    } else {
        self.view_colorFormat.selectedIndex = 1;
    }
    
    self.view_contrast.selectedIndex = manager.imageContrastLevel;

    self.view_appearance.selectedIndex = manager.appearanceType;
    self.view_doubleClick.selectedIndex = manager.doubleClickBehavior;
    self.view_enableLog.isChecked = manager.enableReport;
}

- (void)viewDidLayout {
    [super viewDidLayout];
    
    NSEdgeInsets insets = NSEdgeInsetsMake(20, 30, 10, 30);
    
    $(self.view_appearance).x(insets.left).toRight(insets.right).y(insets.top).height(50);

    $(self.view_colorFormat).x(insets.left).toRight(insets.right).y(self.view_appearance.$maxY).height(80);
    $(self.view_contrast).x(insets.left).toRight(insets.right).y(self.view_colorFormat.$maxY).height(65);
    
    $(self.view_doubleClick).x(insets.left).toRight(insets.right).y(self.view_contrast.$maxY).height(50);
    
    __block CGFloat y = self.view_doubleClick.$maxY;
    [$(self.view_enableLog).array enumerateObjectsUsingBlock:^(NSView *  _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        $(view).x(115).toRight(insets.right).y(y).heightToFit;
        y = view.$maxY + 5;
    }];
    
    $(self.resetButton).width(120).bottom(insets.bottom).right(insets.right);
//    $(self.debugButton).bottom(insets.bottom).maxX(self.resetButton.$x - 15);
}

- (void)_handleResetButton {
    PVDetailPreferenceManager *manager = [PVDetailPreferenceManager mainManager];
    manager.appearanceType = PVPreferredAppearanceTypeSystem;
    manager.enableReport = YES;
    manager.rgbaFormat = YES;
    manager.doubleClickBehavior = PVDoubleClickBehaviorCollapse;
    manager.imageContrastLevel = 0;
    [self renderFromPreferenceManager];
    
#if DEBUG
    [[PVDetailMessageManager sharedInstance] reset];
    [[PVDetailPreferenceManager mainManager] reset];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IgnoreFastModeTips"];
#endif
}

- (void)_handleDebugButton {
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

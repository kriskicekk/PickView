//
//  PVDetailLaunchViewController.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailLaunchViewController.h"
#import "PVDetailLaunchAppView.h"
#import "PVDetailProgressIndicatorView.h"
#import "PVDetailStaticHierarchyDataSource.h"
#import "PVDetailAppsManager.h"
#import "PVHierarchyInfo.h"
#import "PVDetailNavigationManager.h"
#import "PVDetailPreferenceManager.h"
#import "PVDetailTextControl.h"
#import "PVDetailPerformanceReporter.h"

@interface PVDetailLaunchViewController () <NSGestureRecognizerDelegate>

@property(nonatomic, weak) NSWindow *window;
@property(nonatomic, copy) NSArray<PVDetailLaunchAppView *> *appViews;
@property(nonatomic, strong) PVDetailProgressIndicatorView *bottomIndicatorView;
@property(nonatomic, strong) NSProgressIndicator *reloadingIndicator;
@property(nonatomic, strong) PVDetailLabel *noAppsTitleLabel;
@property(nonatomic, strong) PVDetailTextControl *tutorialControl;
@property(nonatomic, copy) void (^crashBlock)(void);

@property(nonatomic, assign) BOOL isEnteringApp;

@property(nonatomic, copy) NSArray<PVAppInfo *> *appInfos;

@end

@implementation PVDetailLaunchViewController {
    CGFloat _appViewInterSpace;
    CGFloat _contentHorInset;
    CGFloat _contentHeight;
}

- (instancetype)initWithWindow:(NSWindow *)window {
    self.window = window;
    return [self init];
}

- (NSView *)makeContainerView {
    _appViewInterSpace = 10;
    _contentHeight = 400;
    _contentHorInset = 30;
    
    PVDetailVisualEffectView *containerView = [PVDetailVisualEffectView new];
    containerView.blendingMode = NSVisualEffectBlendingModeBehindWindow;
    containerView.state = NSVisualEffectStateActive;
    
    self.appViews = [NSArray array];
    
    self.tutorialControl = [PVDetailTextControl new];
    self.tutorialControl.layer.cornerRadius = 4;
    self.tutorialControl.label.stringValue = NSLocalizedString(@"Can't see your app ?", nil);
    self.tutorialControl.label.textColor = [NSColor linkColor];
    self.tutorialControl.label.font = NSFontMake(12);
    self.tutorialControl.adjustAlphaWhenClick = YES;
    [self.tutorialControl addTarget:self clickAction:@selector(_handleTutorial)];
    [containerView addSubview:self.tutorialControl];
    
    self.bottomIndicatorView = [PVDetailProgressIndicatorView new];
    [containerView addSubview:self.bottomIndicatorView];
    
    [self.bottomIndicatorView animateToProgress:.7 duration:0.5];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 延时一下，因为如果有 USB 设备被连接，则需要一定时间来使 ConnectionManager 检测到，这个时间实际实验大概 0.1 秒，这里稍微宽裕一点给个 0.2 秒
        [self _reloadWithAutoEntering:YES];
    });
    
    return containerView;
}

- (void)viewDidLayout {
    [super viewDidLayout];
    
    if (self.reloadingIndicator && self.noAppsTitleLabel) {
        [self.reloadingIndicator sizeToFit];
        $(self.noAppsTitleLabel).sizeToFit.x(self.reloadingIndicator.$maxX + 5).midY(self.reloadingIndicator.$midY);
        $(self.reloadingIndicator, self.noAppsTitleLabel).groupHorAlign.midY(self.view.$height * .35);
    }

    $(self.tutorialControl).sizeToFit.horAlign.offsetX(3).bottom(14);
    
    __block CGFloat posX = _contentHorInset;
    [self.appViews enumerateObjectsUsingBlock:^(PVDetailLaunchAppView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        $(obj).sizeToFit.x(posX).y(30);
        posX = obj.$maxX + self->_appViewInterSpace;
    }];
    
    $(_bottomIndicatorView).fullWidth.height(3).bottom(0);
}

#pragma mark - Others

- (void)_reloadWithAutoEntering:(BOOL)autoEnter {
    if (self.isEnteringApp) {
        return;
    }
    
    @weakify(self);
    [[[[PVDetailAppsManager sharedInstance] fetchAppInfosWithImage:YES localInfos:self.appInfos] deliverOnMainThread] subscribeNext:^(NSArray<PVDetailInspectableApp *> *apps) {
        @strongify(self);
        
        self.appInfos = [apps pv_inspect_map:^id(NSUInteger idx, PVDetailInspectableApp *value) {
            return value.appInfo;
        }];
        
        if (autoEnter && apps.count == 1 && !apps.firstObject.serverVersionError) {
            // 进入页面时自动触发的 refetch，并且只有一个 app，则自动拉取 hierarchy
            [self _renderWithApps:apps];
            [self _enterApp:apps.firstObject];

        } else {
            if (self.bottomIndicatorView.progress > 0) {
                [self.bottomIndicatorView finishWithCompletion:nil];
            }

            [self _renderWithApps:apps];

            // 每 1.5 秒刷新一次
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self _reloadWithAutoEntering:NO];
            });
        }
    }];
}

- (void)_handleClickAppView:(PVDetailLaunchAppView *)view {
    if (self.isEnteringApp) {
        return;
    }
    if (view.app.serverVersionError) {
        if (view.app.serverVersionError.code == PVInspectErrCode_ServerVersionTooLow) {
            [PVDetailHelper openPickViewWebsiteWithPath:@"faq/server-version-too-low/"];
        } else {
            [PVDetailHelper openPickViewWebsiteWithPath:@"faq/server-version-too-high/"];
        }
        
    } else {
        [self.bottomIndicatorView animateToProgress:.8 duration:1];
        
        PVDetailInspectableApp *app = view.app;
        [self _enterApp:app];
    }
}

- (void)_renderWithApps:(NSArray<PVDetailInspectableApp *> *)apps {
    if (!apps || apps.count == 0) {
        [self.window setContentSize:NSMakeSize(256, _contentHeight)];
        
        [self showNoAppsView];
        $(self.appViews).hide;
        
    } else {
        __block CGFloat windowWidth = _contentHorInset * 2 + (apps.count - 1) * _appViewInterSpace;
        self.appViews = [self.appViews pv_inspect_resizeWithCount:apps.count add:^PVDetailLaunchAppView *(NSUInteger idx) {
            PVDetailLaunchAppView *view = [PVDetailLaunchAppView new];
            [self.view addSubview:view];
            return view;
        } remove:^(NSUInteger idx, PVDetailLaunchAppView *obj) {
            [obj removeFromSuperview];
        } doNext:^(NSUInteger idx, PVDetailLaunchAppView *obj) {
            obj.app = apps[idx];
            [obj addTarget:self clickAction:@selector(_handleClickAppView:)];
            windowWidth += [obj sizeThatFits:NSSizeMax].width;
        }];
        $(self.appViews).show;
        
        [self.window setContentSize:NSMakeSize(windowWidth, _contentHeight)];
        
        [self hideNoAppsViews];
    }
    
    [self.view setNeedsLayout:YES];
}

- (void)_enterApp:(PVDetailInspectableApp *)app {
    if (self.isEnteringApp) {
        return;
    }
    self.isEnteringApp = YES;
    
    [PVDetailPerformanceReporter.sharedInstance willStartReload];
    
    @weakify(self);
    [[app fetchHierarchyData] subscribeNext:^(PVHierarchyInfo *info) {
        @strongify(self);
        
        if (!info) {
            [self _handleEnterAppFailWithError:PVInspectErr_Inner];
        } else {
            [PVDetailAppsManager sharedInstance].inspectingApp = app;
            [[PVDetailStaticHierarchyDataSource sharedInstance] reloadWithHierarchyInfo:info keepState:NO];
            
            [self.bottomIndicatorView finishWithCompletion:^{
                [[PVDetailNavigationManager sharedInstance] showStaticWorkspace];
                [[PVDetailNavigationManager sharedInstance] closeLaunch];
            }];
        }
        
        [PVDetailPerformanceReporter.sharedInstance didFetchHierarchy];
        
    } error:^(NSError * _Nullable error) {
        @strongify(self);
        [self _handleEnterAppFailWithError:error];
    }];
}

- (void)_handleEnterAppFailWithError:(NSError *)error {
    self.isEnteringApp = NO;
    [self.bottomIndicatorView resetToZero];
    [[NSAlert alertWithError:error] beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
        [self _reloadWithAutoEntering:NO];
    }];
}

- (void)showNoAppsView {
    if (!self.noAppsTitleLabel) {
        self.noAppsTitleLabel = [[PVDetailLabel alloc] init];
        self.noAppsTitleLabel.textColor = [NSColor labelColor];
        self.noAppsTitleLabel.font = NSFontMake(14);
        self.noAppsTitleLabel.stringValue = NSLocalizedString(@"Searching for inspectable apps", nil);
        [self.view addSubview:self.noAppsTitleLabel];
    }
    if (!self.reloadingIndicator) {
        self.reloadingIndicator = [NSProgressIndicator new];
        self.reloadingIndicator.indeterminate = YES;
        self.reloadingIndicator.style = NSProgressIndicatorStyleSpinning;
        self.reloadingIndicator.controlSize = NSControlSizeSmall;
        [self.view addSubview:self.reloadingIndicator];
        [self.reloadingIndicator startAnimation:self];
    }
    [self.view setNeedsLayout:YES];
}

- (void)hideNoAppsViews {
    [_noAppsTitleLabel removeFromSuperview];
    _noAppsTitleLabel = nil;
    
    [self.reloadingIndicator removeFromSuperview];
    self.reloadingIndicator = nil;
}

- (void)_handleTutorial {
    [PVDetailHelper openPickViewWebsiteWithPath:@"faq/cannot-see/"];
}

@end

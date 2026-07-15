//
//  PVDetailBaseViewController.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailBaseViewController.h"
#import "PVDetailWindowController.h"
#import "PVDetailTipsView.h"
#import "PVDetailAppsManager.h"
#import "PVDetailNavigationManager.h"
#import "PVDetailStaticWindowController.h"

@interface PVDetailBaseViewController ()

@end

@implementation PVDetailBaseViewController

- (instancetype)initWithContainerView:(NSView *)view {
    if (self = [super initWithNibName:nil bundle:nil]) {
        if (!view) {
            view = [self makeContainerView];
        }
        self.view = view;
    }
    return self;
}

- (instancetype)initWithNibName:(NSNibName)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithContainerView:nil];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    return [self initWithContainerView:nil];
}

- (void)viewDidAppear {
    [super viewDidAppear];
    _isViewAppeared = YES;
}

- (void)setView:(NSView *)view {
    [super setView:view];
    if (self.shouldShowConnectionTips) {
        _connectionTipsView = [PVDetailRedTipsView new];
        self.connectionTipsView.hidden = YES;
        self.connectionTipsView.title = NSLocalizedString(@"Reconnecting…", nil);
        self.connectionTipsView.buttonText = NSLocalizedString(@"Change App", nil);
        self.connectionTipsView.target = self;
        self.connectionTipsView.clickAction = @selector(_handleClickReconnectTips);
        
        @weakify(self);
        [RACObserve([PVDetailAppsManager sharedInstance], inspectingApp) subscribeNext:^(PVDetailInspectableApp *app) {
            @strongify(self);
            if (app) {
                [self.connectionTipsView endAnimation];
                self.connectionTipsView.hidden = YES;
                [self.connectionTipsView setImageByDeviceType:app.appInfo.deviceType];
                
            } else {
                if (!self.connectionTipsView.superview) {
                    [view addSubview:self.connectionTipsView];
                }
                self.connectionTipsView.hidden = NO;
                [self.connectionTipsView startAnimation];
                
                [self.view setNeedsLayout:YES];
            }
        }];
    }
}

- (void)viewDidLayout {
    [super viewDidLayout];
    if (self.connectionTipsView.isVisible) {
        CGFloat windowTitleHeight = [PVDetailNavigationManager sharedInstance].windowTitleBarHeight;
        $(self.connectionTipsView).sizeToFit.horAlign.y(windowTitleHeight + 10);
    }
}

- (void)_handleClickReconnectTips {
    NSWindowController *wc = self.view.window.windowController;
    PVDetailStaticWindowController *staticWc = [PVDetailNavigationManager sharedInstance].staticWindowController;
    
    if (wc == staticWc) {
        [staticWc popupAllInspectableAppsWithSource:MenuPopoverAppsListControllerEventSourceNoConnectionTips];

    } else if (staticWc) {
        [staticWc showWindow:self];
        [staticWc popupAllInspectableAppsWithSource:MenuPopoverAppsListControllerEventSourceNoConnectionTips];
        
    } else {
        NSAssert(NO, @"");
    }
}

- (void)dealloc {
    NSLog(@"%@ dealloc", self.class);
}

@end

@implementation PVDetailBaseViewController (NSSubclassingHooks)

- (NSView *)makeContainerView {
    return [[PVDetailBaseView alloc] init];
}

- (BOOL)shouldShowConnectionTips {
    return NO;
}

@end

//
//  PVDetailReadViewController.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailReadViewController.h"
#import "PVDetailSplitView.h"
#import "PVDetailDashboardViewController.h"
#import "PVDetailReadHierarchyController.h"
#import "PVDetailReadHierarchyDataSource.h"
#import "PVHierarchyFile.h"
#import "PVDetailPreviewController.h"
#import "PVDetailTipsView.h"
#import "PVDetailReadWindowController.h"
#import "PVHierarchyFile.h"
#import "PVHierarchyInfo.h"
#import "PVDetailPreferenceManager.h"
#import "PVDetailNavigationManager.h"
#import "PVDetailMeasureController.h"
#import "PVDetailFlutterViewController.h"
#import "PVDisplayItem.h"

@interface PVDetailReadViewController () <NSSplitViewDelegate>

@property(nonatomic, strong) PVDetailSplitView *splitView;
@property(nonatomic, strong) NSView *splitLeftView;
@property(nonatomic, strong) NSView *splitRightView;

@property(nonatomic, strong) PVDetailDashboardViewController *dashboardController;
@property(nonatomic, strong) PVDetailReadHierarchyController *hierarchyController;
@property(nonatomic, strong) PVDetailPreviewController *previewController;
@property(nonatomic, strong) PVDetailMeasureController *measureController;
@property(nonatomic, strong) PVDetailFlutterViewController *flutterController;
@property(nonatomic, strong) PVDetailYellowTipsView *focusTipView;

@end

@implementation PVDetailReadViewController

- (instancetype)initWithFile:(PVHierarchyFile *)file preferenceManager:(PVDetailPreferenceManager *)manager {
    if (self = [self initWithContainerView:nil]) {
        self.hierarchyDataSource = [[PVDetailReadHierarchyDataSource alloc] initWithFile:file preferenceManager:manager];
     
        self.hierarchyController = [[PVDetailReadHierarchyController alloc] initWithDataSource:self.hierarchyDataSource];
        [self addChildViewController:self.hierarchyController];
        self.splitLeftView = self.hierarchyController.view;
        [self.splitView addArrangedSubview:self.splitLeftView];
        
        self.splitRightView = [PVDetailBaseView new];
        [self.splitView addArrangedSubview:self.splitRightView];
        
        self.previewController = [[PVDetailPreviewController alloc] initWithDataSource:self.hierarchyDataSource];
        [self.splitRightView addSubview:self.previewController.view];
        [self addChildViewController:self.previewController];
        
        self.dashboardController = [[PVDetailDashboardViewController alloc] initWithReadDataSource:self.hierarchyDataSource];
        [self.splitRightView addSubview:self.dashboardController.view];
        [self addChildViewController:self.dashboardController];

        self.flutterController = [PVDetailFlutterViewController new];
        self.flutterController.view.hidden = YES;
        [self.splitRightView addSubview:self.flutterController.view];
        [self addChildViewController:self.flutterController];
        
        self.measureController = [[PVDetailMeasureController alloc] initWithDataSource:self.hierarchyDataSource];
        self.measureController.view.hidden = YES;
        [self.splitRightView addSubview:self.measureController.view];
        [self addChildViewController:self.measureController];
        
        self.focusTipView = [PVDetailYellowTipsView new];
        self.focusTipView.image = NSImageMake(@"icon_info");
        self.focusTipView.title = NSLocalizedString(@"Currently in focus mode", nil);
        self.focusTipView.hidden = YES;
        self.focusTipView.buttonText = NSLocalizedString(@"Exit", nil);
        self.focusTipView.target = self;
        self.focusTipView.clickAction = @selector(_handleExitFocusTipView);
        [self.view addSubview:self.focusTipView];
        
        [manager.measureState subscribe:self action:@selector(_handleMeasureStateChange:) relatedObject:nil];
        
        @weakify(self);
        [RACObserve(self.hierarchyDataSource, state) subscribeNext:^(NSNumber * _Nullable x) {
            @strongify(self);
            PVDetailHierarchyDataSourceState state = x.unsignedIntegerValue;
            BOOL isFocus = (state == PVDetailHierarchyDataSourceStateFocus);
            self.focusTipView.hidden = !isFocus;
            if (isFocus) {
                [self.focusTipView startAnimation];
            } else {
                [self.focusTipView endAnimation];
            }
            [self.view setNeedsLayout:YES];
        }];
        [RACObserve(self.hierarchyDataSource, selectedItem) subscribeNext:^(PVDisplayItem *item) {
            @strongify(self);
            [self updateDetailControllerForItem:item];
        }];
    }
    return self;
}

- (NSView *)makeContainerView {
    self.splitView = [PVDetailSplitView new];
    self.splitView.didFinishFirstLayout = ^(PVDetailSplitView *view) {
        [view setPosition:350 ofDividerAtIndex:0];
    };
    self.splitView.arrangesAllSubviews = NO;
    self.splitView.vertical = YES;
    self.splitView.dividerStyle = NSSplitViewDividerStyleThin;
    self.splitView.delegate = self;
    return self.splitView;
}

- (void)viewDidLayout {
    [super viewDidLayout];
    $(self.previewController.view).fullFrame;
    $(self.dashboardController.view).width(DashboardViewWidth).right(0).fullHeight;
    CGFloat flutterWidth = MIN(PVFlutterInspectorPanelWidth, NSWidth(self.splitRightView.bounds));
    self.flutterController.view.frame = NSMakeRect(NSWidth(self.splitRightView.bounds) - flutterWidth,
                                                   0,
                                                   flutterWidth,
                                                   NSHeight(self.splitRightView.bounds));
    self.flutterController.view.autoresizingMask = NSViewMinXMargin | NSViewHeightSizable;
    $(self.measureController.view).width(MeasureViewWidth).right(DashboardHorInset).fullHeight;
    [self.splitRightView addSubview:self.dashboardController.view positioned:NSWindowAbove relativeTo:self.previewController.view];
    [self.splitRightView addSubview:self.flutterController.view positioned:NSWindowAbove relativeTo:self.dashboardController.view];
    [self.splitRightView addSubview:self.measureController.view positioned:NSWindowAbove relativeTo:self.flutterController.view];
    
    CGFloat windowTitleHeight = [PVDetailNavigationManager sharedInstance].windowTitleBarHeight;
    __block CGFloat tipsY = windowTitleHeight + 10;
    [$(self.focusTipView).visibles.array enumerateObjectsUsingBlock:^(PVDetailTipsView *tipsView, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat midX = self.hierarchyController.view.$width + (self.previewController.view.$width - DashboardViewWidth) / 2.0;
        $(tipsView).sizeToFit.y(tipsY).midX(midX);
        tipsY = tipsView.$maxY + 5;
    }];
}

- (PVDetailHierarchyView *)currentHierarchyView {
    return self.hierarchyController.hierarchyView;
}

- (void)_handleMeasureStateChange:(PVDetailMsgActionParams *)param {
    PVMeasureState state = param.integerValue;
    BOOL isMeasure = (state != PVMeasureState_no);
    BOOL isFlutter = self.hierarchyDataSource.selectedItem.pv_isFlutterItem;
    self.dashboardController.view.hidden = isMeasure || isFlutter;
    self.flutterController.view.hidden = isMeasure || !isFlutter;
    self.measureController.view.hidden = !isMeasure;
}

- (void)updateDetailControllerForItem:(PVDisplayItem *)item {
    BOOL isFlutter = item.pv_isFlutterItem;
    BOOL isMeasure = self.hierarchyDataSource.preferenceManager.measureState.currentIntegerValue != PVMeasureState_no;
    self.dashboardController.view.hidden = isMeasure || isFlutter;
    self.flutterController.view.hidden = isMeasure || !isFlutter;
    self.flutterController.displayItem = isFlutter ? item : nil;
    if (isFlutter) {
        [self.splitRightView addSubview:self.flutterController.view
                               positioned:NSWindowAbove
                               relativeTo:self.dashboardController.view];
        [self.flutterController.view setNeedsLayout:YES];
        [self.flutterController.view layoutSubtreeIfNeeded];
    }
}

- (void)_handleExitFocusTipView {
    [[self hierarchyDataSource] endFocus];
}

#pragma mark - <NSSplitViewDelegate>

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview {
    return NO;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex {
    return 200;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex {
    return 700;
}

@end

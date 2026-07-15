//
//  PVDetailStaticViewController.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import <Cocoa/Cocoa.h>

@class PVDetailPreviewController, PVDetailProgressIndicatorView, PVDetailHierarchyView;

@interface PVDetailStaticViewController : PVDetailBaseViewController

@property(nonatomic, strong, readonly) PVDetailPreviewController *viewsPreviewController;

@property(nonatomic, strong) PVDetailProgressIndicatorView *progressView;

@property(nonatomic, assign) BOOL showConsole;

/// 获取当前的 hierarchyView
- (PVDetailHierarchyView *)currentHierarchyView;

#pragma mark - Tutorials

- (void)showQuickSelectionTutorialTips;
@property(nonatomic, assign) BOOL isShowingQuickSelectTutorialTips;

- (void)showMoveWithSpaceTutorialTips;
@property(nonatomic, assign) BOOL isShowingMoveWithSpaceTutorialTips;

- (void)showNoPreviewTutorialTips;

- (void)removeTutorialTips;


@end

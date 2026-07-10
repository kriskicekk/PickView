//
//  PVDetailReadWindowController.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailReadWindowController.h"
#import "PVDetailReadViewController.h"
#import "PVDetailWindowToolbarHelper.h"
#import "PVHierarchyFile.h"
#import "PVDetailPreferenceManager.h"
#import "PVDetailReadHierarchyDataSource.h"
#import "PVHierarchyInfo.h"
#import "PVDetailWindow.h"
#import "PVDetailMenuPopoverSettingController.h"
#import "PVDetailTutorialManager.h"
#import "PVDetailPreviewView.h"
#import "PVDetailHierarchyView.h"

@interface PVDetailReadWindowController () <NSToolbarDelegate>

@property(nonatomic, strong) PVDetailReadViewController *viewController;

@property(nonatomic, strong) NSMutableDictionary<NSString *, NSToolbarItem *> *toolbarItemsMap;

@property(nonatomic, strong) PVDetailPreferenceManager *preferenceManager;

@end

@implementation PVDetailReadWindowController

- (instancetype)initWithFile:(PVHierarchyFile *)file {
    NSSize screenSize = [NSScreen mainScreen].frame.size;
    PVDetailWindow *window = [[PVDetailWindow alloc] initWithContentRect:NSMakeRect(0, 0, screenSize.width * .7, screenSize.height * .7) styleMask:NSWindowStyleMaskTitled|NSWindowStyleMaskClosable|NSWindowStyleMaskMiniaturizable|NSWindowStyleMaskResizable|NSWindowStyleMaskFullSizeContentView backing:NSBackingStoreBuffered defer:YES];
    window.tabbingMode = NSWindowTabbingModeDisallowed;
    if (@available(macOS 11.0, *)) {
        window.toolbarStyle = NSWindowToolbarStyleUnified;
    }
    window.minSize = NSMakeSize(800, 500);
    [window center];
    
    if (self = [self initWithWindow:window]) {
        self.preferenceManager = [PVDetailPreferenceManager new];
        _viewController = [[PVDetailReadViewController alloc] initWithFile:file preferenceManager:self.preferenceManager];
        window.contentView = self.viewController.view;
        self.contentViewController = self.viewController;
        
        @weakify(self);
        [RACObserve(self.viewController.hierarchyDataSource, selectedItem) subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            NSButton *measureButton = (NSButton *)self.toolbarItemsMap[PVDetailToolBarIdentifier_Measure].view;
            BOOL canMeasure = !!x;
            measureButton.enabled = canMeasure;
        }];
        
        NSToolbar *toolbar = [[NSToolbar alloc] init];
        toolbar.displayMode = NSToolbarDisplayModeIconAndLabel;
        toolbar.sizeMode = NSToolbarSizeModeRegular;
        toolbar.delegate = self;
        window.toolbar = toolbar;
    }
    return self;
}

#pragma mark - NSToolbarDelegate

- (NSArray<NSToolbarItemIdentifier> *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar {
    return [self toolbarDefaultItemIdentifiers:toolbar];
}

- (NSArray<NSToolbarItemIdentifier> *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {
    return @[PVDetailToolBarIdentifier_AppInReadMode, NSToolbarFlexibleSpaceItemIdentifier, PVDetailToolBarIdentifier_Dimension, PVDetailToolBarIdentifier_Rotation, PVDetailToolBarIdentifier_Setting, NSToolbarFlexibleSpaceItemIdentifier, PVDetailToolBarIdentifier_Scale, NSToolbarFlexibleSpaceItemIdentifier, PVDetailToolBarIdentifier_Measure];
}

- (nullable NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSToolbarItemIdentifier)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
    NSToolbarItem *item = self.toolbarItemsMap[itemIdentifier];
    if (!item) {
        if (!self.toolbarItemsMap) {
            self.toolbarItemsMap = [NSMutableDictionary dictionary];
        }
        if ([itemIdentifier isEqualToString:PVDetailToolBarIdentifier_AppInReadMode]) {
            item = [[PVDetailWindowToolbarHelper sharedInstance] makeAppInReadModeItemWithAppInfo:self.viewController.hierarchyDataSource.rawHierarchyInfo.appInfo];
        } else {
            item = [[PVDetailWindowToolbarHelper sharedInstance] makeToolBarItemWithIdentifier:itemIdentifier preferenceManager:self.preferenceManager];
        }
        self.toolbarItemsMap[itemIdentifier] = item;
        
        if ([item.itemIdentifier isEqualToString:PVDetailToolBarIdentifier_Setting]) {
            item.label = NSLocalizedString(@"View", nil);
            item.target = self;
            item.action = @selector(_handleSetting:);
        } else if ([item.itemIdentifier isEqualToString:PVDetailToolBarIdentifier_Rotation]) {
            item.target = self;
            item.action = @selector(_handleFreeRotation);
        }
    }
    return item;
}
#pragma mark - Event Handler

- (void)_handleSetting:(NSButton *)button {
    NSPopover *popover = [[NSPopover alloc] init];
    popover.behavior = NSPopoverBehaviorTransient;
    popover.animates = NO;
    popover.contentSize = NSMakeSize(IsEnglish ? 270 : 350, 200);
    popover.contentViewController = [[PVDetailMenuPopoverSettingController alloc] initWithPreferenceManager:self.preferenceManager];
    [popover showRelativeToRect:NSMakeRect(0, 0, button.bounds.size.width, button.bounds.size.height) ofView:button preferredEdge:NSRectEdgeMaxY];
}

- (void)_handleFreeRotation {
    PVDetailPreferenceManager *manager = self.preferenceManager;
    BOOL boolValue = manager.freeRotation.currentBOOLValue;
    [manager.freeRotation setBOOLValue:!boolValue ignoreSubscriber:nil];
}

#pragma mark - <PVDetailAppMenuManagerDelegate>

- (void)appMenuManagerDidSelectDimension {
    if (self.preferenceManager.previewDimension.currentIntegerValue == PVPreviewDimension2D) {
        [self.preferenceManager.previewDimension setIntegerValue:PVPreviewDimension3D ignoreSubscriber:nil];
    } else {
        [self.preferenceManager.previewDimension setIntegerValue:PVPreviewDimension2D ignoreSubscriber:nil];
    }
}

- (void)appMenuManagerDidSelectZoomIn {
    PVDetailPreferenceManager *manager = self.preferenceManager;
    double currentScale = manager.previewScale.currentDoubleValue;
    double targetScale = MIN(MAX(currentScale + 0.1, PVPreviewMinScale), PVPreviewMaxScale);
    [manager.previewScale setDoubleValue:targetScale ignoreSubscriber:nil];
}

- (void)appMenuManagerDidSelectZoomOut {
    PVDetailPreferenceManager *manager = self.preferenceManager;
    double currentScale = manager.previewScale.currentDoubleValue;
    double targetScale = MIN(MAX(currentScale - 0.1, PVPreviewMinScale), PVPreviewMaxScale);
    [manager.previewScale setDoubleValue:targetScale ignoreSubscriber:nil];
}

- (void)appMenuManagerDidSelectDecreaseInterspace {
    PVDetailPreferenceManager *manager = self.preferenceManager;
    double currentValue = manager.zInterspace.currentDoubleValue;
    double newValue = currentValue - 0.1;
    newValue = MIN(MAX(newValue, PVPreviewMinZInterspace), PVPreviewMaxZInterspace);
    [manager.zInterspace setDoubleValue:newValue ignoreSubscriber:nil];
}

- (void)appMenuManagerDidSelectIncreaseInterspace {
    PVDetailPreferenceManager *manager = self.preferenceManager;
    double currentValue = manager.zInterspace.currentDoubleValue;
    double newValue = currentValue + 0.1;
    newValue = MIN(MAX(newValue, PVPreviewMinZInterspace), PVPreviewMaxZInterspace);
    [manager.zInterspace setDoubleValue:newValue ignoreSubscriber:nil];
}

- (void)appMenuManagerDidSelectExpansionIndex:(NSUInteger)index {
    [self.viewController.hierarchyDataSource adjustExpansionByIndex:index referenceDict:nil selectedItem:nil];
}

- (void)appMenuManagerDidSelectFilter {
    [[self.viewController currentHierarchyView] activateSearchBar];
}

@end

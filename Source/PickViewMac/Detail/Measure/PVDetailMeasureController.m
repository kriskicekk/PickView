//
//  PVDetailMeasureController.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailAnalytics.h"

#import "PVDetailMeasureController.h"
#import "PVDetailHierarchyDataSource.h"
#import "PVDetailPreferenceManager.h"
#import "PVDisplayItem.h"
#import "PVDetailTextFieldView.h"
#import "PVDetailMeasureTutorialView.h"
#import "PVDetailMeasureResultView.h"
#import "PVDetailNavigationManager.h"
#import "PVDetailPreferenceSwitchView.h"

@interface PVDetailMeasureController ()

@property(nonatomic, strong) PVDetailMeasureTutorialView *tutorialView;
@property(nonatomic, strong) PVDetailMeasureResultView *resultView;
@property(nonatomic, strong) PVDetailHierarchyDataSource *dataSource;
@property(nonatomic, strong) PVDetailLabel *shortcutLabel;
@property(nonatomic, strong) NSButton *lockSwitchButton;

@end

@implementation PVDetailMeasureController

- (instancetype)initWithDataSource:(PVDetailHierarchyDataSource *)dataSource {
    if (self = [self initWithContainerView:nil]) {
        self.dataSource = dataSource;
        
        self.tutorialView = [PVDetailMeasureTutorialView new];
        [self.view addSubview:self.tutorialView];
        
        self.resultView = [PVDetailMeasureResultView new];
        [self.view addSubview:self.resultView];
        
        [dataSource.preferenceManager.measureState subscribe:self action:@selector(_measureStatePropertyDidChange:) relatedObject:nil];
        
        @weakify(self);
        [[RACObserve(dataSource, selectedItem) combineLatestWith:RACObserve(dataSource, hoveredItem)] subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            [self _reRender];
        }];
    }
    return self;
}

- (void)viewDidLayout {
    [super viewDidLayout];
    
    CGFloat titleHeight = [PVDetailNavigationManager sharedInstance].windowTitleBarHeight;
    
    NSView *contentView = nil;
    if (self.tutorialView.isVisible) {
        $(self.tutorialView).fullWidth.heightToFit.verAlign.offsetY(titleHeight / 2.0);
        contentView = self.tutorialView;
    }
    if (self.resultView.isVisible) {
        $(self.resultView).fullWidth.heightToFit.verAlign.offsetY(titleHeight / 2.0);
        contentView = self.resultView;
    }
    if (self.shortcutLabel) {
        $(self.shortcutLabel).sizeToFit.horAlign.y(contentView.$maxY + 5);
    }
    if (self.lockSwitchButton) {
        $(self.lockSwitchButton).sizeToFit.horAlign.y(contentView.$maxY + 5);
    }
}

- (void)_measureStatePropertyDidChange:(PVDetailMsgActionParams *)params {
    self.shortcutLabel.hidden = YES;
    
    PVMeasureState state = params.integerValue;
    switch (state) {
        case PVMeasureState_no:
            self.lockSwitchButton.hidden = YES;
            self.lockSwitchButton.state = NSControlStateValueOff;
            break;
            
        case PVMeasureState_unlocked:
            // 由快捷键触发
            [PVDetailAnalytics trackEvent:@"Start Measure" withProperties:@{@"shortcut":@"YES"}];
            
            if (!self.lockSwitchButton) {
                self.lockSwitchButton = [NSButton new];
                [self.lockSwitchButton setButtonType:NSButtonTypeSwitch];
                self.lockSwitchButton.font = NSFontMake(15);
                self.lockSwitchButton.title = NSLocalizedString(@"Cancel measure after key up.", nil);
                self.lockSwitchButton.target = self;
                self.lockSwitchButton.action = @selector(handleLockSwitchButton);
                [self.view addSubview:self.lockSwitchButton];
            }
            self.lockSwitchButton.state = NSControlStateValueOn;
            self.lockSwitchButton.hidden = NO;
            break;
            
        case PVMeasureState_locked: {
            [PVDetailAnalytics trackEvent:@"Start Measure" withProperties:@{@"shortcut":@"NO"}];
            
            if (!self.shortcutLabel) {
                self.shortcutLabel = [PVDetailLabel new];
                self.shortcutLabel.stringValue = NSLocalizedString(@"shortcut: holding \"option\" key", nil);
                self.shortcutLabel.textColor = [NSColor secondaryLabelColor];
                [self.view addSubview:self.shortcutLabel];
            }
            self.shortcutLabel.hidden = NO;
            break;
        }
    }
    [self _reRender];
}

- (void)_reRender {
    if (self.dataSource.preferenceManager.measureState.currentIntegerValue == PVMeasureState_no) {
        return;
    }
    if (!self.dataSource.selectedItem) {
        return;
    }
    if (!self.dataSource.hoveredItem || (self.dataSource.selectedItem == self.dataSource.hoveredItem)) {
        NSString *format = NSLocalizedString(@"to measure between it and selected %@.", nil);
        NSString *subtitle = [NSString stringWithFormat:format, self.dataSource.selectedItem.title];
        
        self.resultView.hidden = YES;
        self.tutorialView.hidden = NO;
        [self.tutorialView renderWithImage:NSImageMake(@"measure_hover") title:NSLocalizedString(@"Hover on a layer", nil) subtitle:subtitle];
        [self.view setNeedsLayout:YES];
        return;
    }
    
    NSString *sizeInvalidClass = nil;
    NSString *sizeInvalidProperty = nil;
    CGRect selectedItemFrame = [self.dataSource.selectedItem calculateFrameToRoot];
    CGRect hoveredItemFrame = [self.dataSource.hoveredItem calculateFrameToRoot];
    
    if (selectedItemFrame.size.width <= 0) {
        sizeInvalidClass = self.dataSource.selectedItem.title;
        sizeInvalidProperty = @"width";
    } else if (selectedItemFrame.size.height <= 0) {
        sizeInvalidClass = self.dataSource.selectedItem.title;
        sizeInvalidProperty = @"height";
    } else if (hoveredItemFrame.size.width <= 0) {
        sizeInvalidClass = self.dataSource.hoveredItem.title;
        sizeInvalidProperty = @"width";
    } else if (hoveredItemFrame.size.height <= 0) {
        sizeInvalidClass = self.dataSource.hoveredItem.title;
        sizeInvalidProperty = @"height";
    }
    if (sizeInvalidClass || sizeInvalidProperty) {
        NSString *subtitleFormat = NSLocalizedString(@"Selected %@'s %@ is less than or equal to 0.", nil);
        NSString *subtitle = [NSString stringWithFormat:subtitleFormat, sizeInvalidClass, sizeInvalidProperty];
        
        self.resultView.hidden = YES;
        self.tutorialView.hidden = NO;
        [self.tutorialView renderWithImage:NSImageMake(@"measure_info") title:NSLocalizedString(@"Invalid Size", nil) subtitle:subtitle];
        [self.view setNeedsLayout:YES];
        return;
    }
    
    self.tutorialView.hidden = YES;
    self.resultView.hidden = NO;
    [self.resultView renderWithMainRect:selectedItemFrame mainImage:self.dataSource.selectedItem.groupScreenshot referRect:hoveredItemFrame referImage:self.dataSource.hoveredItem.groupScreenshot];
    [self.view setNeedsLayout:YES];
}

- (void)handleLockSwitchButton {
    if (!self.lockSwitchButton) {
        return;
    }
    if (self.lockSwitchButton.state == NSControlStateValueOn) {
        [self.dataSource.preferenceManager.measureState setIntegerValue:PVMeasureState_unlocked ignoreSubscriber:self];
    } else {
        [self.dataSource.preferenceManager.measureState setIntegerValue:PVMeasureState_locked ignoreSubscriber:self];
    }
}

@end

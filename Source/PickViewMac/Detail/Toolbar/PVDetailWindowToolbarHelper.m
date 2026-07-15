//
//  PVDetailWindowToolbarHelper.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailWindowToolbarHelper.h"
#import "PVDetailPreferenceManager.h"
#import "PVDetailMenuPopoverSettingController.h"
#import "PVDetailAppsManager.h"
#import "PVDetailNavigationManager.h"
#import "PVDetailPreviewView.h"
#import "PVDetailWindowToolbarScaleView.h"
#import "PVDetailWindowToolbarAppButton.h"

NSToolbarItemIdentifier const PVDetailToolBarIdentifier_Dimension = @"0";
NSToolbarItemIdentifier const PVDetailToolBarIdentifier_Scale = @"1";
NSToolbarItemIdentifier const PVDetailToolBarIdentifier_Setting = @"2";
NSToolbarItemIdentifier const PVDetailToolBarIdentifier_Reload = @"3";
NSToolbarItemIdentifier const PVDetailToolBarIdentifier_App = @"5";
NSToolbarItemIdentifier const PVDetailToolBarIdentifier_AppInReadMode = @"12";
NSToolbarItemIdentifier const PVDetailToolBarIdentifier_Add = @"13";
NSToolbarItemIdentifier const PVDetailToolBarIdentifier_Remove = @"14";
NSToolbarItemIdentifier const PVDetailToolBarIdentifier_Console = @"15";
NSToolbarItemIdentifier const PVDetailToolBarIdentifier_Rotation = @"16";
NSToolbarItemIdentifier const PVDetailToolBarIdentifier_Measure = @"17";
NSToolbarItemIdentifier const PVDetailToolBarIdentifier_Message = @"18";
NSToolbarItemIdentifier const PVDetailToolBarIdentifier_FastMode = @"19";


static NSString * const Key_BindingPreferenceManager = @"PreferenceManager";
static NSString * const Key_BindingAppInfo = @"AppInfo";

@interface PVDetailWindowToolbarHelper ()

@end

@implementation PVDetailWindowToolbarHelper

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static PVDetailWindowToolbarHelper *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self sharedInstance];
}

- (NSToolbarItem *)makeToolBarItemWithIdentifier:(NSToolbarItemIdentifier)identifier preferenceManager:(PVDetailPreferenceManager *)manager {
    NSAssert(![identifier isEqualToString:PVDetailToolBarIdentifier_AppInReadMode], @"请使用 makeAppInReadModeItemWithAppInfo: 方法");
    
    if ([identifier isEqualToString:PVDetailToolBarIdentifier_Measure]) {
        NSImage *image = NSImageMake(@"icon_measure");
        image.template = YES;
        
        NSButton *button = [NSButton new];
        [button setImage:image];
        button.bezelStyle = NSBezelStyleTexturedRounded;
        [button setButtonType:NSButtonTypePushOnPushOff];
        button.target = self;
        button.action = @selector(_handleToggleMeasureButton:);
        [button pv_inspect_bindObject:manager forKey:@"manager"];
        
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:PVDetailToolBarIdentifier_Measure];
        item.label = NSLocalizedString(@"Measure", nil);
        item.view = button;
        item.minSize = NSMakeSize(48, 34);

        [manager.measureState subscribe:self action:@selector(_handleMeasureStateDidChange:) relatedObject:button sendAtOnce:YES];
        
        return item;
    }
    
    if ([identifier isEqualToString:PVDetailToolBarIdentifier_Rotation]) {
        NSImage *image = NSImageMake(@"icon_rotation");
        image.template = YES;
        
        NSButton *button = [NSButton new];
        [button setImage:image];
        button.bezelStyle = NSBezelStyleTexturedRounded;
        [button setButtonType:NSButtonTypePushOnPushOff];
        
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:PVDetailToolBarIdentifier_Rotation];
        item.label = NSLocalizedString(@"Free Rotation", nil);
        item.view = button;
        item.minSize = NSMakeSize(48, 34);

        [manager.freeRotation subscribe:self action:@selector(_handleFreeRotationDidChange:) relatedObject:button sendAtOnce:YES];
        
        return item;
    }
    
    if ([identifier isEqualToString:PVDetailToolBarIdentifier_Dimension]) {
        NSImage *image_2d = NSImageMake(@"icon_2d");
        image_2d.template = YES;
        NSImage *image_3d = NSImageMake(@"icon_3d");
        image_3d.template = YES;
        
        NSSegmentedControl *control = [NSSegmentedControl segmentedControlWithImages:@[image_2d, image_3d] trackingMode:NSSegmentSwitchTrackingSelectOne target:self action:@selector(_handleDimension:)];
        [control pv_inspect_bindObjectWeakly:manager forKey:Key_BindingPreferenceManager];
        control.segmentDistribution = NSSegmentDistributionFillEqually;
        
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:PVDetailToolBarIdentifier_Dimension];
        item.label = @"2D / 3D";
        item.view = control;
        item.minSize = NSMakeSize(90, 34);

        [manager.previewDimension subscribe:self action:@selector(_handleDimensionDidChange:) relatedObject:control sendAtOnce:YES];

        return item;
    }
    
    if ([identifier isEqualToString:PVDetailToolBarIdentifier_Scale]) {
        double scale = manager.previewScale.currentDoubleValue;
        
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:PVDetailToolBarIdentifier_Scale];
        PVDetailWindowToolbarScaleView *scaleView = [PVDetailWindowToolbarScaleView new];
        scaleView.slider.minValue = PVPreviewMinScale;
        scaleView.slider.maxValue = PVPreviewMaxScale;
        scaleView.slider.doubleValue = scale;
        scaleView.slider.target = self;
        scaleView.slider.action = @selector(_handleScaleSlider:);
        scaleView.increaseButton.target = self;
        scaleView.increaseButton.action = @selector(_handleScaleIncreaseButton:);
        scaleView.decreaseButton.target = self;
        scaleView.decreaseButton.action = @selector(_handleScaleDecreaseButton:);
        [scaleView.slider pv_inspect_bindObjectWeakly:manager forKey:Key_BindingPreferenceManager];
        [scaleView.increaseButton pv_inspect_bindObjectWeakly:manager forKey:Key_BindingPreferenceManager];
        [scaleView.decreaseButton pv_inspect_bindObjectWeakly:manager forKey:Key_BindingPreferenceManager];
        
        item.label = NSLocalizedString(@"Zoom", nil);
        item.view = scaleView;
        item.minSize = NSMakeSize(160, 34);
        
        [manager.previewScale subscribe:self action:@selector(_handlePreviewScaleDidChange:) relatedObject:scaleView.slider sendAtOnce:YES];
        
        return item;
    }
    
    if ([identifier isEqualToString:PVDetailToolBarIdentifier_Setting]) {
        NSImage *image = NSImageMake(@"icon_setting");
        image.template = YES;
        
        NSButton *button = [NSButton new];
        [button setImage:image];
        button.bezelStyle = NSBezelStyleTexturedRounded;
        [button pv_inspect_bindObjectWeakly:manager forKey:Key_BindingPreferenceManager];
        
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:PVDetailToolBarIdentifier_Setting];
        item.view = button;
        item.minSize = NSMakeSize(48, 34);
        return item;
    }
    
    if ([identifier isEqualToString:PVDetailToolBarIdentifier_Reload]) {
        NSImage *image = NSImageMake(@"icon_reload");
        image.template = YES;
        
        NSButton *button = [NSButton new];
        [button setImage:image];
        button.bezelStyle = NSBezelStyleTexturedRounded;
        
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:PVDetailToolBarIdentifier_Reload];
        item.label = NSLocalizedString(@"Reload", nil);
        item.view = button;
        item.minSize = NSMakeSize(68, 34);
        return item;
    }
    
    if ([identifier isEqualToString:PVDetailToolBarIdentifier_App]) {
        PVDetailWindowToolbarAppButton *button = [PVDetailWindowToolbarAppButton new];
        button.bezelStyle = NSBezelStyleTexturedRounded;
        
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:PVDetailToolBarIdentifier_App];
        item.label = NSLocalizedString(@"Select App", nil);
        item.view = button;
        
        [[RACObserve([PVDetailAppsManager sharedInstance], inspectingApp) takeUntil:item.rac_willDeallocSignal] subscribeNext:^(PVDetailInspectableApp *app) {
            button.appInfo = app.appInfo;
            if (app) {
                item.minSize = NSMakeSize(button.bestWidth + 6, 34);
                item.maxSize = item.minSize;
            } else {
                item.minSize = NSMakeSize(42, 34);
                item.maxSize = item.minSize;
            }
        }];
        return item;
    }
    
    if ([identifier isEqualToString:PVDetailToolBarIdentifier_Console]) {
        NSImage *image = NSImageMake(@"icon_console");
        image.template = YES;

        NSButton *button = [NSButton new];
        [button setImage:image];
        button.bezelStyle = NSBezelStyleTexturedRounded;
        [button setButtonType:NSButtonTypePushOnPushOff];
        
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:PVDetailToolBarIdentifier_Console];
        item.label = NSLocalizedString(@"Console", nil);
        item.view = button;
        item.minSize = NSMakeSize(48, 34);
        return item;
    }
    
    if ([identifier isEqualToString:PVDetailToolBarIdentifier_FastMode]) {
        NSImage *image = NSImageMake(@"icon_turbo");
        image.template = YES;

        NSButton *button = [NSButton new];
        [button setImage:image];
        button.bezelStyle = NSBezelStyleTexturedRounded;
        [button setButtonType:NSButtonTypePushOnPushOff];
        
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:PVDetailToolBarIdentifier_FastMode];
        item.label = NSLocalizedString(@"Fast Mode", nil);
        item.view = button;
        item.minSize = NSMakeSize(60, 34);
        
        [manager.fastMode subscribe:self action:@selector(_handleFastModeDidChange:) relatedObject:button sendAtOnce:YES];
        return item;
    }
    
    if ([identifier isEqualToString:PVDetailToolBarIdentifier_Add]) {
        NSImage *image = [NSImage imageNamed:NSImageNameAddTemplate];
        image.template = YES;
        
        NSButton *button = [NSButton new];
        [button setImage:image];
        button.bezelStyle = NSBezelStyleTexturedRounded;
        
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:PVDetailToolBarIdentifier_Add];
        item.view = button;
        item.minSize = NSMakeSize(48, 34);
        return item;
    }
    
    if ([identifier isEqualToString:PVDetailToolBarIdentifier_Remove]) {
        NSImage *image = NSImageMake(@"icon_delete");
        image.template = YES;
        
        NSButton *button = [NSButton new];
        [button setImage:image];
        button.bezelStyle = NSBezelStyleTexturedRounded;
        
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:PVDetailToolBarIdentifier_Remove];
        item.view = button;
        item.minSize = NSMakeSize(48, 34);
        return item;
    }
    
    if ([identifier isEqualToString:PVDetailToolBarIdentifier_Message]) {
        NSImage *image = NSImageMake(@"icon_notification");
        image.template = YES;
        
        NSButton *button = [NSButton new];
        [button setImage:image];
        button.bezelStyle = NSBezelStyleTexturedRounded;
        
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:PVDetailToolBarIdentifier_Message];
        item.view = button;
        item.minSize = NSMakeSize(48, 34);
        return item;
    }
    
    NSAssert(NO, @"");
    return nil;
}

- (NSToolbarItem *)makeAppInReadModeItemWithAppInfo:(PVAppInfo *)appInfo {
    PVDetailWindowToolbarAppButton *button = [PVDetailWindowToolbarAppButton new];
    button.bezelStyle = NSBezelStyleTexturedRounded;
    [button pv_inspect_bindObject:appInfo forKey:Key_BindingAppInfo];
    button.appInfo = appInfo;
    
    NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:PVDetailToolBarIdentifier_AppInReadMode];
    item.label = @"iOS App";
    item.view = button;
    item.minSize = NSMakeSize(button.bestWidth + 6, 34);
    
    item.maxSize = item.minSize;
    return item;
}

- (void)_handleDimension:(NSSegmentedControl *)control {
    PVDetailPreferenceManager *manager = [control pv_inspect_getBindObjectForKey:Key_BindingPreferenceManager];
    NSUInteger index = control.selectedSegment;
    [manager.previewDimension setIntegerValue:index ignoreSubscriber:self];
}

- (void)_handleScaleSlider:(NSSlider *)slider {
    PVDetailPreferenceManager *manager = [slider pv_inspect_getBindObjectForKey:Key_BindingPreferenceManager];
    [manager.previewScale setDoubleValue:slider.doubleValue ignoreSubscriber:self];
}

- (void)_handleScaleIncreaseButton:(NSButton *)button {
    PVDetailPreferenceManager *manager = [button pv_inspect_getBindObjectForKey:Key_BindingPreferenceManager];
    double currentScale = manager.previewScale.currentDoubleValue;
    double targetScale = MIN(MAX(currentScale + 0.1, PVPreviewMinScale), PVPreviewMaxScale);
    [manager.previewScale setDoubleValue:targetScale ignoreSubscriber:nil];
}

- (void)_handleScaleDecreaseButton:(NSButton *)button {
    PVDetailPreferenceManager *manager = [button pv_inspect_getBindObjectForKey:Key_BindingPreferenceManager];
    double currentScale = manager.previewScale.currentDoubleValue;
    double targetScale = MIN(MAX(currentScale - 0.1, PVPreviewMinScale), PVPreviewMaxScale);
    [manager.previewScale setDoubleValue:targetScale ignoreSubscriber:nil];
}

- (void)_handlePreviewScaleDidChange:(PVDetailMsgActionParams *)param {
    NSSlider *slider = param.relatedObject;
    CGFloat scale = param.doubleValue;
    slider.doubleValue = scale;
}

- (void)_handleFastModeDidChange:(PVDetailMsgActionParams *)param {
    NSButton *button = param.relatedObject;
    BOOL boolValue = param.boolValue;
    button.state = boolValue ? NSControlStateValueOn : NSControlStateValueOff;
}

- (void)_handleDimensionDidChange:(PVDetailMsgActionParams *)param {
    PVPreviewDimension newDimension = param.integerValue;
    NSSegmentedControl *control = param.relatedObject;
    control.selectedSegment = newDimension;
}

- (void)_handleFreeRotationDidChange:(PVDetailMsgActionParams *)param {
    NSButton *button = param.relatedObject;
    BOOL boolValue = param.boolValue;
    button.state = boolValue ? NSControlStateValueOn : NSControlStateValueOff;
}

- (void)_handleToggleMeasureButton:(NSButton *)button {
    PVDetailPreferenceManager *manager = [button pv_inspect_getBindObjectForKey:@"manager"];
    PVMeasureState state = ((button.state == NSControlStateValueOn) ? PVMeasureState_locked : PVMeasureState_no);
    [manager.measureState setIntegerValue:state ignoreSubscriber:self];
}

- (void)_handleMeasureStateDidChange:(PVDetailMsgActionParams *)param {
    NSButton *button = param.relatedObject;
    PVMeasureState measureState = param.integerValue;
    button.state = (measureState != PVMeasureState_no);
}

@end

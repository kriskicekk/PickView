//
//  PVDetailPreferenceManager.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailAnalytics.h"

#import "PVDetailPreferenceManager.h"
#import "PVDashboardBlueprint.h"
#import "PVDetailPreviewView.h"
#import "PVDetailTutorialManager.h"

NSString *const NotificationName_DidChangeSectionShowing = @"NotificationName_DidChangeSectionShowing";

NSString *const PVDetailWindowSizeName_Dynamic = @"PVDetailWindowSizeName_Dynamic";
NSString *const PVDetailWindowSizeName_Static = @"PVDetailWindowSizeName_Static";

const CGFloat PVDetailInitialPreviewScale = 0.27;

static NSString * const Key_PreviousClientVersion = @"preVer";
static NSString * const Key_ShowOutline = @"showOutline";
static NSString * const Key_ShowHiddenItems = @"showHiddenItems";
static NSString * const Key_EnableReport = @"enableReport";
static NSString * const Key_RgbaFormat = @"egbaFormat";
static NSString * const Key_ZInterspace = @"zInterspace_v095";
static NSString * const Key_AppearanceType = @"appearanceType";
static NSString * const Key_DoubleClickBehavior = @"doubleClickBehavior";
static NSString * const Key_ExpansionIndex = @"expansionIndex";
static NSString * const Key_ContrastLevel = @"contrastLevel";
static NSString * const Key_SectionsShow = @"ss";
static NSString * const Key_CollapsedGroups = @"collapsedGroups_918";
static NSString * const Key_PreferredExportCompression = @"preferredExportCompression";
static NSString * const Key_CallStackType = @"callStackType";
static NSString * const Key_SyncConsoleTarget = @"syncConsoleTarget";
static NSString * const Key_FreeRotation = @"FreeRotation";
static NSString * const Key_FastMode = @"fastMode";
static NSString * const Key_ReceivingConfigTime_Color = @"ConfigTime_Color";
static NSString * const Key_ReceivingConfigTime_Class = @"ConfigTime_Class";

@interface PVDetailPreferenceManager ()

@property(nonatomic, strong) NSMutableDictionary<PVAttrSectionIdentifier, NSNumber *> *storedSectionShowConfig;

@end

@implementation PVDetailPreferenceManager

+ (instancetype)mainManager {
    static dispatch_once_t onceToken;
    static PVDetailPreferenceManager *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
        instance.shouldStoreToLocal = YES;
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _previewScale = [PVDetailDoubleMsgAttribute attributeWithDouble:PVDetailInitialPreviewScale];
        _previewDimension = [PVDetailIntegerMsgAttribute attributeWithInteger:PVPreviewDimension3D];
        _measureState = [PVDetailIntegerMsgAttribute attributeWithInteger:PVMeasureState_no];
        _isQuickSelecting = [PVDetailBOOLMsgAttribute attributeWithBOOL:NO];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        // 如果本次 PickView 客户端的 version 和上次不同，则该变量会被置为 YES
//        BOOL clientVersionHasChanged = NO;
        NSInteger prevClientVersion = [userDefaults integerForKey:Key_PreviousClientVersion];
        if (prevClientVersion != 1) {
//            clientVersionHasChanged = YES;
            [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:Key_PreviousClientVersion];
        }
        
        NSNumber *obj_showOutline = [userDefaults objectForKey:Key_ShowOutline];
        if (obj_showOutline != nil) {
            _showOutline = [PVDetailBOOLMsgAttribute attributeWithBOOL:[obj_showOutline boolValue]];
        } else {
            _showOutline = [PVDetailBOOLMsgAttribute attributeWithBOOL:YES];
            [userDefaults setObject:@(YES) forKey:Key_ShowOutline];
        }
        [self.showHiddenItems subscribe:self action:@selector(_handleShowOutlineDidChange:) relatedObject:nil];
        
        NSNumber *obj_showHiddenItems = [userDefaults objectForKey:Key_ShowHiddenItems];
        if (obj_showHiddenItems != nil) {
            _showHiddenItems = [PVDetailBOOLMsgAttribute attributeWithBOOL:[obj_showHiddenItems boolValue]];
        } else {
            _showHiddenItems = [PVDetailBOOLMsgAttribute attributeWithBOOL:NO];
            [userDefaults setObject:@(NO) forKey:Key_ShowHiddenItems];
        }
        [self.showHiddenItems subscribe:self action:@selector(_handleShowHiddenItemsChange:) relatedObject:nil];
        
        NSNumber *obj_enableReport = [userDefaults objectForKey:Key_EnableReport];
        if (obj_enableReport != nil) {
            _enableReport = [obj_enableReport boolValue];
        } else {
            _enableReport = YES;
            [userDefaults setObject:@(_enableReport) forKey:Key_EnableReport];
        }
        
        NSNumber *obj_doubleClickBehavior = [userDefaults objectForKey:Key_DoubleClickBehavior];
        if (obj_doubleClickBehavior) {
            _doubleClickBehavior = [obj_doubleClickBehavior intValue];
        } else {
            _doubleClickBehavior = PVDoubleClickBehaviorCollapse;
            [userDefaults setObject:@(_doubleClickBehavior) forKey:Key_DoubleClickBehavior];
        }
        
        NSNumber *obj_rgbaFormat = [userDefaults objectForKey:Key_RgbaFormat];
        if (obj_rgbaFormat != nil) {
            _rgbaFormat = [obj_rgbaFormat boolValue];
        } else {
            _rgbaFormat = YES;
            [userDefaults setObject:@(_rgbaFormat) forKey:Key_RgbaFormat];
        }
        
        double zInterspaceValue;
        NSNumber *obj_zInterspace = [userDefaults objectForKey:Key_ZInterspace];
        if (obj_zInterspace != nil) {
            zInterspaceValue = [obj_zInterspace doubleValue];
        } else {
            /// 默认值为 0.22
            zInterspaceValue = .22;
            [userDefaults setObject:@(zInterspaceValue) forKey:Key_ZInterspace];
        }
        zInterspaceValue = MAX(MIN(zInterspaceValue, PVPreviewMaxZInterspace), PVPreviewMinZInterspace);
        _zInterspace = [PVDetailDoubleMsgAttribute attributeWithDouble:zInterspaceValue];
        [self.zInterspace subscribe:self action:@selector(_handleZInterspaceDidChange:) relatedObject:nil];
        
        NSNumber *obj_appearanceType = [userDefaults objectForKey:Key_AppearanceType];
        if (obj_appearanceType != nil) {
            _appearanceType = [obj_appearanceType integerValue];
        } else {
            _appearanceType = PVPreferredAppearanceTypeSystem;
            [userDefaults setObject:@(_appearanceType) forKey:Key_AppearanceType];
        }
        
        NSNumber *obj_expansionIndex = [userDefaults objectForKey:Key_ExpansionIndex];
        if (obj_expansionIndex != nil) {
            _expansionIndex = [obj_expansionIndex integerValue];
        } else {
            _expansionIndex = 3;
            [userDefaults setObject:@(_expansionIndex) forKey:Key_ExpansionIndex];
        }
        
        NSNumber *obj_contrastLevel = [userDefaults objectForKey:Key_ContrastLevel];
        if (obj_contrastLevel != nil) {
            _imageContrastLevel = [obj_contrastLevel integerValue];
        } else {
            _imageContrastLevel = 0;
            [userDefaults setObject:@(_imageContrastLevel) forKey:Key_ContrastLevel];
        }
        
        NSNumber *obj_syncConsoleTarget = [userDefaults objectForKey:Key_SyncConsoleTarget];
        if (obj_syncConsoleTarget != nil) {
            _syncConsoleTarget = [obj_syncConsoleTarget boolValue];
        } else {
            _syncConsoleTarget = YES;
            [userDefaults setObject:@(_syncConsoleTarget) forKey:Key_SyncConsoleTarget];
        }
        
        NSNumber *obj_freeRotation = [userDefaults objectForKey:Key_FreeRotation];
        if (obj_freeRotation != nil) {
            _freeRotation = [PVDetailBOOLMsgAttribute attributeWithBOOL:obj_freeRotation.boolValue];
        } else {
            _freeRotation = [PVDetailBOOLMsgAttribute attributeWithBOOL:YES];
            [userDefaults setObject:@(_freeRotation.currentBOOLValue) forKey:Key_FreeRotation];
        }
        [self.freeRotation subscribe:self action:@selector(_handleFreeRotationDidChange:) relatedObject:nil];
        
        NSNumber *obj_fastMode = [userDefaults objectForKey:Key_FastMode];
        if (obj_fastMode != nil) {
            _fastMode = [PVDetailBOOLMsgAttribute attributeWithBOOL:obj_fastMode.boolValue];
        } else {
            _fastMode = [PVDetailBOOLMsgAttribute attributeWithBOOL:NO];
            [userDefaults setObject:@(_fastMode.currentBOOLValue) forKey:Key_FastMode];
        }
        [self.fastMode subscribe:self action:@selector(_handleFastModeDidChange:) relatedObject:nil];
        
        self.storedSectionShowConfig = [[userDefaults objectForKey:Key_SectionsShow] mutableCopy];
        if (!self.storedSectionShowConfig) {
            self.storedSectionShowConfig = [NSMutableDictionary dictionary];
        }
        
        _collapsedAttrGroups = [userDefaults objectForKey:Key_CollapsedGroups];
        if (!_collapsedAttrGroups) {
            _collapsedAttrGroups = @[PVAttrGroup_Class];
        }
        
        NSNumber *obj_preferredExportCompression = [userDefaults objectForKey:Key_PreferredExportCompression];
        if (obj_preferredExportCompression != nil) {
            _preferredExportCompression = [obj_preferredExportCompression doubleValue];
        } else {
            /// 这里的默认值需要在 PVDetailExportAccessory.m 里定义的选项里面
            _preferredExportCompression = .5;
            [userDefaults setObject:@(_preferredExportCompression) forKey:Key_PreferredExportCompression];
        }
        
        _receivingConfigTime_Color = [userDefaults doubleForKey:Key_ReceivingConfigTime_Color];
        _receivingConfigTime_Class = [userDefaults doubleForKey:Key_ReceivingConfigTime_Class];
    }
    return self;
}

- (void)_handleShowOutlineDidChange:(PVDetailMsgActionParams *)param {
    if (self.shouldStoreToLocal) {
        [[NSUserDefaults standardUserDefaults] setObject:@(param.boolValue) forKey:Key_ShowOutline];
    }
}

- (void)_handleShowHiddenItemsChange:(PVDetailMsgActionParams *)param {
    if (self.shouldStoreToLocal) {
        [[NSUserDefaults standardUserDefaults] setObject:@(param.boolValue) forKey:Key_ShowHiddenItems];
    }
}

- (void)setEnableReport:(BOOL)enableReport {
    if (_enableReport == enableReport) {
        return;
    }
    _enableReport = enableReport;
    if (self.shouldStoreToLocal) {
        [[NSUserDefaults standardUserDefaults] setObject:@(enableReport) forKey:Key_EnableReport];
    }
    
    PVDetailAppCenter.enabled = enableReport;
}

- (void)setRgbaFormat:(BOOL)rgbaFormat {
    if (_rgbaFormat == rgbaFormat) {
        return;
    }
    _rgbaFormat = rgbaFormat;
    if (self.shouldStoreToLocal) {
        [[NSUserDefaults standardUserDefaults] setObject:@(rgbaFormat) forKey:Key_RgbaFormat];
    }
}

- (void)setDoubleClickBehavior:(PVDoubleClickBehavior)doubleClickBehavior {
    _doubleClickBehavior = doubleClickBehavior;
    if (self.shouldStoreToLocal) {
        [[NSUserDefaults standardUserDefaults] setObject:@(doubleClickBehavior) forKey:Key_DoubleClickBehavior];
    }
}

- (void)setAppearanceType:(PVPreferredAppearanceType)appearanceType {
    if (_appearanceType == appearanceType) {
        return;
    }
    _appearanceType = appearanceType;
    if (self.shouldStoreToLocal) {
        [[NSUserDefaults standardUserDefaults] setObject:@(appearanceType) forKey:Key_AppearanceType];
    }
}

- (void)setExpansionIndex:(NSInteger)expansionIndex {
    if (_expansionIndex == expansionIndex) {
        return;
    }
    _expansionIndex = expansionIndex;
    if (self.shouldStoreToLocal) {
        [[NSUserDefaults standardUserDefaults] setObject:@(expansionIndex) forKey:Key_ExpansionIndex];
    }
}

- (void)setImageContrastLevel:(NSInteger)imageContrastLevel {
    if (_imageContrastLevel == imageContrastLevel) {
        return;
    }
    _imageContrastLevel = imageContrastLevel;
    
    if (self.shouldStoreToLocal) {
        [[NSUserDefaults standardUserDefaults] setObject:@(imageContrastLevel) forKey:Key_ContrastLevel];
    }
}

- (void)setCollapsedAttrGroups:(NSArray<NSNumber *> *)collapsedAttrGroups {
    _collapsedAttrGroups = collapsedAttrGroups.copy;
    if (self.shouldStoreToLocal) {
        [[NSUserDefaults standardUserDefaults] setObject:collapsedAttrGroups forKey:Key_CollapsedGroups];
    }
}

- (void)setPreferredExportCompression:(CGFloat)preferredExportCompression {
    if (_preferredExportCompression == preferredExportCompression) {
        return;
    }
    _preferredExportCompression = preferredExportCompression;
    if (self.shouldStoreToLocal) {
        [[NSUserDefaults standardUserDefaults] setObject:@(preferredExportCompression) forKey:Key_PreferredExportCompression];
    }
}

- (void)setCallStackType:(PVPreferredCallStackType)callStackType {
    if (callStackType < 0 || callStackType > 2) {
        NSAssert(NO, @"");
        callStackType = 0;
    }
    _callStackType = callStackType;
}

- (void)setSyncConsoleTarget:(BOOL)syncConsoleTarget {
    if (_syncConsoleTarget == syncConsoleTarget) {
        return;
    }
    _syncConsoleTarget = syncConsoleTarget;
    if (self.shouldStoreToLocal) {
        [[NSUserDefaults standardUserDefaults] setObject:@(syncConsoleTarget) forKey:Key_SyncConsoleTarget];
    }
}

- (void)setReceivingConfigTime_Class:(NSTimeInterval)receivingConfigTime_Class {
    _receivingConfigTime_Class = receivingConfigTime_Class;
    [[NSUserDefaults standardUserDefaults] setDouble:receivingConfigTime_Class forKey:Key_ReceivingConfigTime_Class];
}

- (void)setReceivingConfigTime_Color:(NSTimeInterval)receivingConfigTime_Color {
    _receivingConfigTime_Color = receivingConfigTime_Color;
    [[NSUserDefaults standardUserDefaults] setDouble:receivingConfigTime_Color forKey:Key_ReceivingConfigTime_Color];
}

- (void)_handleFreeRotationDidChange:(PVDetailMsgActionParams *)param {
    if (!self.shouldStoreToLocal) {
        return;
    }
    BOOL boolValue = param.boolValue;
    [[NSUserDefaults standardUserDefaults] setObject:@(boolValue) forKey:Key_FreeRotation];
}

- (void)_handleFastModeDidChange:(PVDetailMsgActionParams *)param {
    if (!self.shouldStoreToLocal) {
        return;
    }
    BOOL boolValue = param.boolValue;
    [[NSUserDefaults standardUserDefaults] setObject:@(boolValue) forKey:Key_FastMode];
}


- (void)_handleZInterspaceDidChange:(PVDetailMsgActionParams *)param {
    if (!self.shouldStoreToLocal) {
        return;
    }
    double doubleValue = param.doubleValue;
    [[NSUserDefaults standardUserDefaults] setObject:@(doubleValue) forKey:Key_ZInterspace];
}

/// 返回某个 section 是否应该被显示在主界面上
- (BOOL)isSectionShowing:(PVAttrSectionIdentifier)secID {
    if (self.storedSectionShowConfig[secID] != nil) {
        return [self.storedSectionShowConfig[secID] boolValue];
    }
    NSSet<PVAttrSectionIdentifier> *showingSecIDs = [self _showingSecIDsInDefault];
    if ([showingSecIDs containsObject:secID]) {
        return YES;
    } else {
        return NO;
    }
}

/// 把某个 section 显示在主界面上
- (void)showSection:(PVAttrSectionIdentifier)secID {
    if ([self isSectionShowing:secID]) {
        NSAssert(NO, @"");
        return;
    }
    self.storedSectionShowConfig[secID] = @(YES);
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationName_DidChangeSectionShowing object:nil];
    [[NSUserDefaults standardUserDefaults] setObject:self.storedSectionShowConfig.copy forKey:Key_SectionsShow];
}

/// 把某个 section 从主界面上移除
- (void)hideSection:(PVAttrSectionIdentifier)secID {
    if (![self isSectionShowing:secID]) {
        NSAssert(NO, @"");
        return;
    }
    self.storedSectionShowConfig[secID] = @(NO);
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationName_DidChangeSectionShowing object:nil];
    [[NSUserDefaults standardUserDefaults] setObject:self.storedSectionShowConfig.copy forKey:Key_SectionsShow];
}

/// 返回默认情况下，哪些 section 应该被显示在主界面上
- (NSSet<PVAttrSectionIdentifier> *)_showingSecIDsInDefault {
    static dispatch_once_t onceToken;
    static NSSet *targetSet = nil;
    dispatch_once(&onceToken,^{
        NSArray<PVAttrSectionIdentifier> *array = @[PVAttrSec_Class_Class,
                                                        
                                                        PVAttrSec_Relation_Relation,
                                                        
                                                        PVAttrSec_Layout_Frame,
                                                        PVAttrSec_Layout_Bounds,
                                                        
                                                        PVAttrSec_AutoLayout_Hugging,
                                                        PVAttrSec_AutoLayout_Resistance,
                                                        PVAttrSec_AutoLayout_Constraints,
                                                        PVAttrSec_AutoLayout_IntrinsicSize,
                                                        
                                                        PVAttrSec_ViewLayer_Visibility,
                                                        PVAttrSec_ViewLayer_InterationAndMasks,
                                                        PVAttrSec_ViewLayer_Corner,
                                                        PVAttrSec_ViewLayer_BgColor,
                                                        PVAttrSec_ViewLayer_Border,
                                                        PVAttrSec_ViewLayer_Shadow,
                                                        
                                                        PVAttrSec_UIStackView_Axis,
                                                        PVAttrSec_UIStackView_Alignment,
                                                        PVAttrSec_UIStackView_Distribution,
                                                        PVAttrSec_UIStackView_Spacing,
                                                        
                                                        PVAttrSec_UIVisualEffectView_Style,
                                                        PVAttrSec_UIVisualEffectView_QMUIForegroundColor,
                                                        
                                                        PVAttrSec_UIImageView_Name,
                                                        PVAttrSec_UIImageView_Open,
                                                        
                                                        PVAttrSec_UILabel_Text,
                                                        PVAttrSec_UILabel_Font,
                                                        PVAttrSec_UILabel_NumberOfLines,
                                                        PVAttrSec_UILabel_TextColor,
                                                        PVAttrSec_UILabel_BreakMode,
                                                        PVAttrSec_UILabel_Alignment,
                                                        
                                                        PVAttrSec_UIControl_EnabledSelected,
                                                        PVAttrSec_UIControl_QMUIOutsideEdge,
                                                        
                                                        PVAttrSec_UIButton_ContentInsets,
                                                        
                                                        PVAttrSec_UIScrollView_ContentInset,
                                                        PVAttrSec_UIScrollView_AdjustedInset,
                                                        PVAttrSec_UIScrollView_IndicatorInset,
                                                        PVAttrSec_UIScrollView_Offset,
                                                        PVAttrSec_UIScrollView_ContentSize,
                                                        PVAttrSec_UIScrollView_Behavior,
                                                        
                                                        PVAttrSec_UITableView_Style,
                                                        PVAttrSec_UITableView_SectionsNumber,
                                                        PVAttrSec_UITableView_RowsNumber,
                                                        
                                                        PVAttrSec_UITextView_Text,
                                                        PVAttrSec_UITextView_Font,
                                                        PVAttrSec_UITextView_TextColor,
                                                        PVAttrSec_UITextView_Alignment,
                                                        PVAttrSec_UITextView_ContainerInset,
                                                        
                                                        PVAttrSec_UITextField_Text,
                                                        PVAttrSec_UITextField_Font,
                                                        PVAttrSec_UITextField_TextColor,
                                                        PVAttrSec_UITextField_Alignment
        ];
        targetSet = [NSSet setWithArray:array];
    });
    return targetSet;
}

+ (BOOL)popupToAskDoubleClickBehaviorIfNeededWithWindow:(NSWindow *)window {
    if (!window) {
        return NO;
    }
    if ([PVDetailTutorialManager sharedInstance].hasAskedDoubleClickBehavior) {
        return NO;
    }
    NSAlert *alert = [NSAlert new];
    alert.messageText = NSLocalizedString(@"What do you want to happen when you double click the layer?", nil);
    alert.informativeText = NSLocalizedString(@"You can change it at any time in your Preferences.", nil);
    alert.alertStyle = NSAlertStyleInformational;
    [alert addButtonWithTitle:NSLocalizedString(@"Expand or collapse layer", nil)];
    [alert addButtonWithTitle:NSLocalizedString(@"Focus on layer", nil)];
    [alert beginSheetModalForWindow:window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn) {
            // collapse
            [PVDetailPreferenceManager mainManager].doubleClickBehavior = PVDoubleClickBehaviorCollapse;
        } else {
            // focus
            [PVDetailPreferenceManager mainManager].doubleClickBehavior = PVDoubleClickBehaviorFocus;
        }
    }];
    [PVDetailTutorialManager sharedInstance].hasAskedDoubleClickBehavior = YES;
    return YES;
}

- (void)reset {
    [PVDetailTutorialManager sharedInstance].hasAskedDoubleClickBehavior = NO;
}

- (void)reportStatistics {
    [PVDetailAnalytics trackEvent:@"Preference" withProperties:@{
        @"DoubleClick": [NSString stringWithFormat:@"%@", @(self.doubleClickBehavior)],
        @"ShowHidden": [NSString stringWithFormat:@"%@", @(self.showHiddenItems.currentBOOLValue)],
        @"RGBA": [NSString stringWithFormat:@"%@", @(self.rgbaFormat)],
        @"FreeRotation": [NSString stringWithFormat:@"%@", @(self.freeRotation.currentBOOLValue)],
        @"FastMode": [NSString stringWithFormat:@"%@", @(self.fastMode.currentBOOLValue)]
    }];
}

@end

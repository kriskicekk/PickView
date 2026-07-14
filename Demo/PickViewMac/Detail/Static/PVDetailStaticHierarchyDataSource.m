//
//  PVDetailStaticHierarchyDataSource.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailAnalytics.h"

#import "PVDetailStaticHierarchyDataSource.h"
#import "PVHierarchyInfo.h"
#import "PVDisplayItem.h"
#import "PVAttributesGroup.h"
#import "PVAttribute.h"
#import "PVDetailPreferenceManager.h"
#import "PVDetailStaticAsyncUpdateManager.h"
#import "PVDisplayItemDetail.h"
#import "PVDisplayItem.h"
#import "PVAppInfo.h"
#import "PVDetailMessageManager.h"
#import "PVDetailServerVersionRequestor.h"
#import "PVDetailVersionComparer.h"
#import "PVDetailAppsManager.h"
#import "PVDetailDanceUIAttrMaker.h"

@interface PVDetailStaticHierarchyDataSource ()

@property(nonatomic, assign) BOOL shouldIgnoreFastModeAutoUpdate;
@property(nonatomic, assign) BOOL isUsingDanceUI;

@end

@implementation PVDetailStaticHierarchyDataSource

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static PVDetailStaticHierarchyDataSource *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self sharedInstance];
}

- (instancetype)init {
    if (self = [super init]) {
        _itemsDidChangeFrame = [RACSubject subject];
    }
    return self;
}

#pragma mark - Public

- (void)reloadWithHierarchyInfo:(PVHierarchyInfo *)info keepState:(BOOL)keepState {
    [super reloadWithHierarchyInfo:info keepState:keepState];
    
    _appInfo = info.appInfo;
    
    NSAssert(info.appInfo.screenScale > 0, @"");
    CGFloat screenScale = MAX(info.appInfo.screenScale, 1);

    // SCNNode 的图片的长和宽均不能超过 16384px，这里再随手减掉 100，注意单位是 px 不是 pt
    CGFloat maxLengthInPx = PVNodeImageMaxLengthInPx - 100;
    [self.flatItems enumerateObjectsUsingBlock:^(PVDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat widthInPx = obj.frame.size.width * screenScale;
        CGFloat heightInPx = obj.frame.size.height * screenScale;
        if (widthInPx > maxLengthInPx || heightInPx > maxLengthInPx) {
            obj.doNotFetchScreenshotReason = PVDoNotFetchScreenshotForTooLarge;
        }
    }];
    
    [self updateMessageStatus];

    BOOL shouldUpdateAll = (PVDetailPreferenceManager.mainManager.fastMode.currentBOOLValue == NO);
    if (shouldUpdateAll) {
        [[PVDetailStaticAsyncUpdateManager sharedInstance] updateAll];        
    }
}

- (void)modifyWithDisplayItemDetail:(PVDisplayItemDetail *)detail {
    if (!detail) {
        return;
    }
    PVDisplayItem *displayItem = [self displayItemWithOid:detail.displayItemOid];
    if (!displayItem) {
        NSAssert(NO, @"");
        return;
    }
    if (detail.contentKind == PVDisplayItemContentKindFlutter) {
        displayItem.contentKind = detail.contentKind;
        displayItem.flutterDetail = detail.flutterDetail;
        displayItem.flutterReference = detail.flutterDetail.reference ?: displayItem.flutterReference;
        displayItem.flutterLoadState = detail.flutterDetail ? PVFlutterLoadStateLoaded : displayItem.flutterLoadState;
        [self.itemDidChangeAttrGroup sendNext:displayItem];
    }
    if (detail.customDisplayTitle) {
        displayItem.customDisplayTitle = detail.customDisplayTitle;
    }
    if (detail.danceUISource) {
        displayItem.danceuiSource = detail.danceUISource;
        
        if (!self.isUsingDanceUI) {
            self.isUsingDanceUI = YES;
            [PVDetailAnalytics trackEvent:@"UseDance"];
        }
    }
    if (detail.groupScreenshot) {
        displayItem.groupScreenshot = detail.groupScreenshot;
    }
    if (detail.soloScreenshot) {
        displayItem.soloScreenshot = detail.soloScreenshot;
    }
    
    if (detail.frameValue || detail.boundsValue) {
        [self _modifyDisplayItem:displayItem newFrame:[detail.frameValue rectValue] newBounds:[detail.boundsValue rectValue]];
    }
    
    BOOL didChangeHiddenAlpha = NO;
    if (detail.hiddenValue && detail.hiddenValue.boolValue != displayItem.isHidden) {
        displayItem.isHidden = [detail.hiddenValue boolValue];
        didChangeHiddenAlpha = YES;
    }
    if (detail.alphaValue && detail.alphaValue.floatValue != displayItem.alpha) {
        displayItem.alpha = [detail.alphaValue floatValue];
        didChangeHiddenAlpha = YES;
    }
    if (didChangeHiddenAlpha) {
        [self.itemDidChangeHiddenAlphaValue sendNext:displayItem];
    }

    BOOL attrChanged = NO;
    if (detail.attributesGroupList.count) {
        displayItem.attributesGroupList = detail.attributesGroupList;
        attrChanged = YES;
    }
    if (detail.customAttrGroupList.count) {
        displayItem.customAttrGroupList = detail.customAttrGroupList;
        attrChanged = YES;
    }
    if (attrChanged) {
        [self.itemDidChangeAttrGroup sendNext:displayItem];        
    }
    if (detail.subitems && (displayItem.subitems.count > 0 || detail.subitems.count > 0)) {
        // 如果没有这个标记位的话，待会儿的 buildDisplayingItem 在 fastMode 下会触发 update task，而此时上一个 update task 其实还没有结束（此时还在 sendTask 的 subscribe 阶段、还没有到 completion 阶段），因此就会同时有两个 update task，而 task 理论上是不能并发的。所以我们这里先简单的用一个标记位防止一下。
        self.shouldIgnoreFastModeAutoUpdate = YES;
        
        // 可能在 search 或 focus 状态，先退出，否则状态维护太麻烦
        switch (self.state) {
            case PVDetailHierarchyDataSourceStateFocus:
                [self endFocus];
                break;
            case PVDetailHierarchyDataSourceStateSearch:
                [self endSearch];
                break;
            default:
                break;
        }
        
        displayItem.subitems = detail.subitems;
        // 根据 subitems 属性打平为二维数组，同时给每个 item 设置 indentLevel
        self.rawFlatItems = [PVDisplayItem flatItemsFromHierarchicalItems:self.rawHierarchyInfo.displayItems];
        self.flatItems = self.rawFlatItems;
        [self.didReloadHierarchyInfo sendNext:nil];
        
        [displayItem enumerateSelfAndChildren:^(PVDisplayItem * _Nonnull obj) {
            if (obj == displayItem) {
                return;
            }
            if (obj.contentKind != PVDisplayItemContentKindFlutter &&
                !obj.isUserCustom && !obj.shouldCaptureImage) {
                [obj enumerateSelfAndChildren:^(PVDisplayItem *item) {
                    item.noPreview = YES;
                    item.doNotFetchScreenshotReason = PVDoNotFetchScreenshotForUserConfig;
                }];
            }
            if (obj.customInfo.danceuiSource.length > 0) {
                [PVDetailDanceUIAttrMaker makeDanceUIJumpAttribute:obj danceSource:obj.customInfo.danceuiSource];
            }
        }];
        [self buildDisplayingFlatItems];
        self.shouldIgnoreFastModeAutoUpdate = NO;
    }
}

- (void)buildDisplayingFlatItems {
    [super buildDisplayingFlatItems];
    if ([PVDetailPreferenceManager mainManager].fastMode.currentBOOLValue && !self.shouldIgnoreFastModeAutoUpdate) {
        [[PVDetailStaticAsyncUpdateManager sharedInstance] updateForDisplayingItems];
    }
}

- (PVDetailPreferenceManager *)preferenceManager {
    return [PVDetailPreferenceManager mainManager];
}

#pragma mark - Private

- (void)_modifyDisplayItem:(PVDisplayItem *)item newFrame:(CGRect)frame newBounds:(CGRect)bounds {
    if (!item) {
        NSAssert(NO, @"");
        return;
    }
    if (CGRectEqualToRect(item.frame, frame) && CGRectEqualToRect(item.bounds, bounds)) {
        return;
    }
    item.frame = frame;
    item.bounds = bounds;
    
    [self.itemsDidChangeFrame sendNext:item];
}

- (void)updateMessageStatus {
    if (self.serverSideIsSwiftProject && self.appInfo.swiftEnabledInPickViewServer == -1) {
        [[PVDetailMessageManager sharedInstance] addMessage:PVDetailMessage_SwiftSubspec];
    } else {
        [[PVDetailMessageManager sharedInstance] removeMessage:PVDetailMessage_SwiftSubspec];
    }
    
    if ([self queryIfUsingNewestServerVersion]) {
        [[PVDetailMessageManager sharedInstance] removeMessage:PVDetailMessage_NewServerVersion];
    } else {
        [[PVDetailMessageManager sharedInstance] addMessage:PVDetailMessage_NewServerVersion];
    }
}

/// 如果 Server 端使用的是最新版，或者无法判断，那么就返回 YES
- (BOOL)queryIfUsingNewestServerVersion {
    NSString *newestVersion = [[PVDetailServerVersionRequestor shared] query];
    if (!newestVersion) {
        return YES;
    }
    NSString *userVersion = [self.appInfo serverReadableVersion];
    if (!userVersion) {
        // PickViewServer 1.2.3 之前的版本没有该字段
        return NO;
    }
    [PVDetailAnalytics trackEvent:@"ServerVersion" withProperties:@{@"version":userVersion}];
    BOOL isNew = [PVDetailVersionComparer compareWithNewest:newestVersion user:userVersion];
    return isNew;
}

- (BOOL)isReadOnly {
    return NO;
}

@end

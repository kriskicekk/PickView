//
//  PVDetailDashboardViewController.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailAnalytics.h"

#import "PVDetailDashboardViewController.h"
#import "PVDetailStaticHierarchyDataSource.h"
#import "PVDetailDashboardCardView.h"
#import "PVInspectionDefines.h"
#import "PVDetailAppsManager.h"
#import "PVDetailPreferenceManager.h"
#import "PVDetailStaticAsyncUpdateManager.h"
#import "PVDetailReadHierarchyDataSource.h"
#import "PVDashboardBlueprint.h"
#import "PVDetailUserActionManager.h"
#import "PVDetailDashboardHeaderView.h"
#import "PVDetailDashboardSearchPropView.h"
#import "PVAttributesSection.h"
#import "PVDetailDashboardSectionView.h"
#import "PVDetailDashboardSearchMethodsView.h"
#import "PVDetailDashboardSearchMethodsDataSource.h"
#import "PVCustomAttrModification.h"
#import "PVDetailDashboardTextControlEditingFlag.h"

@interface PVDetailDashboardViewController () <PVDetailDashboardCardViewDelegate, PVDetailDashboardHeaderViewDelegate, PVDetailDashboardSearchPropViewDelegate, PVDetailDashboardSearchMethodsViewDelegate>

@property(nonatomic, strong) NSScrollView *scrollView;
@property(nonatomic, strong) PVDetailBaseView *documentView;
@property(nonatomic, strong) PVDetailBaseView *cardContainerView;
@property(nonatomic, strong) PVDetailLabel *emptyLabel;

@property(nonatomic, copy) NSArray<PVAttributesGroup *> *groupList;
/// key 是 group.uniqueKey
@property(nonatomic, strong) NSMutableDictionary<NSString *, PVDetailDashboardCardView *> *cardViews;

@property(nonatomic, strong) PVDetailBaseView *searchContainerView;
@property(nonatomic, strong) PVDetailDashboardHeaderView *headerView;
@property(nonatomic, strong) NSMutableArray<PVDetailDashboardSearchPropView *> *searchPropViews;
@property(nonatomic, strong) PVDetailDashboardSearchMethodsView *searchMethodsView;
@property(nonatomic, strong) PVDetailDashboardSearchMethodsDataSource *methodsDataSource;

@property(nonatomic, strong) PVDetailStaticHierarchyDataSource *staticDataSource;
@property(nonatomic, strong) PVDetailReadHierarchyDataSource *readDataSource;

@end

@implementation PVDetailDashboardViewController

- (instancetype)initWithStaticDataSource:(PVDetailStaticHierarchyDataSource *)dataSource {
    if (self = [self initWithContainerView:nil]) {
        self.staticDataSource = dataSource;
        _isStaticMode = YES;
        [self _didInitialized];
        
    }
    return self;
}

- (instancetype)initWithReadDataSource:(PVDetailReadHierarchyDataSource *)dataSource {
    if (self = [self initWithContainerView:nil]) {
        self.readDataSource = dataSource;
        _isStaticMode = NO;
        [self _didInitialized];
    }
    return self;
}

- (NSView *)makeContainerView {
    PVDetailBaseView *containerView = [PVDetailBaseView new];
    containerView.backgroundColor = NSColor.windowBackgroundColor;
    containerView.borderPosition = PVDetailViewBorderPositionLeft;
    
    self.documentView = [PVDetailBaseView new];
    
    self.scrollView = [[NSScrollView alloc] init];
    self.scrollView.drawsBackground = NO;
    self.scrollView.hasVerticalScroller = YES;
    self.scrollView.hasHorizontalScroller = NO;
    self.scrollView.autohidesScrollers = YES;
    self.scrollView.contentView.documentView = self.documentView;
    [containerView addSubview:self.scrollView];
    
    self.headerView = [PVDetailDashboardHeaderView new];
    self.headerView.delegate = self;
    [self.documentView addSubview:self.headerView];
    
    self.cardContainerView = [PVDetailBaseView new];
    [self.documentView addSubview:self.cardContainerView];
    
    self.searchContainerView = [PVDetailBaseView new];
    self.searchContainerView.hidden = YES;
    [self.documentView addSubview:self.searchContainerView];

    self.emptyLabel = [PVDetailLabel new];
    self.emptyLabel.stringValue = @"No Inspect Data";
    self.emptyLabel.font = NSFontMake(13);
    self.emptyLabel.textColor = NSColor.secondaryLabelColor;
    self.emptyLabel.hidden = YES;
    [containerView addSubview:self.emptyLabel];
    
    return containerView;
}

- (void)_didInitialized {
    self.cardViews = [NSMutableDictionary dictionary];
    self.searchPropViews = [NSMutableArray array];
    
    @weakify(self);
    if (self.staticDataSource) {
        [[[RACSignal merge:@[RACObserve(self.staticDataSource, selectedItem)]] deliverOnMainThread] subscribeNext:^(id x) {
            @strongify(self);
            [self reloadWithGroupList:[self.staticDataSource.selectedItem queryAllAttrGroupList]];
        }];
        
        [[self.staticDataSource.itemDidChangeAttrGroup deliverOnMainThread] subscribeNext:^(PVDisplayItem *displayItem) {
            @strongify(self);
            if (self.staticDataSource.selectedItem == displayItem) {
                [self reloadWithGroupList:[displayItem queryAllAttrGroupList]];
            }
        }];
        
        self.methodsDataSource = [PVDetailDashboardSearchMethodsDataSource new];
        [self.staticDataSource.didReloadHierarchyInfo subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            [self.methodsDataSource clearAllCache];
        }];
        
    } else if (self.readDataSource) {
        [[[RACSignal merge:@[RACObserve(self.readDataSource, selectedItem)]] deliverOnMainThread] subscribeNext:^(id x) {
            @strongify(self);
            [self reloadWithGroupList:[self.readDataSource.selectedItem queryAllAttrGroupList]];
        }];
    }
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NotificationName_DidChangeSectionShowing object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        @strongify(self);
        [self reloadWithGroupList:[[self currentDataSource].selectedItem queryAllAttrGroupList]];
    }];
}

- (void)viewDidLayout {
    [super viewDidLayout];
    
    $(self.scrollView).fullFrame;
    if (self.emptyLabel.isVisible) {
        $(self.emptyLabel).sizeToFit.centerAlign;
    }
    
    CGFloat verMargin = 10;
    CGFloat contentWidth = DashboardViewWidth - DashboardHorInset * 2;
    
    $(self.headerView).width(contentWidth).x(DashboardHorInset).height(23).y(10);
    
    if (!self.cardContainerView.hidden) {
        $(self.cardContainerView).width(contentWidth).x(DashboardHorInset).y(self.headerView.$maxY + verMargin);
        
        __block CGFloat y = 0;
        
        [self.groupList enumerateObjectsUsingBlock:^(PVAttributesGroup * _Nonnull group, NSUInteger idx, BOOL * _Nonnull stop) {
            PVDetailDashboardCardView *view = self.cardViews[group.uniqueKey];
            if (view && !view.hidden) {
                $(view).width(contentWidth).y(y).heightToFit;
                y = view.$maxY + verMargin;
            }
        }];
        
        $(self.cardContainerView).height(y);
        $(self.documentView).fullWidth.y(0).toMaxY(self.cardContainerView.$maxY);
    }
    
    if (!self.searchContainerView.hidden) {
        $(self.searchContainerView).width(contentWidth).x(DashboardHorInset).y(self.headerView.$maxY + verMargin);
        
        __block CGFloat y = 0;
        [self.searchPropViews enumerateObjectsUsingBlock:^(PVDetailDashboardSearchPropView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
            if (!view.hidden) {
                $(view).width(contentWidth).x(0).heightToFit.y(y);
                y = view.$maxY + verMargin;
            }
        }];
        
        if (self.searchMethodsView.isVisible) {
            $(self.searchMethodsView).width(contentWidth).y(y).heightToFit;
            y = self.searchMethodsView.$maxY;
        }
        
        $(self.searchContainerView).height(y);
        $(self.documentView).fullWidth.y(0).toMaxY(self.searchContainerView.$maxY);
    }
}

- (void)reloadWithGroupList:(NSArray<PVAttributesGroup *> *)list {
    self.groupList = list;
    
    if (list.count > 0) {
        self.scrollView.hidden = NO;
        self.emptyLabel.hidden = YES;
    } else {
        self.scrollView.hidden = YES;
        self.emptyLabel.hidden = NO;
        [self.view setNeedsLayout:YES];
        return;
    }
    
    NSMutableArray<PVDetailDashboardCardView *> *needlessViews = [self.cardViews allValues].mutableCopy;
    
    [list enumerateObjectsUsingBlock:^(PVAttributesGroup * _Nonnull group, NSUInteger idx, BOOL * _Nonnull stop) {
        PVDetailDashboardCardView *cardView = self.cardViews[group.uniqueKey];
        if (cardView) {
            [needlessViews removeObject:cardView];
        } else {
            cardView = [PVDetailDashboardCardView new];
            cardView.dashboardViewController = self;
            cardView.delegate = self;
            self.cardViews[group.uniqueKey] = cardView;
            [self.cardContainerView addSubview:cardView];
        }
        cardView.hidden = NO;
        cardView.attrGroup = group;
        cardView.isCollapsed = [[PVDetailPreferenceManager mainManager].collapsedAttrGroups containsObject:group.identifier];
        [cardView render];
    }];
    
    [needlessViews enumerateObjectsUsingBlock:^(PVDetailDashboardCardView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hidden = YES;
    }];
    
    [self.view setNeedsLayout:YES];
}

- (RACSignal *)modifyAttribute:(PVAttribute *)attribute newValue:(id)newValue {
    if (attribute.isUserCustom) {
        return [self modifyCustomAttribute:attribute newValue:newValue];
    } else {
        return [self modifyInbuiltAttribute:attribute newValue:newValue];
    }
}

- (RACSignal *)modifyCustomAttribute:(PVAttribute *)attribute newValue:(id)newValue {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        @strongify(self);        
        PVCustomAttrModification *modification = [PVCustomAttrModification new];
        modification.customSetterID = attribute.customSetterID;
        modification.attrType = attribute.attrType;
        modification.value = newValue;
    
        if (modification.customSetterID.length == 0) {
            NSAssert(NO, @"");
            AlertError(PVInspectErr_Inner, self.view.window);
            [subscriber sendError:PVInspectErr_Inner];
            return nil;
        }
        
        if (![PVDetailAppsManager sharedInstance].inspectingApp) {
            AlertError(PVInspectErr_NoConnect, self.view.window);
            [subscriber sendError:PVInspectErr_NoConnect];
            return nil;
        }
        
        @weakify(self);
        [[[PVDetailAppsManager sharedInstance].inspectingApp submitCustomModification:modification] subscribeNext:^(id ret) {
            NSLog(@"custom modification - succ");
            attribute.value = newValue;
            [subscriber sendNext:nil];

        } error:^(NSError * _Nullable error) {
            @strongify(self);
            AlertError(error, self.view.window);
            [subscriber sendError:error];
        }];
        
        return nil;
    }];
}

- (RACSignal *)modifyInbuiltAttribute:(PVAttribute *)attribute newValue:(id)newValue {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        @strongify(self);
        PVDisplayItem *modifyingItem = attribute.targetDisplayItem;
        
        PVAttributeModification *modification = [PVAttributeModification new];
        modification.clientReadableVersion = [PVDetailHelper pickviewReadableVersion];
        if (attribute.modificationTargetOid) {
            modification.targetOid = attribute.modificationTargetOid;
        } else if ([PVDashboardBlueprint isUIViewPropertyWithAttrID:attribute.identifier]) {
            modification.targetOid = modifyingItem.viewObject.oid;
        } else {
            modification.targetOid = modifyingItem.layerObject.oid;
        }
        modification.setterSelector = attribute.modificationSetterName.length
            ? NSSelectorFromString(attribute.modificationSetterName)
            : [PVDashboardBlueprint setterWithAttrID:attribute.identifier];
        modification.attrType = attribute.attrType;
        modification.value = newValue;
        
        if (!modification.setterSelector) {
            NSAssert(NO, @"");
            AlertError(PVInspectErr_Inner, self.view.window);
            [subscriber sendError:PVInspectErr_Inner];
        }
        
        if (![PVDetailAppsManager sharedInstance].inspectingApp) {
            AlertError(PVInspectErr_NoConnect, self.view.window);
            [subscriber sendError:PVInspectErr_NoConnect];
        }
        
        @weakify(self);
        [[[PVDetailAppsManager sharedInstance].inspectingApp submitInbuiltModification:modification] subscribeNext:^(PVDisplayItemDetail *detail) {
            NSLog(@"modification - succ");
            @strongify(self);
            if (self.staticDataSource) {
                PVDetailDashboardTextControlEditingFlag.sharedInstance.shouldIgnoreTextEditingChangeEvent = YES;
                // 用户通过回车键触发 endEditing -> 触发编辑 -> 走到这里 -> 这一句会触发 reload -> reload 触发 cardView removeFromSuperview -> 再次触发 editEditing，因此会导致连续修改两次（多 sync 一次图像数据），所以这里用标记位规避一下，懒得琢磨其它办法了
                [self.staticDataSource modifyWithDisplayItemDetail:detail];
                PVDetailDashboardTextControlEditingFlag.sharedInstance.shouldIgnoreTextEditingChangeEvent = NO;
                
                if ([PVDashboardBlueprint needPatchAfterModificationWithAttrID:attribute.identifier]) {
                    [[PVDetailStaticAsyncUpdateManager sharedInstance] updateAfterModifyingDisplayItem:(PVDisplayItem *)modifyingItem];
                }
                
            } else {
                NSAssert(NO, @"");
            }
            [subscriber sendNext:nil];
            
        } error:^(NSError * _Nullable error) {
            @strongify(self);
            AlertError(error, self.view.window);
            [subscriber sendError:error];
        }];
        
        return nil;
    }];
}

- (PVDetailHierarchyDataSource *)currentDataSource {
    if (self.staticDataSource) {
        return self.staticDataSource;
    }
    if (self.readDataSource) {
        return self.readDataSource;
    }
    NSAssert(NO, @"");
    return nil;
}

#pragma mark - <PVDetailDashboardCardViewDelegate>

- (void)dashboardCardViewNeedToggleCollapse:(PVDetailDashboardCardView *)view {
    PVDetailPreferenceManager *manager = self.currentDataSource.preferenceManager;
    if ([manager.collapsedAttrGroups containsObject:view.attrGroup.identifier]) {
        view.isCollapsed = NO;
        manager.collapsedAttrGroups = [manager.collapsedAttrGroups pv_inspect_arrayByRemovingObject:view.attrGroup.identifier];
    } else {
        view.isCollapsed = YES;
        manager.collapsedAttrGroups = [manager.collapsedAttrGroups arrayByAddingObject:view.attrGroup.identifier];;
    }
    [self.view setNeedsLayout:YES];
}

#pragma mark - <PVDetailDashboardHeaderViewDelegate>

- (void)dashboardHeaderView:(PVDetailDashboardHeaderView *)view didInputString:(NSString *)searchString {
    if (searchString.length < 3) {
        self.searchContainerView.hidden = YES;
        return;
    }
    
    [PVDetailAnalytics trackEvent:@"SearchAttr"];
    
    searchString = searchString.lowercaseString;
    
    // 以下是在渲染 attrs
    
    NSMutableArray<PVAttribute *> *resultAttrs = [NSMutableArray array];
    [[self.currentDataSource.selectedItem queryAllAttrGroupList]  enumerateObjectsUsingBlock:^(PVAttributesGroup * _Nonnull group, NSUInteger idx, BOOL * _Nonnull stop) {
        [group.attrSections enumerateObjectsUsingBlock:^(PVAttributesSection * _Nonnull section, NSUInteger idx, BOOL * _Nonnull stop) {
            [section.attributes enumerateObjectsUsingBlock:^(PVAttribute * _Nonnull attr, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *title;
                if (attr.isUserCustom) {
                    title = attr.displayTitle;
                } else {
                    title = [PVDashboardBlueprint fullTitleWithAttrID:attr.identifier];
                }
                if ([title.lowercaseString containsString:searchString]) {
                    [resultAttrs addObject:attr];
                }
            }];
        }];
    }];
    
    [self.searchPropViews pv_inspect_dequeueWithCount:resultAttrs.count add:^PVDetailDashboardSearchPropView *(NSUInteger idx) {
        PVDetailDashboardSearchPropView *view = [PVDetailDashboardSearchPropView new];
        view.delegate = self;
        [self.searchContainerView addSubview:view];
        return view;
        
    } notDequeued:^(NSUInteger idx, PVDetailDashboardSearchPropView *view) {
        view.hidden = YES;
        
    } doNext:^(NSUInteger idx, PVDetailDashboardSearchPropView *view) {
        PVAttribute *attribute = resultAttrs[idx];
        [view renderWithAttribute:attribute];
        view.hidden = NO;
    }];
    
    // 以下是在渲染 methods
    
    if (self.currentDataSource != self.staticDataSource) {
        self.searchContainerView.hidden = NO;
        self.searchMethodsView.hidden = YES;
        [self.view setNeedsLayout:YES];
        return;
    }
    
    if (!self.searchMethodsView) {
        self.searchMethodsView = [PVDetailDashboardSearchMethodsView new];
        self.searchMethodsView.delegate = self;
        [self.searchContainerView addSubview:self.searchMethodsView];
    }
    
    PVObject *selectedObj = self.currentDataSource.selectedItem.viewObject ? : self.currentDataSource.selectedItem.layerObject;
    NSString *selectedClassName = [selectedObj rawClassName];
    @weakify(self);
    [[self.methodsDataSource fetchNonArgMethodsListWithClass:selectedClassName] subscribeNext:^(NSArray<NSString *> *methodsList) {
        @strongify(self);
        if (![searchString isEqualToString:[self.headerView currentInputString]]) {
            return;
        }
        NSArray<NSString *> *searchedMethods = [PVDetailHelper bestMatchesInCandidates:methodsList input:searchString maxResultsCount:5];
        [self.searchMethodsView renderWithMethods:searchedMethods oid:selectedObj.oid];
        self.searchContainerView.hidden = NO;
        [self.view setNeedsLayout:YES];
        
    } error:^(NSError * _Nullable error) {
        @strongify(self);
        if (![searchString isEqualToString:[self.headerView currentInputString]]) {
            return;
        }
        [self.searchMethodsView renderWithError:error];
        self.searchContainerView.hidden = NO;
        [self.view setNeedsLayout:YES];
    }];
}

- (void)dashboardHeaderView:(PVDetailDashboardHeaderView *)view didToggleActive:(BOOL)isActive {
    if (isActive) {
        self.cardContainerView.animator.hidden = YES;
        self.currentDataSource.shouldAvoidChangingPreviewSelectionDueToDashboardSearch = YES;
    
    } else {
        self.cardContainerView.animator.hidden = NO;
        self.searchContainerView.animator.hidden = YES;
        [self.view setNeedsLayout:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 这个 0.25 的延时是关键，想象这个场景：用户想要结束搜索于是点击了空白图像处，此时程序会先走到这里的 resignActive 逻辑，然后再走到 preview 那边的取消图层选中逻辑（这两者时差大概在 0.1s 左右），但此时用户应该是并不想取消图层选中的，所以这里要用一个 flag 保护一下这种情况
            if (!view.isActive) {
                self.currentDataSource.shouldAvoidChangingPreviewSelectionDueToDashboardSearch = NO;
            }
        });
    }
}

#pragma mark - <PVDetailDashboardSearchMethodsViewDelegate>

- (void)dashboardSearchMethodsView:(PVDetailDashboardSearchMethodsView *)view requestToInvokeMethod:(NSString *)method oid:(unsigned long)oid {
    [PVDetailAnalytics trackEvent:@"ClickServerAttr"];
    
    RACSignal *signal;
    if (oid == 0 || method.length == 0) {
        signal = [RACSignal error:PVInspectErr_Inner];
    } else if (![PVDetailAppsManager sharedInstance].inspectingApp) {
        signal = [RACSignal error:PVInspectErr_NoConnect];
    } else {
        signal = [[PVDetailAppsManager sharedInstance].inspectingApp invokeMethodWithOid:oid text:method];
    }
    
    [signal subscribeNext:^(NSDictionary *value) {
        NSAlert *alert = [NSAlert new];
        alert.messageText = method;
        alert.informativeText = value[@"description"];
        alert.alertStyle = NSAlertStyleInformational;
        [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {

        }];
        
    } error:^(NSError * _Nullable error) {
        AlertError(error, self.view.window);
    }];
    
}

#pragma mark - <PVDetailDashboardSearchPropViewDelegate>

- (void)dashboardSearchPropView:(PVDetailDashboardSearchPropView *)view didClickRevealAttribute:(PVAttribute *)clickedAttr {
    self.headerView.isActive = NO;
    
    __block PVAttributesGroup *targetGroup = nil;
    __block PVAttributesSection *targetSection = nil;
    
    [[self.currentDataSource.selectedItem queryAllAttrGroupList] enumerateObjectsUsingBlock:^(PVAttributesGroup * _Nonnull group, NSUInteger idx, BOOL * _Nonnull stop0) {
        [group.attrSections enumerateObjectsUsingBlock:^(PVAttributesSection * _Nonnull section, NSUInteger idx, BOOL * _Nonnull stop1) {
            [section.attributes enumerateObjectsUsingBlock:^(PVAttribute * _Nonnull attr, NSUInteger idx, BOOL * _Nonnull stop2) {
                if (attr == clickedAttr) {
                    *stop0 = YES;
                    *stop1 = YES;
                    *stop2 = YES;
                    
                    BOOL isAlreadyAdded = [[PVDetailPreferenceManager mainManager] isSectionShowing:section.identifier];
                    if (!isAlreadyAdded) {
                        // 把这个属性添加到主面板上
                        [[PVDetailPreferenceManager mainManager] showSection:section.identifier];
                    }
                    
                    targetGroup = group;
                    targetSection = section;
                }
            }];
        }];
    }];
    
    if (!targetGroup || !targetSection) {
        NSAssert(NO, @"");
        return;
    }
    PVDetailDashboardCardView *targetCardView = self.cardViews[targetGroup.uniqueKey];
    if (!targetCardView) {
        NSAssert(NO, @"");
        return;
    }
    if (targetCardView.isCollapsed) {
        // 如果在折叠状态则展开
        [self dashboardCardViewNeedToggleCollapse:targetCardView];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        PVDetailDashboardSectionView *targetSecView = [targetCardView querySectionViewWithSection:targetSection];
        [self.scrollView.contentView.animator scrollRectToVisible:[self.scrollView.contentView convertRect:targetSecView.frame fromView:targetSecView.superview]];
        
        [self.cardViews.allValues enumerateObjectsUsingBlock:^(PVDetailDashboardCardView * _Nonnull cardView, NSUInteger idx, BOOL * _Nonnull stop) {
            if (cardView.hidden) {
                return;
            }
            if (cardView == targetCardView) {
                [cardView playFadeAnimationWithHighlightRect:[cardView convertRect:targetSecView.frame fromView:targetSecView.superview]];
            } else {
                [cardView playFadeAnimationWithHighlightRect:CGRectZero];
            }
        }];
    });
}

@end

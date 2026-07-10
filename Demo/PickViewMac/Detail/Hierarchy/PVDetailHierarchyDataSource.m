//
//  PVDetailHierarchyDataSource.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailAnalytics.h"

#import "PVDetailHierarchyDataSource.h"
#import "PVHierarchyInfo.h"
#import "PVDisplayItem.h"
#import "PVDetailPreferenceManager.h"
#import "PVDetailColorIndicatorLayer.h"
#import "PVDetailUserActionManager.h"
#import "PVDisplayItem+PVClient.h"
#import "PVDetailDanceUIAttrMaker.h"
#import "PVDetailStaticAsyncUpdateManager.h"

@interface PVDetailSelectColorItem : NSObject

+ (instancetype)itemWithTitle:(NSString *)title color:(PVColor *)color;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, strong) NSColor *color;

@end

@implementation PVDetailSelectColorItem

+ (instancetype)itemWithTitle:(NSString *)title color:(PVColor *)color {
    PVDetailSelectColorItem *item = [PVDetailSelectColorItem new];
    item.title = title;
    item.color = color;
    return item;
}

@end

@interface PVDetailSelectColorItemsSection : NSObject

@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSArray<PVDetailSelectColorItem *> *items;

@end

@implementation PVDetailSelectColorItemsSection

- (void)setItems:(NSArray<PVDetailSelectColorItem *> *)items {
    _items = [items sortedArrayUsingComparator:^NSComparisonResult(PVDetailSelectColorItem * _Nonnull obj1, PVDetailSelectColorItem * _Nonnull obj2) {
        return [obj1.title caseInsensitiveCompare:obj2.title];
    }].copy;
}

@end

@interface PVDisplayItem (PVDetailHierarchyDataSource)

/// 记录搜索之前的 isExpanded 的值，用来在结束搜索后恢复
@property(nonatomic, assign) BOOL isExpandedBeforeSearchOrFocus;

@end

@implementation PVDisplayItem (PVDetailHierarchyDataSource)

- (void)setIsExpandedBeforeSearchOrFocus:(BOOL)isExpandedBeforeSearching {
    [self pv_inspect_bindBOOL:isExpandedBeforeSearching forKey:@"isExpandedBeforeSearching"];
}

- (BOOL)isExpandedBeforeSearchOrFocus {
    return [self pv_inspect_getBindBOOLForKey:@"isExpandedBeforeSearching"];
}

@end

@interface PVDetailHierarchyDataSource ()
@property(nonatomic, assign) PVDetailHierarchyDataSourceState state;

@property(nonatomic, strong, readwrite) PVHierarchyInfo *rawHierarchyInfo;

/// displayingFlatItems 是 flatItems 的子集，仅包含用户可以看到的 items，而那些被折叠的 items 会被剔除。换句话说，当用户展开或收起 item 时，displayingFlatItems 属性会被 buildDisplayingFlatItems 方法不断更新
@property(nonatomic, copy, readwrite) NSArray<PVDisplayItem *> *displayingFlatItems;

@property(nonatomic, strong, readwrite) NSMenu *selectColorMenu;
@property(nonatomic, copy) NSDictionary<NSNumber *, PVDisplayItem *> *oidToDisplayItemMap;

/**
 key 是 rgba 字符串，value 是 alias 字符串数组，比如：
 
 @{
 @"(255, 255, 255, 1)": @[@"MyWhite", @"MainThemeWhite"],
 @"(255, 0, 0, 0.5)": @[@"BestRed", @"TransparentRed"]
 };
 
 */
@property(nonatomic, strong) NSDictionary<NSString *, NSArray<NSString *> *> *colorToAliasMap;

@end

@implementation PVDetailHierarchyDataSource

- (instancetype)init {
    if (self = [super init]) {
        _itemDidChangeHiddenAlphaValue = [RACSubject subject];
        _itemDidChangeAttrGroup = [RACSubject subject];
        _itemDidChangeNoPreview = [RACSubject subject];
        _didReloadHierarchyInfo = [RACSubject subject];
        _willReloadHierarchyInfo = [RACSubject subject];
        _didReloadFlatItemsWithSearchOrFocus = [RACSubject subject];
        
        @weakify(self);
        [[[RACObserve([PVDetailPreferenceManager mainManager], rgbaFormat) skip:1] distinctUntilChanged] subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            [self _setUpColors];
        }];
    }
    return self;
}

- (void)reloadWithHierarchyInfo:(PVHierarchyInfo *)info keepState:(BOOL)keepState {
    self.rawHierarchyInfo = info;
    
    [self.willReloadHierarchyInfo sendNext:nil];

    if (info.colorAlias.count) {
        [PVDetailPreferenceManager mainManager].receivingConfigTime_Color = [[NSDate date] timeIntervalSince1970];
    }
    if (info.collapsedClassList.count) {
        [PVDetailPreferenceManager mainManager].receivingConfigTime_Class = [[NSDate date] timeIntervalSince1970];
    }
    
    unsigned long prevSelectedOid = 0;
    NSMutableDictionary *prevExpansionMap = nil;
    if (keepState) {
        prevSelectedOid = self.selectedItem.layerObject.oid;
        
        prevExpansionMap = [NSMutableDictionary dictionary];
        [self.flatItems enumerateObjectsUsingBlock:^(PVDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            prevExpansionMap[@(obj.layerObject.oid)] = @(obj.isExpanded);
        }];
    }
    
    // 设置 color alias 和 select color menu
    [self _setUpColors];
    
    // 根据 subitems 属性打平为二维数组，同时给每个 item 设置 indentLevel
    self.rawFlatItems = [PVDisplayItem flatItemsFromHierarchicalItems:info.displayItems];
    NSArray<PVDisplayItem *> *flatItems = self.rawFlatItems.copy;
    
    // 设置 preferToBeCollapsed 属性
    NSSet<NSString *> *classesPreferredToCollapse = [NSSet setWithObjects:@"UILabel", @"UIPickerView", @"UIProgressView", @"UIActivityIndicatorView", @"UIAlertView", @"UIActionSheet", @"UISearchBar", @"UIButton", @"UITextView", @"UIDatePicker", @"UIPageControl", @"UISegmentedControl", @"UITextField", @"UISlider", @"UISwitch", @"UIVisualEffectView", @"UIImageView", @"WKCommonWebView", @"UITextEffectsWindow", nil];
    if (info.collapsedClassList.count) {
        classesPreferredToCollapse = [classesPreferredToCollapse setByAddingObjectsFromArray:info.collapsedClassList];
    }
    // no preview
    NSSet<NSString *> *classesWithNoPreview = [NSSet setWithArray:@[@"UITextEffectsWindow", @"UIRemoteKeyboardWindow"]];
    
    __block BOOL hasCustomSubviews = NO;
    __block BOOL hasCustomAttrs = NO;
    [flatItems enumerateObjectsUsingBlock:^(PVDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj itemIsKindOfClassesWithNames:classesPreferredToCollapse]) {
            [obj enumerateSelfAndChildren:^(PVDisplayItem *item) {
                item.preferToBeCollapsed = YES;
            }];
        }
        
        if (obj.indentLevel == 0) {
            if ([obj itemIsKindOfClassesWithNames:classesWithNoPreview]) {
                obj.noPreview = YES;
            }
        }
        
        if (!obj.isUserCustom && !obj.shouldCaptureImage) {
            [obj enumerateSelfAndChildren:^(PVDisplayItem *item) {
                item.noPreview = YES;
                item.doNotFetchScreenshotReason = PVDoNotFetchScreenshotForUserConfig;
            }];
        }
//        } else if ([PVDetailPreferenceManager mainManager].showHiddenItems.currentBOOLValue == NO && obj.inHiddenHierarchy) {
//            [obj enumerateSelfAndChildren:^(PVDisplayItem *item) {
//                item.noPreview = YES;
//                item.doNotFetchScreenshotReason = PVDoNotFetchScreenshotForHidden;
//            }];
//        }
        
        if (!self.serverSideIsSwiftProject) {
            if ([obj.displayingObject.lk_completedDemangledClassName containsString:@"."]) {
                _serverSideIsSwiftProject = YES;
            }
        }
        
        if (obj.customInfo.danceuiSource.length > 0) {
            [PVDetailDanceUIAttrMaker makeDanceUIJumpAttribute:obj danceSource:obj.customInfo.danceuiSource];
        }
        
        if (obj.isUserCustom) {
            hasCustomSubviews = YES;
        }
        if (obj.customAttrGroupList.count > 0) {
            hasCustomAttrs = YES;
        }
    }];
    [PVDetailAnalytics trackEvent:@"CustomSubview" withProperties:@{@"Has": hasCustomSubviews ? @"True" : @"False"}];
    [PVDetailAnalytics trackEvent:@"CustomAttrs" withProperties:@{@"Has": hasCustomAttrs ? @"True" : @"False"}];
    
    self.flatItems = flatItems;
    
    // 设置选中
    PVDisplayItem *shouldSelectedItem = nil;
    if (keepState) {
        PVDisplayItem *prevSelectedItem = [self displayItemWithOid:prevSelectedOid];
        if (prevSelectedItem) {
            shouldSelectedItem = prevSelectedItem;
        }
    }

    // 设置展开和折叠
    NSInteger expansionIndex = self.preferenceManager.expansionIndex;
    if (self.flatItems.count > 300) {
        if (expansionIndex > 2) {
            expansionIndex = 2;
        }
    }
    [self adjustExpansionByIndex:expansionIndex referenceDict:(keepState ? prevExpansionMap : nil) selectedItem:(shouldSelectedItem ? nil : &shouldSelectedItem)];
    
    if (self.flatItems.count > 20 && self.displayingFlatItems.count < 10 && expansionIndex > 1) {
        // 被展开的图层太少了，所以忽略 referDict 重新调整。通常是由于 iOS App 重新编译或者界面改变了导致之前被展开的图层都被释放掉了
        NSLog(@"adjust expansion again");
        [self adjustExpansionByIndex:expansionIndex referenceDict:nil selectedItem:nil];
    }
    
    if (!shouldSelectedItem) {
        shouldSelectedItem = self.flatItems.firstObject;
    }
    self.selectedItem = shouldSelectedItem;

    if (self.state != PVDetailHierarchyDataSourceStateNormal) {
        // 可能在 search 或 focus 状态，要退出
        self.state = PVDetailHierarchyDataSourceStateNormal;
    }
    
    [self.didReloadHierarchyInfo sendNext:nil];
}

- (NSInteger)numberOfRows {
    return self.displayingFlatItems.count;
}

- (PVDisplayItem *)itemAtRow:(NSInteger)index {
    if (index < 0) {
        return nil;
    }
    if ([self.displayingFlatItems pv_inspect_hasIndex:index]) {
        return self.displayingFlatItems[index];
    }
    return nil;
}

- (NSInteger)rowForItem:(PVDisplayItem *)item {
    NSInteger row = [self.displayingFlatItems indexOfObject:item];
    return row;
}

- (void)setSelectedItem:(PVDisplayItem *)selectedItem {
    if (_selectedItem == selectedItem) {
        return;
    }
    PVDisplayItem *prevItem = _selectedItem;
    _selectedItem = selectedItem;
    
    [prevItem notifySelectionChangeToDelegates];
    [_selectedItem notifySelectionChangeToDelegates];

    [[PVDetailUserActionManager sharedInstance] sendAction:PVDetailUserActionType_SelectedItemChange];
    
    if (NSColorPanel.sharedColorPanelExists) {
        [[NSColorPanel sharedColorPanel] close];
    }

    if (!selectedItem && self.preferenceManager.measureState.currentIntegerValue != PVMeasureState_no) {
        // 如果当前在测距，则取消
        [self.preferenceManager.measureState setIntegerValue:PVMeasureState_no ignoreSubscriber:nil];
    }
}

- (void)setHoveredItem:(PVDisplayItem *)hoveredItem {
    if (_hoveredItem == hoveredItem) {
        return;
    }
    PVDisplayItem *prevItem = _hoveredItem;
    _hoveredItem = hoveredItem;
    [prevItem notifyHoverChangeToDelegates];
    [_hoveredItem notifyHoverChangeToDelegates];
}

- (void)adjustExpansionByIndex:(NSInteger)index referenceDict:(NSDictionary<NSNumber *, NSNumber *> *)referenceDict selectedItem:(PVDisplayItem **)selectedItem {
    if (index < 0 || index > 4) {
        NSAssert(NO, @"adjustExpansionByIndex, index 为 %@", @(index));
        index = MAX(MIN(index, 4), 0);
    }
    
    self.preferenceManager.expansionIndex = index;
    
    __block NSUInteger expandedCount = self.flatItems.count;
    [self.flatItems enumerateObjectsUsingBlock:^(PVDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hasDeterminedExpansion = NO;

        if (!obj.isExpandable) {
            obj.hasDeterminedExpansion = YES;
            expandedCount--;
            return;
        }
        
        if (referenceDict) {
            NSNumber *prevState = referenceDict[@(obj.layerObject.oid)];
            if (prevState != nil) {
                // 旧的对象，直接维持之前的状态
                obj.isExpanded = [prevState boolValue];
                obj.hasDeterminedExpansion = YES;
                if (!obj.isExpanded) {
                    expandedCount--;
                }
            }
        }
    }];
    
    if (index == 0) {
        // 全部折叠，只剩下最顶层的 UIWindow
        
        __block PVDisplayItem *preferedSelectedItem = nil;
        [self.flatItems enumerateObjectsUsingBlock:^(PVDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.hasDeterminedExpansion) {
                return;
            }
            obj.isExpanded = NO;
            
            if (obj.representedAsKeyWindow) {
                preferedSelectedItem = obj;
            }
        }];
            
        if (selectedItem) {
            *selectedItem = preferedSelectedItem;
        }
        
    } else if (index == 4) {
        // 全部展开，包括 UIButton、UITabBar、UINavigationBar 等等，全部展开
        [self.flatItems enumerateObjectsUsingBlock:^(PVDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.hasDeterminedExpansion) {
                return;
            }
            if (obj.inNoPreviewHierarchy) {
                obj.isExpanded = NO;
                return;
            }
            obj.isExpanded = YES;
        }];
        
        if (selectedItem) {
            __block PVDisplayItem *preferedSelectedItem = nil;
            PVDisplayItem *keyWindowRootItem = [self.rawHierarchyInfo.displayItems pv_inspect_firstFiltered:^BOOL(PVDisplayItem *obj) {
                return obj.representedAsKeyWindow;
            }];
            [[PVDisplayItem flatItemsFromHierarchicalItems:@[keyWindowRootItem]] enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(PVDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (!!obj.hostViewControllerObject) {
                    preferedSelectedItem = obj;
                    *stop = YES;
                }
            }];
            *selectedItem = preferedSelectedItem;
        }
        
    } else {
        PVDisplayItem *keyWindowItem = [self.rawHierarchyInfo.displayItems pv_inspect_firstFiltered:^BOOL(PVDisplayItem *windowItem) {
            return windowItem.representedAsKeyWindow;
        }];
        if (!keyWindowItem) {
            keyWindowItem = self.rawHierarchyInfo.displayItems.firstObject;
        }
        [self.rawHierarchyInfo.displayItems enumerateObjectsUsingBlock:^(PVDisplayItem * _Nonnull windowItem, NSUInteger idx, BOOL * _Nonnull stop) {
            if (windowItem == keyWindowItem) {
                return;
            }
            // 非 keyWindow 上的都折叠起来
            [[PVDisplayItem flatItemsFromHierarchicalItems:@[windowItem]] enumerateObjectsUsingBlock:^(PVDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.hasDeterminedExpansion) {
                    return;
                }
                obj.isExpanded = NO;
                obj.hasDeterminedExpansion = YES;
            }];
        }];
        
        NSArray<PVDisplayItem *> *UITransitionViewItems = [keyWindowItem.subitems pv_inspect_filter:^BOOL(PVDisplayItem *obj) {
            return [obj.title isEqualToString:@"UITransitionView"];
        }];
        [UITransitionViewItems enumerateObjectsUsingBlock:^(PVDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.hasDeterminedExpansion) {
                return;
            }
            if (idx == (UITransitionViewItems.count - 1)) {
                // 展开最后一个 UITransitionView
                obj.isExpanded = YES;
            } else {
                // 折叠前几个 UITransitionView
                obj.isExpanded = NO;
            }
            obj.hasDeterminedExpansion = YES;
        }];
        
        NSMutableArray<PVDisplayItem *> *viewControllerItems = [NSMutableArray array];
        [[PVDisplayItem flatItemsFromHierarchicalItems:@[keyWindowItem]] enumerateObjectsUsingBlock:^(PVDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (!!obj.hostViewControllerObject) {
                [viewControllerItems addObject:obj];
                return;
            }
            if (obj.hasDeterminedExpansion) {
                return;
            }
            if (obj.inNoPreviewHierarchy || obj.preferToBeCollapsed || (![PVDetailPreferenceManager mainManager].showHiddenItems && obj.inHiddenHierarchy)) {
                // 把 noPreview 和 UIButton 之类常用控件叠起来
                obj.isExpanded = NO;
                obj.hasDeterminedExpansion = YES;
                return;
            }
            if ([obj itemIsKindOfClassesWithNames:[NSSet setWithObjects:@"UINavigationBar", @"UITabBar", nil]]) {
                // 把 NavigationBar 和 TabBar 折叠起来
                [obj enumerateSelfAndChildren:^(PVDisplayItem *item) {
                    if (item.hasDeterminedExpansion) {
                        return;
                    }
                    item.isExpanded = NO;
                    item.hasDeterminedExpansion = YES;
                }];
                return;
            }
        }];
        
        if (selectedItem) {
            *selectedItem = viewControllerItems.lastObject;
        }
        
        if (index == 1) {
            // 恰好把 viewController 显示出来
            // 倒序，以确保多个 viewController 在同一条树上时，只有最 leaf 的那一个是被折叠的
            [viewControllerItems enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(PVDisplayItem * _Nonnull viewControllerItem, NSUInteger idx, BOOL * _Nonnull stop) {
                [viewControllerItem enumerateSelfAndAncestors:^(PVDisplayItem *item, BOOL *stop) {
                    // 把 viewController 的 ancestors 都展开
                    if (item.hasDeterminedExpansion) {
                        return;
                    }
                    item.isExpanded = (item != viewControllerItem);
                    item.hasDeterminedExpansion = YES;
                }];
            }];
            
            // 剩下未处理的都折叠
            [self.flatItems enumerateObjectsUsingBlock:^(PVDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.hasDeterminedExpansion) {
                    return;
                }
                obj.isExpanded = NO;
            }];
        
        } else if (index == 2) {
            // 从 viewController 开始算向 leaf 多推 3 层
            [viewControllerItems enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(PVDisplayItem * _Nonnull viewControllerItem, NSUInteger idx, BOOL * _Nonnull stop) {
                [viewControllerItem enumerateAncestors:^(PVDisplayItem *item, BOOL *stop) {
                    // 把 viewController 的 ancestors 都展开
                    if (item.hasDeterminedExpansion) {
                        return;
                    }
                    item.isExpanded = YES;
                    item.hasDeterminedExpansion = YES;
                }];
                
                BOOL hasTableOrCollectionView = [viewControllerItem.subitems.firstObject itemIsKindOfClassesWithNames:[NSSet setWithObjects:@"UITableView", @"UICollectionView", nil]];
                // 如果是那种典型的 UITableView 或 UICollectionView 的话，则向 leaf 方向推进 2 层（这样就可以让 cell 恰好露出来而不露出来 cell 的 contentView），否则就推 3 层
                NSUInteger indentsForward = hasTableOrCollectionView ? 2 : 3;

                [viewControllerItem enumerateSelfAndChildren:^(PVDisplayItem *item) {
                    if (item.hasDeterminedExpansion) {
                        return;
                    }
                    if (item.indentLevel < viewControllerItem.indentLevel + indentsForward) {
                        item.isExpanded = YES;
                        item.hasDeterminedExpansion = YES;
                    }
                }];
            }];
            
            // 剩下未处理的都折叠
            [self.flatItems enumerateObjectsUsingBlock:^(PVDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.hasDeterminedExpansion) {
                    return;
                }
                obj.isExpanded = NO;
            }];
            
        } else if (index == 3) {
            // 展开大部分
            [self.flatItems enumerateObjectsUsingBlock:^(PVDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.hasDeterminedExpansion) {
                    return;
                }
                obj.isExpanded = YES;
                obj.hasDeterminedExpansion = YES;
            }];
        }
    }
    
    [self buildDisplayingFlatItems];
}

- (PVDisplayItem *)displayItemWithOid:(unsigned long)oid {
    PVDisplayItem *item = self.oidToDisplayItemMap[@(oid)];
    return item;
}

- (void)setRawFlatItems:(NSArray<PVDisplayItem *> *)rawFlatItems {
    _rawFlatItems = rawFlatItems.copy;
    
    NSMutableDictionary<NSNumber *, PVDisplayItem *> *map = [NSMutableDictionary dictionaryWithCapacity:rawFlatItems.count * 2];
    [rawFlatItems enumerateObjectsUsingBlock:^(PVDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.viewObject.oid) {
            map[@(obj.viewObject.oid)] = obj;
        }
        if (obj.layerObject.oid) {
            map[@(obj.layerObject.oid)] = obj;
        }
    }];
    self.oidToDisplayItemMap = map;
}

- (void)buildDisplayingFlatItems {
    NSMutableArray<PVDisplayItem *> *displayingItems = [NSMutableArray array];
    [self.flatItems enumerateObjectsUsingBlock:^(PVDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.displayingInHierarchy) {
            [displayingItems addObject:obj];
        }
    }];
    self.displayingFlatItems = displayingItems;
}

- (void)collapseItem:(PVDisplayItem *)item {
    if (!item.isExpandable) {
        return;
    }
    if (!item.isExpanded) {
        return;
    }
    item.isExpanded = NO;
    [self buildDisplayingFlatItems];
}

- (void)expandItem:(PVDisplayItem *)item {
    if (!item.isExpandable) {
        return;
    }
    if (item.isExpanded) {
        return;
    }
    item.isExpanded = YES;
    [self buildDisplayingFlatItems];
}

- (void)expandToShowItem:(PVDisplayItem *)item {
    [item enumerateAncestors:^(PVDisplayItem *targetItem, BOOL *stop) {
        if (!targetItem.isExpanded) {
            targetItem.isExpanded = YES;
        }
    }];
    
    [self buildDisplayingFlatItems];
}

- (void)expandItemsRootedByItem:(PVDisplayItem *)item {
    if (item.preferToBeCollapsed) {
        [item enumerateSelfAndChildren:^(PVDisplayItem *targetItem) {
            if (targetItem.isExpandable && !targetItem.isExpanded) {
                targetItem.isExpanded = YES;
            }
        }];
    } else {
        [item enumerateSelfAndChildren:^(PVDisplayItem *targetItem) {
            if (targetItem.isExpandable && !targetItem.isExpanded && ![targetItem preferToBeCollapsed]) {
                targetItem.isExpanded = YES;
            }
        }];
    }
    
    [self buildDisplayingFlatItems];
}

- (void)collapseAllChildrenOfItem:(PVDisplayItem *)item {
    [item enumerateSelfAndChildren:^(PVDisplayItem *enumeratedItem) {
        if (enumeratedItem == item) {
            return;
        }
        if (!enumeratedItem.isExpandable) {
            return;
        }
        if (!enumeratedItem.isExpanded) {
            return;
        }
        enumeratedItem.isExpanded = NO;
    }];
    [self buildDisplayingFlatItems];
}

#pragma mark - Search

- (void)searchWithString:(NSString *)string {
    if (string.length == 0) {
        NSAssert(NO, @"");
        return;
    }
    
    if (self.state != PVDetailHierarchyDataSourceStateSearch) {
        [self.rawFlatItems enumerateObjectsUsingBlock:^(PVDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.isExpandedBeforeSearchOrFocus = obj.isExpanded;
        }];
        self.state = PVDetailHierarchyDataSourceStateSearch;
    }
    
    self.selectedItem = nil;
    
    /// 被打上这个标记的都是本次搜索需要在界面中显示出来的（尽管可能会被折叠）
    NSString *Key_ShouldShow = @"show";
    [self.rawFlatItems enumerateObjectsUsingBlock:^(PVDisplayItem * _Nonnull displayItem, NSUInteger idx, BOOL * _Nonnull stop) {
        // 先
        [displayItem pv_inspect_bindBOOL:NO forKey:Key_ShouldShow];
        displayItem.highlightedSearchString = nil;
    }];
    [self.rawFlatItems enumerateObjectsUsingBlock:^(PVDisplayItem * _Nonnull displayItem, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL isMatched = [displayItem isMatchedWithSearchString:string];
        if (isMatched) {
            displayItem.highlightedSearchString = string;
            [displayItem enumerateAncestors:^(PVDisplayItem *ancestor, BOOL *stop) {
                // 上级元素都显示且展开
                ancestor.isExpanded = YES;
                [ancestor pv_inspect_bindBOOL:YES forKey:Key_ShouldShow];
            }];
            [displayItem enumerateSelfAndChildren:^(PVDisplayItem *selfOrChild) {
                // 自身和下级元素都显示但折叠，允许用户手动展开
                selfOrChild.isExpanded = NO;
                [selfOrChild pv_inspect_bindBOOL:YES forKey:Key_ShouldShow];
            }];
        }
    }];
    
    NSArray<PVDisplayItem *> *flatItems = [self.rawFlatItems pv_inspect_filter:^BOOL(PVDisplayItem *displayItem) {
        BOOL shouldShow = [displayItem pv_inspect_getBindBOOLForKey:Key_ShouldShow];
        if (shouldShow) {
            displayItem.isInSearch = YES;
        }
        return shouldShow;
    }];
    self.flatItems = flatItems;
    [self.didReloadFlatItemsWithSearchOrFocus sendNext:nil];
    
    [self buildDisplayingFlatItems];
}

// 有可能从 normal 状态或 search 状态进入该状态
- (void)focusDisplayItem:(PVDisplayItem *)item {
    [PVDetailAnalytics trackEvent:@"Focus"];

    if (!item) {
        NSAssert(NO, @"");
        return;
    }

    if (self.state == PVDetailHierarchyDataSourceStateNormal) {
        [self.rawFlatItems enumerateObjectsUsingBlock:^(PVDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.isExpandedBeforeSearchOrFocus = obj.isExpanded;
        }];
    } else if (self.state == PVDetailHierarchyDataSourceStateSearch) {
        [self.rawFlatItems enumerateObjectsUsingBlock:^(PVDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.isInSearch = NO;
            obj.highlightedSearchString = nil;
        }];
    }
    self.state = PVDetailHierarchyDataSourceStateFocus;

    NSMutableArray *newFlatItems = [NSMutableArray array];
    [item enumerateSelfAndChildren:^(PVDisplayItem *currItem) {
        [newFlatItems addObject:currItem];
    }];
    self.flatItems = newFlatItems;
    [self.didReloadFlatItemsWithSearchOrFocus sendNext:nil];
    [self buildDisplayingFlatItems];
}

- (void)endFocus {
    if (self.state == PVDetailHierarchyDataSourceStateNormal) {
        return;
    }
    self.state = PVDetailHierarchyDataSourceStateNormal;
    
    [self.rawFlatItems enumerateObjectsUsingBlock:^(PVDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.isExpanded = obj.isExpandedBeforeSearchOrFocus;
    }];
    
    self.flatItems = self.rawFlatItems;
    [self.didReloadFlatItemsWithSearchOrFocus sendNext:nil];
    [self buildDisplayingFlatItems];
}

- (void)endSearch {
    if (self.state == PVDetailHierarchyDataSourceStateNormal) {
        return;
    }
    self.state = PVDetailHierarchyDataSourceStateNormal;
    
    [self.rawFlatItems enumerateObjectsUsingBlock:^(PVDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.isInSearch = NO;
        obj.highlightedSearchString = nil;
        obj.isExpanded = obj.isExpandedBeforeSearchOrFocus;
    }];
    /// 搜索时被选中的 item，在结束搜索后也应该处于被选中且可见的状态
    [self.selectedItem enumerateAncestors:^(PVDisplayItem *item, BOOL *stop) {
        item.isExpanded = YES;
    }];
    
    self.flatItems = self.rawFlatItems;
    [self.didReloadFlatItemsWithSearchOrFocus sendNext:nil];
    
    [self buildDisplayingFlatItems];
}

#pragma mark - Colors

- (NSArray<NSString *> *)aliasForColor:(NSColor *)color {
    if (!color) {
        return nil;
    }
    NSString *rgbaString = color.rgbaString;
    NSArray<NSString *> *names = self.colorToAliasMap[rgbaString];
    return names;
}

- (void)_setUpColors {
    NSMutableDictionary<NSString *, NSMutableArray<NSString *> *> *colorToAliasMap = [NSMutableDictionary dictionary];
    /// 成员可能是 PVDetailSelectColorItem 和 PVDetailSelectColorItemsSection 混杂在一起
    NSMutableArray *aliasColorItemsOrSections = [NSMutableArray array];
    
    /**
     hierarchyInfo.colorAlias 可以有三种结构：
     1）key 是颜色别名，value 是 UIColor/NSColor。即 <NSString *, Color *>
     2）key 是一组颜色的标题，value 是 NSDictionary，而这个 NSDictionary 的 key 是颜色别名，value 是 UIColor / NSColor。即 <NSString *, NSDictionary<NSString *, Color *> *>
     3）以上两者混在一起
     */
    [self.rawHierarchyInfo.colorAlias enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id _Nonnull colorOrDict, BOOL * _Nonnull stop) {
        if ([colorOrDict isKindOfClass:[NSColor class]]) {
            NSString *colorDesc = [((NSColor *)colorOrDict) rgbaString];
            if (colorDesc) {
                if (!colorToAliasMap[colorDesc]) {
                    colorToAliasMap[colorDesc] = [NSMutableArray array];
                }
                [colorToAliasMap[colorDesc] addObject:key];
            }
            
            [aliasColorItemsOrSections addObject:[PVDetailSelectColorItem itemWithTitle:key color:(NSColor *)colorOrDict]];
            
        } else if ([colorOrDict isKindOfClass:[NSDictionary class]]) {
            PVDetailSelectColorItemsSection *section = [PVDetailSelectColorItemsSection new];
            section.title = key;
            NSMutableArray<PVDetailSelectColorItem *> *aliasItems = [NSMutableArray array];
            
            [((NSDictionary *)colorOrDict) enumerateKeysAndObjectsUsingBlock:^(NSString *colorAliaName, NSColor *colorObj, BOOL * _Nonnull stop) {
                NSString *colorDesc = colorObj.rgbaString;
                if (colorDesc) {
                    if (!colorToAliasMap[colorDesc]) {
                        colorToAliasMap[colorDesc] = [NSMutableArray array];
                    }
                    [colorToAliasMap[colorDesc] addObject:colorAliaName];
                }
                
                [aliasItems addObject:[PVDetailSelectColorItem itemWithTitle:colorAliaName color:colorObj]];
            }];
            
            if (aliasItems.count) {
                section.items = aliasItems;
                [aliasColorItemsOrSections addObject:section];
            }
            
        } else {
            NSAssert(NO, @"");
        }
    }];
    
    [aliasColorItemsOrSections sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if ([obj1 isKindOfClass:[PVDetailSelectColorItem class]]) {
            if ([obj2 isKindOfClass:[PVDetailSelectColorItem class]]) {
                return [((PVDetailSelectColorItem *)obj1).title caseInsensitiveCompare:((PVDetailSelectColorItem *)obj2).title];
            }
            if ([obj2 isKindOfClass:[PVDetailSelectColorItemsSection class]]) {
                return NSOrderedAscending;
            }
        }
        if ([obj1 isKindOfClass:[PVDetailSelectColorItemsSection class]]) {
            if ([obj2 isKindOfClass:[PVDetailSelectColorItem class]]) {
                return NSOrderedDescending;
            }
            if ([obj2 isKindOfClass:[PVDetailSelectColorItemsSection class]]) {
                return [((PVDetailSelectColorItemsSection *)obj1).title caseInsensitiveCompare:((PVDetailSelectColorItemsSection *)obj2).title];
            }
        }
        NSAssert(NO, @"");
        return NSOrderedAscending;
    }];
    
    self.colorToAliasMap = colorToAliasMap;
    self.selectColorMenu = [self _makeMenuWithAliasColorItemsOrSections:aliasColorItemsOrSections usingRGBAFormat:[PVDetailPreferenceManager mainManager].rgbaFormat];
}

- (NSMenu *)_makeMenuWithAliasColorItemsOrSections:(NSArray *)AliasColorItemsOrSections usingRGBAFormat:(BOOL)rgbaFormat {
    NSMutableArray *menuModel = [NSMutableArray array];
    
    [menuModel addObject:[PVDetailSelectColorItem itemWithTitle:@"nil" color:nil]];
    [menuModel addObject:[PVDetailSelectColorItem itemWithTitle:@"clear color" color:PVColorRGBAMake(0, 0, 0, 0)]];
    
    NSArray<NSColor *> *defaultColors = @[PVColorMake(0, 0, 0),
                                          PVColorMake(126, 126, 126),
                                          PVColorMake(255, 255, 255),
                                          PVColorRGBAMake(0, 166, 248, .5),
                                          PVColorMake(253, 62, 0),
                                          PVColorMake(105, 190, 0),
                                          PVColorMake(254, 182, 2)];
    NSArray<PVDetailSelectColorItem *> *defaultColorItems = [defaultColors pv_inspect_map:^id(NSUInteger idx, NSColor *value) {
        PVDetailSelectColorItem *item = [PVDetailSelectColorItem new];
        item.color = value;
        if (value) {
            item.title = rgbaFormat ? [value rgbaString]: [value hexString];
        } else {
            item.title = @"nil";
        }
        return item;
    }];
    [menuModel addObjectsFromArray:defaultColorItems];
    
    NSUInteger defaultItemsCount = menuModel.count;
    
    if (AliasColorItemsOrSections) {
        [menuModel addObjectsFromArray:AliasColorItemsOrSections];
    }
    
    NSMenu *menu = [NSMenu new];
    [menuModel enumerateObjectsUsingBlock:^(id itemOrSection, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == defaultItemsCount) {
            [menu addItem:[NSMenuItem separatorItem]];
        }
        
        if ([itemOrSection isKindOfClass:[PVDetailSelectColorItemsSection class]]) {
            PVDetailSelectColorItemsSection *itemsSection = itemOrSection;
            
            NSMenuItem *menuItem = [NSMenuItem new];
            menuItem.image = [[NSImage alloc] initWithSize:NSMakeSize(1, 22)];
            [menu addItem:menuItem];
            menuItem.title = itemsSection.title;
            
            NSMenu *submenu = [NSMenu new];
            [itemsSection.items enumerateObjectsUsingBlock:^(PVDetailSelectColorItem * _Nonnull subAliasItem, NSUInteger idx, BOOL * _Nonnull stop) {
                NSMenuItem *subMenuItem = [self _menuItemFromColorItem:subAliasItem];
                [submenu addItem:subMenuItem];
            }];
            menuItem.submenu = submenu;
            
        } else if ([itemOrSection isKindOfClass:[PVDetailSelectColorItem class]]) {
            NSMenuItem *menuItem = [self _menuItemFromColorItem:itemOrSection];
            [menu addItem:menuItem];
            
        } else {
            NSAssert(NO, @"");
        }
    }];
    
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItem:({
        NSMenuItem *menuItem = [NSMenuItem new];
        menuItem.image = [[NSImage alloc] initWithSize:NSMakeSize(1, 22)];
        menuItem.title = NSLocalizedString(@"Other…", nil);
        menuItem.tag = self.customColorMenuItemTag;
        menuItem;
    })];
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItem:({
        NSMenuItem *menuItem = [NSMenuItem new];
        menuItem.image = [[NSImage alloc] initWithSize:NSMakeSize(1, 22)];
        if (rgbaFormat) {
            menuItem.title = NSLocalizedString(@"Switch color format to HEX", nil);
        } else {
            menuItem.title = NSLocalizedString(@"Switch color format to RGBA", nil);
        }
        menuItem.tag = self.toggleColorFormatMenuItemTag;
        menuItem;
    })];
    
    return menu;
}

- (NSMenuItem *)_menuItemFromColorItem:(PVDetailSelectColorItem *)item {
    NSImage *image = [PVDetailColorIndicatorLayer imageWithColor:item.color shapeSize:NSMakeSize(20, 20) insets:NSEdgeInsetsMake(4, 5, 4, 6)];
    NSMenuItem *menuItem = [NSMenuItem new];
    menuItem.image = image;
    menuItem.title = item.title;
    menuItem.representedObject = item.color;
    return menuItem;
}

- (NSInteger)customColorMenuItemTag {
    return 10;
}

- (NSInteger)toggleColorFormatMenuItemTag {
    return 11;
}

#pragma mark - Others

/// 子类实现该方法
- (PVDetailPreferenceManager *)preferenceManager {
    NSAssert(NO, @"should implement by subclass");
    return nil;
}

- (void)dealloc {
    NSLog(@"%@ dealloc", self.class);
}

- (BOOL)isReadOnly {
    return YES;
}

@end

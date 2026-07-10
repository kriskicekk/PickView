//
//  LKHierarchyDataSource.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "LKHierarchyDataSource.h"
#import "PickViewHierarchyInfo.h"
#import "PickViewDisplayItem.h"
#import "LKPreferenceManager.h"
#import "LKColorIndicatorLayer.h"
#import "LKUserActionManager.h"
#import "PickViewDisplayItem+PickViewClient.h"
#import "LKDanceUIAttrMaker.h"
#import "LKStaticAsyncUpdateManager.h"
@import AppCenter;
@import AppCenterAnalytics;

@interface LKSelectColorItem : NSObject

+ (instancetype)itemWithTitle:(NSString *)title color:(PickViewColor *)color;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, strong) NSColor *color;

@end

@implementation LKSelectColorItem

+ (instancetype)itemWithTitle:(NSString *)title color:(PickViewColor *)color {
    LKSelectColorItem *item = [LKSelectColorItem new];
    item.title = title;
    item.color = color;
    return item;
}

@end

@interface LKSelectColorItemsSection : NSObject

@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSArray<LKSelectColorItem *> *items;

@end

@implementation LKSelectColorItemsSection

- (void)setItems:(NSArray<LKSelectColorItem *> *)items {
    _items = [items sortedArrayUsingComparator:^NSComparisonResult(LKSelectColorItem * _Nonnull obj1, LKSelectColorItem * _Nonnull obj2) {
        return [obj1.title caseInsensitiveCompare:obj2.title];
    }].copy;
}

@end

@interface PickViewDisplayItem (LKHierarchyDataSource)

/// 记录搜索之前的 isExpanded 的值，用来在结束搜索后恢复
@property(nonatomic, assign) BOOL isExpandedBeforeSearchOrFocus;

@end

@implementation PickViewDisplayItem (LKHierarchyDataSource)

- (void)setIsExpandedBeforeSearchOrFocus:(BOOL)isExpandedBeforeSearching {
    [self pickview_bindBOOL:isExpandedBeforeSearching forKey:@"isExpandedBeforeSearching"];
}

- (BOOL)isExpandedBeforeSearchOrFocus {
    return [self pickview_getBindBOOLForKey:@"isExpandedBeforeSearching"];
}

@end

@interface LKHierarchyDataSource ()
@property(nonatomic, assign) LKHierarchyDataSourceState state;

@property(nonatomic, strong, readwrite) PickViewHierarchyInfo *rawHierarchyInfo;

/// displayingFlatItems 是 flatItems 的子集，仅包含用户可以看到的 items，而那些被折叠的 items 会被剔除。换句话说，当用户展开或收起 item 时，displayingFlatItems 属性会被 buildDisplayingFlatItems 方法不断更新
@property(nonatomic, copy, readwrite) NSArray<PickViewDisplayItem *> *displayingFlatItems;

@property(nonatomic, strong, readwrite) NSMenu *selectColorMenu;
@property(nonatomic, copy) NSDictionary<NSNumber *, PickViewDisplayItem *> *oidToDisplayItemMap;

/**
 key 是 rgba 字符串，value 是 alias 字符串数组，比如：
 
 @{
 @"(255, 255, 255, 1)": @[@"MyWhite", @"MainThemeWhite"],
 @"(255, 0, 0, 0.5)": @[@"BestRed", @"TransparentRed"]
 };
 
 */
@property(nonatomic, strong) NSDictionary<NSString *, NSArray<NSString *> *> *colorToAliasMap;

@end

@implementation LKHierarchyDataSource

- (instancetype)init {
    if (self = [super init]) {
        _itemDidChangeHiddenAlphaValue = [RACSubject subject];
        _itemDidChangeAttrGroup = [RACSubject subject];
        _itemDidChangeNoPreview = [RACSubject subject];
        _didReloadHierarchyInfo = [RACSubject subject];
        _willReloadHierarchyInfo = [RACSubject subject];
        _didReloadFlatItemsWithSearchOrFocus = [RACSubject subject];
        
        @weakify(self);
        [[[RACObserve([LKPreferenceManager mainManager], rgbaFormat) skip:1] distinctUntilChanged] subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            [self _setUpColors];
        }];
    }
    return self;
}

- (void)reloadWithHierarchyInfo:(PickViewHierarchyInfo *)info keepState:(BOOL)keepState {
    self.rawHierarchyInfo = info;
    
    [self.willReloadHierarchyInfo sendNext:nil];

    if (info.colorAlias.count) {
        [LKPreferenceManager mainManager].receivingConfigTime_Color = [[NSDate date] timeIntervalSince1970];
    }
    if (info.collapsedClassList.count) {
        [LKPreferenceManager mainManager].receivingConfigTime_Class = [[NSDate date] timeIntervalSince1970];
    }
    
    unsigned long prevSelectedOid = 0;
    NSMutableDictionary *prevExpansionMap = nil;
    if (keepState) {
        prevSelectedOid = self.selectedItem.layerObject.oid;
        
        prevExpansionMap = [NSMutableDictionary dictionary];
        [self.flatItems enumerateObjectsUsingBlock:^(PickViewDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            prevExpansionMap[@(obj.layerObject.oid)] = @(obj.isExpanded);
        }];
    }
    
    // 设置 color alias 和 select color menu
    [self _setUpColors];
    
    // 根据 subitems 属性打平为二维数组，同时给每个 item 设置 indentLevel
    self.rawFlatItems = [PickViewDisplayItem flatItemsFromHierarchicalItems:info.displayItems];
    NSArray<PickViewDisplayItem *> *flatItems = self.rawFlatItems.copy;
    
    // 设置 preferToBeCollapsed 属性
    NSSet<NSString *> *classesPreferredToCollapse = [NSSet setWithObjects:@"UILabel", @"UIPickerView", @"UIProgressView", @"UIActivityIndicatorView", @"UIAlertView", @"UIActionSheet", @"UISearchBar", @"UIButton", @"UITextView", @"UIDatePicker", @"UIPageControl", @"UISegmentedControl", @"UITextField", @"UISlider", @"UISwitch", @"UIVisualEffectView", @"UIImageView", @"WKCommonWebView", @"UITextEffectsWindow", nil];
    if (info.collapsedClassList.count) {
        classesPreferredToCollapse = [classesPreferredToCollapse setByAddingObjectsFromArray:info.collapsedClassList];
    }
    // no preview
    NSSet<NSString *> *classesWithNoPreview = [NSSet setWithArray:@[@"UITextEffectsWindow", @"UIRemoteKeyboardWindow"]];
    
    __block BOOL hasCustomSubviews = NO;
    __block BOOL hasCustomAttrs = NO;
    [flatItems enumerateObjectsUsingBlock:^(PickViewDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj itemIsKindOfClassesWithNames:classesPreferredToCollapse]) {
            [obj enumerateSelfAndChildren:^(PickViewDisplayItem *item) {
                item.preferToBeCollapsed = YES;
            }];
        }
        
        if (obj.indentLevel == 0) {
            if ([obj itemIsKindOfClassesWithNames:classesWithNoPreview]) {
                obj.noPreview = YES;
            }
        }
        
        if (!obj.isUserCustom && !obj.shouldCaptureImage) {
            [obj enumerateSelfAndChildren:^(PickViewDisplayItem *item) {
                item.noPreview = YES;
                item.doNotFetchScreenshotReason = PVDoNotFetchScreenshotForUserConfig;
            }];
        }
//        } else if ([LKPreferenceManager mainManager].showHiddenItems.currentBOOLValue == NO && obj.inHiddenHierarchy) {
//            [obj enumerateSelfAndChildren:^(PickViewDisplayItem *item) {
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
            [LKDanceUIAttrMaker makeDanceUIJumpAttribute:obj danceSource:obj.customInfo.danceuiSource];
        }
        
        if (obj.isUserCustom) {
            hasCustomSubviews = YES;
        }
        if (obj.customAttrGroupList.count > 0) {
            hasCustomAttrs = YES;
        }
    }];
    [MSACAnalytics trackEvent:@"CustomSubview" withProperties:@{@"Has": hasCustomSubviews ? @"True" : @"False"}];
    [MSACAnalytics trackEvent:@"CustomAttrs" withProperties:@{@"Has": hasCustomAttrs ? @"True" : @"False"}];
    
    self.flatItems = flatItems;
    
    // 设置选中
    PickViewDisplayItem *shouldSelectedItem = nil;
    if (keepState) {
        PickViewDisplayItem *prevSelectedItem = [self displayItemWithOid:prevSelectedOid];
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

    if (self.state != LKHierarchyDataSourceStateNormal) {
        // 可能在 search 或 focus 状态，要退出
        self.state = LKHierarchyDataSourceStateNormal;
    }
    
    [self.didReloadHierarchyInfo sendNext:nil];
}

- (NSInteger)numberOfRows {
    return self.displayingFlatItems.count;
}

- (PickViewDisplayItem *)itemAtRow:(NSInteger)index {
    if (index < 0) {
        return nil;
    }
    if ([self.displayingFlatItems pickview_hasIndex:index]) {
        return self.displayingFlatItems[index];
    }
    return nil;
}

- (NSInteger)rowForItem:(PickViewDisplayItem *)item {
    NSInteger row = [self.displayingFlatItems indexOfObject:item];
    return row;
}

- (void)setSelectedItem:(PickViewDisplayItem *)selectedItem {
    if (_selectedItem == selectedItem) {
        return;
    }
    PickViewDisplayItem *prevItem = _selectedItem;
    _selectedItem = selectedItem;
    
    [prevItem notifySelectionChangeToDelegates];
    [_selectedItem notifySelectionChangeToDelegates];

    [[LKUserActionManager sharedInstance] sendAction:LKUserActionType_SelectedItemChange];
    
    if (NSColorPanel.sharedColorPanelExists) {
        [[NSColorPanel sharedColorPanel] close];
    }

    if (!selectedItem && self.preferenceManager.measureState.currentIntegerValue != PVMeasureState_no) {
        // 如果当前在测距，则取消
        [self.preferenceManager.measureState setIntegerValue:PVMeasureState_no ignoreSubscriber:nil];
    }
}

- (void)setHoveredItem:(PickViewDisplayItem *)hoveredItem {
    if (_hoveredItem == hoveredItem) {
        return;
    }
    PickViewDisplayItem *prevItem = _hoveredItem;
    _hoveredItem = hoveredItem;
    [prevItem notifyHoverChangeToDelegates];
    [_hoveredItem notifyHoverChangeToDelegates];
}

- (void)adjustExpansionByIndex:(NSInteger)index referenceDict:(NSDictionary<NSNumber *, NSNumber *> *)referenceDict selectedItem:(PickViewDisplayItem **)selectedItem {
    if (index < 0 || index > 4) {
        NSAssert(NO, @"adjustExpansionByIndex, index 为 %@", @(index));
        index = MAX(MIN(index, 4), 0);
    }
    
    self.preferenceManager.expansionIndex = index;
    
    __block NSUInteger expandedCount = self.flatItems.count;
    [self.flatItems enumerateObjectsUsingBlock:^(PickViewDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
        
        __block PickViewDisplayItem *preferedSelectedItem = nil;
        [self.flatItems enumerateObjectsUsingBlock:^(PickViewDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
        [self.flatItems enumerateObjectsUsingBlock:^(PickViewDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
            __block PickViewDisplayItem *preferedSelectedItem = nil;
            PickViewDisplayItem *keyWindowRootItem = [self.rawHierarchyInfo.displayItems pickview_firstFiltered:^BOOL(PickViewDisplayItem *obj) {
                return obj.representedAsKeyWindow;
            }];
            [[PickViewDisplayItem flatItemsFromHierarchicalItems:@[keyWindowRootItem]] enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(PickViewDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (!!obj.hostViewControllerObject) {
                    preferedSelectedItem = obj;
                    *stop = YES;
                }
            }];
            *selectedItem = preferedSelectedItem;
        }
        
    } else {
        PickViewDisplayItem *keyWindowItem = [self.rawHierarchyInfo.displayItems pickview_firstFiltered:^BOOL(PickViewDisplayItem *windowItem) {
            return windowItem.representedAsKeyWindow;
        }];
        if (!keyWindowItem) {
            keyWindowItem = self.rawHierarchyInfo.displayItems.firstObject;
        }
        [self.rawHierarchyInfo.displayItems enumerateObjectsUsingBlock:^(PickViewDisplayItem * _Nonnull windowItem, NSUInteger idx, BOOL * _Nonnull stop) {
            if (windowItem == keyWindowItem) {
                return;
            }
            // 非 keyWindow 上的都折叠起来
            [[PickViewDisplayItem flatItemsFromHierarchicalItems:@[windowItem]] enumerateObjectsUsingBlock:^(PickViewDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.hasDeterminedExpansion) {
                    return;
                }
                obj.isExpanded = NO;
                obj.hasDeterminedExpansion = YES;
            }];
        }];
        
        NSArray<PickViewDisplayItem *> *UITransitionViewItems = [keyWindowItem.subitems pickview_filter:^BOOL(PickViewDisplayItem *obj) {
            return [obj.title isEqualToString:@"UITransitionView"];
        }];
        [UITransitionViewItems enumerateObjectsUsingBlock:^(PickViewDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
        
        NSMutableArray<PickViewDisplayItem *> *viewControllerItems = [NSMutableArray array];
        [[PickViewDisplayItem flatItemsFromHierarchicalItems:@[keyWindowItem]] enumerateObjectsUsingBlock:^(PickViewDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (!!obj.hostViewControllerObject) {
                [viewControllerItems addObject:obj];
                return;
            }
            if (obj.hasDeterminedExpansion) {
                return;
            }
            if (obj.inNoPreviewHierarchy || obj.preferToBeCollapsed || (![LKPreferenceManager mainManager].showHiddenItems && obj.inHiddenHierarchy)) {
                // 把 noPreview 和 UIButton 之类常用控件叠起来
                obj.isExpanded = NO;
                obj.hasDeterminedExpansion = YES;
                return;
            }
            if ([obj itemIsKindOfClassesWithNames:[NSSet setWithObjects:@"UINavigationBar", @"UITabBar", nil]]) {
                // 把 NavigationBar 和 TabBar 折叠起来
                [obj enumerateSelfAndChildren:^(PickViewDisplayItem *item) {
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
            [viewControllerItems enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(PickViewDisplayItem * _Nonnull viewControllerItem, NSUInteger idx, BOOL * _Nonnull stop) {
                [viewControllerItem enumerateSelfAndAncestors:^(PickViewDisplayItem *item, BOOL *stop) {
                    // 把 viewController 的 ancestors 都展开
                    if (item.hasDeterminedExpansion) {
                        return;
                    }
                    item.isExpanded = (item != viewControllerItem);
                    item.hasDeterminedExpansion = YES;
                }];
            }];
            
            // 剩下未处理的都折叠
            [self.flatItems enumerateObjectsUsingBlock:^(PickViewDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.hasDeterminedExpansion) {
                    return;
                }
                obj.isExpanded = NO;
            }];
        
        } else if (index == 2) {
            // 从 viewController 开始算向 leaf 多推 3 层
            [viewControllerItems enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(PickViewDisplayItem * _Nonnull viewControllerItem, NSUInteger idx, BOOL * _Nonnull stop) {
                [viewControllerItem enumerateAncestors:^(PickViewDisplayItem *item, BOOL *stop) {
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

                [viewControllerItem enumerateSelfAndChildren:^(PickViewDisplayItem *item) {
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
            [self.flatItems enumerateObjectsUsingBlock:^(PickViewDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.hasDeterminedExpansion) {
                    return;
                }
                obj.isExpanded = NO;
            }];
            
        } else if (index == 3) {
            // 展开大部分
            [self.flatItems enumerateObjectsUsingBlock:^(PickViewDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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

- (PickViewDisplayItem *)displayItemWithOid:(unsigned long)oid {
    PickViewDisplayItem *item = self.oidToDisplayItemMap[@(oid)];
    return item;
}

- (void)setRawFlatItems:(NSArray<PickViewDisplayItem *> *)rawFlatItems {
    _rawFlatItems = rawFlatItems.copy;
    
    NSMutableDictionary<NSNumber *, PickViewDisplayItem *> *map = [NSMutableDictionary dictionaryWithCapacity:rawFlatItems.count * 2];
    [rawFlatItems enumerateObjectsUsingBlock:^(PickViewDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
    NSMutableArray<PickViewDisplayItem *> *displayingItems = [NSMutableArray array];
    [self.flatItems enumerateObjectsUsingBlock:^(PickViewDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.displayingInHierarchy) {
            [displayingItems addObject:obj];
        }
    }];
    self.displayingFlatItems = displayingItems;
}

- (void)collapseItem:(PickViewDisplayItem *)item {
    if (!item.isExpandable) {
        return;
    }
    if (!item.isExpanded) {
        return;
    }
    item.isExpanded = NO;
    [self buildDisplayingFlatItems];
}

- (void)expandItem:(PickViewDisplayItem *)item {
    if (!item.isExpandable) {
        return;
    }
    if (item.isExpanded) {
        return;
    }
    item.isExpanded = YES;
    [self buildDisplayingFlatItems];
}

- (void)expandToShowItem:(PickViewDisplayItem *)item {
    [item enumerateAncestors:^(PickViewDisplayItem *targetItem, BOOL *stop) {
        if (!targetItem.isExpanded) {
            targetItem.isExpanded = YES;
        }
    }];
    
    [self buildDisplayingFlatItems];
}

- (void)expandItemsRootedByItem:(PickViewDisplayItem *)item {
    if (item.preferToBeCollapsed) {
        [item enumerateSelfAndChildren:^(PickViewDisplayItem *targetItem) {
            if (targetItem.isExpandable && !targetItem.isExpanded) {
                targetItem.isExpanded = YES;
            }
        }];
    } else {
        [item enumerateSelfAndChildren:^(PickViewDisplayItem *targetItem) {
            if (targetItem.isExpandable && !targetItem.isExpanded && ![targetItem preferToBeCollapsed]) {
                targetItem.isExpanded = YES;
            }
        }];
    }
    
    [self buildDisplayingFlatItems];
}

- (void)collapseAllChildrenOfItem:(PickViewDisplayItem *)item {
    [item enumerateSelfAndChildren:^(PickViewDisplayItem *enumeratedItem) {
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
    
    if (self.state != LKHierarchyDataSourceStateSearch) {
        [self.rawFlatItems enumerateObjectsUsingBlock:^(PickViewDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.isExpandedBeforeSearchOrFocus = obj.isExpanded;
        }];
        self.state = LKHierarchyDataSourceStateSearch;
    }
    
    self.selectedItem = nil;
    
    /// 被打上这个标记的都是本次搜索需要在界面中显示出来的（尽管可能会被折叠）
    NSString *Key_ShouldShow = @"show";
    [self.rawFlatItems enumerateObjectsUsingBlock:^(PickViewDisplayItem * _Nonnull displayItem, NSUInteger idx, BOOL * _Nonnull stop) {
        // 先
        [displayItem pickview_bindBOOL:NO forKey:Key_ShouldShow];
        displayItem.highlightedSearchString = nil;
    }];
    [self.rawFlatItems enumerateObjectsUsingBlock:^(PickViewDisplayItem * _Nonnull displayItem, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL isMatched = [displayItem isMatchedWithSearchString:string];
        if (isMatched) {
            displayItem.highlightedSearchString = string;
            [displayItem enumerateAncestors:^(PickViewDisplayItem *ancestor, BOOL *stop) {
                // 上级元素都显示且展开
                ancestor.isExpanded = YES;
                [ancestor pickview_bindBOOL:YES forKey:Key_ShouldShow];
            }];
            [displayItem enumerateSelfAndChildren:^(PickViewDisplayItem *selfOrChild) {
                // 自身和下级元素都显示但折叠，允许用户手动展开
                selfOrChild.isExpanded = NO;
                [selfOrChild pickview_bindBOOL:YES forKey:Key_ShouldShow];
            }];
        }
    }];
    
    NSArray<PickViewDisplayItem *> *flatItems = [self.rawFlatItems pickview_filter:^BOOL(PickViewDisplayItem *displayItem) {
        BOOL shouldShow = [displayItem pickview_getBindBOOLForKey:Key_ShouldShow];
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
- (void)focusDisplayItem:(PickViewDisplayItem *)item {
    [MSACAnalytics trackEvent:@"Focus"];

    if (!item) {
        NSAssert(NO, @"");
        return;
    }

    if (self.state == LKHierarchyDataSourceStateNormal) {
        [self.rawFlatItems enumerateObjectsUsingBlock:^(PickViewDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.isExpandedBeforeSearchOrFocus = obj.isExpanded;
        }];
    } else if (self.state == LKHierarchyDataSourceStateSearch) {
        [self.rawFlatItems enumerateObjectsUsingBlock:^(PickViewDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.isInSearch = NO;
            obj.highlightedSearchString = nil;
        }];
    }
    self.state = LKHierarchyDataSourceStateFocus;

    NSMutableArray *newFlatItems = [NSMutableArray array];
    [item enumerateSelfAndChildren:^(PickViewDisplayItem *currItem) {
        [newFlatItems addObject:currItem];
    }];
    self.flatItems = newFlatItems;
    [self.didReloadFlatItemsWithSearchOrFocus sendNext:nil];
    [self buildDisplayingFlatItems];
}

- (void)endFocus {
    if (self.state == LKHierarchyDataSourceStateNormal) {
        return;
    }
    self.state = LKHierarchyDataSourceStateNormal;
    
    [self.rawFlatItems enumerateObjectsUsingBlock:^(PickViewDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.isExpanded = obj.isExpandedBeforeSearchOrFocus;
    }];
    
    self.flatItems = self.rawFlatItems;
    [self.didReloadFlatItemsWithSearchOrFocus sendNext:nil];
    [self buildDisplayingFlatItems];
}

- (void)endSearch {
    if (self.state == LKHierarchyDataSourceStateNormal) {
        return;
    }
    self.state = LKHierarchyDataSourceStateNormal;
    
    [self.rawFlatItems enumerateObjectsUsingBlock:^(PickViewDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.isInSearch = NO;
        obj.highlightedSearchString = nil;
        obj.isExpanded = obj.isExpandedBeforeSearchOrFocus;
    }];
    /// 搜索时被选中的 item，在结束搜索后也应该处于被选中且可见的状态
    [self.selectedItem enumerateAncestors:^(PickViewDisplayItem *item, BOOL *stop) {
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
    /// 成员可能是 LKSelectColorItem 和 LKSelectColorItemsSection 混杂在一起
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
            
            [aliasColorItemsOrSections addObject:[LKSelectColorItem itemWithTitle:key color:(NSColor *)colorOrDict]];
            
        } else if ([colorOrDict isKindOfClass:[NSDictionary class]]) {
            LKSelectColorItemsSection *section = [LKSelectColorItemsSection new];
            section.title = key;
            NSMutableArray<LKSelectColorItem *> *aliasItems = [NSMutableArray array];
            
            [((NSDictionary *)colorOrDict) enumerateKeysAndObjectsUsingBlock:^(NSString *colorAliaName, NSColor *colorObj, BOOL * _Nonnull stop) {
                NSString *colorDesc = colorObj.rgbaString;
                if (colorDesc) {
                    if (!colorToAliasMap[colorDesc]) {
                        colorToAliasMap[colorDesc] = [NSMutableArray array];
                    }
                    [colorToAliasMap[colorDesc] addObject:colorAliaName];
                }
                
                [aliasItems addObject:[LKSelectColorItem itemWithTitle:colorAliaName color:colorObj]];
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
        if ([obj1 isKindOfClass:[LKSelectColorItem class]]) {
            if ([obj2 isKindOfClass:[LKSelectColorItem class]]) {
                return [((LKSelectColorItem *)obj1).title caseInsensitiveCompare:((LKSelectColorItem *)obj2).title];
            }
            if ([obj2 isKindOfClass:[LKSelectColorItemsSection class]]) {
                return NSOrderedAscending;
            }
        }
        if ([obj1 isKindOfClass:[LKSelectColorItemsSection class]]) {
            if ([obj2 isKindOfClass:[LKSelectColorItem class]]) {
                return NSOrderedDescending;
            }
            if ([obj2 isKindOfClass:[LKSelectColorItemsSection class]]) {
                return [((LKSelectColorItemsSection *)obj1).title caseInsensitiveCompare:((LKSelectColorItemsSection *)obj2).title];
            }
        }
        NSAssert(NO, @"");
        return NSOrderedAscending;
    }];
    
    self.colorToAliasMap = colorToAliasMap;
    self.selectColorMenu = [self _makeMenuWithAliasColorItemsOrSections:aliasColorItemsOrSections usingRGBAFormat:[LKPreferenceManager mainManager].rgbaFormat];
}

- (NSMenu *)_makeMenuWithAliasColorItemsOrSections:(NSArray *)AliasColorItemsOrSections usingRGBAFormat:(BOOL)rgbaFormat {
    NSMutableArray *menuModel = [NSMutableArray array];
    
    [menuModel addObject:[LKSelectColorItem itemWithTitle:@"nil" color:nil]];
    [menuModel addObject:[LKSelectColorItem itemWithTitle:@"clear color" color:PickViewColorRGBAMake(0, 0, 0, 0)]];
    
    NSArray<NSColor *> *defaultColors = @[PickViewColorMake(0, 0, 0),
                                          PickViewColorMake(126, 126, 126),
                                          PickViewColorMake(255, 255, 255),
                                          PickViewColorRGBAMake(0, 166, 248, .5),
                                          PickViewColorMake(253, 62, 0),
                                          PickViewColorMake(105, 190, 0),
                                          PickViewColorMake(254, 182, 2)];
    NSArray<LKSelectColorItem *> *defaultColorItems = [defaultColors pickview_map:^id(NSUInteger idx, NSColor *value) {
        LKSelectColorItem *item = [LKSelectColorItem new];
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
        
        if ([itemOrSection isKindOfClass:[LKSelectColorItemsSection class]]) {
            LKSelectColorItemsSection *itemsSection = itemOrSection;
            
            NSMenuItem *menuItem = [NSMenuItem new];
            menuItem.image = [[NSImage alloc] initWithSize:NSMakeSize(1, 22)];
            [menu addItem:menuItem];
            menuItem.title = itemsSection.title;
            
            NSMenu *submenu = [NSMenu new];
            [itemsSection.items enumerateObjectsUsingBlock:^(LKSelectColorItem * _Nonnull subAliasItem, NSUInteger idx, BOOL * _Nonnull stop) {
                NSMenuItem *subMenuItem = [self _menuItemFromColorItem:subAliasItem];
                [submenu addItem:subMenuItem];
            }];
            menuItem.submenu = submenu;
            
        } else if ([itemOrSection isKindOfClass:[LKSelectColorItem class]]) {
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

- (NSMenuItem *)_menuItemFromColorItem:(LKSelectColorItem *)item {
    NSImage *image = [LKColorIndicatorLayer imageWithColor:item.color shapeSize:NSMakeSize(20, 20) insets:NSEdgeInsetsMake(4, 5, 4, 6)];
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
- (LKPreferenceManager *)preferenceManager {
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

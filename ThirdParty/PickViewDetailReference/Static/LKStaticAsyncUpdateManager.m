//
//  LKStaticAsyncUpdateManager.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "LKStaticAsyncUpdateManager.h"
#import "PickViewDisplayItem.h"
#import "LKAppsManager.h"
#import "LKStaticHierarchyDataSource.h"
#import "PickViewDisplayItemDetail.h"
#import "LKPreferenceManager.h"
#import "LKProgressIndicatorView.h"
#import "PickViewHierarchyInfo.h"
#import "PickViewStaticAsyncUpdateTask.h"
#import "LKNavigationManager.h"
#import "LKPerformanceReporter.h"
#import "PickViewDisplayItem+PickViewClient.h"
#import "LKPreferenceManager.h"
#import "LKVersionComparer.h"
#import "LKReloadSingleItemUpdateTaskMaker.h"
#import "LKReloadItemAndChildrenUpdateTaskMaker.h"

@interface LKDetailUpdateRequest : NSObject

@property(nonatomic, copy) NSArray<PickViewStaticAsyncUpdateTasksPackage *> *packages;
/// 已经收到回复的 task 的数量（但受限于目前的设计，无法知道具体是哪些 task 收到了回复）
/// detail 有 failureCode 时，也仍然会被算到 finishedTasksCount 里面
@property(nonatomic, assign) NSInteger finishedTasksCount;
@property(nonatomic, assign) NSInteger tasksTotalCount;
@property(nonatomic, assign) NSInteger failedTasksCount;

@end

@implementation LKDetailUpdateRequest

- (BOOL)queryIfContainsTask:(PickViewStaticAsyncUpdateTask *)task {
    for (PickViewStaticAsyncUpdateTasksPackage *pack in self.packages) {
        if ([pack.tasks containsObject:task]) {
            return YES;
        }
    }
    return NO;
}

- (void)removeTaskWithItem:(PickViewDisplayItem *)item {
    for (PickViewStaticAsyncUpdateTasksPackage *pack in self.packages) {
        pack.tasks = [pack.tasks pickview_filter:^BOOL(PickViewStaticAsyncUpdateTask *task) {
            if (task.oid == item.layerObject.oid) {
                return NO;
            } else {
                return YES;
            }
        }];
    }
}

- (NSInteger)tasksTotalCount {
    NSInteger count = 0;
    for (PickViewStaticAsyncUpdateTasksPackage *pack in self.packages) {
        count += pack.tasks.count;
    }
    return count;
}

@end

@interface LKStaticAsyncUpdateManager ()

/// 已经成功收到了所有回复的 request
@property(nonatomic, strong) NSMutableArray<LKDetailUpdateRequest *> *succeededRequests;
/// 已经发送出去、尚未结束的 request
@property(nonatomic, strong) LKDetailUpdateRequest *ongoingRequest;

@end

@implementation LKStaticAsyncUpdateManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static LKStaticAsyncUpdateManager *instance = nil;
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
        self.succeededRequests = [NSMutableArray array];
        _modifyingUpdateProgressSignal = [RACSubject subject];
        _modifyingUpdateErrorSignal = [RACSubject subject];
        
        @weakify(self);
        [[self dataSource].willReloadHierarchyInfo subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            [self.succeededRequests removeAllObjects];
        }];
    }
    return self;
}

- (void)updateAll {
    NSAssert(!LKPreferenceManager.mainManager.fastMode.currentBOOLValue, @"");
    
    LKInspectableApp *app = [LKAppsManager sharedInstance].inspectingApp;
    if (!app || !self.dataSource.flatItems.count) {
        return;
    }
    [self endUpdating];
    
    NSArray<PickViewStaticAsyncUpdateTask *> *newTasks = [self makeMaximumTasks];
    if (newTasks.count == 0) {
        return;
    }
    [self sendTasks:newTasks completion:nil];
}

- (void)endUpdating {
    if (!self.ongoingRequest) {
        return;
    }
    NSLog(@"AsyncUpdate - endUpdating");
    // 这句会触发 sendTasks 方法里的 completed 事件，进而导致 delegate 被通知
    [InspectingApp cancelHierarchyDetailFetching];
}

- (NSArray<PickViewStaticAsyncUpdateTask *> *)makeMaximumTasks {
    // tasks 里的元素顺序很重要：index 更小的 task 会优先被拉取回来展示。所以我们优先把用户可见的图层加进来，这样用户体验更好
    NSMutableArray<PickViewStaticAsyncUpdateTask *> *tasks = [(NSArray<PickViewDisplayItem *> *)self.dataSource.displayingFlatItems pickview_map:^id(NSUInteger idx, PickViewDisplayItem *item) {
        if (item.isUserCustom) {
            return nil;
        }
        if (item.doNotFetchScreenshotReason == PickViewFetchScreenshotPermitted) {
            if (item.isExpandable && item.isExpanded) {
                return [self _taskFromDisplayItem:item type:PickViewStaticAsyncUpdateTaskTypeSoloScreenshot];
            } else {
                return [self _taskFromDisplayItem:item type:PickViewStaticAsyncUpdateTaskTypeGroupScreenshot];
            }
        } else {
            return [self _taskFromDisplayItem:item type:PickViewStaticAsyncUpdateTaskTypeNoScreenshot];
        }
    }].mutableCopy;
    
    [self.dataSource.flatItems enumerateObjectsUsingBlock:^(PickViewDisplayItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        if (item.isUserCustom) {
            return;
        }
        if (item.doNotFetchScreenshotReason == PickViewFetchScreenshotPermitted) {
            PickViewStaticAsyncUpdateTask *task = [self _taskFromDisplayItem:item type:PickViewStaticAsyncUpdateTaskTypeGroupScreenshot];
            if (![tasks containsObject:task]) {
                [tasks addObject:task];
            }
            
            if (item.isExpandable) {
                PickViewStaticAsyncUpdateTask *task2 = [self _taskFromDisplayItem:item type:PickViewStaticAsyncUpdateTaskTypeSoloScreenshot];
                if (![tasks containsObject:task2]) {
                    [tasks addObject:task2];
                }
            }
        } else {
            PickViewStaticAsyncUpdateTask *task = [self _taskFromDisplayItem:item type:PickViewStaticAsyncUpdateTaskTypeNoScreenshot];
            if (![tasks containsObject:task]) {
                [tasks addObject:task];
            }
        }
    }];    
    return tasks.copy;
}

- (NSArray<PickViewStaticAsyncUpdateTasksPackage *> *)_makePackagesFromTasks:(NSArray<PickViewStaticAsyncUpdateTask *> *)tasks {
    NSMutableArray<PickViewStaticAsyncUpdateTasksPackage *> *packages = [NSMutableArray array];
    NSMutableArray<PickViewStaticAsyncUpdateTask *> *bufferTasks = [NSMutableArray array];
    
    __block NSUInteger packageTotalArea = 0;
    NSUInteger packageMaxArea = 2000000;
    NSUInteger packageMaxTasksCount = 100;
    [tasks enumerateObjectsUsingBlock:^(PickViewStaticAsyncUpdateTask * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat currentArea = task.frameSize.width * task.frameSize.height;
        if ((packageTotalArea + currentArea > packageMaxArea) || bufferTasks.count >= packageMaxTasksCount) {
            if (bufferTasks.count > 0) {
                packageTotalArea = 0;
                PickViewStaticAsyncUpdateTasksPackage *package = [PickViewStaticAsyncUpdateTasksPackage new];
                package.tasks = bufferTasks;
                [packages addObject:package];
                [bufferTasks removeAllObjects];
            }
        }
        
        packageTotalArea += currentArea;
        [bufferTasks addObject:task];
    }];
    
    if (bufferTasks.count) {
        PickViewStaticAsyncUpdateTasksPackage *package = [PickViewStaticAsyncUpdateTasksPackage new];
        package.tasks = bufferTasks;
        [packages addObject:package];
    }
    return packages.copy;
}

- (PickViewStaticAsyncUpdateTask *)_taskFromDisplayItem:(PickViewDisplayItem *)item type:(PickViewStaticAsyncUpdateTaskType)type {
    PickViewStaticAsyncUpdateTask *task = [PickViewStaticAsyncUpdateTask new];
    task.oid = item.layerObject.oid;
    task.frameSize = item.frame.size;
    task.taskType = type;
    task.clientReadableVersion = [LKHelper pickviewReadableVersion];
    return task;
}

- (void)updateAfterModifyingDisplayItem:(PickViewDisplayItem *)displayItem {
    LKInspectableApp *app = [LKAppsManager sharedInstance].inspectingApp;
    if (!app) {
        return;
    }
    if (!displayItem) {
        NSAssert(NO, @"");
        return;
    }
    
    NSMutableArray<PickViewStaticAsyncUpdateTask *> *tasks = [NSMutableArray array];
    [displayItem enumerateSelfAndAncestors:^(PickViewDisplayItem *item, BOOL *stop) {
        if (item.doNotFetchScreenshotReason != PickViewFetchScreenshotPermitted) {
            return;
        }
        if (item == displayItem && item.subitems.count) {
            PickViewStaticAsyncUpdateTask *task = [self _taskFromDisplayItem:item type:PickViewStaticAsyncUpdateTaskTypeSoloScreenshot];
            [tasks addObject:task];
        }
        PickViewStaticAsyncUpdateTask *task2 = [self _taskFromDisplayItem:item type:PickViewStaticAsyncUpdateTaskTypeGroupScreenshot];
        [tasks addObject:task2];
    }];
    
    [self.modifyingUpdateProgressSignal sendNext:[RACTwoTuple tupleWithObjectsFromArray:@[@0, @0]]];
    
    @weakify(self);
    NSUInteger screenshotsTotalCount = tasks.count;
    __block NSUInteger receivedScreenshotsCount = 0;
    [[app fetchModificationPatchWithTasks:tasks] subscribeNext:^(PickViewDisplayItemDetail *detail) {
        @strongify(self);
        [[LKStaticHierarchyDataSource sharedInstance] modifyWithDisplayItemDetail:detail];
        
        if (detail.groupScreenshot) {
            receivedScreenshotsCount++;
        }
        if (detail.soloScreenshot) {
            receivedScreenshotsCount++;
        }
        [self.modifyingUpdateProgressSignal sendNext:[RACTwoTuple tupleWithObjectsFromArray:@[@(receivedScreenshotsCount), @(screenshotsTotalCount)]]];
        
    } error:^(NSError * _Nullable error) {
        @strongify(self);
        NSAssert(NO, @"");
        [self.modifyingUpdateProgressSignal sendError:error];
        
    } completed:^{
        @strongify(self);
        NSAssert(screenshotsTotalCount == screenshotsTotalCount, @"");
        [self.modifyingUpdateProgressSignal sendNext:[RACTwoTuple tupleWithObjectsFromArray:@[@(screenshotsTotalCount), @(screenshotsTotalCount)]]];
    }];
}

- (LKStaticHierarchyDataSource *)dataSource {
    return [LKStaticHierarchyDataSource sharedInstance];
}

- (NSArray<PickViewStaticAsyncUpdateTask *> *)makeMinimumTasksForItems:(NSArray<PickViewDisplayItem *> *)items {
    NSArray<PickViewStaticAsyncUpdateTask *> *tasks = [items pickview_map:^id(NSUInteger idx, PickViewDisplayItem *item) {
        if (item.isUserCustom) {
            return nil;
        }
        if (item.appropriateScreenshot != nil) {
            // 已经有图像了，无需再拉取（而且既然有图像了，那么 attrs 必然也有了）
            return nil;
        }
        
        PickViewStaticAsyncUpdateTask *newTask = nil;
        if (item.doNotFetchScreenshotReason == PickViewFetchScreenshotPermitted) {
            // 该图层应该有图像（但是现在没有），所以应该拉取图像
            if (item.isExpandable && item.isExpanded) {
                newTask = [self _taskFromDisplayItem:item type:PickViewStaticAsyncUpdateTaskTypeSoloScreenshot];
            } else {
                newTask = [self _taskFromDisplayItem:item type:PickViewStaticAsyncUpdateTaskTypeGroupScreenshot];
            }
        } else {
            // 该图层确实不应该有图像
            if (item.attributesGroupList.count > 0) {
                // 有 attr 了，说明已经拉取过了，无需再次拉取
                return nil;
            } else {
                // 拉取 attr
                newTask = [self _taskFromDisplayItem:item type:PickViewStaticAsyncUpdateTaskTypeNoScreenshot];
            }
        }
        if (!newTask) {
            return nil;
        }
        
        /// Client 1.0.7 & Server 1.2.7 开始支持 attrRequest 这个参数
        if (item.attributesGroupList.count == 0) {
            newTask.attrRequest = DetailUpdateTaskAttrRequest_Need;
        } else {
            newTask.attrRequest = DetailUpdateTaskAttrRequest_NotNeed;
        }
        
        for (LKDetailUpdateRequest *req in self.succeededRequests) {
            if ([req queryIfContainsTask:newTask]) {
                // 该 task 已经请求成功过，不再重复请求
                return nil;
            }
        }
        return newTask;
    }];
    return tasks;
}

- (void)updateForDisplayingItems {
    NSAssert(LKPreferenceManager.mainManager.fastMode.currentValue, @"");

    LKInspectableApp *app = [LKAppsManager sharedInstance].inspectingApp;
    if (!app) {
        return;
    }
    NSArray *items = [LKStaticHierarchyDataSource sharedInstance].displayingFlatItems;
    if (items.count == 0) {
        return;
    }
    NSArray<PickViewStaticAsyncUpdateTask *> *newTasks = [self makeMinimumTasksForItems:items];
    if (newTasks.count == 0) {
        return;
    }
    [self sendTasks:newTasks completion:nil];
}

- (void)sendTasks:(NSArray<PickViewStaticAsyncUpdateTask *> *)newTasks completion:(void (^)(void))completionBlock {
    LKInspectableApp *app = [LKAppsManager sharedInstance].inspectingApp;
    if (!app || newTasks.count == 0) {
        return;
    }
    // 相同请求不能并发，因此必须先把之前的请求先取消掉
    [self endUpdating];
    
    NSArray<PickViewStaticAsyncUpdateTasksPackage *> *packages = [self _makePackagesFromTasks:newTasks];
    self.ongoingRequest = [LKDetailUpdateRequest new];
    self.ongoingRequest.packages = packages;
    
    [self notifyTasksCountToDelegate];
    
    NSLog(@"AsyncUpdate - Will send %@ tasks.", @(newTasks.count));
    
    @weakify(self);
    [[app fetchHierarchyDetailWithTaskPackages:packages] subscribeNext:^(NSArray<PickViewDisplayItemDetail *> *details) {
        @strongify(self);
        [details enumerateObjectsUsingBlock:^(PickViewDisplayItemDetail * _Nonnull detail, NSUInteger idx, BOOL * _Nonnull stop) {
            if (detail.failureCode == -1) {
                self.ongoingRequest.failedTasksCount += 1;
            } else {
                [[LKStaticHierarchyDataSource sharedInstance] modifyWithDisplayItemDetail:detail];
            }
        }];
        self.ongoingRequest.finishedTasksCount += details.count;
        [self notifyTasksCountToDelegate];
        
    } error:^(NSError * _Nullable error) {
        @strongify(self);
        self.ongoingRequest = nil;
        [self notifyTasksCountToDelegate];
        
        NSString *msgTitle = [NSString stringWithFormat:NSLocalizedString(@"Request timeout, layer data transmission failed.", nil)];
        NSString *msgDetail = NSLocalizedString(@"Perhaps your iOS app is paused with breakpoint in Xcode, blocked by other tasks in main thread, or moved to background state.\nToo large screenshots may also lead to this error.", nil);
        error = PickViewErrorMake(msgTitle, msgDetail);
        [[RACScheduler mainThreadScheduler] afterDelay:1 schedule:^{
            // 此时可能 StaticViewController 还没来得及被初始化导致错误 tips 显示不出来，所以稍等一下
            [self.delegate detailUpdateReceivedError:error];
        }];
    } completed:^{
        // 注意，用户手动取消请求后，也会走到这里
        @strongify(self);
        if (self.ongoingRequest) {
            BOOL userCancel = (self.ongoingRequest.tasksTotalCount > self.ongoingRequest.finishedTasksCount);
            if (!userCancel) {
                [self.succeededRequests addObject:self.ongoingRequest];
            }
            
            if (self.ongoingRequest.failedTasksCount > 0) {
                NSError *error = PickViewErrorMake(NSLocalizedString(@"Some layer data failed to transmit.", nil), NSLocalizedString(@"It may be due to changes in the layer structure within the iOS app. You can try reloading the entire structure in PickView.", nil));
                [self.delegate detailUpdateReceivedError:error];
            }
            
            self.ongoingRequest = nil;
        } else {
            NSAssert(NO, @"");
        }
        [self notifyTasksCountToDelegate];
        [LKPerformanceReporter.sharedInstance didComplete];
        
        if (completionBlock) {
            completionBlock();
        }
    }];
}

- (void)notifyTasksCountToDelegate {
    NSUInteger totalCount = 0;

    for (PickViewStaticAsyncUpdateTasksPackage *pack in self.ongoingRequest.packages) {
        totalCount += pack.tasks.count;
    }
    NSUInteger finishedCount = self.ongoingRequest.finishedTasksCount;

    NSLog(@"AsyncUpdate - notify delagate: %@/%@", @(finishedCount), @(totalCount));
    [self.delegate detailUpdateTasksTotalCount:totalCount finishedCount:finishedCount];
}

- (void)reloadSingleDisplayItem:(PickViewDisplayItem *)item {
    NSArray *tasks = [LKReloadSingleItemUpdateTaskMaker makeWithItem:item];
    if (tasks.count == 0) {
        return;
    }
    [self sendTasks:tasks completion:nil];
}

- (void)reloadDisplayItemAndChildren:(PickViewDisplayItem *)rootItem {
    // 先更新 rootItem 的 basis + attr + subitems
    NSArray *tasks = [LKReloadItemAndChildrenUpdateTaskMaker makeWithItem:rootItem];
    if (tasks.count == 0) {
        return;
    }
    [rootItem enumerateSelfAndChildren:^(PickViewDisplayItem * _Nonnull item) {
        // 把 screenshots 以及完成的任务记录都删掉，因为稍后我们要重新拉取
        // 虽然待会儿返回的新 children 是新的 displayItem 实例，但新的 displayItem 实例的 oid 很可能没有变化，而 task 的 equal 是根据 oid 来计算的
        item.soloScreenshot = nil;
        item.groupScreenshot = nil;
        [self.succeededRequests enumerateObjectsUsingBlock:^(LKDetailUpdateRequest * _Nonnull req, NSUInteger idx, BOOL * _Nonnull stop) {
            [req removeTaskWithItem:item];
        }];
    }];
    
    [self sendTasks:tasks completion:^{
        // 更新 rootItem 以及 children 的图层详情
        [self updateAfterReloadingItemAndChildren:rootItem];
    }];
}

- (void)updateAfterReloadingItemAndChildren:(PickViewDisplayItem *)rootItem {
    // 拉取 rootItem 以及 children 的 screenshots + attr
    if (LKPreferenceManager.mainManager.fastMode.currentBOOLValue) {
        [self updateForDisplayingItems];
    } else {
        NSMutableArray<PickViewStaticAsyncUpdateTask *> *tasks = [NSMutableArray array];
        [rootItem enumerateSelfAndChildren:^(PickViewDisplayItem * _Nonnull item) {
            if (item.isUserCustom) {
                return;
            }
            if (item.doNotFetchScreenshotReason == PickViewFetchScreenshotPermitted) {
                [tasks addObject:[self _taskFromDisplayItem:item type:PickViewStaticAsyncUpdateTaskTypeGroupScreenshot]];
                if (item.isExpandable) {
                    [tasks addObject:[self _taskFromDisplayItem:item type:PickViewStaticAsyncUpdateTaskTypeSoloScreenshot]];
                }
            } else {
                [tasks addObject:[self _taskFromDisplayItem:item type:PickViewStaticAsyncUpdateTaskTypeNoScreenshot]];
            }
        }];
        [self sendTasks:tasks completion:nil];
    }
}

- (BOOL)isUpdating {
    return self.ongoingRequest != nil;
}

@end

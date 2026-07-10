//
//  PVDetailStaticAsyncUpdateManager.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailStaticAsyncUpdateManager.h"
#import "PVDisplayItem.h"
#import "PVDetailAppsManager.h"
#import "PVDetailStaticHierarchyDataSource.h"
#import "PVDisplayItemDetail.h"
#import "PVDetailPreferenceManager.h"
#import "PVDetailProgressIndicatorView.h"
#import "PVHierarchyInfo.h"
#import "PVStaticAsyncUpdateTask.h"
#import "PVDetailNavigationManager.h"
#import "PVDetailPerformanceReporter.h"
#import "PVDisplayItem+PVClient.h"
#import "PVDetailPreferenceManager.h"
#import "PVDetailVersionComparer.h"
#import "PVDetailReloadSingleItemUpdateTaskMaker.h"
#import "PVDetailReloadItemAndChildrenUpdateTaskMaker.h"

@interface PVDetailDetailUpdateRequest : NSObject

@property(nonatomic, copy) NSArray<PVStaticAsyncUpdateTasksPackage *> *packages;
/// 已经收到回复的 task 的数量（但受限于目前的设计，无法知道具体是哪些 task 收到了回复）
/// detail 有 failureCode 时，也仍然会被算到 finishedTasksCount 里面
@property(nonatomic, assign) NSInteger finishedTasksCount;
@property(nonatomic, assign) NSInteger tasksTotalCount;
@property(nonatomic, assign) NSInteger failedTasksCount;

@end

@implementation PVDetailDetailUpdateRequest

- (BOOL)queryIfContainsTask:(PVStaticAsyncUpdateTask *)task {
    for (PVStaticAsyncUpdateTasksPackage *pack in self.packages) {
        if ([pack.tasks containsObject:task]) {
            return YES;
        }
    }
    return NO;
}

- (void)removeTaskWithItem:(PVDisplayItem *)item {
    for (PVStaticAsyncUpdateTasksPackage *pack in self.packages) {
        pack.tasks = [pack.tasks pv_inspect_filter:^BOOL(PVStaticAsyncUpdateTask *task) {
            if ([[item availableObjectOidsPreferView:YES] containsObject:@(task.oid)]) {
                return NO;
            } else {
                return YES;
            }
        }];
    }
}

- (NSInteger)tasksTotalCount {
    NSInteger count = 0;
    for (PVStaticAsyncUpdateTasksPackage *pack in self.packages) {
        count += pack.tasks.count;
    }
    return count;
}

@end

@interface PVDetailStaticAsyncUpdateManager ()

/// 已经成功收到了所有回复的 request
@property(nonatomic, strong) NSMutableArray<PVDetailDetailUpdateRequest *> *succeededRequests;
/// 已经发送出去、尚未结束的 request
@property(nonatomic, strong) PVDetailDetailUpdateRequest *ongoingRequest;

@end

@implementation PVDetailStaticAsyncUpdateManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static PVDetailStaticAsyncUpdateManager *instance = nil;
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
    NSAssert(!PVDetailPreferenceManager.mainManager.fastMode.currentBOOLValue, @"");
    
    PVDetailInspectableApp *app = [PVDetailAppsManager sharedInstance].inspectingApp;
    if (!app || !self.dataSource.flatItems.count) {
        return;
    }
    [self endUpdating];
    
    NSArray<PVStaticAsyncUpdateTask *> *newTasks = [self makeMaximumTasks];
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

- (NSArray<PVStaticAsyncUpdateTask *> *)makeMaximumTasks {
    // tasks 里的元素顺序很重要：index 更小的 task 会优先被拉取回来展示。所以我们优先把用户可见的图层加进来，这样用户体验更好
    NSMutableArray<PVStaticAsyncUpdateTask *> *tasks = [(NSArray<PVDisplayItem *> *)self.dataSource.displayingFlatItems pv_inspect_map:^id(NSUInteger idx, PVDisplayItem *item) {
        if (item.isUserCustom) {
            return nil;
        }
        if (item.doNotFetchScreenshotReason == PVFetchScreenshotPermitted) {
            if (item.isExpandable && item.isExpanded) {
                return [self _taskFromDisplayItem:item type:PVStaticAsyncUpdateTaskTypeSoloScreenshot];
            } else {
                return [self _taskFromDisplayItem:item type:PVStaticAsyncUpdateTaskTypeGroupScreenshot];
            }
        } else {
            return [self _taskFromDisplayItem:item type:PVStaticAsyncUpdateTaskTypeNoScreenshot];
        }
    }].mutableCopy;
    
    [self.dataSource.flatItems enumerateObjectsUsingBlock:^(PVDisplayItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        if (item.isUserCustom) {
            return;
        }
        if (item.doNotFetchScreenshotReason == PVFetchScreenshotPermitted) {
            PVStaticAsyncUpdateTask *task = [self _taskFromDisplayItem:item type:PVStaticAsyncUpdateTaskTypeGroupScreenshot];
            if (![tasks containsObject:task]) {
                [tasks addObject:task];
            }
            
            if (item.isExpandable) {
                PVStaticAsyncUpdateTask *task2 = [self _taskFromDisplayItem:item type:PVStaticAsyncUpdateTaskTypeSoloScreenshot];
                if (![tasks containsObject:task2]) {
                    [tasks addObject:task2];
                }
            }
        } else {
            PVStaticAsyncUpdateTask *task = [self _taskFromDisplayItem:item type:PVStaticAsyncUpdateTaskTypeNoScreenshot];
            if (![tasks containsObject:task]) {
                [tasks addObject:task];
            }
        }
    }];    
    return tasks.copy;
}

- (NSArray<PVStaticAsyncUpdateTasksPackage *> *)_makePackagesFromTasks:(NSArray<PVStaticAsyncUpdateTask *> *)tasks {
    NSMutableArray<PVStaticAsyncUpdateTasksPackage *> *packages = [NSMutableArray array];
    NSMutableArray<PVStaticAsyncUpdateTask *> *bufferTasks = [NSMutableArray array];
    
    __block NSUInteger packageTotalArea = 0;
    NSUInteger packageMaxArea = 2000000;
    NSUInteger packageMaxTasksCount = 100;
    [tasks enumerateObjectsUsingBlock:^(PVStaticAsyncUpdateTask * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat currentArea = task.frameSize.width * task.frameSize.height;
        if ((packageTotalArea + currentArea > packageMaxArea) || bufferTasks.count >= packageMaxTasksCount) {
            if (bufferTasks.count > 0) {
                packageTotalArea = 0;
                PVStaticAsyncUpdateTasksPackage *package = [PVStaticAsyncUpdateTasksPackage new];
                package.tasks = bufferTasks;
                [packages addObject:package];
                [bufferTasks removeAllObjects];
            }
        }
        
        packageTotalArea += currentArea;
        [bufferTasks addObject:task];
    }];
    
    if (bufferTasks.count) {
        PVStaticAsyncUpdateTasksPackage *package = [PVStaticAsyncUpdateTasksPackage new];
        package.tasks = bufferTasks;
        [packages addObject:package];
    }
    return packages.copy;
}

- (PVStaticAsyncUpdateTask *)_taskFromDisplayItem:(PVDisplayItem *)item type:(PVStaticAsyncUpdateTaskType)type {
    BOOL preferViewOid = [PVDetailHelper appInfoLooksLikeMacTarget:self.dataSource.rawHierarchyInfo.appInfo];
    unsigned long oid = [item bestObjectOidPreferView:preferViewOid];
    if (!oid) {
        return nil;
    }
    PVStaticAsyncUpdateTask *task = [PVStaticAsyncUpdateTask new];
    task.oid = oid;
    task.frameSize = item.frame.size;
    task.taskType = type;
    task.needBasisVisualInfo = YES;
    task.clientReadableVersion = [PVDetailHelper pickviewReadableVersion];
    return task;
}

- (void)updateAfterModifyingDisplayItem:(PVDisplayItem *)displayItem {
    PVDetailInspectableApp *app = [PVDetailAppsManager sharedInstance].inspectingApp;
    if (!app) {
        return;
    }
    if (!displayItem) {
        NSAssert(NO, @"");
        return;
    }
    
    NSMutableArray<PVStaticAsyncUpdateTask *> *tasks = [NSMutableArray array];
    [displayItem enumerateSelfAndAncestors:^(PVDisplayItem *item, BOOL *stop) {
        if (item.doNotFetchScreenshotReason != PVFetchScreenshotPermitted) {
            return;
        }
        if (item == displayItem && item.subitems.count) {
            PVStaticAsyncUpdateTask *task = [self _taskFromDisplayItem:item type:PVStaticAsyncUpdateTaskTypeSoloScreenshot];
            if (task) {
                [tasks addObject:task];
            }
        }
        PVStaticAsyncUpdateTask *task2 = [self _taskFromDisplayItem:item type:PVStaticAsyncUpdateTaskTypeGroupScreenshot];
        if (task2) {
            [tasks addObject:task2];
        }
    }];
    
    [self.modifyingUpdateProgressSignal sendNext:[RACTwoTuple tupleWithObjectsFromArray:@[@0, @0]]];
    
    @weakify(self);
    NSUInteger screenshotsTotalCount = tasks.count;
    __block NSUInteger receivedScreenshotsCount = 0;
    [[app fetchModificationPatchWithTasks:tasks] subscribeNext:^(PVDisplayItemDetail *detail) {
        @strongify(self);
        [[PVDetailStaticHierarchyDataSource sharedInstance] modifyWithDisplayItemDetail:detail];
        
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

- (PVDetailStaticHierarchyDataSource *)dataSource {
    return [PVDetailStaticHierarchyDataSource sharedInstance];
}

- (NSArray<PVStaticAsyncUpdateTask *> *)makeMinimumTasksForItems:(NSArray<PVDisplayItem *> *)items {
    NSArray<PVStaticAsyncUpdateTask *> *tasks = [items pv_inspect_map:^id(NSUInteger idx, PVDisplayItem *item) {
        if (item.isUserCustom) {
            return nil;
        }
        if (item.appropriateScreenshot != nil) {
            // 已经有图像了，无需再拉取（而且既然有图像了，那么 attrs 必然也有了）
            return nil;
        }
        
        PVStaticAsyncUpdateTask *newTask = nil;
        if (item.doNotFetchScreenshotReason == PVFetchScreenshotPermitted) {
            // 该图层应该有图像（但是现在没有），所以应该拉取图像
            if (item.isExpandable && item.isExpanded) {
                newTask = [self _taskFromDisplayItem:item type:PVStaticAsyncUpdateTaskTypeSoloScreenshot];
            } else {
                newTask = [self _taskFromDisplayItem:item type:PVStaticAsyncUpdateTaskTypeGroupScreenshot];
            }
        } else {
            // 该图层确实不应该有图像
            if (item.attributesGroupList.count > 0) {
                // 有 attr 了，说明已经拉取过了，无需再次拉取
                return nil;
            } else {
                // 拉取 attr
                newTask = [self _taskFromDisplayItem:item type:PVStaticAsyncUpdateTaskTypeNoScreenshot];
            }
        }
        if (!newTask) {
            return nil;
        }
        
        /// Client 1.0.7 & Server 1.2.7 开始支持 attrRequest 这个参数
        if (item.attributesGroupList.count == 0) {
            newTask.attrRequest = PVDetailUpdateTaskAttrRequest_Need;
        } else {
            newTask.attrRequest = PVDetailUpdateTaskAttrRequest_NotNeed;
        }
        
        for (PVDetailDetailUpdateRequest *req in self.succeededRequests) {
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
    NSAssert(PVDetailPreferenceManager.mainManager.fastMode.currentValue, @"");

    PVDetailInspectableApp *app = [PVDetailAppsManager sharedInstance].inspectingApp;
    if (!app) {
        return;
    }
    NSArray *items = [PVDetailStaticHierarchyDataSource sharedInstance].displayingFlatItems;
    if (items.count == 0) {
        return;
    }
    NSArray<PVStaticAsyncUpdateTask *> *newTasks = [self makeMinimumTasksForItems:items];
    if (newTasks.count == 0) {
        return;
    }
    [self sendTasks:newTasks completion:nil];
}

- (void)sendTasks:(NSArray<PVStaticAsyncUpdateTask *> *)newTasks completion:(void (^)(void))completionBlock {
    PVDetailInspectableApp *app = [PVDetailAppsManager sharedInstance].inspectingApp;
    if (!app || newTasks.count == 0) {
        return;
    }
    // 相同请求不能并发，因此必须先把之前的请求先取消掉
    [self endUpdating];
    
    NSArray<PVStaticAsyncUpdateTasksPackage *> *packages = [self _makePackagesFromTasks:newTasks];
    self.ongoingRequest = [PVDetailDetailUpdateRequest new];
    self.ongoingRequest.packages = packages;
    
    [self notifyTasksCountToDelegate];
    
    NSLog(@"AsyncUpdate - Will send %@ tasks.", @(newTasks.count));
    
    @weakify(self);
    [[app fetchHierarchyDetailWithTaskPackages:packages] subscribeNext:^(NSArray<PVDisplayItemDetail *> *details) {
        @strongify(self);
        [details enumerateObjectsUsingBlock:^(PVDisplayItemDetail * _Nonnull detail, NSUInteger idx, BOOL * _Nonnull stop) {
            if (detail.failureCode == -1) {
                self.ongoingRequest.failedTasksCount += 1;
            } else {
                [[PVDetailStaticHierarchyDataSource sharedInstance] modifyWithDisplayItemDetail:detail];
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
        error = PVInspectErrorMake(msgTitle, msgDetail);
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
                NSError *error = PVInspectErrorMake(NSLocalizedString(@"Some layer data failed to transmit.", nil), NSLocalizedString(@"It may be due to changes in the layer structure within the iOS app. You can try reloading the entire structure in PickView.", nil));
                [self.delegate detailUpdateReceivedError:error];
            }
            
            self.ongoingRequest = nil;
        } else {
            NSAssert(NO, @"");
        }
        [self notifyTasksCountToDelegate];
        [PVDetailPerformanceReporter.sharedInstance didComplete];
        
        if (completionBlock) {
            completionBlock();
        }
    }];
}

- (void)notifyTasksCountToDelegate {
    NSUInteger totalCount = 0;

    for (PVStaticAsyncUpdateTasksPackage *pack in self.ongoingRequest.packages) {
        totalCount += pack.tasks.count;
    }
    NSUInteger finishedCount = self.ongoingRequest.finishedTasksCount;

    NSLog(@"AsyncUpdate - notify delagate: %@/%@", @(finishedCount), @(totalCount));
    [self.delegate detailUpdateTasksTotalCount:totalCount finishedCount:finishedCount];
}

- (void)reloadSingleDisplayItem:(PVDisplayItem *)item {
    NSArray *tasks = [PVDetailReloadSingleItemUpdateTaskMaker makeWithItem:item];
    if (tasks.count == 0) {
        return;
    }
    [self sendTasks:tasks completion:nil];
}

- (void)reloadDisplayItemAndChildren:(PVDisplayItem *)rootItem {
    // 先更新 rootItem 的 basis + attr + subitems
    NSArray *tasks = [PVDetailReloadItemAndChildrenUpdateTaskMaker makeWithItem:rootItem];
    if (tasks.count == 0) {
        return;
    }
    [rootItem enumerateSelfAndChildren:^(PVDisplayItem * _Nonnull item) {
        // 把 screenshots 以及完成的任务记录都删掉，因为稍后我们要重新拉取
        // 虽然待会儿返回的新 children 是新的 displayItem 实例，但新的 displayItem 实例的 oid 很可能没有变化，而 task 的 equal 是根据 oid 来计算的
        item.soloScreenshot = nil;
        item.groupScreenshot = nil;
        [self.succeededRequests enumerateObjectsUsingBlock:^(PVDetailDetailUpdateRequest * _Nonnull req, NSUInteger idx, BOOL * _Nonnull stop) {
            [req removeTaskWithItem:item];
        }];
    }];
    
    [self sendTasks:tasks completion:^{
        // 更新 rootItem 以及 children 的图层详情
        [self updateAfterReloadingItemAndChildren:rootItem];
    }];
}

- (void)updateAfterReloadingItemAndChildren:(PVDisplayItem *)rootItem {
    // 拉取 rootItem 以及 children 的 screenshots + attr
    if (PVDetailPreferenceManager.mainManager.fastMode.currentBOOLValue) {
        [self updateForDisplayingItems];
    } else {
        NSMutableArray<PVStaticAsyncUpdateTask *> *tasks = [NSMutableArray array];
        [rootItem enumerateSelfAndChildren:^(PVDisplayItem * _Nonnull item) {
            if (item.isUserCustom) {
                return;
            }
            if (item.doNotFetchScreenshotReason == PVFetchScreenshotPermitted) {
                [tasks addObject:[self _taskFromDisplayItem:item type:PVStaticAsyncUpdateTaskTypeGroupScreenshot]];
                if (item.isExpandable) {
                    [tasks addObject:[self _taskFromDisplayItem:item type:PVStaticAsyncUpdateTaskTypeSoloScreenshot]];
                }
            } else {
                [tasks addObject:[self _taskFromDisplayItem:item type:PVStaticAsyncUpdateTaskTypeNoScreenshot]];
            }
        }];
        [self sendTasks:tasks completion:nil];
    }
}

- (BOOL)isUpdating {
    return self.ongoingRequest != nil;
}

@end

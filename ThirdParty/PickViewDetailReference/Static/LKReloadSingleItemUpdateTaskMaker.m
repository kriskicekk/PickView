//
//  LKReloadSingleItemUpdateTaskMaker.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "LKReloadSingleItemUpdateTaskMaker.h"
#import "LKStaticAsyncUpdateManager.h"
#import "LKAppsManager.h"
#import "LKVersionComparer.h"

@implementation LKReloadSingleItemUpdateTaskMaker

+ (NSArray<PickViewStaticAsyncUpdateTask *> *)makeWithItem:(PickViewDisplayItem *)item {
    if (!item || [LKStaticAsyncUpdateManager sharedInstance].isUpdating) {
        NSAssert(NO, @"");
        return nil;
    }
    NSString *serverVersion = [[LKAppsManager sharedInstance] inspectingApp].appInfo.serverReadableVersion;
    BOOL supported = [LKVersionComparer compareWithExpectedVersion:@"1.2.7" realVersion:serverVersion];
    if (!supported) {
        AlertErrorText(NSLocalizedString(@"Operation failed.", nil), NSLocalizedString(@"Please upgrade the PickViewServer SDK version in your iOS project to 1.2.7 or higher.", nil), CurrentKeyWindow);
        return nil;
    }
    NSMutableArray<PickViewStaticAsyncUpdateTask *> *tasks = [NSMutableArray array];

    if (item.doNotFetchScreenshotReason == PickViewFetchScreenshotPermitted) {
        PickViewStaticAsyncUpdateTask *task = [self taskFromItem:item];
        task.taskType = PickViewStaticAsyncUpdateTaskTypeGroupScreenshot;
        [tasks addObject:task];
        
        if (item.isExpandable) {
            PickViewStaticAsyncUpdateTask *task2 = [self taskFromItem:item];
            task2.taskType = PickViewStaticAsyncUpdateTaskTypeSoloScreenshot;
            [tasks addObject:task2];
        }
    } else {
        PickViewStaticAsyncUpdateTask *task = [self taskFromItem:item];
        task.taskType = PickViewStaticAsyncUpdateTaskTypeNoScreenshot;
        [tasks addObject:task];
    }
    [tasks firstObject].needBasisVisualInfo = YES;
    return tasks;
}

+ (PickViewStaticAsyncUpdateTask *)taskFromItem:(PickViewDisplayItem *)item {
    PickViewStaticAsyncUpdateTask *task = [PickViewStaticAsyncUpdateTask new];
    task.oid = item.layerObject.oid;
    task.frameSize = item.frame.size;
    task.clientReadableVersion = [LKHelper pickviewReadableVersion];
    return task;
}

@end

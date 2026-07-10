//
//  PVDetailReloadSingleItemUpdateTaskMaker.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailReloadSingleItemUpdateTaskMaker.h"
#import "PVDetailStaticAsyncUpdateManager.h"
#import "PVDetailAppsManager.h"
#import "PVDetailVersionComparer.h"

@implementation PVDetailReloadSingleItemUpdateTaskMaker

+ (NSArray<PVStaticAsyncUpdateTask *> *)makeWithItem:(PVDisplayItem *)item {
    if (!item || [PVDetailStaticAsyncUpdateManager sharedInstance].isUpdating) {
        NSAssert(NO, @"");
        return nil;
    }
    NSString *serverVersion = [[PVDetailAppsManager sharedInstance] inspectingApp].appInfo.serverReadableVersion;
    BOOL supported = [PVDetailVersionComparer compareWithExpectedVersion:@"1.2.7" realVersion:serverVersion];
    if (!supported) {
        AlertErrorText(NSLocalizedString(@"Operation failed.", nil), NSLocalizedString(@"Please upgrade the PickViewServer SDK version in your iOS project to 1.2.7 or higher.", nil), CurrentKeyWindow);
        return nil;
    }
    NSMutableArray<PVStaticAsyncUpdateTask *> *tasks = [NSMutableArray array];

    if (item.doNotFetchScreenshotReason == PVFetchScreenshotPermitted) {
        PVStaticAsyncUpdateTask *task = [self taskFromItem:item];
        task.taskType = PVStaticAsyncUpdateTaskTypeGroupScreenshot;
        [tasks addObject:task];
        
        if (item.isExpandable) {
            PVStaticAsyncUpdateTask *task2 = [self taskFromItem:item];
            task2.taskType = PVStaticAsyncUpdateTaskTypeSoloScreenshot;
            [tasks addObject:task2];
        }
    } else {
        PVStaticAsyncUpdateTask *task = [self taskFromItem:item];
        task.taskType = PVStaticAsyncUpdateTaskTypeNoScreenshot;
        [tasks addObject:task];
    }
    [tasks firstObject].needBasisVisualInfo = YES;
    return tasks;
}

+ (PVStaticAsyncUpdateTask *)taskFromItem:(PVDisplayItem *)item {
    PVStaticAsyncUpdateTask *task = [PVStaticAsyncUpdateTask new];
    task.oid = item.layerObject.oid;
    task.frameSize = item.frame.size;
    task.clientReadableVersion = [PVDetailHelper pickviewReadableVersion];
    return task;
}

@end

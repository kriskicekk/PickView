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
#import "PVAppInfo.h"
#import "PVDisplayItem+PVClient.h"
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
        if (!task) {
            return nil;
        }
        task.taskType = PVStaticAsyncUpdateTaskTypeGroupScreenshot;
        [tasks addObject:task];
        
        if (item.isExpandable) {
            PVStaticAsyncUpdateTask *task2 = [self taskFromItem:item];
            if (task2) {
                task2.taskType = PVStaticAsyncUpdateTaskTypeSoloScreenshot;
                [tasks addObject:task2];
            }
        }
    } else {
        PVStaticAsyncUpdateTask *task = [self taskFromItem:item];
        if (!task) {
            return nil;
        }
        task.taskType = PVStaticAsyncUpdateTaskTypeNoScreenshot;
        [tasks addObject:task];
    }
    return tasks;
}

+ (PVStaticAsyncUpdateTask *)taskFromItem:(PVDisplayItem *)item {
    PVAppInfo *appInfo = [PVDetailAppsManager sharedInstance].inspectingApp.appInfo;
    BOOL preferViewOid = [PVDetailHelper appInfoLooksLikeMacTarget:appInfo];
    unsigned long oid = [item bestObjectOidPreferView:preferViewOid];
    if (!oid) {
        return nil;
    }
    PVStaticAsyncUpdateTask *task = [PVStaticAsyncUpdateTask new];
    task.oid = oid;
    task.frameSize = item.frame.size;
    task.needBasisVisualInfo = YES;
    task.clientReadableVersion = [PVDetailHelper pickviewReadableVersion];
    return task;
}

@end

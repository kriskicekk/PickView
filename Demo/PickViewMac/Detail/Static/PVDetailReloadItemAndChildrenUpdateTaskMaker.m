//
//  PVDetailReloadItemAndChildrenUpdateTaskMaker.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailReloadItemAndChildrenUpdateTaskMaker.h"
#import "PVDetailStaticAsyncUpdateManager.h"
#import "PVDetailAppsManager.h"
#import "PVDetailVersionComparer.h"

@implementation PVDetailReloadItemAndChildrenUpdateTaskMaker

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
    PVStaticAsyncUpdateTask *task = [PVStaticAsyncUpdateTask new];
    task.oid = item.layerObject.oid;
    task.taskType = PVStaticAsyncUpdateTaskTypeNoScreenshot;
    task.attrRequest = PVDetailUpdateTaskAttrRequest_NotNeed;
    task.needBasisVisualInfo = YES;
    task.needSubitems = YES;
    task.frameSize = item.frame.size;
    task.clientReadableVersion = [PVDetailHelper pickviewReadableVersion];
    return @[task];
}

@end

//
//  LKReloadItemAndChildrenUpdateTaskMaker.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "LKReloadItemAndChildrenUpdateTaskMaker.h"
#import "LKStaticAsyncUpdateManager.h"
#import "LKAppsManager.h"
#import "LKVersionComparer.h"

@implementation LKReloadItemAndChildrenUpdateTaskMaker

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
    PickViewStaticAsyncUpdateTask *task = [PickViewStaticAsyncUpdateTask new];
    task.oid = item.layerObject.oid;
    task.taskType = PickViewStaticAsyncUpdateTaskTypeNoScreenshot;
    task.attrRequest = DetailUpdateTaskAttrRequest_NotNeed;
    task.needBasisVisualInfo = YES;
    task.needSubitems = YES;
    task.frameSize = item.frame.size;
    task.clientReadableVersion = [LKHelper pickviewReadableVersion];
    return @[task];
}

@end

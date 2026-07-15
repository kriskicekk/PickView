//
//  PVDetailReloadItemAndChildrenUpdateTaskMaker.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import <Foundation/Foundation.h>
#import "PVStaticAsyncUpdateTask.h"

@interface PVDetailReloadItemAndChildrenUpdateTaskMaker : NSObject

+ (NSArray<PVStaticAsyncUpdateTask *> *)makeWithItem:(PVDisplayItem *)item;

@end

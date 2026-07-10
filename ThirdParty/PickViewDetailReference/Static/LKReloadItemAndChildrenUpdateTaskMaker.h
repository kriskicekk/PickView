//
//  LKReloadItemAndChildrenUpdateTaskMaker.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import <Foundation/Foundation.h>
#import "PickViewStaticAsyncUpdateTask.h"

@interface LKReloadItemAndChildrenUpdateTaskMaker : NSObject

+ (NSArray<PickViewStaticAsyncUpdateTask *> *)makeWithItem:(PickViewDisplayItem *)item;

@end

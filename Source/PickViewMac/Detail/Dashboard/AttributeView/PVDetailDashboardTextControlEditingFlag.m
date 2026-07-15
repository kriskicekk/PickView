//
//  PVDetailDashboardTextControlEditingFlag.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailDashboardTextControlEditingFlag.h"

@implementation PVDetailDashboardTextControlEditingFlag

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static PVDetailDashboardTextControlEditingFlag *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self sharedInstance];
}

@end

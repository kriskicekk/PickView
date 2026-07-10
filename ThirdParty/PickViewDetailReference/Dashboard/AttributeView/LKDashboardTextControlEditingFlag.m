//
//  LKDashboardTextControlEditingFlag.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "LKDashboardTextControlEditingFlag.h"

@implementation LKDashboardTextControlEditingFlag

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static LKDashboardTextControlEditingFlag *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self sharedInstance];
}

@end

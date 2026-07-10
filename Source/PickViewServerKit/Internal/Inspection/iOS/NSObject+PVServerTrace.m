//
//  NSObject+PVServerTrace.m
//  PickViewServer
//
//  Created by kris cheng on 2026/7/10.
//

#import "NSObject+PVServerTrace.h"

#import "PVIvarTrace.h"

#import <objc/runtime.h>

@implementation NSObject (PVServerTrace)

- (void)setLks_ivarTraces:(NSArray<PVIvarTrace *> *)lks_ivarTraces {
    objc_setAssociatedObject(self, @selector(lks_ivarTraces), lks_ivarTraces.copy, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSArray<PVIvarTrace *> *)lks_ivarTraces {
    return objc_getAssociatedObject(self, _cmd);
}

@end

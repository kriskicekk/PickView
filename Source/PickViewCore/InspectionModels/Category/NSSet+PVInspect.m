//
//  NSSet+PVInspect.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "NSSet+PVInspect.h"

@implementation NSSet (PickView)

- (NSSet *)pv_inspect_map:(id (^)(id obj))block {
    if (!block) {
        NSAssert(NO, @"");
        return nil;
    }
    
    NSMutableSet *newSet = [NSMutableSet setWithCapacity:self.count];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        id newObj = block(obj);
        if (newObj) {
            [newSet addObject:newObj];
        }
    }];
    return [newSet copy];
}

- (id)pv_inspect_firstFiltered:(BOOL (^)(id obj))block {
    if (!block) {
        NSAssert(NO, @"");
        return nil;
    }
    
    __block id targetObj = nil;
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (block(obj)) {
            targetObj = obj;
            *stop = YES;
        }
    }];
    return targetObj;
}

- (NSSet *)pv_inspect_filter:(BOOL (^)(id obj))block {
    if (!block) {
        NSAssert(NO, @"");
        return nil;
    }
    
    NSMutableSet *mSet = [NSMutableSet set];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (block(obj)) {
            [mSet addObject:obj];
        }
    }];
    return [mSet copy];
}

- (BOOL)pv_inspect_any:(BOOL (^)(id obj))block {
    if (!block) {
        NSAssert(NO, @"");
        return NO;
    }
    __block BOOL boolValue = NO;
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (block(obj)) {
            boolValue = YES;
            *stop = YES;
        }
    }];
    return boolValue;
}

@end


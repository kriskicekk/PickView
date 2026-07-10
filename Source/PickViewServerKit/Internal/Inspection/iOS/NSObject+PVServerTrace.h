//
//  NSObject+PVServerTrace.h
//  PickViewServer
//
//  Created by kris cheng on 2026/7/10.
//

#import <Foundation/Foundation.h>

@class PVIvarTrace;

@interface NSObject (PVServerTrace)

@property(nonatomic, copy) NSArray<PVIvarTrace *> *lks_ivarTraces;

@end

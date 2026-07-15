//
//  PVDetailReadHierarchyDataSource.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailHierarchyDataSource.h"

@class PVHierarchyFile, PVDetailPreferenceManager;

@interface PVDetailReadHierarchyDataSource : PVDetailHierarchyDataSource

- (instancetype)initWithFile:(PVHierarchyFile *)file preferenceManager:(PVDetailPreferenceManager *)manager;

@end

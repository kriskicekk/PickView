//
//  PVDetailReadWindowController.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailWindowController.h"

@class PVHierarchyFile, PVDetailPreferenceManager;

@interface PVDetailReadWindowController : PVDetailWindowController

- (instancetype)initWithFile:(PVHierarchyFile *)file;

@end

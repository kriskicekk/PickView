//
//  PVDetailDocument.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import <Cocoa/Cocoa.h>

@class PVHierarchyFile;

@interface PVDetailDocument : NSDocument

@property(nonatomic, strong) PVHierarchyFile *hierarchyFile;

@end

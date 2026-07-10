//
//  PVDetailExportManager.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import <Foundation/Foundation.h>

@class PVHierarchyInfo, PVDisplayItem;

@interface PVDetailExportManager : NSObject

+ (instancetype)sharedInstance;

- (NSData *)dataFromHierarchyInfo:(PVHierarchyInfo *)info imageCompression:(CGFloat)compression fileName:(NSString **)fileName;

+ (void)exportScreenshotWithDisplayItem:(PVDisplayItem *)displayItem;

@end

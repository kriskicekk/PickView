//
//  PVDetailReadHierarchyDataSource.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailReadHierarchyDataSource.h"
#import "PVHierarchyFile.h"
#import "PVDisplayItem.h"
#import "PVDetailPreferenceManager.h"
#import "PVHierarchyInfo.h"

@interface PVDetailReadHierarchyDataSource ()

@property(nonatomic, strong) PVDetailPreferenceManager *readPreferenceManager;

@end

@implementation PVDetailReadHierarchyDataSource

- (instancetype)initWithFile:(PVHierarchyFile *)file preferenceManager:(PVDetailPreferenceManager *)manager {
    if (self = [self init]) {
        self.readPreferenceManager = manager;
        
        [self reloadWithHierarchyInfo:file.hierarchyInfo keepState:NO];

        if (file.soloScreenshots.count || file.groupScreenshots.count) {
            [self.flatItems enumerateObjectsUsingBlock:^(PVDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                unsigned long oid = obj.layerObject.oid;
                
                NSData *soloData = file.soloScreenshots[@(oid)];
                if (soloData) {
                    NSImage *soloImage = [[NSImage alloc] initWithData:soloData];
                    obj.soloScreenshot = soloImage;
                }
                
                NSData *groupData = file.groupScreenshots[@(oid)];
                if (groupData) {
                    NSImage *groupImage = [[NSImage alloc] initWithData:groupData];
                    obj.groupScreenshot = groupImage;                    
                }
            }];
        }
    }
    return self;
}

- (PVDetailPreferenceManager *)preferenceManager {
    return self.readPreferenceManager;
}

@end

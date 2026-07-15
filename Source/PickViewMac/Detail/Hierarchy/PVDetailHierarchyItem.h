//
//  PVDetailHierarchyItem.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, PVDetailHierarchyItemStatus) {
    PVDetailHierarchyItemStatusNotExpandable,
    PVDetailHierarchyItemStatusExpanded,
    PVDetailHierarchyItemStatusCollapsed
};

@interface PVDetailHierarchyItem : NSObject

@property(nonatomic, copy) NSArray<PVDetailHierarchyItem *> *subItems;

@property(nonatomic, weak, readonly) PVDetailHierarchyItem *superItem;

@property(nonatomic, assign) PVDetailHierarchyItemStatus status;

@property(nonatomic, assign, readonly) NSUInteger indentation;

- (NSArray<PVDetailHierarchyItem *> *)flatItems;

+ (NSArray<PVDetailHierarchyItem *> *)flatItemsFromRootItems:(NSArray<PVDetailHierarchyItem *> *)items;

@end

//
//  PVDetailOutlineItem.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, PVDetailOutlineItemStatus) {
    PVDetailOutlineItemStatusNotExpandable,
    PVDetailOutlineItemStatusExpanded,
    PVDetailOutlineItemStatusCollapsed
};

@interface PVDetailOutlineItem : NSObject

@property(nonatomic, strong) NSArray<PVDetailOutlineItem *> *subItems;

@property(nonatomic, assign) PVDetailOutlineItemStatus status;

@property(nonatomic, copy) NSString *titleText;

@property(nonatomic, strong) NSImage *image;

@property(nonatomic, assign, readonly) NSUInteger indentation;

+ (NSArray<PVDetailOutlineItem *> *)flatItemsFromRootItems:(NSArray<PVDetailOutlineItem *> *)items;

@end

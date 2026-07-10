//
//  LKOutlineItem.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, LKOutlineItemStatus) {
    LKOutlineItemStatusNotExpandable,
    LKOutlineItemStatusExpanded,
    LKOutlineItemStatusCollapsed
};

@interface LKOutlineItem : NSObject

@property(nonatomic, strong) NSArray<LKOutlineItem *> *subItems;

@property(nonatomic, assign) LKOutlineItemStatus status;

@property(nonatomic, copy) NSString *titleText;

@property(nonatomic, strong) NSImage *image;

@property(nonatomic, assign, readonly) NSUInteger indentation;

+ (NSArray<LKOutlineItem *> *)flatItemsFromRootItems:(NSArray<LKOutlineItem *> *)items;

@end

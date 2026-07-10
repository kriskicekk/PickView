//
//  PVDisplayItem.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#ifndef PVDisplayItem_h
#define PVDisplayItem_h

#import "PVCustomDisplayItemInfo.h"
#import "PVInspectionDefines.h"
#import "PVObject.h"

#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>

@class PVAttributesGroup;
@class PVEventHandler;
@class PVDisplayItem;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PVDisplayItemImageEncodeType) {
    PVDisplayItemImageEncodeTypeNone,
    PVDisplayItemImageEncodeTypeNSData,
    PVDisplayItemImageEncodeTypeImage
};

typedef NS_ENUM(NSUInteger, PVDoNotFetchScreenshotReason) {
    PVFetchScreenshotPermitted,
    PVDoNotFetchScreenshotForTooLarge,
    PVDoNotFetchScreenshotForUserConfig
};

typedef NS_ENUM(NSUInteger, PVDisplayItemProperty) {
    PVDisplayItemProperty_None,
    PVDisplayItemProperty_FrameToRoot,
    PVDisplayItemProperty_DisplayingInHierarchy,
    PVDisplayItemProperty_InHiddenHierarchy,
    PVDisplayItemProperty_IsExpandable,
    PVDisplayItemProperty_IsExpanded,
    PVDisplayItemProperty_SoloScreenshot,
    PVDisplayItemProperty_GroupScreenshot,
    PVDisplayItemProperty_IsSelected,
    PVDisplayItemProperty_IsHovered,
    PVDisplayItemProperty_AvoidSyncScreenshot,
    PVDisplayItemProperty_InNoPreviewHierarchy,
    PVDisplayItemProperty_IsInSearch,
    PVDisplayItemProperty_HighlightedSearchString,
};

@protocol PVDisplayItemDelegate <NSObject>

- (void)displayItem:(PVDisplayItem *)displayItem propertyDidChange:(PVDisplayItemProperty)property;

@end

@interface PVDisplayItem : NSObject <NSSecureCoding, NSCopying>

@property (nonatomic, copy) NSString *objectID;
@property (nonatomic, copy) NSString *displayName;
@property (nonatomic, copy) NSString *viewClassName;
@property (nonatomic, copy) NSString *layerClassName;
@property (nonatomic, copy) NSString *backgroundColorText;
@property (nonatomic, copy) NSArray<PVDisplayItem *> *children;

@property (nonatomic, strong, nullable) PVCustomDisplayItemInfo *customInfo;
@property (nonatomic, copy) NSArray<PVDisplayItem *> *subitems;
@property (nonatomic, assign) BOOL isHidden;
@property (nonatomic, assign) BOOL hidden;
@property (nonatomic, assign) float alpha;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, assign) CGRect bounds;
@property (nonatomic, strong, nullable) PVImage *soloScreenshot;
@property (nonatomic, strong, nullable) PVImage *groupScreenshot;
@property (nonatomic, strong, nullable) PVObject *windowObject;
@property (nonatomic, strong, nullable) PVObject *viewObject;
@property (nonatomic, strong, nullable) PVObject *layerObject;
@property (nonatomic, strong, nullable) PVObject *hostWindowControllerObject;
@property (nonatomic, strong, nullable) PVObject *hostViewControllerObject;
@property (nonatomic, copy) NSArray<PVAttributesGroup *> *attributesGroupList;
@property (nonatomic, copy) NSArray<PVAttributesGroup *> *customAttrGroupList;
- (NSArray<PVAttributesGroup *> *)queryAllAttrGroupList;
@property (nonatomic, copy) NSArray<PVEventHandler *> *eventHandlers;
@property (nonatomic, assign) BOOL representedAsKeyWindow;
@property (nonatomic, strong, nullable) PVColor *backgroundColor;
@property (nonatomic, assign) BOOL shouldCaptureImage;
@property (nonatomic, copy, nullable) NSString *customDisplayTitle;
@property (nonatomic, copy, nullable) NSString *danceuiSource;

@property (nonatomic, weak, nullable) id<PVDisplayItemDelegate> previewItemDelegate;
@property (nonatomic, weak, nullable) id<PVDisplayItemDelegate> rowViewDelegate;
@property (nonatomic, weak, nullable) PVDisplayItem *superItem;
- (nullable PVObject *)displayingObject;
- (NSInteger)indentLevel;
@property (nonatomic, assign) BOOL isExpanded;
@property (nonatomic, assign, readonly) BOOL isExpandable;
@property (nonatomic, assign, readonly) BOOL displayingInHierarchy;
@property (nonatomic, assign, readonly) BOOL inHiddenHierarchy;
@property (nonatomic, assign) PVDisplayItemImageEncodeType screenshotEncodeType;
@property (nonatomic, assign) PVDoNotFetchScreenshotReason doNotFetchScreenshotReason;
@property (nonatomic, weak, nullable) id previewLayer;
@property (nonatomic, weak, nullable) id previewNode;
@property (nonatomic, assign) BOOL noPreview;
@property (nonatomic, assign, readonly) BOOL inNoPreviewHierarchy;
@property (nonatomic, assign) NSInteger previewZIndex;
@property (nonatomic, assign) BOOL preferToBeCollapsed;
@property (nonatomic, assign) BOOL hasDeterminedExpansion;
@property (nonatomic, assign) BOOL isInSearch;
@property (nonatomic, copy, nullable) NSString *highlightedSearchString;

- (void)notifySelectionChangeToDelegates;
- (void)notifyHoverChangeToDelegates;
+ (NSArray<PVDisplayItem *> *)flatItemsFromHierarchicalItems:(NSArray<PVDisplayItem *> *)items;

@end

NS_ASSUME_NONNULL_END

#endif /* PVDisplayItem_h */

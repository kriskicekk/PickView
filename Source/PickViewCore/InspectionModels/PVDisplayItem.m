//
//  PVDisplayItem.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDisplayItem.h"

#import "NSArray+PVInspect.h"
#import "Image+PVInspect.h"
#import "NSObject+PVInspect.h"
#import "PVAttribute.h"
#import "PVAttributesGroup.h"
#import "PVAttributesSection.h"
#import "PVEventHandler.h"

@interface PVDisplayItem ()

@property (nonatomic, assign, readwrite) CGRect frameToRoot;
@property (nonatomic, assign, readwrite) BOOL inNoPreviewHierarchy;
@property (nonatomic, assign) NSInteger indentLevel;
@property (nonatomic, assign, readwrite) BOOL isExpandable;
@property (nonatomic, assign, readwrite) BOOL inHiddenHierarchy;
@property (nonatomic, assign, readwrite) BOOL displayingInHierarchy;

@end

@implementation PVDisplayItem

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _objectID = @"";
        _displayName = @"";
        _viewClassName = @"";
        _layerClassName = @"";
        _backgroundColorText = @"";
        _subitems = @[];
        _attributesGroupList = @[];
        _customAttrGroupList = @[];
        _eventHandlers = @[];
        _alpha = 1;
        _shouldCaptureImage = YES;
        _previewZIndex = -1;
        _doNotFetchScreenshotReason = PVFetchScreenshotPermitted;
        [self _updateDisplayingInHierarchyProperty];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.objectID forKey:@"objectID"];
    [coder encodeObject:self.displayName forKey:@"displayName"];
    [coder encodeObject:self.viewClassName forKey:@"viewClassName"];
    [coder encodeObject:self.layerClassName forKey:@"layerClassName"];
    [coder encodeObject:self.backgroundColorText forKey:@"backgroundColorText"];
    [coder encodeObject:self.customInfo forKey:@"customInfo"];
    [coder encodeObject:self.subitems forKey:@"subitems"];
    [coder encodeObject:self.subitems forKey:@"children"];
    [coder encodeBool:self.isHidden forKey:@"hidden"];
    [coder encodeFloat:self.alpha forKey:@"alpha"];
    [coder encodeObject:self.viewObject forKey:@"viewObject"];
    [coder encodeObject:self.layerObject forKey:@"layerObject"];
    [coder encodeObject:self.hostViewControllerObject forKey:@"hostViewControllerObject"];
    [coder encodeObject:self.attributesGroupList forKey:@"attributesGroupList"];
    [coder encodeObject:self.customAttrGroupList forKey:@"customAttrGroupList"];
    [coder encodeBool:self.representedAsKeyWindow forKey:@"representedAsKeyWindow"];
    [coder encodeObject:self.eventHandlers forKey:@"eventHandlers"];
    [coder encodeBool:self.shouldCaptureImage forKey:@"shouldCaptureImage"];
    [coder encodeObject:self.customDisplayTitle forKey:@"customDisplayTitle"];
    [coder encodeObject:self.danceuiSource forKey:@"danceuiSource"];
    [coder encodeInteger:self.doNotFetchScreenshotReason forKey:@"doNotFetchScreenshotReason"];
    [coder encodeBool:self.noPreview forKey:@"noPreview"];
#if TARGET_OS_IPHONE
    [coder encodeCGRect:self.frame forKey:@"frame"];
    [coder encodeCGRect:self.bounds forKey:@"bounds"];
#elif TARGET_OS_OSX
    [coder encodeRect:self.frame forKey:@"frame"];
    [coder encodeRect:self.bounds forKey:@"bounds"];
#endif
    [coder encodeDouble:CGRectGetMinX(self.frame) forKey:@"frame.x"];
    [coder encodeDouble:CGRectGetMinY(self.frame) forKey:@"frame.y"];
    [coder encodeDouble:CGRectGetWidth(self.frame) forKey:@"frame.width"];
    [coder encodeDouble:CGRectGetHeight(self.frame) forKey:@"frame.height"];
    [coder encodeDouble:CGRectGetMinX(self.bounds) forKey:@"bounds.x"];
    [coder encodeDouble:CGRectGetMinY(self.bounds) forKey:@"bounds.y"];
    [coder encodeDouble:CGRectGetWidth(self.bounds) forKey:@"bounds.width"];
    [coder encodeDouble:CGRectGetHeight(self.bounds) forKey:@"bounds.height"];
    if (self.screenshotEncodeType == PVDisplayItemImageEncodeTypeNSData) {
        [coder encodeObject:[self.soloScreenshot pv_inspect_encodedObjectWithType:PVCodingValueTypeImage] forKey:@"soloScreenshot"];
        [coder encodeObject:[self.groupScreenshot pv_inspect_encodedObjectWithType:PVCodingValueTypeImage] forKey:@"groupScreenshot"];
    } else if (self.screenshotEncodeType == PVDisplayItemImageEncodeTypeImage) {
        [coder encodeObject:self.soloScreenshot forKey:@"soloScreenshot"];
        [coder encodeObject:self.groupScreenshot forKey:@"groupScreenshot"];
    }
    [coder encodeObject:[self.backgroundColor pv_inspect_encodedObjectWithType:PVCodingValueTypeColor] forKey:@"backgroundColor"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _objectID = [[coder decodeObjectForKey:@"objectID"] copy] ?: @"";
        _displayName = [[coder decodeObjectForKey:@"displayName"] copy] ?: @"";
        _viewClassName = [[coder decodeObjectForKey:@"viewClassName"] copy] ?: @"";
        _layerClassName = [[coder decodeObjectForKey:@"layerClassName"] copy] ?: @"";
        _backgroundColorText = [[coder decodeObjectForKey:@"backgroundColorText"] copy] ?: @"";
        _customInfo = [coder decodeObjectForKey:@"customInfo"];
        NSArray *decodedSubitems = [coder decodeObjectForKey:@"subitems"] ?: [coder decodeObjectForKey:@"children"];
        self.subitems = decodedSubitems ?: @[];
        _isHidden = [coder decodeBoolForKey:@"hidden"];
        _alpha = [coder containsValueForKey:@"alpha"] ? [coder decodeFloatForKey:@"alpha"] : 1;
        _viewObject = [coder decodeObjectForKey:@"viewObject"];
        _layerObject = [coder decodeObjectForKey:@"layerObject"];
        _hostViewControllerObject = [coder decodeObjectForKey:@"hostViewControllerObject"];
        self.attributesGroupList = [coder decodeObjectForKey:@"attributesGroupList"] ?: @[];
        self.customAttrGroupList = [coder decodeObjectForKey:@"customAttrGroupList"] ?: @[];
        _representedAsKeyWindow = [coder decodeBoolForKey:@"representedAsKeyWindow"];
        _eventHandlers = [coder decodeObjectForKey:@"eventHandlers"] ?: @[];
        _shouldCaptureImage = [coder containsValueForKey:@"shouldCaptureImage"] ? [coder decodeBoolForKey:@"shouldCaptureImage"] : YES;
        _customDisplayTitle = [[coder decodeObjectForKey:@"customDisplayTitle"] copy];
        _danceuiSource = [[coder decodeObjectForKey:@"danceuiSource"] copy];
        _doNotFetchScreenshotReason = [coder containsValueForKey:@"doNotFetchScreenshotReason"] ? [coder decodeIntegerForKey:@"doNotFetchScreenshotReason"] : PVFetchScreenshotPermitted;
        _noPreview = [coder decodeBoolForKey:@"noPreview"];
#if TARGET_OS_IPHONE
        _frame = [coder decodeCGRectForKey:@"frame"];
        _bounds = [coder decodeCGRectForKey:@"bounds"];
#elif TARGET_OS_OSX
        _frame = [coder decodeRectForKey:@"frame"];
        _bounds = [coder decodeRectForKey:@"bounds"];
#endif
        if ([coder containsValueForKey:@"frame.width"]) {
            _frame = CGRectMake([coder decodeDoubleForKey:@"frame.x"],
                                [coder decodeDoubleForKey:@"frame.y"],
                                [coder decodeDoubleForKey:@"frame.width"],
                                [coder decodeDoubleForKey:@"frame.height"]);
        }
        if ([coder containsValueForKey:@"bounds.width"]) {
            _bounds = CGRectMake([coder decodeDoubleForKey:@"bounds.x"],
                                 [coder decodeDoubleForKey:@"bounds.y"],
                                 [coder decodeDoubleForKey:@"bounds.width"],
                                 [coder decodeDoubleForKey:@"bounds.height"]);
        }
        id soloScreenshotObj = [coder decodeObjectForKey:@"soloScreenshot"];
        if ([soloScreenshotObj isKindOfClass:NSData.class]) {
            _soloScreenshot = [soloScreenshotObj pv_inspect_decodedObjectWithType:PVCodingValueTypeImage];
        } else {
            _soloScreenshot = soloScreenshotObj;
        }
        id groupScreenshotObj = [coder decodeObjectForKey:@"groupScreenshot"];
        if ([groupScreenshotObj isKindOfClass:NSData.class]) {
            _groupScreenshot = [groupScreenshotObj pv_inspect_decodedObjectWithType:PVCodingValueTypeImage];
        } else {
            _groupScreenshot = groupScreenshotObj;
        }
        _backgroundColor = [[coder decodeObjectForKey:@"backgroundColor"] pv_inspect_decodedObjectWithType:PVCodingValueTypeColor];
        [self _updateDisplayingInHierarchyProperty];
        [self _updateInHiddenHierarchyProperty];
        [self _updateInNoPreviewHierarchy];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    PVDisplayItem *item = [[[self class] allocWithZone:zone] init];
    item.objectID = self.objectID;
    item.displayName = self.displayName;
    item.viewClassName = self.viewClassName;
    item.layerClassName = self.layerClassName;
    item.backgroundColorText = self.backgroundColorText;
    item.customInfo = self.customInfo.copy;
    item.isHidden = self.isHidden;
    item.alpha = self.alpha;
    item.frame = self.frame;
    item.bounds = self.bounds;
    item.soloScreenshot = self.soloScreenshot;
    item.groupScreenshot = self.groupScreenshot;
    item.viewObject = self.viewObject.copy;
    item.layerObject = self.layerObject.copy;
    item.hostViewControllerObject = self.hostViewControllerObject.copy;
    item.attributesGroupList = [self.attributesGroupList pv_inspect_map:^id(NSUInteger idx, PVAttributesGroup *value) { return value.copy; }];
    item.customAttrGroupList = [self.customAttrGroupList pv_inspect_map:^id(NSUInteger idx, PVAttributesGroup *value) { return value.copy; }];
    item.eventHandlers = [self.eventHandlers pv_inspect_map:^id(NSUInteger idx, PVEventHandler *value) { return value.copy; }];
    item.representedAsKeyWindow = self.representedAsKeyWindow;
    item.backgroundColor = self.backgroundColor;
    item.shouldCaptureImage = self.shouldCaptureImage;
    item.customDisplayTitle = self.customDisplayTitle;
    item.danceuiSource = self.danceuiSource;
    item.doNotFetchScreenshotReason = self.doNotFetchScreenshotReason;
    item.noPreview = self.noPreview;
    item.subitems = [self.subitems pv_inspect_map:^id(NSUInteger idx, PVDisplayItem *value) { return value.copy; }];
    [item _updateDisplayingInHierarchyProperty];
    return item;
}

- (NSArray<PVDisplayItem *> *)children {
    return self.subitems ?: @[];
}

- (void)setChildren:(NSArray<PVDisplayItem *> *)children {
    self.subitems = children ?: @[];
}

- (BOOL)hidden {
    return self.isHidden;
}

- (void)setHidden:(BOOL)hidden {
    self.isHidden = hidden;
}

- (PVObject *)displayingObject {
    return self.viewObject ?: self.layerObject;
}

- (void)setAttributesGroupList:(NSArray<PVAttributesGroup *> *)attributesGroupList {
    _attributesGroupList = [attributesGroupList copy] ?: @[];
    [_attributesGroupList enumerateObjectsUsingBlock:^(PVAttributesGroup *group, NSUInteger idx, BOOL *stop) {
        [group.attrSections enumerateObjectsUsingBlock:^(PVAttributesSection *section, NSUInteger idx, BOOL *stop) {
            [section.attributes enumerateObjectsUsingBlock:^(PVAttribute *attr, NSUInteger idx, BOOL *stop) {
                attr.targetDisplayItem = self;
            }];
        }];
    }];
}

- (void)setCustomAttrGroupList:(NSArray<PVAttributesGroup *> *)customAttrGroupList {
    _customAttrGroupList = [customAttrGroupList copy] ?: @[];
    [_customAttrGroupList enumerateObjectsUsingBlock:^(PVAttributesGroup *group, NSUInteger idx, BOOL *stop) {
        [group.attrSections enumerateObjectsUsingBlock:^(PVAttributesSection *section, NSUInteger idx, BOOL *stop) {
            [section.attributes enumerateObjectsUsingBlock:^(PVAttribute *attr, NSUInteger idx, BOOL *stop) {
                attr.targetDisplayItem = self;
            }];
        }];
    }];
}

- (void)setSubitems:(NSArray<PVDisplayItem *> *)subitems {
    [_subitems enumerateObjectsUsingBlock:^(PVDisplayItem *obj, NSUInteger idx, BOOL *stop) {
        obj.superItem = nil;
    }];
    _subitems = [subitems copy] ?: @[];
    self.isExpandable = (_subitems.count > 0);
    [_subitems enumerateObjectsUsingBlock:^(PVDisplayItem *obj, NSUInteger idx, BOOL *stop) {
        obj.superItem = self;
        [obj _updateInHiddenHierarchyProperty];
        [obj _updateDisplayingInHierarchyProperty];
        [obj _updateInNoPreviewHierarchy];
    }];
}

- (void)setIsExpandable:(BOOL)isExpandable {
    if (_isExpandable == isExpandable) return;
    _isExpandable = isExpandable;
    [self _notifyDelegatesWith:PVDisplayItemProperty_IsExpandable];
}

- (void)setIsExpanded:(BOOL)isExpanded {
    if (_isExpanded == isExpanded) return;
    _isExpanded = isExpanded;
    [self.subitems enumerateObjectsUsingBlock:^(PVDisplayItem *obj, NSUInteger idx, BOOL *stop) {
        [obj _updateDisplayingInHierarchyProperty];
    }];
    [self _notifyDelegatesWith:PVDisplayItemProperty_IsExpanded];
}

- (void)setSoloScreenshot:(PVImage *)soloScreenshot {
    if (_soloScreenshot == soloScreenshot) return;
    _soloScreenshot = soloScreenshot;
    [self _notifyDelegatesWith:PVDisplayItemProperty_SoloScreenshot];
}

- (void)setGroupScreenshot:(PVImage *)groupScreenshot {
    if (_groupScreenshot == groupScreenshot) return;
    _groupScreenshot = groupScreenshot;
    [self _notifyDelegatesWith:PVDisplayItemProperty_GroupScreenshot];
}

- (void)setDoNotFetchScreenshotReason:(PVDoNotFetchScreenshotReason)doNotFetchScreenshotReason {
    if (_doNotFetchScreenshotReason == doNotFetchScreenshotReason) return;
    _doNotFetchScreenshotReason = doNotFetchScreenshotReason;
    [self _notifyDelegatesWith:PVDisplayItemProperty_AvoidSyncScreenshot];
}

- (void)setFrame:(CGRect)frame {
    _frame = frame;
    [self recursivelyNotifyFrameToRootMayChange];
}

- (void)setBounds:(CGRect)bounds {
    _bounds = bounds;
    [self recursivelyNotifyFrameToRootMayChange];
}

- (void)recursivelyNotifyFrameToRootMayChange {
    [self _notifyDelegatesWith:PVDisplayItemProperty_FrameToRoot];
    [self.subitems enumerateObjectsUsingBlock:^(PVDisplayItem *obj, NSUInteger idx, BOOL *stop) {
        [obj recursivelyNotifyFrameToRootMayChange];
    }];
}

- (void)setIsHidden:(BOOL)isHidden {
    _isHidden = isHidden;
    [self _updateInHiddenHierarchyProperty];
}

- (void)setAlpha:(float)alpha {
    _alpha = alpha;
    [self _updateInHiddenHierarchyProperty];
}

- (void)setInHiddenHierarchy:(BOOL)inHiddenHierarchy {
    if (_inHiddenHierarchy == inHiddenHierarchy) return;
    _inHiddenHierarchy = inHiddenHierarchy;
    [self.subitems enumerateObjectsUsingBlock:^(PVDisplayItem *obj, NSUInteger idx, BOOL *stop) {
        [obj _updateInHiddenHierarchyProperty];
    }];
    [self _notifyDelegatesWith:PVDisplayItemProperty_InHiddenHierarchy];
}

- (void)_updateInHiddenHierarchyProperty {
    if (self.superItem.inHiddenHierarchy || self.isHidden || self.alpha <= 0) {
        self.inHiddenHierarchy = YES;
    } else {
        self.inHiddenHierarchy = NO;
    }
}

- (void)setDisplayingInHierarchy:(BOOL)displayingInHierarchy {
    if (_displayingInHierarchy == displayingInHierarchy) return;
    _displayingInHierarchy = displayingInHierarchy;
    [self.subitems enumerateObjectsUsingBlock:^(PVDisplayItem *obj, NSUInteger idx, BOOL *stop) {
        [obj _updateDisplayingInHierarchyProperty];
    }];
    [self _notifyDelegatesWith:PVDisplayItemProperty_DisplayingInHierarchy];
}

- (void)_updateDisplayingInHierarchyProperty {
    if (self.superItem && (!self.superItem.displayingInHierarchy || !self.superItem.isExpanded)) {
        self.displayingInHierarchy = NO;
    } else {
        self.displayingInHierarchy = YES;
    }
}

- (void)setNoPreview:(BOOL)noPreview {
    _noPreview = noPreview;
    [self _updateInNoPreviewHierarchy];
}

- (void)setInNoPreviewHierarchy:(BOOL)inNoPreviewHierarchy {
    if (_inNoPreviewHierarchy == inNoPreviewHierarchy) return;
    _inNoPreviewHierarchy = inNoPreviewHierarchy;
    [self.subitems enumerateObjectsUsingBlock:^(PVDisplayItem *obj, NSUInteger idx, BOOL *stop) {
        [obj _updateInNoPreviewHierarchy];
    }];
    [self _notifyDelegatesWith:PVDisplayItemProperty_InNoPreviewHierarchy];
}

- (void)_updateInNoPreviewHierarchy {
    if (self.superItem.inNoPreviewHierarchy || self.noPreview) {
        self.inNoPreviewHierarchy = YES;
    } else {
        self.inNoPreviewHierarchy = NO;
    }
}

- (void)setPreviewItemDelegate:(id<PVDisplayItemDelegate>)previewItemDelegate {
    _previewItemDelegate = previewItemDelegate;
    if (previewItemDelegate && ![previewItemDelegate respondsToSelector:@selector(displayItem:propertyDidChange:)]) {
        _previewItemDelegate = nil;
        return;
    }
    [self.previewItemDelegate displayItem:self propertyDidChange:PVDisplayItemProperty_None];
}

- (void)setRowViewDelegate:(id<PVDisplayItemDelegate>)rowViewDelegate {
    if (_rowViewDelegate == rowViewDelegate) return;
    _rowViewDelegate = rowViewDelegate;
    if (rowViewDelegate && ![rowViewDelegate respondsToSelector:@selector(displayItem:propertyDidChange:)]) {
        _rowViewDelegate = nil;
        return;
    }
    [self.rowViewDelegate displayItem:self propertyDidChange:PVDisplayItemProperty_None];
}

- (void)notifySelectionChangeToDelegates {
    [self _notifyDelegatesWith:PVDisplayItemProperty_IsSelected];
}

- (void)notifyHoverChangeToDelegates {
    [self _notifyDelegatesWith:PVDisplayItemProperty_IsHovered];
}

- (void)setIsInSearch:(BOOL)isInSearch {
    _isInSearch = isInSearch;
    [self _notifyDelegatesWith:PVDisplayItemProperty_IsInSearch];
}

- (void)setHighlightedSearchString:(NSString *)highlightedSearchString {
    _highlightedSearchString = [highlightedSearchString copy];
    [self _notifyDelegatesWith:PVDisplayItemProperty_HighlightedSearchString];
}

- (void)_notifyDelegatesWith:(PVDisplayItemProperty)property {
    [self.previewItemDelegate displayItem:self propertyDidChange:property];
    [self.rowViewDelegate displayItem:self propertyDidChange:property];
}

+ (NSArray<PVDisplayItem *> *)flatItemsFromHierarchicalItems:(NSArray<PVDisplayItem *> *)items {
    NSMutableArray<PVDisplayItem *> *resultArray = [NSMutableArray array];
    [items enumerateObjectsUsingBlock:^(PVDisplayItem *obj, NSUInteger idx, BOOL *stop) {
        if (obj.superItem) {
            obj.indentLevel = obj.superItem.indentLevel + 1;
        }
        [resultArray addObject:obj];
        if (obj.subitems.count) {
            [resultArray addObjectsFromArray:[self flatItemsFromHierarchicalItems:obj.subitems]];
        }
    }];
    return resultArray.copy;
}

- (NSArray<PVAttributesGroup *> *)queryAllAttrGroupList {
    NSMutableArray<PVAttributesGroup *> *array = [NSMutableArray array];
    if (self.attributesGroupList) [array addObjectsFromArray:self.attributesGroupList];
    if (self.customAttrGroupList) [array addObjectsFromArray:self.customAttrGroupList];
    return array.copy;
}

- (NSString *)description {
    return self.viewObject.rawClassName ?: self.layerObject.rawClassName ?: [super description];
}

@end

//
//  PVPreviewSceneView.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVPreviewSceneView.h"

#import "PVAppInfo.h"
#import "PVDisplayItem.h"
#import "PVDisplayItemDetail.h"
#import "PVHierarchyInfo.h"
#import "PVWindowInfo.h"

static CGFloat const PVPreviewSceneFactor = 0.01;
static CGFloat const PVPreviewMinCameraFocalLength = 20.0;
static CGFloat const PVPreviewMaxCameraFocalLength = 750.0;

@interface PVPreviewLayoutEntry : NSObject

@property (nonatomic, strong) PVDisplayItem *displayItem;
@property (nonatomic, assign) CGRect frameToRoot;
@property (nonatomic, assign) NSInteger zIndex;

@end

@implementation PVPreviewLayoutEntry
@end

@interface PVPreviewItemNode : SCNNode

@property (nonatomic, strong) PVDisplayItem *displayItem;
@property (nonatomic, strong) SCNPlane *contentPlane;
@property (nonatomic, strong) SCNNode *contentNode;
@property (nonatomic, strong) SCNNode *borderNode;

- (void)configureWithEntry:(PVPreviewLayoutEntry *)entry
                screenSize:(CGSize)screenSize
                    detail:(nullable PVDisplayItemDetail *)detail
                   selected:(BOOL)selected
                      index:(NSUInteger)index;
- (void)setSelected:(BOOL)selected;

@end

@implementation PVPreviewItemNode

- (instancetype)init {
    self = [super init];
    if (self) {
        _contentPlane = [SCNPlane planeWithWidth:1.0 height:1.0];
        _contentPlane.firstMaterial.doubleSided = YES;
        _contentPlane.firstMaterial.lightingModelName = SCNLightingModelConstant;
        _contentPlane.firstMaterial.diffuse.contents = [NSColor clearColor];

        _contentNode = [SCNNode nodeWithGeometry:_contentPlane];
        _contentNode.name = @"content";
        [self addChildNode:_contentNode];

        _borderNode = [SCNNode node];
        _borderNode.name = @"border";
        _borderNode.position = SCNVector3Make(0.0, 0.0, 0.002);
        [self addChildNode:_borderNode];
    }
    return self;
}

- (void)configureWithEntry:(PVPreviewLayoutEntry *)entry
                screenSize:(CGSize)screenSize
                    detail:(PVDisplayItemDetail *)detail
                  selected:(BOOL)selected
                     index:(NSUInteger)index {
    self.displayItem = entry.displayItem;
    CGRect frame = entry.frameToRoot;
    CGFloat width = MAX(1.0, frame.size.width);
    CGFloat height = MAX(1.0, frame.size.height);

    self.contentPlane.width = width * PVPreviewSceneFactor;
    self.contentPlane.height = height * PVPreviewSceneFactor;
    self.contentPlane.firstMaterial.diffuse.contents = [self materialContentsWithDetail:detail displayItem:entry.displayItem];
    self.contentNode.opacity = entry.displayItem.isHidden ? 0.22 : 1.0;
    self.contentNode.renderingOrder = (NSInteger)index * 10;

    CGFloat transformedX = frame.origin.x + width / 2.0 - screenSize.width / 2.0;
    CGFloat transformedY = -(frame.origin.y + height / 2.0) + screenSize.height / 2.0;
    self.position = SCNVector3Make(transformedX * PVPreviewSceneFactor,
                                   transformedY * PVPreviewSceneFactor,
                                   self.position.z);
    self.borderNode.geometry = [self borderGeometryWithWidth:self.contentPlane.width height:self.contentPlane.height];
    self.borderNode.renderingOrder = (NSInteger)index * 10 + 1;
    [self setSelected:selected];
}

- (id)materialContentsWithDetail:(PVDisplayItemDetail *)detail displayItem:(PVDisplayItem *)displayItem {
    NSData *imageData = detail.soloImageData ?: detail.groupImageData;
    if (imageData.length) {
        NSImage *image = [[NSImage alloc] initWithData:imageData];
        if (image) {
            return image;
        }
    }

    if (displayItem.backgroundColorText.length) {
        return [NSColor colorWithCalibratedWhite:0.85 alpha:0.18];
    }
    return [NSColor colorWithCalibratedWhite:0.8 alpha:0.08];
}

- (SCNGeometry *)borderGeometryWithWidth:(CGFloat)width height:(CGFloat)height {
    CGFloat halfWidth = width / 2.0;
    CGFloat halfHeight = height / 2.0;
    SCNVector3 vertices[] = {
        SCNVector3Make(-halfWidth, halfHeight, 0.0),
        SCNVector3Make(halfWidth, halfHeight, 0.0),
        SCNVector3Make(halfWidth, -halfHeight, 0.0),
        SCNVector3Make(-halfWidth, -halfHeight, 0.0)
    };
    uint8_t indexes[] = {0, 1, 1, 2, 2, 3, 3, 0};
    SCNGeometrySource *source = [SCNGeometrySource geometrySourceWithVertices:vertices count:4];
    NSData *indexData = [NSData dataWithBytes:indexes length:sizeof(indexes)];
    SCNGeometryElement *element = [SCNGeometryElement geometryElementWithData:indexData
                                                                primitiveType:SCNGeometryPrimitiveTypeLine
                                                               primitiveCount:4
                                                                bytesPerIndex:sizeof(uint8_t)];
    SCNGeometry *geometry = [SCNGeometry geometryWithSources:@[source] elements:@[element]];
    geometry.firstMaterial.doubleSided = YES;
    geometry.firstMaterial.lightingModelName = SCNLightingModelConstant;
    return geometry;
}

- (void)setSelected:(BOOL)selected {
    NSColor *borderColor = selected ? [NSColor colorWithCalibratedRed:0.16 green:0.48 blue:0.95 alpha:1.0] : [NSColor colorWithCalibratedWhite:0.45 alpha:0.45];
    self.borderNode.geometry.firstMaterial.diffuse.contents = borderColor;
}

@end

@interface PVPreviewSceneView ()

@property (nonatomic, assign, readwrite) PVPreviewDimension dimension;
@property (nonatomic, strong) SCNNode *stageNode;
@property (nonatomic, strong) SCNNode *cameraNode;
@property (nonatomic, strong) SCNNode *rightLightNode;
@property (nonatomic, strong) SCNNode *leftLightNode;
@property (nonatomic, copy) NSArray<PVPreviewLayoutEntry *> *layoutEntries;
@property (nonatomic, strong) NSMutableDictionary<NSString *, PVPreviewItemNode *> *itemNodesByID;
@property (nonatomic, strong) NSMutableDictionary<NSString *, PVDisplayItemDetail *> *detailsByID;
@property (nonatomic, weak, nullable) PVDisplayItem *selectedDisplayItem;
@property (nonatomic, assign) CGSize screenSize;
@property (nonatomic, assign) CGPoint rotation;
@property (nonatomic, assign) CGPoint initialRotation;
@property (nonatomic, assign) CGPoint initialTranslation;
@property (nonatomic, assign) BOOL panningStage;
@property (nonatomic, assign) BOOL didPlayInitialAnimation;

@end

@implementation PVPreviewSceneView

- (instancetype)initWithFrame:(NSRect)frame options:(NSDictionary<SCNViewOption, id> *)options {
    self = [super initWithFrame:frame options:options];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect options:nil];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _dimension = PVPreviewDimension3D;
    _previewScale = 0.56;
    _zInterspace = 0.55;
    _itemNodesByID = [NSMutableDictionary dictionary];
    _detailsByID = [NSMutableDictionary dictionary];
    _layoutEntries = @[];

    self.allowsCameraControl = NO;
    self.showsStatistics = NO;
    self.backgroundColor = NSColor.whiteColor;
    self.scene = [SCNScene scene];

    self.stageNode = [SCNNode node];
    self.stageNode.name = @"stage";
    [self.scene.rootNode addChildNode:self.stageNode];

    self.cameraNode = [SCNNode node];
    self.cameraNode.name = @"camera";
    self.cameraNode.camera = [SCNCamera camera];
    self.cameraNode.camera.automaticallyAdjustsZRange = YES;
    self.cameraNode.position = SCNVector3Make(0.0, 0.0, 34.0);
    [self.scene.rootNode addChildNode:self.cameraNode];
    self.pointOfView = self.cameraNode;

    self.rightLightNode = [self lightNodeWithPosition:SCNVector3Make(4.0, 4.0, 6.0)];
    self.leftLightNode = [self lightNodeWithPosition:SCNVector3Make(-4.0, -4.0, 6.0)];
    [self.scene.rootNode addChildNode:self.rightLightNode];
    [self.scene.rootNode addChildNode:self.leftLightNode];

    self.previewScale = _previewScale;
    [self setRotation:CGPointMake(0.6, 0.0) animated:NO];
}

- (SCNNode *)lightNodeWithPosition:(SCNVector3)position {
    SCNLight *light = [SCNLight light];
    light.type = SCNLightTypeOmni;
    SCNNode *node = [SCNNode node];
    node.light = light;
    node.position = position;
    return node;
}

- (void)resetPreview {
    NSAssert(NSThread.isMainThread, @"Preview scene should be mutated on main thread.");
    self.selectedDisplayItem = nil;
    self.didPlayInitialAnimation = NO;
    self.layoutEntries = @[];
    [self.detailsByID removeAllObjects];
    [self.itemNodesByID removeAllObjects];
    [self.stageNode.childNodes makeObjectsPerformSelector:@selector(removeFromParentNode)];
    self.stageNode.position = SCNVector3Zero;
    [self setRotation:CGPointZero animated:NO];
}

- (void)renderHierarchy:(PVHierarchyInfo *)hierarchy
            detailsByID:(NSDictionary<NSString *, PVDisplayItemDetail *> *)detailsByID
           selectedItem:(PVDisplayItem *)selectedItem {
    NSAssert(NSThread.isMainThread, @"Preview scene should be rendered on main thread.");
    if (!hierarchy) {
        [self resetPreview];
        return;
    }

    [self.detailsByID removeAllObjects];
    [self.detailsByID addEntriesFromDictionary:detailsByID ?: @{}];
    self.selectedDisplayItem = selectedItem;
    self.screenSize = [self screenSizeForHierarchy:hierarchy];
    self.layoutEntries = [self layoutEntriesForHierarchy:hierarchy];
    [self updateZIndexesForLayoutEntries];
    [self renderLayoutEntries];
    [self playInitialAnimationIfNeeded];
}

- (void)updateDetailsByID:(NSDictionary<NSString *, PVDisplayItemDetail *> *)detailsByID
             selectedItem:(PVDisplayItem *)selectedItem {
    NSAssert(NSThread.isMainThread, @"Preview scene should be updated on main thread.");
    [self.detailsByID removeAllObjects];
    [self.detailsByID addEntriesFromDictionary:detailsByID ?: @{}];
    self.selectedDisplayItem = selectedItem;
    [self renderLayoutEntries];
}

- (void)playInitialAnimationIfNeeded {
    if (self.didPlayInitialAnimation || !self.layoutEntries.count) {
        return;
    }

    self.didPlayInitialAnimation = YES;
    self.alphaValue = 0.0;
    [self setRotation:CGPointMake(0.8, 0.0) animated:NO];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            context.duration = 1.0;
            self.animator.alphaValue = 1.0;
        } completionHandler:nil];
        [self setRotation:CGPointMake(0.6, 0.0) animated:YES];
    });
}

- (void)selectDisplayItem:(PVDisplayItem *)displayItem {
    self.selectedDisplayItem = displayItem;
    for (PVPreviewItemNode *node in self.itemNodesByID.allValues) {
        [node setSelected:[node.displayItem.objectID isEqualToString:displayItem.objectID]];
    }
}

- (void)setDimension:(PVPreviewDimension)dimension animated:(BOOL)animated {
    if (_dimension == dimension) {
        return;
    }

    _dimension = dimension;
    if (dimension == PVPreviewDimension2D) {
        [self setRotation:CGPointZero animated:animated];
    } else {
        CGFloat rotationX = fabs(self.rotation.x) < 0.18 ? 0.62 : self.rotation.x;
        CGFloat rotationY = self.freeRotationEnabled ? self.rotation.y : 0.0;
        [self setRotation:CGPointMake(rotationX, rotationY) animated:animated];
    }
    [self updateZPositionsAnimated:animated];
}

- (void)setPreviewScale:(CGFloat)previewScale {
    _previewScale = MIN(MAX(previewScale, 0.0), 1.0);
    CGFloat focalLength = PVPreviewMinCameraFocalLength + _previewScale * _previewScale * (PVPreviewMaxCameraFocalLength - PVPreviewMinCameraFocalLength);
    self.cameraNode.camera.focalLength = focalLength;
}

- (void)setZInterspace:(CGFloat)zInterspace {
    _zInterspace = MIN(MAX(zInterspace, 0.0), 1.0);
    [self updateZPositionsAnimated:YES];
}

- (void)setRotation:(CGPoint)rotation animated:(BOOL)animated {
    _rotation = [self equivalentRotationFromRotation:rotation];
    SCNVector3 eulerAngles = SCNVector3Make(_rotation.y, _rotation.x, 0.0);
    if (animated) {
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:0.25];
        self.stageNode.eulerAngles = eulerAngles;
        [SCNTransaction commit];
    } else {
        self.stageNode.eulerAngles = eulerAngles;
    }
}

- (CGPoint)equivalentRotationFromRotation:(CGPoint)rotation {
    rotation.x = [self equivalentRotationValue:rotation.x];
    rotation.y = [self equivalentRotationValue:rotation.y];
    return rotation;
}

- (CGFloat)equivalentRotationValue:(CGFloat)value {
    while (value <= -M_PI) {
        value += M_PI * 2.0;
    }
    while (value >= M_PI) {
        value -= M_PI * 2.0;
    }
    return value;
}

- (CGSize)screenSizeForHierarchy:(PVHierarchyInfo *)hierarchy {
    CGSize size = CGSizeMake(hierarchy.appInfo.screenWidth, hierarchy.appInfo.screenHeight);
    if (size.width > 0.0 && size.height > 0.0) {
        return size;
    }
    size = hierarchy.windowInfo.frame.size;
    if (size.width > 0.0 && size.height > 0.0) {
        return size;
    }
    PVDisplayItem *rootItem = hierarchy.rootItems.firstObject;
    CGSize rootSize = [self sizeForDisplayItem:rootItem];
    if (rootSize.width > 0.0 && rootSize.height > 0.0) {
        return rootSize;
    }
    return CGSizeMake(375.0, 667.0);
}

- (NSArray<PVPreviewLayoutEntry *> *)layoutEntriesForHierarchy:(PVHierarchyInfo *)hierarchy {
    NSMutableArray<PVPreviewLayoutEntry *> *entries = [NSMutableArray array];
    for (PVDisplayItem *rootItem in hierarchy.rootItems) {
        CGRect rootFrame = rootItem.frame;
        if (rootFrame.size.width <= 0.0 || rootFrame.size.height <= 0.0) {
            rootFrame.size = [self sizeForDisplayItem:rootItem];
        }
        [self appendDisplayItem:rootItem frameToRoot:rootFrame depth:0 entries:entries];
    }
    return entries.copy;
}

- (void)updateZIndexesForLayoutEntries {
    [self.layoutEntries enumerateObjectsUsingBlock:^(PVPreviewLayoutEntry *entry, NSUInteger idx, BOOL *stop) {
        PVPreviewLayoutEntry *referenceEntry = [self maxZIndexEntryUnderEntry:entry entryIndex:idx];
        entry.zIndex = referenceEntry ? referenceEntry.zIndex + 1 : 0;
    }];
}

- (nullable PVPreviewLayoutEntry *)maxZIndexEntryUnderEntry:(PVPreviewLayoutEntry *)entry entryIndex:(NSUInteger)entryIndex {
    if (entryIndex == 0) {
        return nil;
    }

    PVPreviewLayoutEntry *targetEntry = nil;
    for (NSInteger idx = (NSInteger)entryIndex - 1; idx >= 0; idx--) {
        PVPreviewLayoutEntry *candidate = self.layoutEntries[(NSUInteger)idx];
        if (candidate.displayItem.isHidden) {
            continue;
        }
        if (!CGRectIntersectsRect(entry.frameToRoot, candidate.frameToRoot)) {
            continue;
        }
        if (!targetEntry || candidate.zIndex > targetEntry.zIndex) {
            targetEntry = candidate;
        }
    }
    return targetEntry;
}

- (void)appendDisplayItem:(PVDisplayItem *)displayItem
             frameToRoot:(CGRect)frameToRoot
                   depth:(NSInteger)depth
                 entries:(NSMutableArray<PVPreviewLayoutEntry *> *)entries {
    NSAssert(displayItem != nil, @"Display item should not be nil.");
    if (!displayItem.objectID.length || CGRectIsEmpty(frameToRoot)) {
        return;
    }

    PVPreviewLayoutEntry *entry = [[PVPreviewLayoutEntry alloc] init];
    entry.displayItem = displayItem;
    entry.frameToRoot = frameToRoot;
    entry.zIndex = (NSInteger)entries.count;
    [entries addObject:entry];

    for (PVDisplayItem *child in displayItem.children) {
        CGSize childSize = [self sizeForDisplayItem:child];
        CGRect childFrame = CGRectMake(frameToRoot.origin.x + child.frame.origin.x,
                                       frameToRoot.origin.y + child.frame.origin.y,
                                       childSize.width,
                                       childSize.height);
        [self appendDisplayItem:child frameToRoot:childFrame depth:depth + 1 entries:entries];
    }
}

- (CGSize)sizeForDisplayItem:(PVDisplayItem *)displayItem {
    CGSize boundsSize = displayItem.bounds.size;
    if (boundsSize.width > 0.0 && boundsSize.height > 0.0) {
        return boundsSize;
    }
    return displayItem.frame.size;
}

- (void)renderLayoutEntries {
    NSMutableSet<NSString *> *usedIDs = [NSMutableSet set];
    [self.layoutEntries enumerateObjectsUsingBlock:^(PVPreviewLayoutEntry *entry, NSUInteger idx, BOOL *stop) {
        NSString *objectID = entry.displayItem.objectID;
        NSAssert(![usedIDs containsObject:objectID], @"Duplicate display item objectID in preview.");
        [usedIDs addObject:objectID];

        PVPreviewItemNode *node = self.itemNodesByID[objectID];
        if (!node) {
            node = [[PVPreviewItemNode alloc] init];
            self.itemNodesByID[objectID] = node;
            [self.stageNode addChildNode:node];
        }
        PVDisplayItemDetail *detail = self.detailsByID[objectID];
        BOOL selected = [objectID isEqualToString:self.selectedDisplayItem.objectID];
        [node configureWithEntry:entry screenSize:self.screenSize detail:detail selected:selected index:idx];
    }];

    for (NSString *objectID in self.itemNodesByID.allKeys.copy) {
        if (![usedIDs containsObject:objectID]) {
            [self.itemNodesByID[objectID] removeFromParentNode];
            [self.itemNodesByID removeObjectForKey:objectID];
        }
    }
    [self updateZPositionsAnimated:YES];
}

- (void)updateZPositionsAnimated:(BOOL)animated {
    CGFloat interspace = self.dimension == PVPreviewDimension2D ? 0.0008 : 0.02 + self.zInterspace * 0.14;
    __block NSInteger maxZIndex = 0;
    [self.layoutEntries enumerateObjectsUsingBlock:^(PVPreviewLayoutEntry *entry, NSUInteger idx, BOOL *stop) {
        maxZIndex = MAX(maxZIndex, entry.zIndex);
    }];
    NSInteger centerOffset = (NSInteger)round(maxZIndex * 0.5);

    if (animated) {
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:0.22];
    }

    [self.layoutEntries enumerateObjectsUsingBlock:^(PVPreviewLayoutEntry *entry, NSUInteger idx, BOOL *stop) {
        PVPreviewItemNode *node = self.itemNodesByID[entry.displayItem.objectID];
        SCNVector3 position = node.position;
        position.z = (entry.zIndex - centerOffset) * interspace + idx * 0.00001;
        node.position = position;
    }];

    if (animated) {
        [SCNTransaction commit];
    }
}

- (nullable PVDisplayItem *)displayItemAtPoint:(NSPoint)point {
    NSArray<SCNHitTestResult *> *results = [self hitTest:point options:@{SCNHitTestOptionSearchMode: @(SCNHitTestSearchModeClosest)}];
    for (SCNHitTestResult *result in results) {
        SCNNode *node = result.node;
        while (node && ![node isKindOfClass:PVPreviewItemNode.class]) {
            node = node.parentNode;
        }
        if ([node isKindOfClass:PVPreviewItemNode.class]) {
            return ((PVPreviewItemNode *)node).displayItem;
        }
    }
    return nil;
}

#pragma mark - Events

- (void)mouseDown:(NSEvent *)event {
    NSPoint point = [self convertPoint:event.locationInWindow fromView:nil];
    PVDisplayItem *item = [self displayItemAtPoint:point];
    if (item && self.selectionHandler) {
        self.selectionHandler(item);
    }
    self.initialRotation = self.rotation;
    self.initialTranslation = CGPointMake(self.stageNode.position.x, self.stageNode.position.y);
    self.panningStage = (event.modifierFlags & NSEventModifierFlagOption) != 0;
}

- (void)mouseDragged:(NSEvent *)event {
    if (self.panningStage) {
        SCNVector3 position = self.stageNode.position;
        position.x += event.deltaX * 0.01;
        position.y -= event.deltaY * 0.01;
        self.stageNode.position = position;
        return;
    }

    if (self.dimension != PVPreviewDimension3D) {
        return;
    }

    CGFloat nextRotationX = self.rotation.x + event.deltaX * 0.012;
    CGFloat nextRotationY = self.freeRotationEnabled ? self.rotation.y + event.deltaY * 0.006 : 0.0;
    [self setRotation:CGPointMake(nextRotationX, nextRotationY) animated:NO];
}

- (void)scrollWheel:(NSEvent *)event {
    if (fabs(event.deltaY) <= fabs(event.deltaX)) {
        [super scrollWheel:event];
        return;
    }
    self.previewScale = self.previewScale + event.deltaY * 0.012;
}

- (void)magnifyWithEvent:(NSEvent *)event {
    self.previewScale = self.previewScale + event.magnification;
}

@end

//
//  PVFlutterHierarchyCoordinator.m
//  PickViewServer
//

#import "PVFlutterHierarchyCoordinator.h"

#import "PVFVMEngineInspectorSession.h"
#import "PVFVMFlutterViewControllerRecord.h"
#import "PVFVMFlutterRuntime.h"
#import "PVFVMInspectorJSON.h"
#import "PVFVMInspectorKit.h"
#import "PVFVMInspectorTreeBuilder.h"
#import "PVFVMSnapshotNode.h"
#import "PVDisplayItem.h"
#import "PVDisplayItemDetail.h"
#import "PVFlutterInspectionModel.h"
#import "PVObject.h"
#import "PVStaticAsyncUpdateTask.h"

@interface PVFlutterPageSnapshot : NSObject
@property(nonatomic, weak) UIView *hostView;
@property(nonatomic, strong) PVFVMFlutterViewControllerRecord *record;
@property(nonatomic, strong) PVFVMSnapshotNode *rootNode;
@property(nonatomic, copy) NSArray<PVDisplayItem *> *rootItems;
@end

@implementation PVFlutterPageSnapshot
@end

@interface PVFlutterNodeRecord : NSObject
@property(nonatomic, weak) PVFlutterPageSnapshot *page;
@property(nonatomic, strong) PVFVMSnapshotNode *node;
@property(nonatomic, copy) NSString *displayItemID;
@property(nonatomic, strong) PVFlutterNodeDetail *detail;
@end

@implementation PVFlutterNodeRecord
@end

@interface PVFlutterHierarchyCoordinator ()
@property(nonatomic, strong) NSMapTable<UIView *, PVFlutterPageSnapshot *> *pagesByHostView;
@property(nonatomic, strong) NSMapTable<CALayer *, PVFlutterPageSnapshot *> *pagesByHostLayer;
@property(nonatomic, strong) NSMutableDictionary<NSNumber *, PVFlutterNodeRecord *> *recordsByOID;
@property(nonatomic, strong) NSMutableDictionary<NSString *, PVFlutterNodeRecord *> *recordsByDisplayItemID;
@end

@implementation PVFlutterHierarchyCoordinator

- (instancetype)init {
    self = [super init];
    if (self) {
        _pagesByHostView = [NSMapTable weakToStrongObjectsMapTable];
        _pagesByHostLayer = [NSMapTable weakToStrongObjectsMapTable];
        _recordsByOID = [NSMutableDictionary dictionary];
        _recordsByDisplayItemID = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)prepareWindow:(UIWindow *)window completion:(PVFlutterHierarchyPreparationCompletion)completion {
    dispatch_block_t work = ^{
        [self.pagesByHostView removeAllObjects];
        [self.pagesByHostLayer removeAllObjects];
        [self.recordsByOID removeAllObjects];
        [self.recordsByDisplayItemID removeAllObjects];

        NSArray<PVFVMFlutterViewControllerRecord *> *allRecords =
            PVFVMInspectorKit.sharedKit.recordsInCurrentWindowHierarchy;
        NSMutableArray<PVFVMFlutterViewControllerRecord *> *records = [NSMutableArray array];
        NSHashTable<FlutterEngine *> *seenEngines =
            [NSHashTable hashTableWithOptions:NSPointerFunctionsObjectPointerPersonality];
        for (PVFVMFlutterViewControllerRecord *record in allRecords) {
            FlutterViewController *viewController = record.viewController;
            UIView *hostView = viewController.viewIfLoaded;
            if (!record.isActive || hostView.window != window || record.engine == nil ||
                [seenEngines containsObject:record.engine]) {
                continue;
            }
            [seenEngines addObject:record.engine];
            [records addObject:record];
        }
        if (records.count == 0) {
            if (completion) completion(nil);
            return;
        }

        dispatch_group_t group = dispatch_group_create();
        __block NSError *firstError = nil;
        for (PVFVMFlutterViewControllerRecord *record in records) {
            dispatch_group_enter(group);
            [self prepareRecord:record completion:^(NSError *error) {
                if (error && !firstError) firstError = error;
                dispatch_group_leave(group);
            }];
        }
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            if (completion) completion(firstError);
        });
    };
    if (NSThread.isMainThread) work();
    else dispatch_async(dispatch_get_main_queue(), work);
}

- (void)prepareRecord:(PVFVMFlutterViewControllerRecord *)record
            completion:(PVFlutterHierarchyPreparationCompletion)completion {
    PVFVMEngineInspectorSession *session = record.session;
    [session connectWithTimeout:2.5 completion:^(NSError *connectionError) {
        if (connectionError) {
            NSLog(@"PickView Flutter VM connection failed for %@: %@",
                  record.engineIdentifier, connectionError.localizedDescription);
            completion(connectionError);
            return;
        }
        [session fetchRootWidgetTreeSummaryWithCompletion:^(id widgetPayload,
                                                            NSDictionary *response,
                                                            NSError *treeError) {
            if (treeError) {
                completion(treeError);
                return;
            }
            NSDictionary *widgetRoot = [widgetPayload isKindOfClass:NSDictionary.class]
                ? widgetPayload : nil;
            NSString *rootObjectID = [PVFVMInspectorJSON nodeIDFromDictionary:widgetRoot];
            if (rootObjectID.length == 0) {
                NSError *error = [NSError errorWithDomain:@"PickViewFlutterInspector"
                                                     code:1
                                                 userInfo:@{NSLocalizedDescriptionKey:
                                                     @"Widget tree root has no Inspector object ID."}];
                completion(error);
                return;
            }
            [session fetchLayoutExplorerForObjectID:rootObjectID
                                       subtreeDepth:100
                                         completion:^(id layoutPayload,
                                                      NSDictionary *layoutResponse,
                                                      NSError *layoutError) {
                NSDictionary *layoutRoot = [layoutPayload isKindOfClass:NSDictionary.class]
                    ? layoutPayload : nil;
                if (layoutError || !layoutRoot) {
                    completion(layoutError ?: [NSError errorWithDomain:@"PickViewFlutterInspector"
                                                                  code:2
                                                              userInfo:@{NSLocalizedDescriptionKey:
                                                                  @"Layout Explorer did not return an object."}]);
                    return;
                }
                UIView *hostView = record.viewController.viewIfLoaded;
                if (!hostView) {
                    completion([NSError errorWithDomain:@"PickViewFlutterInspector"
                                                   code:3
                                               userInfo:@{NSLocalizedDescriptionKey:
                                                   @"FlutterViewController has no loaded view."}]);
                    return;
                }
                PVFVMSnapshotNode *root = [PVFVMInspectorTreeBuilder
                    snapshotTreeFromLayoutPayload:layoutRoot
                                    widgetPayload:widgetPayload
                                     rootObjectID:rootObjectID
                                 fallbackRootSize:hostView.bounds.size];
                [self installRootNode:root hostView:hostView record:record];
                completion(nil);
            }];
        }];
    }];
}

- (void)installRootNode:(PVFVMSnapshotNode *)root
               hostView:(UIView *)hostView
                 record:(PVFVMFlutterViewControllerRecord *)record {
    PVFlutterPageSnapshot *page = [PVFlutterPageSnapshot new];
    page.hostView = hostView;
    page.record = record;
    page.rootNode = root;

    NSMutableArray<PVDisplayItem *> *items = [NSMutableArray array];
    for (PVFVMSnapshotNode *node in root.children) {
        [items addObject:[self displayItemForNode:node page:page]];
    }
    page.rootItems = items.copy;
    [self.pagesByHostView setObject:page forKey:hostView];
    [self.pagesByHostLayer setObject:page forKey:hostView.layer];
    NSLog(@"PV_FLUTTER_HIERARCHY_PREPARED hostView=%@ hostLayer=%@ rootItems=%@ nodes=%@",
          hostView, hostView.layer, @(page.rootItems.count), @(root.flattenedNodes.count));
}

- (PVDisplayItem *)displayItemForNode:(PVFVMSnapshotNode *)node
                                  page:(PVFlutterPageSnapshot *)page {
    PVFlutterNodeRecord *record = [PVFlutterNodeRecord new];
    record.page = page;
    record.node = node;
    record.displayItemID = [NSString stringWithFormat:@"flutter:%@:%@",
                            page.record.recordIdentifier, node.objectID];
    record.detail = [self detailForNode:node page:page];
    unsigned long oid = (unsigned long)(uintptr_t)record;
    self.recordsByOID[@(oid)] = record;
    self.recordsByDisplayItemID[record.displayItemID] = record;

    PVObject *object = [PVObject new];
    object.oid = oid;
    object.memoryAddress = [NSString stringWithFormat:@"flutter://%@/%@",
                            page.record.engineIdentifier, node.objectID];
    object.classChainList = @[
        node.flutterType.length ? node.flutterType : @"FlutterWidget",
        node.renderObjectType.length ? node.renderObjectType : @"RenderObject",
        @"FlutterRenderObject"
    ];

    PVDisplayItem *item = [PVDisplayItem new];
    item.objectID = record.displayItemID;
    item.displayName = node.flutterType;
    item.viewClassName = node.flutterType;
    item.layerClassName = node.renderObjectType;
    item.layerObject = object;
    item.contentKind = PVDisplayItemContentKindFlutter;
    item.flutterLoadState = PVFlutterLoadStateLoaded;
    item.flutterReference = record.detail.reference;
    item.flutterDetail = record.detail;
    item.frame = CGRectMake(node.localOffset.x, node.localOffset.y,
                            node.logicalSize.width, node.logicalSize.height);
    item.bounds = CGRectMake(0, 0, node.logicalSize.width, node.logicalSize.height);
    item.alpha = 1;
    item.shouldCaptureImage = node.captureEligible || node.nativeDecoration != nil;
    item.attributesGroupList = @[];
    item.customAttrGroupList = @[];

    NSDictionary *color = [node.nativeDecoration[@"backgroundColor"] isKindOfClass:NSDictionary.class]
        ? node.nativeDecoration[@"backgroundColor"] : nil;
    if (color) {
        item.backgroundColor = [self colorFromDictionary:color];
        item.backgroundColorText = [self colorDescription:color];
    }

    NSMutableArray<PVDisplayItem *> *children = [NSMutableArray array];
    for (PVFVMSnapshotNode *child in node.children) {
        [children addObject:[self displayItemForNode:child page:page]];
    }
    item.subitems = children.copy;
    item.children = children.copy;
    return item;
}

- (PVFlutterNodeDetail *)detailForNode:(PVFVMSnapshotNode *)node
                                   page:(PVFlutterPageSnapshot *)page {
    PVFlutterNodeReference *reference = [PVFlutterNodeReference new];
    reference.recordIdentifier = page.record.recordIdentifier;
    reference.engineIdentifier = page.record.engineIdentifier;
    reference.isolateID = page.record.session.isolateID ?: @"";
    reference.objectGroup = page.record.session.objectGroup;
    reference.objectID = node.objectID;

    PVFlutterNodeDetail *detail = [PVFlutterNodeDetail new];
    detail.reference = reference;
    detail.widgetType = node.flutterType;
    detail.elementType = [node.sourceJSON[@"description"] isKindOfClass:NSString.class]
        ? node.sourceJSON[@"description"] : node.flutterType;
    detail.renderObjectType = node.renderObjectType;
    detail.capabilities = node.capabilities.copy;
    detail.rawJSON = [PVFVMInspectorJSON prettyJSONStringForObject:node.sourceJSON ?: @{}];

    PVFlutterDetailSection *geometry = [PVFlutterDetailSection new];
    geometry.identifier = @"geometry";
    geometry.title = @"Geometry";
    geometry.fields = @[
        [self rectField:@"frame" title:@"Frame in parent"
                   rect:CGRectMake(node.localOffset.x, node.localOffset.y,
                                   node.logicalSize.width, node.logicalSize.height)],
        [self sizeField:@"size" title:@"Size" size:node.logicalSize]
    ];

    NSMutableArray<PVFlutterDetailField *> *renderFields = [NSMutableArray arrayWithArray:@[
        [self textField:@"kind" title:@"Kind" value:node.kind],
        [self textField:@"paintRole" title:@"Paint role" value:node.paintRole],
        [self textField:@"renderStrategy" title:@"Render strategy" value:node.renderStrategy],
        [self boolField:@"captureEligible" title:@"Screenshot eligible" value:node.captureEligible]
    ]];
    if (node.textPreview.length) {
        [renderFields addObject:[self textField:@"text" title:@"Text" value:node.textPreview]];
    }
    PVFlutterDetailSection *rendering = [PVFlutterDetailSection new];
    rendering.identifier = @"rendering";
    rendering.title = @"Rendering";
    rendering.fields = renderFields.copy;

    NSMutableArray<PVFlutterDetailSection *> *sections =
        [NSMutableArray arrayWithObjects:geometry, rendering, nil];
    [self appendJSONSection:@"decoration" title:@"Decoration"
                     values:node.nativeDecoration ? @[node.nativeDecoration] : @[] to:sections];
    [self appendJSONSection:@"layoutModifiers" title:@"Layout modifiers"
                     values:node.layoutModifiers to:sections];
    [self appendJSONSection:@"interactions" title:@"Interactions"
                     values:node.interactions to:sections];
    [self appendJSONSection:@"semantics" title:@"Semantics"
                     values:node.semantics to:sections];
    detail.sections = sections.copy;

    NSMutableArray<PVFlutterLayoutGroup *> *layoutGroups = [NSMutableArray array];
    for (NSDictionary *relation in node.childrenLayouts) {
        PVFlutterLayoutGroup *group = [PVFlutterLayoutGroup new];
        group.objectID = [relation[@"objectId"] isKindOfClass:NSString.class]
            ? relation[@"objectId"] : @"";
        group.widgetType = [relation[@"type"] isKindOfClass:NSString.class]
            ? relation[@"type"] : @"Unknown";
        group.renderObjectType = [relation[@"renderObjectType"] isKindOfClass:NSString.class]
            ? relation[@"renderObjectType"] : @"Unknown";
        NSMutableArray<NSString *> *managedIDs = [NSMutableArray array];
        for (NSDictionary *managed in [relation[@"managedChildren"] isKindOfClass:NSArray.class]
                                      ? relation[@"managedChildren"] : @[]) {
            NSString *managedID = [managed[@"objectId"] isKindOfClass:NSString.class]
                ? managed[@"objectId"] : nil;
            if (managedID.length) [managedIDs addObject:managedID];
        }
        group.managedNodeIDs = managedIDs.copy;
        group.fields = @[[self jsonField:@"layout" title:@"Layout data" value:relation]];
        group.rawJSON = [PVFVMInspectorJSON prettyJSONStringForObject:relation];
        [layoutGroups addObject:group];
    }
    detail.layoutGroups = layoutGroups.copy;
    return detail;
}

- (void)appendJSONSection:(NSString *)identifier
                    title:(NSString *)title
                   values:(NSArray *)values
                       to:(NSMutableArray<PVFlutterDetailSection *> *)sections {
    if (values.count == 0) return;
    PVFlutterDetailSection *section = [PVFlutterDetailSection new];
    section.identifier = identifier;
    section.title = title;
    NSMutableArray *fields = [NSMutableArray arrayWithCapacity:values.count];
    [values enumerateObjectsUsingBlock:^(id value, NSUInteger index, BOOL *stop) {
        [fields addObject:[self jsonField:[NSString stringWithFormat:@"%@.%@", identifier, @(index)]
                                    title:[NSString stringWithFormat:@"%@ %@", title, @(index + 1)]
                                    value:value]];
    }];
    section.fields = fields.copy;
    [sections addObject:section];
}

- (NSArray<PVDisplayItem *> *)virtualItemsForHostView:(UIView *)hostView {
    return [self.pagesByHostView objectForKey:hostView].rootItems ?: @[];
}

- (NSArray<PVDisplayItem *> *)virtualItemsForHostLayer:(CALayer *)hostLayer {
    return [self.pagesByHostLayer objectForKey:hostLayer].rootItems ?: @[];
}

- (BOOL)ownsObjectOID:(unsigned long)oid {
    return self.recordsByOID[@(oid)] != nil;
}

- (BOOL)ownsDisplayItemID:(NSString *)displayItemID {
    return self.recordsByDisplayItemID[displayItemID] != nil;
}

- (void)detailsForTaskPackages:(NSArray<PVStaticAsyncUpdateTasksPackage *> *)packages
               lowImageQuality:(BOOL)lowImageQuality
                    completion:(PVFlutterHierarchyDetailsCompletion)completion {
    NSMutableArray<PVStaticAsyncUpdateTask *> *tasks = [NSMutableArray array];
    for (PVStaticAsyncUpdateTasksPackage *package in packages) {
        for (PVStaticAsyncUpdateTask *task in package.tasks) {
            if ([self ownsObjectOID:task.oid]) [tasks addObject:task];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self processTaskAtIndex:0 tasks:tasks lowImageQuality:lowImageQuality
                         results:[NSMutableArray array] completion:completion];
    });
}

- (void)processTaskAtIndex:(NSUInteger)index
                      tasks:(NSArray<PVStaticAsyncUpdateTask *> *)tasks
            lowImageQuality:(BOOL)lowImageQuality
                    results:(NSMutableArray<PVDisplayItemDetail *> *)results
                 completion:(PVFlutterHierarchyDetailsCompletion)completion {
    if (index >= tasks.count) {
        completion(results.copy);
        return;
    }
    PVStaticAsyncUpdateTask *task = tasks[index];
    PVFlutterNodeRecord *record = self.recordsByOID[@(task.oid)];
    if (!record) {
        [self processTaskAtIndex:index + 1 tasks:tasks lowImageQuality:lowImageQuality
                         results:results completion:completion];
        return;
    }

    PVDisplayItemDetail *detail = [self baseDetailForRecord:record oid:task.oid];
    void (^capture)(void) = ^{
        [self captureForTask:task record:record detail:detail
             lowImageQuality:lowImageQuality completion:^{
            [results addObject:detail];
            [self processTaskAtIndex:index + 1 tasks:tasks lowImageQuality:lowImageQuality
                             results:results completion:completion];
        }];
    };
    // Automatic is the default request mode. Flutter diagnostics are not part
    // of the native attribute groups, so the coordinator must resolve it as
    // "fetch" unless the client explicitly opted out.
    if (task.attrRequest == PVDetailUpdateTaskAttrRequest_NotNeed) {
        capture();
        return;
    }
    [record.page.record.session fetchPropertiesForObjectID:record.node.objectID
                                                completion:^(id payload,
                                                             NSDictionary *response,
                                                             NSError *error) {
        if (!error && payload) {
            detail.flutterDetail = [self detailByAddingDiagnostics:payload
                                                           toDetail:detail.flutterDetail];
            record.detail = detail.flutterDetail;
        }
        capture();
    }];
}

- (void)detailsForDisplayItemIDs:(NSArray<NSString *> *)displayItemIDs
                  needsSoloImage:(BOOL)needsSoloImage
                 needsGroupImage:(BOOL)needsGroupImage
                 lowImageQuality:(BOOL)lowImageQuality
                      completion:(PVFlutterHierarchyDetailsCompletion)completion {
    NSMutableArray<PVStaticAsyncUpdateTask *> *tasks = [NSMutableArray array];
    for (NSString *displayItemID in displayItemIDs) {
        PVFlutterNodeRecord *record = self.recordsByDisplayItemID[displayItemID];
        if (!record) continue;
        PVStaticAsyncUpdateTask *task = [PVStaticAsyncUpdateTask new];
        task.oid = (unsigned long)(uintptr_t)record;
        task.frameSize = record.node.logicalSize;
        task.attrRequest = PVDetailUpdateTaskAttrRequest_Need;
        task.taskType = needsGroupImage ? PVStaticAsyncUpdateTaskTypeGroupScreenshot :
            (needsSoloImage ? PVStaticAsyncUpdateTaskTypeSoloScreenshot :
             PVStaticAsyncUpdateTaskTypeNoScreenshot);
        [tasks addObject:task];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self processTaskAtIndex:0 tasks:tasks lowImageQuality:lowImageQuality
                         results:[NSMutableArray array] completion:completion];
    });
}

- (PVDisplayItemDetail *)baseDetailForRecord:(PVFlutterNodeRecord *)record
                                          oid:(unsigned long)oid {
    PVFVMSnapshotNode *node = record.node;
    PVDisplayItemDetail *detail = [PVDisplayItemDetail new];
    detail.displayItemID = record.displayItemID;
    detail.displayItemOid = oid;
    detail.contentKind = PVDisplayItemContentKindFlutter;
    detail.flutterDetail = record.detail;
    detail.frame = CGRectMake(node.localOffset.x, node.localOffset.y,
                              node.logicalSize.width, node.logicalSize.height);
    detail.bounds = CGRectMake(0, 0, node.logicalSize.width, node.logicalSize.height);
    detail.frameValue = [NSValue valueWithCGRect:detail.frame];
    detail.boundsValue = [NSValue valueWithCGRect:detail.bounds];
    detail.hiddenValue = @NO;
    detail.alphaValue = @1;
    detail.alpha = 1;
    return detail;
}

- (void)captureForTask:(PVStaticAsyncUpdateTask *)task
                 record:(PVFlutterNodeRecord *)record
                 detail:(PVDisplayItemDetail *)detail
        lowImageQuality:(BOOL)lowImageQuality
             completion:(dispatch_block_t)completion {
    PVFVMSnapshotNode *node = record.node;
    if (task.taskType == PVStaticAsyncUpdateTaskTypeNoScreenshot) {
        completion();
        return;
    }
    if (task.taskType == PVStaticAsyncUpdateTaskTypeSoloScreenshot && node.children.count > 0) {
        UIImage *image = [self decorationImageForNode:node lowImageQuality:lowImageQuality];
        if (image) {
            NSData *data = UIImagePNGRepresentation(image);
            detail.soloImageData = data;
            detail.soloScreenshot = image;
        }
        completion();
        return;
    }
    if (!node.captureEligible && node.nativeDecoration == nil) {
        completion();
        return;
    }

    CGFloat margin = ([node.renderObjectType isEqual:@"RenderParagraph"] ||
                      [node.renderObjectType isEqual:@"RenderEditable"]) ? 4 : 0;
    CGFloat ratio = lowImageQuality ? 1 : MIN(UIScreen.mainScreen.scale, 3);
    [record.page.record.session screenshotObjectID:node.objectID
                                       logicalSize:node.logicalSize
                                            margin:margin
                                     maxPixelRatio:ratio
                                        completion:^(UIImage *image,
                                                     NSData *pngData,
                                                     NSError *error) {
        if (!error && image && pngData.length) {
            if (task.taskType == PVStaticAsyncUpdateTaskTypeSoloScreenshot) {
                detail.soloImageData = pngData;
                detail.soloScreenshot = image;
            } else {
                detail.groupImageData = pngData;
                detail.groupScreenshot = image;
            }
        }
        completion();
    }];
}

- (UIImage *)decorationImageForNode:(PVFVMSnapshotNode *)node lowImageQuality:(BOOL)lowImageQuality {
    NSDictionary *decoration = node.nativeDecoration;
    if (!decoration || node.logicalSize.width <= 0 || node.logicalSize.height <= 0) return nil;
    UIGraphicsImageRendererFormat *format = [UIGraphicsImageRendererFormat defaultFormat];
    format.opaque = NO;
    format.scale = lowImageQuality ? 1 : UIScreen.mainScreen.scale;
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc]
        initWithSize:node.logicalSize format:format];
    return [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
        CGRect rect = (CGRect){CGPointZero, node.logicalSize};
        CGFloat radius = [decoration[@"cornerRadius"] doubleValue];
        UIBezierPath *path = [decoration[@"shape"] isEqual:@"circle"]
            ? [UIBezierPath bezierPathWithOvalInRect:rect]
            : [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius];
        NSArray *shadows = [decoration[@"shadows"] isKindOfClass:NSArray.class]
            ? decoration[@"shadows"] : @[];
        NSDictionary *shadow = shadows.firstObject;
        UIColor *fillColor = [self colorFromDictionary:decoration[@"backgroundColor"]]
            ?: UIColor.clearColor;
        CGContextRef cg = context.CGContext;
        CGContextSaveGState(cg);
        if (shadow) {
            CGSize offset = CGSizeMake([shadow[@"offsetX"] doubleValue],
                                       [shadow[@"offsetY"] doubleValue]);
            UIColor *shadowColor = [self colorFromDictionary:shadow[@"color"]]
                ?: UIColor.clearColor;
            CGContextSetShadowWithColor(cg, offset, [shadow[@"blurRadius"] doubleValue],
                                        shadowColor.CGColor);
        }
        [fillColor setFill];
        [path fill];
        CGContextRestoreGState(cg);

        NSDictionary *border = [decoration[@"border"] isKindOfClass:NSDictionary.class]
            ? decoration[@"border"] : nil;
        CGFloat width = [border[@"width"] doubleValue];
        UIColor *borderColor = [self colorFromDictionary:border[@"color"]];
        if (width > 0 && borderColor) {
            [borderColor setStroke];
            path.lineWidth = width;
            [path stroke];
        }
    }];
}

- (PVFlutterNodeDetail *)detailByAddingDiagnostics:(id)payload
                                           toDetail:(PVFlutterNodeDetail *)detail {
    NSArray *properties = [payload isKindOfClass:NSArray.class] ? payload :
        ([payload[@"properties"] isKindOfClass:NSArray.class] ? payload[@"properties"] : @[]);
    if (properties.count == 0) return detail;
    PVFlutterNodeDetail *updated = detail.copy;
    PVFlutterDetailSection *section = [PVFlutterDetailSection new];
    section.identifier = @"diagnostics";
    section.title = @"Diagnostics properties";
    NSMutableArray *fields = [NSMutableArray arrayWithCapacity:properties.count];
    [properties enumerateObjectsUsingBlock:^(id value, NSUInteger index, BOOL *stop) {
        NSString *name = [value[@"name"] isKindOfClass:NSString.class]
            ? value[@"name"] : [NSString stringWithFormat:@"Property %@", @(index + 1)];
        [fields addObject:[self jsonField:[NSString stringWithFormat:@"diagnostics.%@", @(index)]
                                    title:name value:value]];
    }];
    section.fields = fields.copy;
    NSMutableArray *sections = updated.sections.mutableCopy ?: [NSMutableArray array];
    NSIndexSet *old = [sections indexesOfObjectsPassingTest:^BOOL(PVFlutterDetailSection *value,
                                                                  NSUInteger index,
                                                                  BOOL *stop) {
        return [value.identifier isEqual:@"diagnostics"];
    }];
    [sections removeObjectsAtIndexes:old];
    [sections addObject:section];
    updated.sections = sections.copy;
    return updated;
}

- (PVFlutterDetailField *)textField:(NSString *)identifier
                               title:(NSString *)title
                               value:(NSString *)value {
    PVFlutterDetailField *field = [PVFlutterDetailField new];
    field.identifier = identifier;
    field.title = title;
    field.valueKind = PVFlutterDetailValueKindText;
    field.textValue = value ?: @"";
    return field;
}

- (PVFlutterDetailField *)boolField:(NSString *)identifier
                               title:(NSString *)title
                               value:(BOOL)value {
    PVFlutterDetailField *field = [PVFlutterDetailField new];
    field.identifier = identifier;
    field.title = title;
    field.valueKind = PVFlutterDetailValueKindBoolean;
    field.numberValue = @(value);
    return field;
}

- (PVFlutterDetailField *)rectField:(NSString *)identifier
                               title:(NSString *)title
                                rect:(CGRect)rect {
    PVFlutterDetailField *field = [PVFlutterDetailField new];
    field.identifier = identifier;
    field.title = title;
    field.valueKind = PVFlutterDetailValueKindRect;
    field.rectValue = rect;
    return field;
}

- (PVFlutterDetailField *)sizeField:(NSString *)identifier
                               title:(NSString *)title
                                size:(CGSize)size {
    PVFlutterDetailField *field = [PVFlutterDetailField new];
    field.identifier = identifier;
    field.title = title;
    field.valueKind = PVFlutterDetailValueKindSize;
    field.sizeValue = size;
    return field;
}

- (PVFlutterDetailField *)jsonField:(NSString *)identifier
                               title:(NSString *)title
                               value:(id)value {
    PVFlutterDetailField *field = [PVFlutterDetailField new];
    field.identifier = identifier;
    field.title = title;
    field.valueKind = PVFlutterDetailValueKindJSON;
    field.textValue = [PVFVMInspectorJSON prettyJSONStringForObject:value ?: @{}];
    return field;
}

- (UIColor *)colorFromDictionary:(NSDictionary *)dictionary {
    if (![dictionary isKindOfClass:NSDictionary.class]) return nil;
    CGFloat red = [dictionary[@"red"] doubleValue];
    CGFloat green = [dictionary[@"green"] doubleValue];
    CGFloat blue = [dictionary[@"blue"] doubleValue];
    CGFloat alpha = [dictionary[@"alpha"] doubleValue];
    if (red > 1 || green > 1 || blue > 1 || alpha > 1) {
        red /= 255; green /= 255; blue /= 255; alpha /= 255;
    }
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

- (NSString *)colorDescription:(NSDictionary *)dictionary {
    UIColor *color = [self colorFromDictionary:dictionary];
    return color ? color.description : @"";
}

@end

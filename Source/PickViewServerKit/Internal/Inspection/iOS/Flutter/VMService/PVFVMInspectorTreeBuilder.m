#import "PVFVMInspectorTreeBuilder.h"

#import <math.h>

#import "PVFVMInspectorJSON.h"
#import "PVFVMSnapshotNode.h"

@implementation PVFVMInspectorTreeBuilder

+ (PVFVMSnapshotNode *)snapshotTreeFromLayoutPayload:(NSDictionary *)layoutPayload
                                     widgetPayload:(id)widgetPayload
                                      rootObjectID:(NSString *)rootObjectID
                                  fallbackRootSize:(CGSize)fallbackRootSize {
  NSMutableDictionary<NSString *, NSDictionary *> *metadata =
      [NSMutableDictionary dictionary];
  [self collectMetadataFromValue:widgetPayload into:metadata];

  PVFVMSnapshotNode *root = [[PVFVMSnapshotNode alloc] init];
  root.objectID = rootObjectID;
  root.flutterType = @"FlutterView";
  root.kind = @"root";
  root.renderObjectType = [self renderObjectTypeFromNode:layoutPayload];
  root.paintRole = @"root";
  root.renderStrategy = @"rootContainer";
  root.captureEligible = NO;
  root.nodeDescription = @"Entire Flutter surface";
  root.localOffset = CGPointZero;
  root.hasLocalOffset = YES;
  root.sourceJSON = layoutPayload;

  CGSize layoutRootSize = [self sizeFromNode:layoutPayload found:NULL];
  root.logicalSize = layoutRootSize.width > 0 && layoutRootSize.height > 0
                         ? layoutRootSize
                         : fallbackRootSize;
  root.hasLogicalSize =
      root.logicalSize.width > 0 && root.logicalSize.height > 0;
  root.depth = 0;

  [self visitLayoutNode:layoutPayload
           metadataByID:metadata
           visualParent:root
      accumulatedOffset:CGPointZero
         layoutModifiers:@[]
             interactions:@[]
                 semantics:@[]];
  [self updateParentAndDepthForNode:root parent:nil depth:0];
  [self assignRenderStrategiesForNode:root];
  [self pruneOccludedFullSurfaceRoutesFromRoot:root];
  return root;
}

+ (void)pruneOccludedFullSurfaceRoutesFromRoot:(PVFVMSnapshotNode *)root {
  if (!root.hasLogicalSize) {
    return;
  }

  [self pruneOccludedFullSurfaceRoutesBelowNode:root];
  [self updateParentAndDepthForNode:root parent:nil depth:0];
}

+ (void)pruneOccludedFullSurfaceRoutesBelowNode:(PVFVMSnapshotNode *)node {
  if (!node.hasLogicalSize || node.children.count == 0) {
    return;
  }

  NSInteger topRouteIndex = NSNotFound;
  NSInteger routeBranchCount = 0;
  for (NSInteger index = 0; index < (NSInteger)node.children.count; index++) {
    PVFVMSnapshotNode *child = node.children[index];
    if ([self subtree:child
            containsFullSurfaceRouteForSize:node.logicalSize
                              relativeOffset:child.localOffset]) {
      routeBranchCount += 1;
      topRouteIndex = index;
    }
  }

  if (routeBranchCount > 1) {
    NSMutableArray<PVFVMSnapshotNode *> *retainedChildren =
        [NSMutableArray arrayWithCapacity:node.children.count];
    for (NSInteger index = 0; index < (NSInteger)node.children.count; index++) {
      PVFVMSnapshotNode *child = node.children[index];
      BOOL isCoveredRouteBranch =
          index < topRouteIndex &&
          [self subtree:child
              containsFullSurfaceRouteForSize:node.logicalSize
                                relativeOffset:child.localOffset];
      if (!isCoveredRouteBranch) {
        [retainedChildren addObject:child];
      }
    }
    node.children = retainedChildren;
  }

  for (PVFVMSnapshotNode *child in node.children.copy) {
    [self pruneOccludedFullSurfaceRoutesBelowNode:child];
  }
}

+ (BOOL)subtree:(PVFVMSnapshotNode *)node
    containsFullSurfaceRouteForSize:(CGSize)surfaceSize
                      relativeOffset:(CGPoint)relativeOffset {
  NSString *type =
      [[node.flutterType componentsSeparatedByString:@"<"] firstObject]
          ?: node.flutterType;
  BOOL pageType = [type isEqualToString:@"Scaffold"] ||
                  [type isEqualToString:@"CupertinoPageScaffold"];
  BOOL startsAtOrigin = fabs(relativeOffset.x) <= 1.0 &&
                        fabs(relativeOffset.y) <= 1.0;
  BOOL coversSurface =
      node.hasLogicalSize &&
      node.logicalSize.width >= surfaceSize.width * 0.95 &&
      node.logicalSize.height >= surfaceSize.height * 0.95;
  if (pageType && startsAtOrigin && coversSurface) {
    return YES;
  }

  for (PVFVMSnapshotNode *child in node.children) {
    CGPoint childOffset =
        CGPointMake(relativeOffset.x + child.localOffset.x,
                    relativeOffset.y + child.localOffset.y);
    if ([self subtree:child
            containsFullSurfaceRouteForSize:surfaceSize
                              relativeOffset:childOffset]) {
      return YES;
    }
  }
  return NO;
}

+ (void)pruneUnavailableNodesFromRoot:(PVFVMSnapshotNode *)root {
  NSMutableArray<PVFVMSnapshotNode *> *availableChildren = [NSMutableArray array];
  for (PVFVMSnapshotNode *child in root.children.copy) {
    [availableChildren addObjectsFromArray:[self availableNodesFromNode:child]];
  }
  root.children = availableChildren;
  [self updateParentAndDepthForNode:root parent:nil depth:0];
}

+ (NSArray<PVFVMSnapshotNode *> *)availableNodesFromNode:(PVFVMSnapshotNode *)node {
  NSMutableArray<PVFVMSnapshotNode *> *availableChildren = [NSMutableArray array];
  for (PVFVMSnapshotNode *child in node.children.copy) {
    [availableChildren addObjectsFromArray:[self availableNodesFromNode:child]];
  }
  node.children = availableChildren;
  // Screenshot availability controls only the center presentation. Layout,
  // spacing and unknown custom RenderObjects must remain inspectable rows.
  return @[ node ];
}

+ (void)visitLayoutNode:(NSDictionary *)layoutNode
           metadataByID:(NSDictionary<NSString *, NSDictionary *> *)metadataByID
           visualParent:(PVFVMSnapshotNode *)visualParent
      accumulatedOffset:(CGPoint)accumulatedOffset
         layoutModifiers:(NSArray<NSDictionary *> *)layoutModifiers
             interactions:(NSArray<NSDictionary *> *)interactions
                 semantics:(NSArray<NSDictionary *> *)semantics {
  BOOL foundOffset = NO;
  CGPoint localOffset = [self offsetFromNode:layoutNode found:&foundOffset];
  CGPoint combinedOffset = CGPointMake(accumulatedOffset.x + localOffset.x,
                                       accumulatedOffset.y + localOffset.y);

  NSString *objectID = [PVFVMInspectorJSON nodeIDFromDictionary:layoutNode];
  NSDictionary *nodeMetadata =
      objectID.length > 0 ? metadataByID[objectID] : nil;
  NSString *type = [self typeFromNode:layoutNode metadata:nodeMetadata];
  NSString *baseType =
      [[type componentsSeparatedByString:@"<"] firstObject] ?: type;
  NSString *kind = [self kindForVisualType:baseType];
  NSString *renderObjectType = [self renderObjectTypeFromNode:layoutNode];
  NSString *paintRole = [self paintRoleForWidgetType:baseType
                                    renderObjectType:renderObjectType];
  BOOL foundSize = NO;
  CGSize size = [self sizeFromNode:layoutNode found:&foundSize];
  BOOL hasGeometry = objectID.length > 0 && foundSize && size.width > 0 &&
                     size.height > 0;
  NSString *hierarchyRole = [self hierarchyRoleForWidgetType:baseType
                                            renderObjectType:renderObjectType];
  BOOL isVisual = hasGeometry && [hierarchyRole isEqual:@"visual"];

  NSDictionary *relation = [self relationForLayoutNode:layoutNode
                                                   type:baseType
                                         renderObjectType:renderObjectType];
  NSArray<NSDictionary *> *nextModifiers = layoutModifiers;
  NSArray<NSDictionary *> *nextInteractions = interactions;
  NSArray<NSDictionary *> *nextSemantics = semantics;
  if ([hierarchyRole isEqual:@"childrenLayout"]) {
    [visualParent.childrenLayouts addObject:relation];
  } else if ([hierarchyRole isEqual:@"layoutModifier"]) {
    nextModifiers = [layoutModifiers arrayByAddingObject:relation];
  } else if ([hierarchyRole isEqual:@"interaction"]) {
    nextInteractions = [interactions arrayByAddingObject:relation];
  } else if ([hierarchyRole isEqual:@"semantics"]) {
    nextSemantics = [semantics arrayByAddingObject:relation];
  }

  PVFVMSnapshotNode *nextParent = visualParent;
  CGPoint nextAccumulatedOffset = combinedOffset;
  if (isVisual) {
    PVFVMSnapshotNode *snapshotNode = [[PVFVMSnapshotNode alloc] init];
    snapshotNode.objectID = objectID;
    snapshotNode.flutterType = type;
    snapshotNode.kind = kind ?: @"custom";
    snapshotNode.renderObjectType = renderObjectType;
    snapshotNode.paintRole = paintRole;
    snapshotNode.nativeDecoration =
        [self nativeDecorationFromLayoutNode:layoutNode
                            renderObjectType:renderObjectType];
    snapshotNode.nodeDescription =
        [layoutNode[@"description"] isKindOfClass:NSString.class]
            ? layoutNode[@"description"]
            : type;
    NSString *text =
        [nodeMetadata[@"textPreview"] isKindOfClass:NSString.class]
            ? nodeMetadata[@"textPreview"]
            : ([layoutNode[@"textPreview"] isKindOfClass:NSString.class]
                   ? layoutNode[@"textPreview"]
                   : nil);
    snapshotNode.textPreview = text;
    snapshotNode.logicalSize = size;
    snapshotNode.hasLogicalSize = YES;
    snapshotNode.localOffset = combinedOffset;
    snapshotNode.hasLocalOffset =
        foundOffset || !CGPointEqualToPoint(combinedOffset, CGPointZero);
    snapshotNode.sourceJSON = layoutNode;
    [snapshotNode.layoutModifiers addObjectsFromArray:nextModifiers];
    [snapshotNode.interactions addObjectsFromArray:nextInteractions];
    [snapshotNode.semantics addObjectsFromArray:nextSemantics];
    [snapshotNode.capabilities addObjectsFromArray:
        [self capabilitiesForWidgetType:baseType
                       renderObjectType:renderObjectType
                              paintRole:paintRole
                       nativeDecoration:snapshotNode.nativeDecoration]];
    snapshotNode.parent = visualParent;
    [visualParent.children addObject:snapshotNode];
    nextParent = snapshotNode;
    nextAccumulatedOffset = CGPointZero;
    nextModifiers = @[];
    nextInteractions = @[];
    nextSemantics = @[];
  }

  NSArray *children = [layoutNode[@"children"] isKindOfClass:NSArray.class]
                          ? layoutNode[@"children"]
                          : @[];
  for (id child in children) {
    if ([child isKindOfClass:NSDictionary.class]) {
      [self visitLayoutNode:child
               metadataByID:metadataByID
               visualParent:nextParent
          accumulatedOffset:nextAccumulatedOffset
             layoutModifiers:nextModifiers
                 interactions:nextInteractions
                     semantics:nextSemantics];
    }
  }
}

+ (void)assignRenderStrategiesForNode:(PVFVMSnapshotNode *)node {
  for (PVFVMSnapshotNode *child in node.children) {
    [self assignRenderStrategiesForNode:child];
  }

  if (node.parent == nil) {
    node.renderStrategy = @"rootContainer";
    node.captureEligible = NO;
    return;
  }
  if ([node.paintRole isEqual:@"layoutOnly"]) {
    node.renderStrategy = @"layoutOnly";
    node.captureEligible = NO;
    return;
  }
  if (node.nativeDecoration != nil) {
    node.renderStrategy = @"nativeViewDecoration";
    node.captureEligible = NO;
    return;
  }
  if (node.children.count == 0) {
    node.renderStrategy = @"flutterLeafScreenshot";
  } else {
    node.renderStrategy = @"flutterSubtreeScreenshot";
  }
  node.captureEligible = YES;
}

+ (void)
    collectMetadataFromValue:(id)value
                        into:(NSMutableDictionary<NSString *, NSDictionary *> *)
                                 metadata {
  if (![value isKindOfClass:NSDictionary.class]) {
    return;
  }
  NSDictionary *node = value;
  NSString *objectID = [PVFVMInspectorJSON nodeIDFromDictionary:node];
  if (objectID.length > 0) {
    NSMutableDictionary *merged =
        [metadata[objectID] mutableCopy] ?: [NSMutableDictionary dictionary];
    for (NSString *key in @[
           @"widgetRuntimeType", @"runtimeType", @"type", @"textPreview",
           @"createdByLocalProject"
         ]) {
      if (node[key] != nil && node[key] != NSNull.null) {
        merged[key] = node[key];
      }
    }
    metadata[objectID] = merged;
  }
  NSArray *children =
      [node[@"children"] isKindOfClass:NSArray.class] ? node[@"children"] : @[];
  for (id child in children) {
    [self collectMetadataFromValue:child into:metadata];
  }
}

+ (NSString *)typeFromNode:(NSDictionary *)node
                  metadata:(NSDictionary *)metadata {
  for (id value in @[
         metadata[@"widgetRuntimeType"] ?: NSNull.null,
         metadata[@"runtimeType"] ?: NSNull.null,
         node[@"widgetRuntimeType"] ?: NSNull.null,
         node[@"runtimeType"] ?: NSNull.null, node[@"type"] ?: NSNull.null
       ]) {
    if ([value isKindOfClass:NSString.class] && [value length] > 0) {
      return value;
    }
  }
  return @"Unknown";
}

+ (NSString *)hierarchyRoleForWidgetType:(NSString *)widgetType
                         renderObjectType:(NSString *)renderObjectType {
  static NSSet<NSString *> *childrenLayouts;
  static NSSet<NSString *> *layoutModifiers;
  static NSSet<NSString *> *spacingWidgets;
  static NSSet<NSString *> *interactionWrappers;
  static NSSet<NSString *> *semanticWrappers;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    childrenLayouts = [NSSet setWithArray:@[
      @"Column", @"Row", @"Flex", @"Stack", @"IndexedStack", @"Wrap",
      @"Flow", @"Table", @"ListBody", @"CustomMultiChildLayout"
    ]];
    layoutModifiers = [NSSet setWithArray:@[
      @"Align", @"Center", @"Padding", @"SafeArea", @"Expanded",
      @"Flexible", @"Positioned", @"PositionedDirectional", @"FittedBox",
      @"FractionallySizedBox", @"AspectRatio", @"ConstrainedBox",
      @"UnconstrainedBox", @"LimitedBox", @"OverflowBox", @"Baseline",
      @"IntrinsicWidth", @"IntrinsicHeight", @"SliverPadding",
      @"SliverToBoxAdapter"
    ]];
    // These are deliberately visual hierarchy elements: they represent
    // inspectable empty space even though they do not paint pixels.
    spacingWidgets = [NSSet setWithArray:@[ @"SizedBox", @"Spacer" ]];
    interactionWrappers = [NSSet setWithArray:@[
      @"GestureDetector", @"RawGestureDetector", @"Listener", @"MouseRegion",
      @"Focus", @"FocusScope", @"FocusableActionDetector", @"Actions",
      @"Shortcuts", @"CallbackShortcuts", @"TapRegion", @"IgnorePointer",
      @"AbsorbPointer", @"ModalBarrier"
    ]];
    semanticWrappers = [NSSet setWithArray:@[
      @"Semantics", @"MergeSemantics", @"ExcludeSemantics", @"BlockSemantics"
    ]];
  });

  if ([spacingWidgets containsObject:widgetType]) return @"visual";
  if ([childrenLayouts containsObject:widgetType]) return @"childrenLayout";
  if ([layoutModifiers containsObject:widgetType]) return @"layoutModifier";
  if ([interactionWrappers containsObject:widgetType]) return @"interaction";
  if ([semanticWrappers containsObject:widgetType]) return @"semantics";

  // Unknown third-party widgets with a concrete RenderObject remain visible.
  // A tool should show an outline for an unknown node instead of dropping it.
  if (renderObjectType.length > 0 &&
      ![renderObjectType isEqual:@"Unknown"]) {
    return @"visual";
  }
  return @"transparent";
}

+ (NSDictionary *)relationForLayoutNode:(NSDictionary *)layoutNode
                                    type:(NSString *)type
                        renderObjectType:(NSString *)renderObjectType {
  NSMutableDictionary *relation = [@{
    @"type" : type ?: @"Unknown",
    @"renderObjectType" : renderObjectType ?: @"Unknown"
  } mutableCopy];
  NSString *objectID = [PVFVMInspectorJSON nodeIDFromDictionary:layoutNode];
  if (objectID.length > 0) relation[@"objectId"] = objectID;
  if ([layoutNode[@"description"] isKindOfClass:NSString.class]) {
    relation[@"description"] = layoutNode[@"description"];
  }
  NSDictionary *renderObject =
      [layoutNode[@"renderObject"] isKindOfClass:NSDictionary.class]
          ? layoutNode[@"renderObject"]
          : nil;
  if ([renderObject[@"properties"] isKindOfClass:NSArray.class]) {
    relation[@"properties"] = renderObject[@"properties"];
  }
  NSArray *children = [layoutNode[@"children"] isKindOfClass:NSArray.class]
                          ? layoutNode[@"children"]
                          : @[];
  NSMutableArray *managedChildren = [NSMutableArray array];
  for (id value in children) {
    if (![value isKindOfClass:NSDictionary.class]) continue;
    NSDictionary *child = value;
    NSMutableDictionary *managedChild = [NSMutableDictionary dictionary];
    NSString *childID = [PVFVMInspectorJSON nodeIDFromDictionary:child];
    if (childID.length > 0) managedChild[@"objectId"] = childID;
    NSString *childType = [self typeFromNode:child metadata:nil];
    if (childType.length > 0) managedChild[@"type"] = childType;
    if (managedChild.count > 0) [managedChildren addObject:managedChild];
  }
  relation[@"managedChildren"] = managedChildren;
  BOOL foundSize = NO;
  CGSize size = [self sizeFromNode:layoutNode found:&foundSize];
  if (foundSize) {
    relation[@"size"] = @{ @"width" : @(size.width), @"height" : @(size.height) };
  }
  return relation;
}

+ (NSArray<NSString *> *)capabilitiesForWidgetType:(NSString *)widgetType
                                  renderObjectType:(NSString *)renderObjectType
                                         paintRole:(NSString *)paintRole
                                  nativeDecoration:(NSDictionary *)decoration {
  NSMutableOrderedSet<NSString *> *result = [NSMutableOrderedSet orderedSet];
  if (renderObjectType.length > 0 && ![renderObjectType isEqual:@"Unknown"]) {
    [result addObject:@"layout"];
  }
  if ([paintRole isEqual:@"selfPainting"]) [result addObject:@"paint"];
  if ([paintRole isEqual:@"effect"]) [result addObject:@"effect"];
  if (decoration != nil) [result addObject:@"decoration"];

  if ([widgetType containsString:@"Clip"] ||
      [renderObjectType containsString:@"Clip"]) {
    [result addObject:@"clip"];
  }
  if ([widgetType containsString:@"Opacity"] ||
      [widgetType containsString:@"Filter"] ||
      [renderObjectType containsString:@"Opacity"] ||
      [renderObjectType containsString:@"Filter"]) {
    [result addObject:@"compositing"];
  }
  if ([widgetType containsString:@"Transform"] ||
      [renderObjectType containsString:@"Transform"]) {
    [result addObject:@"transform"];
  }
  if ([widgetType containsString:@"Scroll"] ||
      [widgetType containsString:@"ListView"] ||
      [widgetType containsString:@"GridView"] ||
      [widgetType containsString:@"PageView"] ||
      [renderObjectType containsString:@"Viewport"] ||
      [renderObjectType containsString:@"Sliver"]) {
    [result addObject:@"scroll"];
  }
  if ([widgetType containsString:@"PlatformView"] ||
      [widgetType isEqual:@"UiKitView"] ||
      [renderObjectType containsString:@"UiKitView"] ||
      [renderObjectType containsString:@"PlatformView"]) {
    [result addObject:@"platformView"];
  }
  return result.array;
}

+ (NSString *)kindForVisualType:(NSString *)type {
  static NSSet<NSString *> *textTypes;
  static NSSet<NSString *> *layoutTypes;
  static NSSet<NSString *> *boxTypes;
  static NSSet<NSString *> *imageTypes;
  static NSSet<NSString *> *controlTypes;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    textTypes = [NSSet setWithArray:@[
      @"Text", @"RichText", @"SelectableText", @"EditableText"
    ]];
    layoutTypes = [NSSet setWithArray:@[
      @"Align",           @"AspectRatio",
      @"Center",          @"Column",
      @"ConstrainedBox",  @"Expanded",
      @"FittedBox",       @"Flex",
      @"Flexible",        @"GridView",
      @"IntrinsicHeight", @"IntrinsicWidth",
      @"LimitedBox",      @"ListView",
      @"OverflowBox",     @"Padding",
      @"Positioned",      @"Row",
      @"SafeArea",        @"SingleChildScrollView",
      @"SizedBox",        @"Spacer",
      @"Stack",           @"Wrap"
    ]];
    boxTypes = [NSSet setWithArray:@[
      @"AppBar", @"Card", @"ColoredBox", @"Container",
      @"CupertinoNavigationBar", @"DecoratedBox", @"Material",
      @"PhysicalModel", @"Scaffold", @"ClipOval", @"ClipPath",
      @"ClipRect", @"ClipRRect", @"Opacity", @"Transform"
    ]];
    imageTypes = [NSSet setWithArray:@[
      @"CircleAvatar", @"FadeInImage", @"FlutterLogo", @"Image", @"RawImage"
    ]];
    controlTypes = [NSSet setWithArray:@[
      @"Checkbox", @"CupertinoButton", @"ElevatedButton",
      @"FloatingActionButton", @"GestureDetector", @"IconButton", @"InkWell",
      @"OutlinedButton", @"Radio", @"Slider", @"Switch", @"TextButton"
    ]];
  });

  if ([textTypes containsObject:type])
    return @"text";
  if ([layoutTypes containsObject:type])
    return @"layout";
  if ([boxTypes containsObject:type])
    return @"box";
  if ([imageTypes containsObject:type])
    return @"image";
  if ([type isEqualToString:@"Icon"])
    return @"icon";
  if ([controlTypes containsObject:type] || [type hasSuffix:@"Button"])
    return @"control";
  if ([type isEqualToString:@"CustomPaint"])
    return @"canvas";
  return @"custom";
}

+ (NSString *)renderObjectTypeFromNode:(NSDictionary *)node {
  NSDictionary *renderObject =
      [node[@"renderObject"] isKindOfClass:NSDictionary.class]
          ? node[@"renderObject"]
          : nil;
  NSString *description =
      [renderObject[@"description"] isKindOfClass:NSString.class]
          ? renderObject[@"description"]
          : nil;
  if (description.length == 0) {
    return @"Unknown";
  }

  NSRegularExpression *regex = [NSRegularExpression
      regularExpressionWithPattern:@"^([_A-Za-z][_A-Za-z0-9]*)"
                           options:0
                             error:nil];
  NSTextCheckingResult *match =
      [regex firstMatchInString:description
                        options:0
                          range:NSMakeRange(0, description.length)];
  if (match.numberOfRanges != 2) {
    return @"Unknown";
  }
  return [description substringWithRange:[match rangeAtIndex:1]];
}

+ (NSDictionary *)nativeDecorationFromLayoutNode:(NSDictionary *)layoutNode
                                 renderObjectType:(NSString *)renderObjectType {
  NSDictionary *renderObject =
      [layoutNode[@"renderObject"] isKindOfClass:NSDictionary.class]
          ? layoutNode[@"renderObject"]
          : nil;
  NSArray *properties =
      [renderObject[@"properties"] isKindOfClass:NSArray.class]
          ? renderObject[@"properties"]
          : @[];

  if ([renderObjectType isEqual:@"RenderDecoratedBox"]) {
    NSDictionary *decoration =
        [self diagnosticPropertyNamed:@"decoration" inProperties:properties];
    NSArray *decorationProperties =
        [decoration[@"properties"] isKindOfClass:NSArray.class]
            ? decoration[@"properties"]
            : @[];
    if (decorationProperties.count == 0) {
      return nil;
    }

    NSDictionary *image =
        [self diagnosticPropertyNamed:@"image"
                         inProperties:decorationProperties];
    NSDictionary *gradient =
        [self diagnosticPropertyNamed:@"gradient"
                         inProperties:decorationProperties];
    if ([self diagnosticPropertyHasValue:image] ||
        [self diagnosticPropertyHasValue:gradient]) {
      return nil;
    }

    NSMutableDictionary *result =
        [@{ @"kind" : @"boxDecoration", @"shape" : @"rectangle" }
            mutableCopy];
    NSDictionary *color = [self colorDictionaryFromProperty:
                                     [self diagnosticPropertyNamed:@"color"
                                                      inProperties:
                                                          decorationProperties]];
    if (color != nil) {
      result[@"backgroundColor"] = color;
    }

    NSDictionary *shape =
        [self diagnosticPropertyNamed:@"shape"
                         inProperties:decorationProperties];
    NSString *shapeDescription = [self diagnosticDescription:shape];
    if ([shapeDescription containsString:@"circle"]) {
      result[@"shape"] = @"circle";
    }

    NSDictionary *radiusProperty =
        [self diagnosticPropertyNamed:@"borderRadius"
                         inProperties:decorationProperties];
    if ([self diagnosticPropertyHasValue:radiusProperty]) {
      NSNumber *radius =
          [self uniformRadiusFromDescription:
                    [self diagnosticDescription:radiusProperty]];
      if (radius == nil) {
        return nil;
      }
      result[@"cornerRadius"] = radius;
    }

    NSDictionary *borderProperty =
        [self diagnosticPropertyNamed:@"border"
                         inProperties:decorationProperties];
    if ([self diagnosticPropertyHasValue:borderProperty]) {
      NSDictionary *border =
          [self borderDictionaryFromDescription:
                    [self diagnosticDescription:borderProperty]];
      if (border == nil) {
        return nil;
      }
      result[@"border"] = border;
    }

    NSDictionary *shadowProperty =
        [self diagnosticPropertyNamed:@"boxShadow"
                         inProperties:decorationProperties];
    if ([self diagnosticPropertyHasValue:shadowProperty]) {
      NSArray *shadows = [self shadowDictionariesFromProperty:shadowProperty];
      if (shadows == nil) {
        return nil;
      }
      result[@"shadows"] = shadows;
    }

    return result.count > 2 ? result : nil;
  }

  if ([renderObjectType isEqual:@"_RenderColoredBox"]) {
    NSDictionary *color = [self colorDictionaryFromProperty:
                                     [self diagnosticPropertyNamed:@"color"
                                                      inProperties:properties]];
    return color == nil
               ? nil
               : @{ @"kind" : @"solidColor",
                    @"shape" : @"rectangle",
                    @"backgroundColor" : color };
  }

  if ([renderObjectType isEqual:@"RenderPhysicalModel"]) {
    NSDictionary *color = [self colorDictionaryFromProperty:
                                     [self diagnosticPropertyNamed:@"color"
                                                      inProperties:properties]];
    if (color == nil) {
      return nil;
    }
    NSMutableDictionary *result =
        [@{ @"kind" : @"physicalModel",
            @"shape" : @"rectangle",
            @"backgroundColor" : color }
            mutableCopy];
    NSString *shapeDescription = [self diagnosticDescription:
        [self diagnosticPropertyNamed:@"shape" inProperties:properties]];
    if ([shapeDescription containsString:@"circle"]) {
      result[@"shape"] = @"circle";
    }
    NSDictionary *radiusProperty =
        [self diagnosticPropertyNamed:@"borderRadius"
                         inProperties:properties];
    if ([self diagnosticPropertyHasValue:radiusProperty]) {
      NSNumber *radius =
          [self uniformRadiusFromDescription:
                    [self diagnosticDescription:radiusProperty]];
      if (radius == nil) {
        return nil;
      }
      result[@"cornerRadius"] = radius;
    }
    NSNumber *elevation = [self numberFromDiagnosticProperty:
        [self diagnosticPropertyNamed:@"elevation" inProperties:properties]];
    if (elevation.doubleValue > 0) {
      result[@"elevation"] = elevation;
      NSDictionary *shadowColor = [self colorDictionaryFromProperty:
          [self diagnosticPropertyNamed:@"shadowColor"
                            inProperties:properties]];
      if (shadowColor != nil) {
        result[@"shadowColor"] = shadowColor;
      }
    }
    return result;
  }

  return nil;
}

+ (NSDictionary *)diagnosticPropertyNamed:(NSString *)name
                              inProperties:(NSArray *)properties {
  for (id value in properties) {
    if ([value isKindOfClass:NSDictionary.class] &&
        [value[@"name"] isEqual:name]) {
      return value;
    }
  }
  return nil;
}

+ (NSString *)diagnosticDescription:(NSDictionary *)property {
  return [property[@"description"] isKindOfClass:NSString.class]
             ? property[@"description"]
             : @"";
}

+ (BOOL)diagnosticPropertyHasValue:(NSDictionary *)property {
  if (property == nil) {
    return NO;
  }
  id value = property[@"value"];
  if (value == NSNull.null) {
    return NO;
  }
  NSString *description = [self diagnosticDescription:property];
  return description.length > 0 && ![description isEqual:@"null"];
}

+ (NSNumber *)numberFromDiagnosticProperty:(NSDictionary *)property {
  NSNumber *value = [PVFVMInspectorJSON numberFromValue:property[@"value"]];
  if (value != nil) {
    return value;
  }
  return [PVFVMInspectorJSON
      numberFromValue:property[@"numberToString"] ?:
                          [self diagnosticDescription:property]];
}

+ (NSDictionary *)colorDictionaryFromProperty:(NSDictionary *)property {
  NSDictionary *components =
      [property[@"valueProperties"] isKindOfClass:NSDictionary.class]
          ? property[@"valueProperties"]
          : nil;
  NSNumber *red = [PVFVMInspectorJSON numberFromValue:components[@"red"]];
  NSNumber *green = [PVFVMInspectorJSON numberFromValue:components[@"green"]];
  NSNumber *blue = [PVFVMInspectorJSON numberFromValue:components[@"blue"]];
  NSNumber *alpha = [PVFVMInspectorJSON numberFromValue:components[@"alpha"]];
  if (red != nil && green != nil && blue != nil && alpha != nil) {
    return @{ @"red" : red,
              @"green" : green,
              @"blue" : blue,
              @"alpha" : alpha };
  }
  return [self colorDictionaryFromDescription:
                   [self diagnosticDescription:property]];
}

+ (NSDictionary *)colorDictionaryFromDescription:(NSString *)description {
  if (description.length == 0) {
    return nil;
  }
  NSRegularExpression *componentsRegex = [NSRegularExpression
      regularExpressionWithPattern:
          @"Color\\(alpha:\\s*([0-9.]+),\\s*red:\\s*([0-9.]+),\\s*green:"
          @"\\s*([0-9.]+),\\s*blue:\\s*([0-9.]+)"
                           options:0
                             error:nil];
  NSTextCheckingResult *match =
      [componentsRegex firstMatchInString:description
                                  options:0
                                    range:NSMakeRange(0, description.length)];
  if (match.numberOfRanges == 5) {
    double alpha =
        [[description substringWithRange:[match rangeAtIndex:1]] doubleValue];
    double red =
        [[description substringWithRange:[match rangeAtIndex:2]] doubleValue];
    double green =
        [[description substringWithRange:[match rangeAtIndex:3]] doubleValue];
    double blue =
        [[description substringWithRange:[match rangeAtIndex:4]] doubleValue];
    return @{ @"red" : @(round(red * 255.0)),
              @"green" : @(round(green * 255.0)),
              @"blue" : @(round(blue * 255.0)),
              @"alpha" : @(round(alpha * 255.0)) };
  }

  NSRegularExpression *hexRegex = [NSRegularExpression
      regularExpressionWithPattern:@"Color\\(0x([0-9A-Fa-f]{8})\\)"
                           options:0
                             error:nil];
  match = [hexRegex firstMatchInString:description
                               options:0
                                 range:NSMakeRange(0, description.length)];
  if (match.numberOfRanges == 2) {
    NSString *hex = [description substringWithRange:[match rangeAtIndex:1]];
    unsigned long long argb = 0;
    [[NSScanner scannerWithString:hex] scanHexLongLong:&argb];
    return @{ @"alpha" : @((argb >> 24) & 0xff),
              @"red" : @((argb >> 16) & 0xff),
              @"green" : @((argb >> 8) & 0xff),
              @"blue" : @(argb & 0xff) };
  }
  return nil;
}

+ (NSNumber *)uniformRadiusFromDescription:(NSString *)description {
  if (description.length == 0 || [description isEqual:@"null"]) {
    return nil;
  }
  if ([description containsString:@"zero"]) {
    return @0;
  }
  if ([description containsString:@"topLeft"] ||
      [description containsString:@"topRight"] ||
      [description containsString:@"bottomLeft"] ||
      [description containsString:@"bottomRight"] ||
      [description containsString:@"elliptical"]) {
    return nil;
  }
  NSRegularExpression *regex = [NSRegularExpression
      regularExpressionWithPattern:
          @"(?:BorderRadius\\.circular|Radius\\.circular)\\(\\s*([-+0-9.eE]+)"
          @"\\s*\\)"
                           options:0
                             error:nil];
  NSTextCheckingResult *match =
      [regex firstMatchInString:description
                        options:0
                          range:NSMakeRange(0, description.length)];
  if (match.numberOfRanges != 2) {
    return nil;
  }
  return @([[description substringWithRange:[match rangeAtIndex:1]]
      doubleValue]);
}

+ (NSDictionary *)borderDictionaryFromDescription:(NSString *)description {
  if ([description containsString:@"BorderSide.none"] ||
      [description containsString:@"BorderStyle.none"]) {
    return @{ @"width" : @0 };
  }
  if (![description containsString:@"Border.all("]) {
    return nil;
  }
  NSDictionary *color = [self colorDictionaryFromDescription:description];
  NSRegularExpression *widthRegex = [NSRegularExpression
      regularExpressionWithPattern:@"width:\\s*([-+0-9.eE]+)"
                           options:0
                             error:nil];
  NSTextCheckingResult *match =
      [widthRegex firstMatchInString:description
                             options:0
                               range:NSMakeRange(0, description.length)];
  if (color == nil || match.numberOfRanges != 2) {
    return nil;
  }
  double width =
      [[description substringWithRange:[match rangeAtIndex:1]] doubleValue];
  return @{ @"width" : @(width), @"color" : color, @"style" : @"solid" };
}

+ (NSArray *)shadowDictionariesFromProperty:(NSDictionary *)property {
  NSArray *values = [property[@"values"] isKindOfClass:NSArray.class]
                        ? property[@"values"]
                        : nil;
  if (values.count == 0) {
    NSString *description = [self diagnosticDescription:property];
    values = description.length > 0 ? @[ description ] : @[];
  }
  NSMutableArray *result = [NSMutableArray arrayWithCapacity:values.count];
  NSRegularExpression *numbersRegex = [NSRegularExpression
      regularExpressionWithPattern:
          @"Offset\\(\\s*([-+0-9.eE]+)\\s*,\\s*([-+0-9.eE]+)\\s*\\)\\s*,"
          @"\\s*([-+0-9.eE]+)\\s*,\\s*([-+0-9.eE]+)"
                           options:0
                             error:nil];
  for (id value in values) {
    NSString *description = [value isKindOfClass:NSString.class] ? value : nil;
    NSDictionary *color = [self colorDictionaryFromDescription:description];
    NSTextCheckingResult *match =
        [numbersRegex firstMatchInString:description ?: @""
                                options:0
                                  range:NSMakeRange(0, description.length)];
    if (color == nil || match.numberOfRanges != 5 ||
        ([description containsString:@"BlurStyle."] &&
         ![description containsString:@"BlurStyle.normal"])) {
      return nil;
    }
    [result addObject:@{
      @"color" : color,
      @"offsetX" : @([[description substringWithRange:[match rangeAtIndex:1]]
          doubleValue]),
      @"offsetY" : @([[description substringWithRange:[match rangeAtIndex:2]]
          doubleValue]),
      @"blurRadius" : @([[description substringWithRange:[match rangeAtIndex:3]]
          doubleValue]),
      @"spreadRadius" : @([[description substringWithRange:[match rangeAtIndex:4]]
          doubleValue])
    }];
  }
  return result;
}

+ (NSString *)paintRoleForWidgetType:(NSString *)widgetType
                    renderObjectType:(NSString *)renderObjectType {
  static NSSet<NSString *> *selfPaintingRenderObjects;
  static NSSet<NSString *> *effectRenderObjects;
  static NSSet<NSString *> *layoutOnlyRenderObjects;
  static NSSet<NSString *> *selfPaintingWidgets;
  static NSSet<NSString *> *effectWidgets;
  static NSSet<NSString *> *layoutOnlyWidgets;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    selfPaintingRenderObjects = [NSSet setWithArray:@[
      @"RenderParagraph", @"RenderEditable", @"RenderImage",
      @"RenderDecoratedBox", @"_RenderColoredBox", @"RenderPhysicalModel",
      @"RenderPhysicalShape", @"RenderCustomPaint", @"RenderFlutterLogo",
      @"RenderErrorBox", @"RenderPerformanceOverlay", @"RenderTextureBox",
      @"RenderAndroidView", @"RenderUiKitView", @"RenderPlatformView"
    ]];
    effectRenderObjects = [NSSet setWithArray:@[
      @"RenderOpacity", @"RenderAnimatedOpacity", @"RenderTransform",
      @"RenderClipRect", @"RenderClipRRect", @"RenderClipOval",
      @"RenderClipPath", @"RenderBackdropFilter", @"RenderShaderMask",
      @"RenderColorFiltered", @"RenderImageFiltered", @"RenderFittedBox",
      @"RenderFractionalTranslation", @"RenderRotatedBox", @"RenderLeaderLayer",
      @"RenderFollowerLayer", @"RenderOffstage", @"RenderAnimatedSize"
    ]];
    layoutOnlyRenderObjects = [NSSet setWithArray:@[
      @"RenderPadding",
      @"RenderPositionedBox",
      @"RenderFlex",
      @"RenderConstrainedBox",
      @"RenderAspectRatio",
      @"RenderIntrinsicWidth",
      @"RenderIntrinsicHeight",
      @"RenderLimitedBox",
      @"RenderSizedOverflowBox",
      @"RenderUnconstrainedBox",
      @"RenderBaseline",
      @"RenderStack",
      @"RenderIndexedStack",
      @"RenderWrap",
      @"RenderListBody",
      @"RenderSemanticsAnnotations",
      @"RenderExcludeSemantics",
      @"RenderMergeSemantics",
      @"RenderBlockSemantics",
      @"RenderIgnorePointer",
      @"RenderAbsorbPointer",
      @"RenderMouseRegion",
      @"RenderPointerListener",
      @"RenderTapRegion",
      @"RenderSliverPadding",
      @"RenderSliverToBoxAdapter",
      @"RenderProxyBox",
      @"RenderProxySliver",
      @"RenderRepaintBoundary"
    ]];

    selfPaintingWidgets = [NSSet setWithArray:@[
      @"AppBar",
      @"Text",
      @"RichText",
      @"SelectableText",
      @"EditableText",
      @"Image",
      @"RawImage",
      @"Icon",
      @"FlutterLogo",
      @"CustomPaint",
      @"Scaffold",
      @"Material",
      @"Card",
      @"PhysicalModel",
      @"ColoredBox",
      @"DecoratedBox",
      @"Checkbox",
      @"CupertinoButton",
      @"CupertinoNavigationBar",
      @"ElevatedButton",
      @"FloatingActionButton",
      @"IconButton",
      @"OutlinedButton",
      @"Radio",
      @"Slider",
      @"Switch",
      @"TextButton"
    ]];
    effectWidgets = [NSSet setWithArray:@[
      @"Opacity", @"Transform", @"ClipOval", @"ClipPath", @"ClipRect",
      @"ClipRRect", @"FittedBox", @"BackdropFilter", @"ShaderMask",
      @"ColorFiltered", @"ImageFiltered", @"RotatedBox",
      @"FractionalTranslation", @"Offstage", @"InkWell"
    ]];
    layoutOnlyWidgets = [NSSet setWithArray:@[
      @"Align",
      @"AspectRatio",
      @"Center",
      @"Column",
      @"ConstrainedBox",
      @"Expanded",
      @"Flex",
      @"Flexible",
      @"GridView",
      @"IntrinsicHeight",
      @"IntrinsicWidth",
      @"LimitedBox",
      @"ListView",
      @"OverflowBox",
      @"Padding",
      @"Positioned",
      @"Row",
      @"SafeArea",
      @"SingleChildScrollView",
      @"SizedBox",
      @"Spacer",
      @"Stack",
      @"Wrap",
      @"GestureDetector"
    ]];
  });

  if ([selfPaintingRenderObjects containsObject:renderObjectType]) {
    return @"selfPaint";
  }
  if ([effectRenderObjects containsObject:renderObjectType]) {
    return @"paintEffect";
  }
  if ([effectWidgets containsObject:widgetType]) {
    return @"paintEffect";
  }
  if ([selfPaintingWidgets containsObject:widgetType]) {
    return @"selfPaint";
  }
  if ([layoutOnlyRenderObjects containsObject:renderObjectType] ||
      [layoutOnlyWidgets containsObject:widgetType]) {
    return @"layoutOnly";
  }
  if ([widgetType isEqual:@"Container"]) {
    return @"selfPaint";
  }
  return @"unknown";
}

+ (CGSize)sizeFromNode:(NSDictionary *)node found:(BOOL *)found {
  NSDictionary *size =
      [node[@"size"] isKindOfClass:NSDictionary.class] ? node[@"size"] : nil;
  NSNumber *width = [PVFVMInspectorJSON numberFromValue:size[@"width"]];
  NSNumber *height = [PVFVMInspectorJSON numberFromValue:size[@"height"]];
  BOOL hasSize = width != nil && height != nil && isfinite(width.doubleValue) &&
                 isfinite(height.doubleValue);
  if (found != NULL) {
    *found = hasSize;
  }
  return hasSize ? CGSizeMake(width.doubleValue, height.doubleValue)
                 : CGSizeZero;
}

+ (CGPoint)offsetFromNode:(NSDictionary *)node found:(BOOL *)found {
  NSDictionary *parentData =
      [node[@"parentData"] isKindOfClass:NSDictionary.class]
          ? node[@"parentData"]
          : nil;
  NSNumber *x = [PVFVMInspectorJSON numberFromValue:parentData[@"offsetX"]];
  NSNumber *y = [PVFVMInspectorJSON numberFromValue:parentData[@"offsetY"]];
  if (x != nil && y != nil) {
    if (found != NULL)
      *found = YES;
    return CGPointMake(x.doubleValue, y.doubleValue);
  }

  NSString *description =
      [self parentDataDescriptionInValue:node[@"renderObject"]];
  if (description.length > 0) {
    NSRegularExpression *regex = [NSRegularExpression
        regularExpressionWithPattern:
            @"offset=Offset\\(\\s*([-+0-9.eE]+)\\s*,\\s*([-+0-9.eE]+)\\s*\\)"
                             options:0
                               error:nil];
    NSTextCheckingResult *match =
        [regex firstMatchInString:description
                          options:0
                            range:NSMakeRange(0, description.length)];
    if (match.numberOfRanges == 3) {
      double parsedX =
          [[description substringWithRange:[match rangeAtIndex:1]] doubleValue];
      double parsedY =
          [[description substringWithRange:[match rangeAtIndex:2]] doubleValue];
      if (isfinite(parsedX) && isfinite(parsedY)) {
        if (found != NULL)
          *found = YES;
        return CGPointMake(parsedX, parsedY);
      }
    }
  }

  if (found != NULL)
    *found = NO;
  return CGPointZero;
}

+ (NSString *)parentDataDescriptionInValue:(id)value {
  if ([value isKindOfClass:NSDictionary.class]) {
    NSDictionary *dictionary = value;
    if ([dictionary[@"name"] isEqual:@"parentData"] &&
        [dictionary[@"description"] isKindOfClass:NSString.class]) {
      return dictionary[@"description"];
    }
    for (id nestedValue in dictionary.allValues) {
      NSString *result = [self parentDataDescriptionInValue:nestedValue];
      if (result.length > 0) {
        return result;
      }
    }
  } else if ([value isKindOfClass:NSArray.class]) {
    for (id nestedValue in value) {
      NSString *result = [self parentDataDescriptionInValue:nestedValue];
      if (result.length > 0) {
        return result;
      }
    }
  }
  return nil;
}

+ (void)updateParentAndDepthForNode:(PVFVMSnapshotNode *)node
                             parent:(PVFVMSnapshotNode *)parent
                              depth:(NSInteger)depth {
  node.parent = parent;
  node.depth = depth;
  for (PVFVMSnapshotNode *child in node.children) {
    [self updateParentAndDepthForNode:child parent:node depth:depth + 1];
  }
}

@end

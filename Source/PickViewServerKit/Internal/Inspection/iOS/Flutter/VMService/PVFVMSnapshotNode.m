#import "PVFVMSnapshotNode.h"

@implementation PVFVMSnapshotNode

- (instancetype)init {
  self = [super init];
  if (self) {
    _objectID = @"";
    _flutterType = @"Unknown";
    _kind = @"unknown";
    _renderObjectType = @"Unknown";
    _paintRole = @"unknown";
    _renderStrategy = @"flutterSubtreeScreenshot";
    _captureEligible = YES;
    _nodeDescription = @"";
    _logicalSize = CGSizeZero;
    _localOffset = CGPointZero;
    _paintInsets = UIEdgeInsetsZero;
    _children = [NSMutableArray array];
    _childrenLayouts = [NSMutableArray array];
    _layoutModifiers = [NSMutableArray array];
    _interactions = [NSMutableArray array];
    _semantics = [NSMutableArray array];
    _capabilities = [NSMutableArray array];
    _screenshotStatus = @"pending";
  }
  return self;
}

- (NSArray<PVFVMSnapshotNode *> *)flattenedNodes {
  NSMutableArray<PVFVMSnapshotNode *> *result =
      [NSMutableArray arrayWithObject:self];
  for (PVFVMSnapshotNode *child in self.children) {
    [result addObjectsFromArray:child.flattenedNodes];
  }
  return result;
}

- (NSDictionary *)manifestDictionaryWithAbsoluteOrigin:(CGPoint)absoluteOrigin {
  CGPoint nodeOrigin = CGPointMake(absoluteOrigin.x + self.localOffset.x,
                                   absoluteOrigin.y + self.localOffset.y);
  NSMutableDictionary *dictionary = [@{
    @"id" : self.objectID,
    @"type" : self.flutterType,
    @"kind" : self.kind,
    @"renderObjectType" : self.renderObjectType,
    @"paintRole" : self.paintRole,
    @"renderStrategy" : self.renderStrategy,
    @"captureEligible" : @(self.captureEligible),
    @"description" : self.nodeDescription,
    @"depth" : @(self.depth),
    @"status" : self.screenshotStatus,
    @"localFrame" : @{
      @"x" : @(self.localOffset.x),
      @"y" : @(self.localOffset.y),
      @"width" : @(self.logicalSize.width),
      @"height" : @(self.logicalSize.height)
    },
    @"absoluteFrame" : @{
      @"x" : @(nodeOrigin.x),
      @"y" : @(nodeOrigin.y),
      @"width" : @(self.logicalSize.width),
      @"height" : @(self.logicalSize.height)
    }
  } mutableCopy];
  if (self.textPreview.length > 0) {
    dictionary[@"text"] = self.textPreview;
  }
  if (self.screenshotFile.length > 0) {
    dictionary[@"file"] = self.screenshotFile;
  }
  if (self.nativeDecoration != nil) {
    dictionary[@"nativeDecoration"] = self.nativeDecoration;
  }
  if (self.childrenLayouts.count > 0) {
    dictionary[@"childrenLayouts"] = self.childrenLayouts;
  }
  if (self.layoutModifiers.count > 0) {
    dictionary[@"layoutModifiers"] = self.layoutModifiers;
  }
  if (self.interactions.count > 0) {
    dictionary[@"interactions"] = self.interactions;
  }
  if (self.semantics.count > 0) {
    dictionary[@"semantics"] = self.semantics;
  }
  dictionary[@"capabilities"] = self.capabilities;
  if (!UIEdgeInsetsEqualToEdgeInsets(self.paintInsets, UIEdgeInsetsZero)) {
    dictionary[@"paintInsets"] = @{
      @"top" : @(self.paintInsets.top),
      @"left" : @(self.paintInsets.left),
      @"bottom" : @(self.paintInsets.bottom),
      @"right" : @(self.paintInsets.right)
    };
  }
  if (self.pngData != nil) {
    dictionary[@"bytes"] = @(self.pngData.length);
  }
  if (self.image.CGImage != nil) {
    dictionary[@"pixelWidth"] = @(CGImageGetWidth(self.image.CGImage));
    dictionary[@"pixelHeight"] = @(CGImageGetHeight(self.image.CGImage));
  }

  NSMutableArray *children =
      [NSMutableArray arrayWithCapacity:self.children.count];
  for (PVFVMSnapshotNode *child in self.children) {
    [children
        addObject:[child manifestDictionaryWithAbsoluteOrigin:nodeOrigin]];
  }
  dictionary[@"children"] = children;
  return dictionary;
}

@end

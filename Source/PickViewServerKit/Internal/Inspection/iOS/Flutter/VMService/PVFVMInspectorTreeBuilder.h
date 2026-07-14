#import <UIKit/UIKit.h>

@class PVFVMSnapshotNode;

NS_ASSUME_NONNULL_BEGIN

@interface PVFVMInspectorTreeBuilder : NSObject

+ (PVFVMSnapshotNode *)snapshotTreeFromLayoutPayload:(NSDictionary *)layoutPayload
                                     widgetPayload:(nullable id)widgetPayload
                                      rootObjectID:(NSString *)rootObjectID
                                  fallbackRootSize:(CGSize)fallbackRootSize;

+ (void)pruneUnavailableNodesFromRoot:(PVFVMSnapshotNode *)root;

/// Keeps the top-most full-surface page branch and overlays painted after it.
+ (void)pruneOccludedFullSurfaceRoutesFromRoot:(PVFVMSnapshotNode *)root;

@end

NS_ASSUME_NONNULL_END

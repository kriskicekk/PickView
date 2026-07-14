//
//  PVFlutterHierarchyCoordinator.h
//  PickViewServer
//

#import <Foundation/Foundation.h>
//#import <UIKit/UIKit.h>

@class PVDisplayItem;
@class PVDisplayItemDetail;
@class PVStaticAsyncUpdateTasksPackage;

NS_ASSUME_NONNULL_BEGIN

typedef void (^PVFlutterHierarchyPreparationCompletion)(NSError *_Nullable error);
typedef void (^PVFlutterHierarchyDetailsCompletion)(NSArray<PVDisplayItemDetail *> *details);

/// Bridges Flutter Inspector objects into PickView's native hierarchy contract.
/// One coordinator owns the virtual oid namespace for one hierarchy provider.
@interface PVFlutterHierarchyCoordinator : NSObject

- (void)prepareWindow:(UIWindow *)window
           completion:(PVFlutterHierarchyPreparationCompletion)completion;

- (NSArray<PVDisplayItem *> *)virtualItemsForHostView:(UIView *)hostView;
- (NSArray<PVDisplayItem *> *)virtualItemsForHostLayer:(CALayer *)hostLayer;
- (BOOL)ownsObjectOID:(unsigned long)oid;
- (BOOL)ownsDisplayItemID:(NSString *)displayItemID;

- (void)detailsForTaskPackages:(NSArray<PVStaticAsyncUpdateTasksPackage *> *)packages
               lowImageQuality:(BOOL)lowImageQuality
                    completion:(PVFlutterHierarchyDetailsCompletion)completion;

- (void)detailsForDisplayItemIDs:(NSArray<NSString *> *)displayItemIDs
                  needsSoloImage:(BOOL)needsSoloImage
                 needsGroupImage:(BOOL)needsGroupImage
                 lowImageQuality:(BOOL)lowImageQuality
                      completion:(PVFlutterHierarchyDetailsCompletion)completion;

@end

NS_ASSUME_NONNULL_END

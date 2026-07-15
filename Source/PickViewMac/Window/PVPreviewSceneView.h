//
//  PVPreviewSceneView.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import <SceneKit/SceneKit.h>

@class PVDisplayItem;
@class PVDisplayItemDetail;
@class PVHierarchyInfo;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PVPreviewDimension) {
    PVPreviewDimension2D,
    PVPreviewDimension3D
};

@interface PVPreviewSceneView : SCNView

@property (nonatomic, assign, readonly) PVPreviewDimension dimension;
@property (nonatomic, assign) BOOL freeRotationEnabled;
@property (nonatomic, assign) CGFloat previewScale;
@property (nonatomic, assign) CGFloat zInterspace;
@property (nonatomic, copy, nullable) void (^selectionHandler)(PVDisplayItem *displayItem);

- (void)setDimension:(PVPreviewDimension)dimension animated:(BOOL)animated;
- (void)renderHierarchy:(nullable PVHierarchyInfo *)hierarchy
            detailsByID:(NSDictionary<NSString *, PVDisplayItemDetail *> *)detailsByID
           selectedItem:(nullable PVDisplayItem *)selectedItem;
- (void)updateDetailsByID:(NSDictionary<NSString *, PVDisplayItemDetail *> *)detailsByID
             selectedItem:(nullable PVDisplayItem *)selectedItem;
- (void)selectDisplayItem:(nullable PVDisplayItem *)displayItem;
- (void)resetPreview;

@end

NS_ASSUME_NONNULL_END

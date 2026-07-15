//
//  PVDetailPreviewView.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import <SceneKit/SceneKit.h>

extern const CGFloat PVPreviewMinScale;
extern const CGFloat PVPreviewMaxScale;

extern const CGFloat PVPreviewMaxZInterspace;
extern const CGFloat PVPreviewMinZInterspace;

typedef NS_ENUM (NSUInteger, PVPreviewDimension) {
    PVPreviewDimension2D,
    PVPreviewDimension3D
};

@class PVDisplayItem, PVDetailPreferenceManager, PVDetailHierarchyDataSource;

@interface PVDetailPreviewView : SCNView

- (instancetype)initWithDataSource:(PVDetailHierarchyDataSource *)dataSource;

/// rotation.x 是左右旋转的角度，rotation.y 是上下旋转的角度
@property(nonatomic, assign, readonly) CGPoint rotation;
- (void)setRotation:(CGPoint)rotation animated:(BOOL)animated;
/// duration 为 0 时表示使用系统默认时长（即 0.25s）
- (void)setRotation:(CGPoint)rotation animated:(BOOL)animated timingFunction:(CAMediaTimingFunction *)function duration:(CGFloat)duration;

/// 上下移动的距离
@property(nonatomic, assign) CGPoint translation;

/// 图像大小，最小值是 PVPreviewMinScale，最大值是 PVPreviewMaxScale
@property(nonatomic, assign) CGFloat scale;

/// 图层之间的纵向间距，最小值是 PVPreviewMinZInterspace，最大值是 PVPreviewMaxZInterspace
@property(nonatomic, assign) CGFloat zInterspace;

/**
 设置 2D 和 3D 模式
 置为 2D 会使得 rotation 变成 0，置为 3D 不会改变 rotation
 */
@property(nonatomic, assign, readonly) PVPreviewDimension dimension;
- (void)setDimension:(PVPreviewDimension)dimension animated:(BOOL)animated;

/// iOS App 的屏幕大小
@property(nonatomic, assign) CGSize appScreenSize;

@property(nonatomic, strong) PVDetailPreferenceManager *preferenceManager;

/// 通过 items 来构建对应的 node，items 里不应该包含 noPreview 为 YES 的 item
/// 如果 discardCache 为 YES，则会丢弃本次渲染未用到的 node 对象。如果 discardCache 为 NO，则本次渲染未用到的 node 对象会被隐藏起来但不会被丢弃，从而供以后使用
- (void)renderWithDisplayItems:(NSArray<PVDisplayItem *> *)items discardCache:(BOOL)discardCache;

- (void)updateZPosition;

- (PVDisplayItem *)displayItemAtPoint:(CGPoint)point;

- (void)didSelectItem:(PVDisplayItem *)item;

@property(nonatomic, assign) BOOL isDarkMode;

@property(nonatomic, assign) BOOL showHiddenItems;

@end

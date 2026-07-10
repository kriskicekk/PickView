//
//  LKPreviewView.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import <SceneKit/SceneKit.h>

extern const CGFloat PickViewPreviewMinScale;
extern const CGFloat PickViewPreviewMaxScale;

extern const CGFloat PickViewPreviewMaxZInterspace;
extern const CGFloat PickViewPreviewMinZInterspace;

typedef NS_ENUM (NSUInteger, PickViewPreviewDimension) {
    PickViewPreviewDimension2D,
    PickViewPreviewDimension3D
};

@class PickViewDisplayItem, LKPreferenceManager, LKHierarchyDataSource;

@interface LKPreviewView : SCNView

- (instancetype)initWithDataSource:(LKHierarchyDataSource *)dataSource;

/// rotation.x 是左右旋转的角度，rotation.y 是上下旋转的角度
@property(nonatomic, assign, readonly) CGPoint rotation;
- (void)setRotation:(CGPoint)rotation animated:(BOOL)animated;
/// duration 为 0 时表示使用系统默认时长（即 0.25s）
- (void)setRotation:(CGPoint)rotation animated:(BOOL)animated timingFunction:(CAMediaTimingFunction *)function duration:(CGFloat)duration;

/// 上下移动的距离
@property(nonatomic, assign) CGPoint translation;

/// 图像大小，最小值是 PickViewPreviewMinScale，最大值是 PickViewPreviewMaxScale
@property(nonatomic, assign) CGFloat scale;

/// 图层之间的纵向间距，最小值是 PickViewPreviewMinZInterspace，最大值是 PickViewPreviewMaxZInterspace
@property(nonatomic, assign) CGFloat zInterspace;

/**
 设置 2D 和 3D 模式
 置为 2D 会使得 rotation 变成 0，置为 3D 不会改变 rotation
 */
@property(nonatomic, assign, readonly) PickViewPreviewDimension dimension;
- (void)setDimension:(PickViewPreviewDimension)dimension animated:(BOOL)animated;

/// iOS App 的屏幕大小
@property(nonatomic, assign) CGSize appScreenSize;

@property(nonatomic, strong) LKPreferenceManager *preferenceManager;

/// 通过 items 来构建对应的 node，items 里不应该包含 noPreview 为 YES 的 item
/// 如果 discardCache 为 YES，则会丢弃本次渲染未用到的 node 对象。如果 discardCache 为 NO，则本次渲染未用到的 node 对象会被隐藏起来但不会被丢弃，从而供以后使用
- (void)renderWithDisplayItems:(NSArray<PickViewDisplayItem *> *)items discardCache:(BOOL)discardCache;

- (void)updateZPosition;

- (PickViewDisplayItem *)displayItemAtPoint:(CGPoint)point;

- (void)didSelectItem:(PickViewDisplayItem *)item;

@property(nonatomic, assign) BOOL isDarkMode;

@property(nonatomic, assign) BOOL showHiddenItems;

@end

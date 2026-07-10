//
//  PVDetailBaseViewController.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import <Cocoa/Cocoa.h>

@class PVDetailRedTipsView;

@interface PVDetailBaseViewController : NSViewController

/**
 如果使用该初始化方法，则 controller.view 会被赋值为传入的 view。
 如果使用普通的 init 方法，或该方法传入 nil，则 controller 会自动创建一个 view，即 [self containerView]
 */
- (instancetype)initWithContainerView:(NSView *)view NS_DESIGNATED_INITIALIZER;

@property(nonatomic, assign, readonly) BOOL isViewAppeared;

@property(nonatomic, strong, readonly) PVDetailRedTipsView *connectionTipsView;

@end

@interface PVDetailBaseViewController (NSSubclassingHooks)

- (NSView *)makeContainerView;

/// 是否在连接断开时显示 tips，默认为 NO
- (BOOL)shouldShowConnectionTips;

@end

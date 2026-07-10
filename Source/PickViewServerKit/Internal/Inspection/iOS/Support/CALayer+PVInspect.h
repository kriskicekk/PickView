//
//  CALayer+PVInspect.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVInspectionDefines.h"



#import <QuartzCore/QuartzCore.h>

@interface CALayer (PickView)

#if TARGET_OS_IPHONE
/// 如果 myView.layer == myLayer，则 myLayer.pv_inspect_hostView 会返回 myView。
@property(nonatomic, readonly, weak) UIView *pv_inspect_hostView;
#endif

- (void)pv_inspect_removeImplicitAnimations;

@end

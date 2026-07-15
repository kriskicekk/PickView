//
//  PVObject+PVClient.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVObject.h"

@interface PVObject (PVClient)

/// 这里返回的类名已经被 demangle 过，但是【有 module 前缀】
- (NSString *)lk_completedDemangledClassName;

/// 这里返回的类名已经被 demangle 过，并且【没有 module 前缀】
- (NSString *)lk_simpleDemangledClassName;

@end

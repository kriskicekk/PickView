//
//  ShortCocoa+PVClient.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "ShortCocoa.h"

@interface ShortCocoa (PickView)

- (ShortCocoa * (^)(CGFloat))lk_maxWidth;
- (ShortCocoa * (^)(CGFloat))lk_minWidth;

@end

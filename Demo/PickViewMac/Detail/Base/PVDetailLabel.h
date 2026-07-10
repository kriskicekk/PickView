//
//  PVDetailLabel.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import <Cocoa/Cocoa.h>

@class PVDetailTwoColors;

@interface PVDetailLabel : NSTextField

/// 默认为 nil
@property(nonatomic, strong) PVDetailTwoColors *textColors;
/// 默认为 nil
@property(nonatomic, strong) PVDetailTwoColors *backgroundColors;


@end

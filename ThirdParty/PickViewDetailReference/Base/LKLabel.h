//
//  LKLabel.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import <Cocoa/Cocoa.h>

@class LKTwoColors;

@interface LKLabel : NSTextField

/// 默认为 nil
@property(nonatomic, strong) LKTwoColors *textColors;
/// 默认为 nil
@property(nonatomic, strong) LKTwoColors *backgroundColors;


@end

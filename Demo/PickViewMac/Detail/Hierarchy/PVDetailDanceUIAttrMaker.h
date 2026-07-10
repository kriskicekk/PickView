//
//  PVDetailDanceUIAttrMaker.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import <Foundation/Foundation.h>

@interface PVDetailDanceUIAttrMaker : NSObject

/// 给 item 的属性列表里填充上“跳转 DanceUI 文件”相关的信息
+ (void)makeDanceUIJumpAttribute:(PVDisplayItem *)item danceSource:(NSString *)source;

@end

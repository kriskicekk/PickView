//
//  PVCustomDisplayItemInfo.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import <Foundation/Foundation.h>

@interface PVCustomDisplayItemInfo : NSObject <NSSecureCoding, NSCopying>

/// 该属性可能有值（CGRect）也可能是 nil（nil 时则表示无图像）
@property(nonatomic, strong) NSValue *frameInWindow;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *subtitle;
@property(nonatomic, copy) NSString *danceuiSource;

@end


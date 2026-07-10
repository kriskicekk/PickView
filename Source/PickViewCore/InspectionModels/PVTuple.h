//
//  PVTuple.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import <Foundation/Foundation.h>

@interface PVTwoTuple : NSObject <NSSecureCoding>

@property(nonatomic, strong) NSObject *first;
@property(nonatomic, strong) NSObject *second;

@end

@interface PVStringTwoTuple : NSObject <NSSecureCoding, NSCopying>

+ (instancetype)tupleWithFirst:(NSString *)firstString second:(NSString *)secondString;

@property(nonatomic, copy) NSString *first;
@property(nonatomic, copy) NSString *second;

@end


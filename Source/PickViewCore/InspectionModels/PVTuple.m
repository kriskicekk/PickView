//
//  PVTuple.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVTuple.h"

@implementation PVTwoTuple

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.first forKey:@"first"];
    [aCoder encodeObject:self.second forKey:@"second"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.first = [aDecoder decodeObjectForKey:@"first"];
        self.second = [aDecoder decodeObjectForKey:@"second"];
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (NSUInteger)hash {
    return self.first.hash ^ self.second.hash;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    if (![object isKindOfClass:[PVTwoTuple class]]) {
        return NO;
    }
    PVTwoTuple *comparedObj = object;
    if ([self.first isEqual:comparedObj.first] && [self.second isEqual:comparedObj.second]) {
        return YES;
    }
    return NO;
}

@end

@implementation PVStringTwoTuple

+ (instancetype)tupleWithFirst:(NSString *)firstString second:(NSString *)secondString {
    PVStringTwoTuple *tuple = [PVStringTwoTuple new];
    tuple.first = firstString;
    tuple.second = secondString;
    return tuple;
}

#pragma mark - <NSCopying>

- (id)copyWithZone:(NSZone *)zone {
    PVStringTwoTuple *newTuple = [[PVStringTwoTuple allocWithZone:zone] init];
    newTuple.first = self.first;
    newTuple.second = self.second;
    return newTuple;
}

#pragma mark - <NSCoding>

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.first forKey:@"first"];
    [aCoder encodeObject:self.second forKey:@"second"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.first = [aDecoder decodeObjectForKey:@"first"];
        self.second = [aDecoder decodeObjectForKey:@"second"];
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

@end


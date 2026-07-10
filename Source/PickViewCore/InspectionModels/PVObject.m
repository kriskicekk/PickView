//
//  PVObject.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVObject.h"
#import "PVIvarTrace.h"
#import "NSArray+PVInspect.h"
#import "NSString+PVInspect.h"

@implementation PVObject

#pragma mark - <NSCopying>

- (id)copyWithZone:(NSZone *)zone {
    PVObject *newObject = [[PVObject allocWithZone:zone] init];
    newObject.oid = self.oid;
    newObject.memoryAddress = self.memoryAddress;
    newObject.classChainList = self.classChainList;
    newObject.specialTrace = self.specialTrace;
    newObject.ivarTraces = [self.ivarTraces pv_inspect_map:^id(NSUInteger idx, PVIvarTrace *value) {
        return value.copy;
    }];
    return newObject;
}

#pragma mark - <NSSecureCoding>

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(self.oid) forKey:@"oid"];
    [aCoder encodeObject:self.memoryAddress forKey:@"memoryAddress"];
    [aCoder encodeObject:self.classChainList forKey:@"classChainList"];
    [aCoder encodeObject:self.specialTrace forKey:@"specialTrace"];
    [aCoder encodeObject:self.ivarTraces forKey:@"ivarTraces"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.oid = [(NSNumber *)[aDecoder decodeObjectForKey:@"oid"] unsignedLongValue];
        self.memoryAddress = [aDecoder decodeObjectForKey:@"memoryAddress"];
        self.classChainList = [aDecoder decodeObjectForKey:@"classChainList"];
        self.specialTrace = [aDecoder decodeObjectForKey:@"specialTrace"];
        self.ivarTraces = [aDecoder decodeObjectForKey:@"ivarTraces"];
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (NSString *)rawClassName {
    return self.classChainList.firstObject;
}

- (NSString *)objectID {
    return [NSString stringWithFormat:@"%lu", self.oid];
}

- (NSString *)className {
    return self.rawClassName ?: @"";
}

- (NSArray<NSString *> *)classChain {
    return self.classChainList ?: @[];
}

@end

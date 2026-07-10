//
//  PVObjectIdentity.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVObjectIdentity.h"

@implementation PVObjectIdentity

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _objectID = @"";
        _memoryAddress = @"";
        _className = @"";
        _classChain = @[];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.objectID forKey:@"objectID"];
    [coder encodeObject:self.memoryAddress forKey:@"memoryAddress"];
    [coder encodeObject:self.className forKey:@"className"];
    [coder encodeObject:self.classChain forKey:@"classChain"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _objectID = [[coder decodeObjectOfClass:NSString.class forKey:@"objectID"] copy] ?: @"";
        _memoryAddress = [[coder decodeObjectOfClass:NSString.class forKey:@"memoryAddress"] copy] ?: @"";
        _className = [[coder decodeObjectOfClass:NSString.class forKey:@"className"] copy] ?: @"";
        NSSet<Class> *classes = [NSSet setWithObjects:NSArray.class, NSString.class, nil];
        _classChain = [[coder decodeObjectOfClasses:classes forKey:@"classChain"] copy] ?: @[];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    PVObjectIdentity *identity = [[[self class] allocWithZone:zone] init];
    identity.objectID = self.objectID;
    identity.memoryAddress = self.memoryAddress;
    identity.className = self.className;
    identity.classChain = self.classChain;
    return identity;
}

@end

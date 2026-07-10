//
//  PVAttributeModification.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVAttributeModification.h"

@implementation PVAttributeModification

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(self.targetOid) forKey:@"targetOid"];
    [aCoder encodeObject:NSStringFromSelector(self.setterSelector) forKey:@"setterSelector"];
    [aCoder encodeInteger:self.attrType forKey:@"attrType"];
    [aCoder encodeObject:self.value forKey:@"value"];
    [aCoder encodeObject:self.clientReadableVersion forKey:@"clientReadableVersion"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.targetOid = [[aDecoder decodeObjectForKey:@"targetOid"] unsignedLongValue];
        self.setterSelector = NSSelectorFromString([aDecoder decodeObjectForKey:@"setterSelector"]);
        self.attrType = [aDecoder decodeIntegerForKey:@"attrType"];
        self.value = [aDecoder decodeObjectForKey:@"value"];
        self.clientReadableVersion = [aDecoder decodeObjectForKey:@"clientReadableVersion"];
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

@end


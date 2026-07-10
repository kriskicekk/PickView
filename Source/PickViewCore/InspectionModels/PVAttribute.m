//
//  PVAttribute.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVAttribute.h"
#import "PVDisplayItem.h"

@implementation PVAttribute

#pragma mark - <NSCopying>

- (id)copyWithZone:(NSZone *)zone {
    PVAttribute *newAttr = [[PVAttribute allocWithZone:zone] init];
    newAttr.identifier = self.identifier;
    newAttr.displayTitle = self.displayTitle;
    newAttr.value = self.value;
    newAttr.attrType = self.attrType;
    newAttr.extraValue = self.extraValue;
    newAttr.customSetterID = self.customSetterID;
    return newAttr;
}

#pragma mark - <NSCoding>

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.displayTitle forKey:@"displayTitle"];
    [aCoder encodeObject:self.identifier forKey:@"identifier"];
    [aCoder encodeInteger:self.attrType forKey:@"attrType"];
    [aCoder encodeObject:self.value forKey:@"value"];
    [aCoder encodeObject:self.extraValue forKey:@"extraValue"];
    [aCoder encodeObject:self.customSetterID forKey:@"customSetterID"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.displayTitle = [aDecoder decodeObjectForKey:@"displayTitle"];
        self.identifier = [aDecoder decodeObjectForKey:@"identifier"];
        self.attrType = [aDecoder decodeIntegerForKey:@"attrType"];
        self.value = [aDecoder decodeObjectForKey:@"value"];
        self.extraValue = [aDecoder decodeObjectForKey:@"extraValue"];
        self.customSetterID = [aDecoder decodeObjectForKey:@"customSetterID"];
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isUserCustom {
    return [self.identifier isEqualToString:PVAttr_UserCustom];
}

@end


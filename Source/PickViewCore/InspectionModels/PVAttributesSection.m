//
//  PVAttributesSection.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVAttributesSection.h"
#import "PVAttribute.h"

#import "NSArray+PVInspect.h"

@implementation PVAttributesSection

#pragma mark - <NSCopying>

- (id)copyWithZone:(NSZone *)zone {
    PVAttributesSection *newSection = [[PVAttributesSection allocWithZone:zone] init];
    newSection.identifier = self.identifier;
    newSection.attributes = [self.attributes pv_inspect_map:^id(NSUInteger idx, PVAttribute *value) {
        return value.copy;
    }];
    return newSection;
}

#pragma mark - <NSCoding>

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.identifier forKey:@"identifier"];
    [aCoder encodeObject:self.attributes forKey:@"attributes"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.identifier = [aDecoder decodeObjectForKey:@"identifier"];
        self.attributes = [aDecoder decodeObjectForKey:@"attributes"];
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isUserCustom {
    return [self.identifier isEqualToString:PVAttrSec_UserCustom];
}

@end


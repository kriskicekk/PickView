//
//  PVAttributesGroup.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVAttributesGroup.h"
#import "PVAttribute.h"
#import "PVAttributesSection.h"
#import "PVDashboardBlueprint.h"
#import "NSArray+PVInspect.h"

@implementation PVAttributesGroup

#pragma mark - <NSCopying>

- (id)copyWithZone:(NSZone *)zone {
    PVAttributesGroup *newGroup = [[PVAttributesGroup allocWithZone:zone] init];
    newGroup.userCustomTitle = self.userCustomTitle;
    newGroup.identifier = self.identifier;
    newGroup.attrSections = [self.attrSections pv_inspect_map:^id(NSUInteger idx, PVAttributesSection *value) {
        return value.copy;
    }];
    return newGroup;
}

#pragma mark - <NSCoding>

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.userCustomTitle forKey:@"userCustomTitle"];
    [aCoder encodeObject:self.identifier forKey:@"identifier"];
    [aCoder encodeObject:self.attrSections forKey:@"attrSections"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.userCustomTitle = [aDecoder decodeObjectForKey:@"userCustomTitle"];
        self.identifier = [aDecoder decodeObjectForKey:@"identifier"];
        self.attrSections = [aDecoder decodeObjectForKey:@"attrSections"];
    }
    return self;
}

- (NSUInteger)hash {
    return self.uniqueKey.hash;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    if (![object isKindOfClass:[PVAttributesGroup class]]) {
        return NO;
    }
    PVAttributesGroup *targetObject = object;

    if (![self.identifier isEqualToString:targetObject.identifier]) {
        return false;
    }
    if ([self.identifier isEqualToString:PVAttrGroup_UserCustom]) {
        BOOL ret = [self.userCustomTitle isEqualToString:targetObject.userCustomTitle];
        return ret;
    } else {
        return true;
    }
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (NSString *)uniqueKey {
    if ([self.identifier isEqualToString:PVAttrGroup_UserCustom]) {
        return self.userCustomTitle;
    } else {
        return self.identifier;
    }
}

- (BOOL)isUserCustom {
    return [self.identifier isEqualToString:PVAttrGroup_UserCustom];
}

@end

//
//  PVHierarchyInfo.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVHierarchyInfo.h"

#import "NSArray+PVInspect.h"
#import "PVAppInfo.h"
#import "PVDisplayItem.h"
#import "PVWindowInfo.h"

@implementation PVHierarchyInfo

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _displayItems = @[];
        _colorAlias = @{};
        _collapsedClassList = @[];
    }
    return self;
}

- (NSArray<PVDisplayItem *> *)rootItems {
    return self.displayItems ?: @[];
}

- (void)setRootItems:(NSArray<PVDisplayItem *> *)rootItems {
    self.displayItems = rootItems ?: @[];
}

- (void)setDisplayItems:(NSArray<PVDisplayItem *> *)displayItems {
    _displayItems = [displayItems copy] ?: @[];
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.windowInfo forKey:@"windowInfo"];
    [coder encodeObject:self.displayItems forKey:@"rootItems"];
    [coder encodeObject:self.displayItems forKey:@"1"];
    [coder encodeObject:self.colorAlias forKey:@"3"];
    [coder encodeObject:self.collapsedClassList forKey:@"4"];
    [coder encodeObject:self.appInfo forKey:@"2"];
    [coder encodeInt:self.serverVersion forKey:@"serverVersion"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _windowInfo = [coder decodeObjectForKey:@"windowInfo"];
        _displayItems = [coder decodeObjectForKey:@"1"] ?: [coder decodeObjectForKey:@"rootItems"] ?: @[];
        _colorAlias = [coder decodeObjectForKey:@"3"] ?: @{};
        _collapsedClassList = [coder decodeObjectForKey:@"4"] ?: @[];
        _appInfo = [coder decodeObjectForKey:@"2"];
        _serverVersion = [coder decodeIntForKey:@"serverVersion"];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    PVHierarchyInfo *info = [[[self class] allocWithZone:zone] init];
    info.windowInfo = self.windowInfo.copy;
    info.serverVersion = self.serverVersion;
    info.appInfo = self.appInfo.copy;
    info.collapsedClassList = self.collapsedClassList.copy;
    info.colorAlias = self.colorAlias.copy;
    info.displayItems = [self.displayItems pv_inspect_map:^id(NSUInteger idx, PVDisplayItem *item) {
        return item.copy;
    }];
    return info;
}

@end

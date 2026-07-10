//
//  PVCustomAttrSetterManager.m
//  PickViewServer
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVCustomAttrSetterManager.h"

@interface PVCustomAttrSetterManager ()

@property(nonatomic, strong) NSMutableDictionary<NSString *, id> *settersMap;

@end

@implementation PVCustomAttrSetterManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static PVCustomAttrSetterManager *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _settersMap = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)removeAll {
    [self.settersMap removeAllObjects];
}

- (void)saveStringSetter:(PVStringSetter)setter uniqueID:(NSString *)uniqueID {
    [self saveSetter:setter uniqueID:uniqueID];
}

- (PVStringSetter)getStringSetterWithID:(NSString *)uniqueID {
    return [self setterWithID:uniqueID];
}

- (void)saveNumberSetter:(PVNumberSetter)setter uniqueID:(NSString *)uniqueID {
    [self saveSetter:setter uniqueID:uniqueID];
}

- (PVNumberSetter)getNumberSetterWithID:(NSString *)uniqueID {
    return [self setterWithID:uniqueID];
}

- (void)saveBoolSetter:(PVBoolSetter)setter uniqueID:(NSString *)uniqueID {
    [self saveSetter:setter uniqueID:uniqueID];
}

- (PVBoolSetter)getBoolSetterWithID:(NSString *)uniqueID {
    return [self setterWithID:uniqueID];
}

- (void)saveColorSetter:(PVColorSetter)setter uniqueID:(NSString *)uniqueID {
    [self saveSetter:setter uniqueID:uniqueID];
}

- (PVColorSetter)getColorSetterWithID:(NSString *)uniqueID {
    return [self setterWithID:uniqueID];
}

- (void)saveEnumSetter:(PVEnumSetter)setter uniqueID:(NSString *)uniqueID {
    [self saveSetter:setter uniqueID:uniqueID];
}

- (PVEnumSetter)getEnumSetterWithID:(NSString *)uniqueID {
    return [self setterWithID:uniqueID];
}

- (void)saveRectSetter:(PVRectSetter)setter uniqueID:(NSString *)uniqueID {
    [self saveSetter:setter uniqueID:uniqueID];
}

- (PVRectSetter)getRectSetterWithID:(NSString *)uniqueID {
    return [self setterWithID:uniqueID];
}

- (void)saveSizeSetter:(PVSizeSetter)setter uniqueID:(NSString *)uniqueID {
    [self saveSetter:setter uniqueID:uniqueID];
}

- (PVSizeSetter)getSizeSetterWithID:(NSString *)uniqueID {
    return [self setterWithID:uniqueID];
}

- (void)savePointSetter:(PVPointSetter)setter uniqueID:(NSString *)uniqueID {
    [self saveSetter:setter uniqueID:uniqueID];
}

- (PVPointSetter)getPointSetterWithID:(NSString *)uniqueID {
    return [self setterWithID:uniqueID];
}

- (void)saveInsetsSetter:(PVInsetsSetter)setter uniqueID:(NSString *)uniqueID {
    [self saveSetter:setter uniqueID:uniqueID];
}

- (PVInsetsSetter)getInsetsSetterWithID:(NSString *)uniqueID {
    return [self setterWithID:uniqueID];
}

- (void)saveSetter:(id)setter uniqueID:(NSString *)uniqueID {
    if (!setter || !uniqueID.length) {
        return;
    }
    self.settersMap[uniqueID] = [setter copy];
}

- (id)setterWithID:(NSString *)uniqueID {
    if (!uniqueID.length) {
        return nil;
    }
    return self.settersMap[uniqueID];
}

@end

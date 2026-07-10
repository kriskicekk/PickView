//
//  PVStaticAsyncUpdateTask.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVStaticAsyncUpdateTask.h"

@implementation PVStaticAsyncUpdateTask

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(self.oid) forKey:@"oid"];
    [aCoder encodeInteger:self.taskType forKey:@"taskType"];
    [aCoder encodeObject:self.clientReadableVersion forKey:@"clientReadableVersion"];
    [aCoder encodeInteger:self.attrRequest forKey:@"attrRequest"];
    [aCoder encodeBool:self.needBasisVisualInfo forKey:@"needBasisVisualInfo"];
    [aCoder encodeBool:self.needSubitems forKey:@"needSubitems"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.oid = [[aDecoder decodeObjectForKey:@"oid"] unsignedLongValue];
        self.taskType = [aDecoder decodeIntegerForKey:@"taskType"];
        self.clientReadableVersion = [aDecoder decodeObjectForKey:@"clientReadableVersion"];
        if ([aDecoder containsValueForKey:@"attrRequest"]) {
            NSInteger value = [aDecoder decodeIntegerForKey:@"attrRequest"];
            if (value >= PVDetailUpdateTaskAttrRequest_Automatic && value <= PVDetailUpdateTaskAttrRequest_NotNeed) {
                self.attrRequest = value;
            } else {
                self.attrRequest = PVDetailUpdateTaskAttrRequest_Automatic;
            }
        } else {
            self.attrRequest = PVDetailUpdateTaskAttrRequest_Automatic;
        }

        if ([aDecoder containsValueForKey:@"needBasisVisualInfo"]) {
            self.needBasisVisualInfo = [aDecoder decodeBoolForKey:@"needBasisVisualInfo"];
        } else {
            self.needBasisVisualInfo = NO;
        }
        
        if ([aDecoder containsValueForKey:@"needSubitems"]) {
            self.needSubitems = [aDecoder decodeBoolForKey:@"needSubitems"];
        } else {
            self.needSubitems = NO;
        }
        
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (NSUInteger)hash {
    return self.oid ^ self.taskType ^ self.attrRequest ^ self.needBasisVisualInfo ^ self.needSubitems;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    if (![object isKindOfClass:[PVStaticAsyncUpdateTask class]]) {
        return NO;
    }
    PVStaticAsyncUpdateTask *targetTask = object;
    if (self.oid == targetTask.oid
        && self.taskType == targetTask.taskType
        && self.attrRequest == targetTask.attrRequest
        && self.needBasisVisualInfo == targetTask.needBasisVisualInfo
        && self.needSubitems == targetTask.needSubitems) {
        return YES;
    }
    return NO;
}

@end

@implementation PVStaticAsyncUpdateTasksPackage

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.tasks forKey:@"tasks"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.tasks = [aDecoder decodeObjectForKey:@"tasks"];
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

@end


//
//  PVDisplayItemDetailRequest.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDisplayItemDetailRequest.h"

@implementation PVDisplayItemDetailRequest

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _displayItemIDs = @[];
        _needsGroupImage = YES;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.displayItemIDs forKey:@"displayItemIDs"];
    [coder encodeBool:self.needsSoloImage forKey:@"needsSoloImage"];
    [coder encodeBool:self.needsGroupImage forKey:@"needsGroupImage"];
    [coder encodeBool:self.lowImageQuality forKey:@"lowImageQuality"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        NSSet<Class> *classes = [NSSet setWithObjects:NSArray.class, NSString.class, nil];
        _displayItemIDs = [[coder decodeObjectOfClasses:classes forKey:@"displayItemIDs"] copy] ?: @[];
        _needsSoloImage = [coder decodeBoolForKey:@"needsSoloImage"];
        _needsGroupImage = [coder decodeBoolForKey:@"needsGroupImage"];
        _lowImageQuality = [coder decodeBoolForKey:@"lowImageQuality"];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    PVDisplayItemDetailRequest *request = [[[self class] allocWithZone:zone] init];
    request.displayItemIDs = self.displayItemIDs;
    request.needsSoloImage = self.needsSoloImage;
    request.needsGroupImage = self.needsGroupImage;
    request.lowImageQuality = self.lowImageQuality;
    return request;
}

@end

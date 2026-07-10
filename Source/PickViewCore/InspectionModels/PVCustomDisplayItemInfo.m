//
//  PVCustomDisplayItemInfo.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVCustomDisplayItemInfo.h"

@implementation PVCustomDisplayItemInfo

- (id)copyWithZone:(NSZone *)zone {
    PVCustomDisplayItemInfo *newInstance = [[PVCustomDisplayItemInfo allocWithZone:zone] init];
    
    if (self.frameInWindow) {
        CGRect rect = CGRectZero;
        [self.frameInWindow getValue:&rect size:sizeof(rect)];
        newInstance.frameInWindow = [NSValue value:&rect withObjCType:@encode(CGRect)];
    }
    newInstance.title = self.title;
    newInstance.subtitle = self.subtitle;
    newInstance.danceuiSource = self.danceuiSource;
    
    return newInstance;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.frameInWindow forKey:@"frameInWindow"];
    if (self.frameInWindow) {
        CGRect rect = CGRectZero;
        [self.frameInWindow getValue:&rect size:sizeof(rect)];
        [aCoder encodeDouble:CGRectGetMinX(rect) forKey:@"frameInWindow.x"];
        [aCoder encodeDouble:CGRectGetMinY(rect) forKey:@"frameInWindow.y"];
        [aCoder encodeDouble:CGRectGetWidth(rect) forKey:@"frameInWindow.width"];
        [aCoder encodeDouble:CGRectGetHeight(rect) forKey:@"frameInWindow.height"];
    }
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.subtitle forKey:@"subtitle"];
    [aCoder encodeObject:self.danceuiSource forKey:@"danceuiSource"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.frameInWindow = [aDecoder decodeObjectForKey:@"frameInWindow"];
        if ([aDecoder containsValueForKey:@"frameInWindow.width"]) {
            CGRect rect = CGRectMake([aDecoder decodeDoubleForKey:@"frameInWindow.x"],
                                     [aDecoder decodeDoubleForKey:@"frameInWindow.y"],
                                     [aDecoder decodeDoubleForKey:@"frameInWindow.width"],
                                     [aDecoder decodeDoubleForKey:@"frameInWindow.height"]);
            self.frameInWindow = [NSValue value:&rect withObjCType:@encode(CGRect)];
        }
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.subtitle = [aDecoder decodeObjectForKey:@"subtitle"];
        self.danceuiSource = [aDecoder decodeObjectForKey:@"danceuiSource"];
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

@end

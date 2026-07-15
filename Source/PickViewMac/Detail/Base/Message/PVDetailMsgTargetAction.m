//
//  PVDetailMsgTargetAction.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailMsgTargetAction.h"



@implementation PVDetailMsgTargetAction

- (NSUInteger)hash {
    return [self.target hash] ^ NSStringFromSelector(self.action).hash ^ [self.relatedObject hash];
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    if (![object isKindOfClass:[PVDetailMsgTargetAction class]]) {
        return NO;
    }
    PVDetailMsgTargetAction *comparedObj = object;
    if (self.target == comparedObj.target && [NSStringFromSelector(self.action) isEqual:NSStringFromSelector(comparedObj.action)] && self.relatedObject == comparedObj.relatedObject) {
        return YES;
    }
    return NO;
}

@end


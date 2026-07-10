//
//  PickViewMsgTargetAction.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#ifdef SHOULD_COMPILE_PICKVIEW_SERVER 

#import "PickViewMsgTargetAction.h"



@implementation PickViewMsgTargetAction

- (NSUInteger)hash {
    return [self.target hash] ^ NSStringFromSelector(self.action).hash ^ [self.relatedObject hash];
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    if (![object isKindOfClass:[PickViewMsgTargetAction class]]) {
        return NO;
    }
    PickViewMsgTargetAction *comparedObj = object;
    if (self.target == comparedObj.target && [NSStringFromSelector(self.action) isEqual:NSStringFromSelector(comparedObj.action)] && self.relatedObject == comparedObj.relatedObject) {
        return YES;
    }
    return NO;
}

@end

#endif /* SHOULD_COMPILE_PICKVIEW_SERVER */

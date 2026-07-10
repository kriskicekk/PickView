//
//  PVWeakContainer.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVWeakContainer.h"

@implementation PVWeakContainer

+ (instancetype)containerWithObject:(id)object {
    PVWeakContainer *container = [PVWeakContainer new];
    container.object = object;
    return container;
}

- (NSUInteger)hash {
    return [self.object hash];
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    if (![object isKindOfClass:[PVWeakContainer class]]) {
        return NO;
    }
    PVWeakContainer *comparedObj = object;
    if ([self.object isEqual:comparedObj.object]) {
        return YES;
    }
    return NO;
}

@end


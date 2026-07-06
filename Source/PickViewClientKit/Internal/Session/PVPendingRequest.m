//
//  PVPendingRequest.m
//  PickViewClient
//
//  Created by kris cheng on 2026/7/6.
//

#import "PVPendingRequest.h"

@implementation PVPendingRequest

- (instancetype)initWithType:(uint32_t)type
                         tag:(uint32_t)tag
             timeoutInterval:(NSTimeInterval)timeoutInterval
                  completion:(PVPendingRequestCompletion)completion {
    self = [super init];
    if (self) {
        _type = type;
        _tag = tag;
        _timeoutInterval = timeoutInterval;
        _completion = [completion copy];
    }
    return self;
}

@end


//
//  PVFrame.m
//  PickView
//
//  Created by kris cheng on 2026/7/6.
//

#import "PVFrame.h"

static const uint32_t PVFrameDefaultVersion = 1;

@implementation PVFrame

- (instancetype)initWithType:(uint32_t)type
                         tag:(uint32_t)tag
                     payload:(NSData *)payload {
    return [self initWithVersion:PVFrameDefaultVersion type:type tag:tag payload:payload];
}

- (instancetype)initWithVersion:(uint32_t)version
                           type:(uint32_t)type
                            tag:(uint32_t)tag
                        payload:(NSData *)payload {
    self = [super init];
    if (self) {
        _version = version;
        _type = type;
        _tag = tag;
        _payload = [payload copy];
    }
    return self;
}

@end

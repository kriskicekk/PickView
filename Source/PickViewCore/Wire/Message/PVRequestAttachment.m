//
//  PVRequestAttachment.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVRequestAttachment.h"

#import "PVArchiveCodec.h"

@implementation PVRequestAttachment

+ (BOOL)supportsSecureCoding {
    return YES;
}

+ (instancetype)attachmentWithData:(id<NSSecureCoding>)data {
    PVRequestAttachment *attachment = [[self alloc] init];
    attachment.data = data;
    return attachment;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.data forKey:@"data"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _data = [coder decodeObjectOfClasses:[PVArchiveCodec defaultAllowedClasses] forKey:@"data"];
    }
    return self;
}

@end

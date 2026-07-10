//
//  PVResponseAttachment.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVResponseAttachment.h"

#import "PVArchiveCodec.h"

@implementation PVResponseAttachment

+ (BOOL)supportsSecureCoding {
    return YES;
}

+ (instancetype)attachmentWithData:(id<NSSecureCoding>)data {
    PVResponseAttachment *attachment = [[self alloc] init];
    attachment.data = data;
    return attachment;
}

+ (instancetype)attachmentWithError:(NSError *)error {
    PVResponseAttachment *attachment = [[self alloc] init];
    attachment.error = error;
    return attachment;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.data forKey:@"data"];
    [coder encodeObject:self.error forKey:@"error"];
    [coder encodeInteger:self.dataTotalCount forKey:@"dataTotalCount"];
    [coder encodeInteger:self.currentDataCount forKey:@"currentDataCount"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _data = [coder decodeObjectOfClasses:[PVArchiveCodec defaultAllowedClasses] forKey:@"data"];
        _error = [coder decodeObjectOfClass:NSError.class forKey:@"error"];
        _dataTotalCount = (NSUInteger)[coder decodeIntegerForKey:@"dataTotalCount"];
        _currentDataCount = (NSUInteger)[coder decodeIntegerForKey:@"currentDataCount"];
    }
    return self;
}

@end

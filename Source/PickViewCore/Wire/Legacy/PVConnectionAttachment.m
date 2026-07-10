//
//  PVConnectionAttachment.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVConnectionAttachment.h"
#import "PVInspectionDefines.h"
#import "NSObject+PVInspect.h"

static NSString * const Key_Data = @"0";
static NSString * const Key_DataType = @"1";

@interface PVConnectionAttachment ()

@end

@implementation PVConnectionAttachment

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:[self.data pv_inspect_encodedObjectWithType:self.dataType] forKey:Key_Data];
    [aCoder encodeInteger:self.dataType forKey:Key_DataType];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.dataType = [aDecoder decodeIntegerForKey:Key_DataType];
        self.data = [[aDecoder decodeObjectForKey:Key_Data] pv_inspect_decodedObjectWithType:self.dataType];
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

@end


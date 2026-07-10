//
//  PVConnectionResponseAttachment.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVConnectionResponseAttachment.h"
#import "PVInspectionDefines.h"

@interface PVConnectionResponseAttachment ()

@end

@implementation PVConnectionResponseAttachment

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeInt:self.pickviewServerVersion forKey:@"pickviewServerVersion"];
    [aCoder encodeObject:self.error forKey:@"error"];
    [aCoder encodeObject:@(self.dataTotalCount) forKey:@"dataTotalCount"];
    [aCoder encodeObject:@(self.currentDataCount) forKey:@"currentDataCount"];
    [aCoder encodeBool:self.appIsInBackground forKey:@"appIsInBackground"];
}

- (instancetype)init {
    if (self = [super init]) {
        self.pickviewServerVersion = PV_INSPECT_SERVER_VERSION;
        self.dataTotalCount = 0;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.pickviewServerVersion = [aDecoder decodeIntForKey:@"pickviewServerVersion"];
        self.error = [aDecoder decodeObjectForKey:@"error"];
        self.dataTotalCount = [[aDecoder decodeObjectForKey:@"dataTotalCount"] unsignedIntegerValue];
        self.currentDataCount = [[aDecoder decodeObjectForKey:@"currentDataCount"] unsignedIntegerValue];
        self.appIsInBackground = [aDecoder decodeBoolForKey:@"appIsInBackground"];
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

+ (instancetype)attachmentWithError:(NSError *)error {
    PVConnectionResponseAttachment *attachment = [PVConnectionResponseAttachment new];
    attachment.error = error;
    return attachment;
}

@end


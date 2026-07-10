//
//  PVHierarchyFile.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVHierarchyFile.h"

#import "NSArray+PVInspect.h"

@implementation PVHierarchyFile

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInt:self.serverVersion forKey:@"serverVersion"];
    [aCoder encodeObject:self.hierarchyInfo forKey:@"hierarchyInfo"];
    [aCoder encodeObject:self.soloScreenshots forKey:@"soloScreenshots"];
    [aCoder encodeObject:self.groupScreenshots forKey:@"groupScreenshots"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.serverVersion = [aDecoder decodeIntForKey:@"serverVersion"];
        self.hierarchyInfo = [aDecoder decodeObjectForKey:@"hierarchyInfo"];
        self.soloScreenshots = [aDecoder decodeObjectForKey:@"soloScreenshots"];
        self.groupScreenshots = [aDecoder decodeObjectForKey:@"groupScreenshots"];
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

+ (NSError *)verifyHierarchyFile:(PVHierarchyFile *)hierarchyFile {
    if (![hierarchyFile isKindOfClass:[PVHierarchyFile class]]) {
        return PVInspectErr_Inner;
    }
    
    if (hierarchyFile.serverVersion < PV_INSPECT_SUPPORTED_SERVER_MIN) {
        // 文件版本太旧
        // 如果不存在 serverVersion 这个字段，说明版本是 6
        int fileVersion = hierarchyFile.serverVersion ? : 6;
        NSString *detail = [NSString stringWithFormat:NSLocalizedString(@"The document was created by a PickView app with too old version. Current PickView app version is %@, but the document version is %@.", nil), @(PV_INSPECT_CLIENT_VERSION), @(fileVersion)];
        return [NSError errorWithDomain:PVInspectErrorDomain code:PVInspectErrCode_ServerVersionTooLow userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"Failed to open the document.", nil), NSLocalizedRecoverySuggestionErrorKey:detail}];
    }
    
    if (hierarchyFile.serverVersion > PV_INSPECT_SUPPORTED_SERVER_MAX) {
        // 文件版本太新
        NSString *detail = [NSString stringWithFormat:NSLocalizedString(@"Current PickView app is too old to open this document. Current PickView app version is %@, but the document version is %@.", nil), @(PV_INSPECT_CLIENT_VERSION), @(hierarchyFile.serverVersion)];
        return [NSError errorWithDomain:PVInspectErrorDomain code:PVInspectErrCode_ServerVersionTooHigh userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"Failed to open the document.", nil), NSLocalizedRecoverySuggestionErrorKey:detail}];
    }
    
    return nil;
}

@end


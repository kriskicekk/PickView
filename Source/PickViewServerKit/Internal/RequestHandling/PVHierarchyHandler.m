//
//  PVHierarchyHandler.m
//  PickViewServer
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVHierarchyHandler.h"

#import "PVArchiveCodec.h"
#import "PVErrorCode.h"
#import "PVHierarchyInfo.h"
#import "PVHierarchyProvider.h"
#import "PVRequestAttachment.h"
#import "PVRequestType.h"
#import "PVResponseAttachment.h"

@interface PVHierarchyHandler ()
@property (nonatomic, strong) id<PVHierarchyProvider> provider;
@end

@implementation PVHierarchyHandler

- (instancetype)initWithProvider:(id<PVHierarchyProvider>)provider {
    self = [super init];
    if (self) {
        _provider = provider;
    }
    return self;
}

- (BOOL)canHandleRequestType:(uint32_t)type {
    return type == PVRequestTypeHierarchy;
}

- (void)handleRequestType:(uint32_t)type
                  payload:(NSData *)payload
               completion:(void (^)(NSData * _Nullable, NSError * _Nullable))completion {
    NSString *windowID = [self windowIDFromPayload:payload];

    NSError *hierarchyError = nil;
    PVHierarchyInfo *hierarchy = [self.provider hierarchyForWindowID:windowID error:&hierarchyError];
    PVResponseAttachment *attachment = hierarchy ? [PVResponseAttachment attachmentWithData:hierarchy] : [PVResponseAttachment attachmentWithError:hierarchyError ?: [self genericError]];

    NSError *archiveError = nil;
    NSData *data = [PVArchiveCodec archivedDataWithObject:attachment error:&archiveError];
    if (completion) completion(data, archiveError);
}

- (NSString *)windowIDFromPayload:(NSData *)payload {
    if (!payload.length) {
        return nil;
    }

    NSError *error = nil;
    id object = [PVArchiveCodec unarchivedObjectFromData:payload
                                          allowedClasses:[PVArchiveCodec defaultAllowedClasses]
                                                   error:&error];
    if ([object isKindOfClass:PVRequestAttachment.class]) {
        id data = ((PVRequestAttachment *)object).data;
        if ([data isKindOfClass:NSString.class]) {
            return data;
        }
    }
    return nil;
}

- (NSError *)genericError {
    return [NSError errorWithDomain:PVErrorDomain
                               code:PVErrorCodeUnknown
                           userInfo:@{NSLocalizedDescriptionKey: @"Failed to build hierarchy."}];
}

@end

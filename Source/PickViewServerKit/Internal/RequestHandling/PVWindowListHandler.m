//
//  PVWindowListHandler.m
//  PickViewServer
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVWindowListHandler.h"

#import "PVArchiveCodec.h"
#import "PVHierarchyProvider.h"
#import "PVRequestType.h"
#import "PVResponseAttachment.h"

@interface PVWindowListHandler ()
@property (nonatomic, strong) id<PVHierarchyProvider> provider;
@end

@implementation PVWindowListHandler

- (instancetype)initWithProvider:(id<PVHierarchyProvider>)provider {
    self = [super init];
    if (self) {
        _provider = provider;
    }
    return self;
}

- (BOOL)canHandleRequestType:(uint32_t)type {
    return type == PVRequestTypeWindowList;
}

- (void)handleRequestType:(uint32_t)type
                  payload:(NSData *)payload
               completion:(void (^)(NSData * _Nullable, NSError * _Nullable))completion {
    NSArray *windows = [self.provider allWindows] ?: @[];
    PVResponseAttachment *attachment = [PVResponseAttachment attachmentWithData:windows];

    NSError *error = nil;
    NSData *data = [PVArchiveCodec archivedDataWithObject:attachment error:&error];
    if (completion) completion(data, error);
}

@end

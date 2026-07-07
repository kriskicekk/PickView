//
//  PVAppInfoHandler.m
//  PickViewServer
//
//  Created by kris cheng on 2026/7/6.
//

#import "PVAppInfoHandler.h"
#import "PVRequestType.h"
#import "PVPeerIdentity.h"

@implementation PVAppInfoHandler

- (BOOL)canHandleRequestType:(uint32_t)type {
    return type == PVRequestTypePing || type == PVRequestTypeAppInfo;
}

- (void)handleRequestType:(uint32_t)type payload:(NSData *)payload completion:(void (^)(NSData * _Nullable, NSError * _Nullable))completion {
    NSDictionary *response = [[PVPeerIdentity sharedIdentity] dictionaryRepresentation];
    NSError *error = nil;
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:response
                                                              format:NSPropertyListBinaryFormat_v1_0
                                                             options:0
                                                               error:&error];

    if (completion) completion(data, error);
}

@end

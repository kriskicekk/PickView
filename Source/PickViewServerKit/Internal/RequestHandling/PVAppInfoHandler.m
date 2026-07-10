//
//  PVAppInfoHandler.m
//  PickViewServer
//
//  Created by kris cheng on 2026/7/6.
//

#import "PVAppInfoHandler.h"

#import "PVAppInfo.h"
#import "PVAppInfoCollector.h"
#import "PVArchiveCodec.h"
#import "PVPeerIdentity.h"
#import "PVKitVersion.h"
#import "PVRequestAttachment.h"
#import "PVRequestType.h"
#import "PVResponseAttachment.h"

@implementation PVAppInfoHandler

- (BOOL)canHandleRequestType:(uint32_t)type {
    return type == PVRequestTypePing || type == PVRequestTypeAppInfo;
}

- (void)handleRequestType:(uint32_t)type payload:(NSData *)payload completion:(void (^)(NSData * _Nullable, NSError * _Nullable))completion {
    if (type == PVRequestTypePing) {
        [self handlePingWithCompletion:completion];
        return;
    }

    [self handleAppInfoWithPayload:payload completion:completion];
}

- (void)handlePingWithCompletion:(void (^)(NSData * _Nullable, NSError * _Nullable))completion {
    PVPeerIdentity *identity = [PVPeerIdentity localIdentityWithProtocolVersion:PVServerProtocolVersion
                                                        supportedPeerVersionMin:PVServerSupportedPeerVersionMin
                                                        supportedPeerVersionMax:PVServerSupportedPeerVersionMax];
    NSDictionary *response = identity.dictionaryRepresentation;
    NSError *error = nil;
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:response
                                                              format:NSPropertyListBinaryFormat_v1_0
                                                             options:0
                                                               error:&error];
    if (completion) completion(data, error);
}

- (void)handleAppInfoWithPayload:(NSData *)payload completion:(void (^)(NSData * _Nullable, NSError * _Nullable))completion {
    NSDictionary *params = [self paramsFromPayload:payload];
    BOOL needImages = [params[@"needImages"] boolValue];
    NSArray<NSNumber *> *localIdentifiers = [params[@"local"] isKindOfClass:NSArray.class] ? params[@"local"] : nil;

    PVAppInfo *appInfo = [self currentAppInfoWithImages:needImages localIdentifiers:localIdentifiers];
    PVResponseAttachment *attachment = [PVResponseAttachment attachmentWithData:appInfo];

    NSError *archiveError = nil;
    NSData *data = [PVArchiveCodec archivedDataWithObject:attachment error:&archiveError];
    if (completion) completion(data, archiveError);
}

- (NSDictionary *)paramsFromPayload:(NSData *)payload {
    if (!payload.length) {
        return @{};
    }

    NSError *error = nil;
    id object = [PVArchiveCodec unarchivedObjectFromData:payload
                                          allowedClasses:[PVArchiveCodec defaultAllowedClasses]
                                                   error:&error];
    if ([object isKindOfClass:PVRequestAttachment.class]) {
        id data = ((PVRequestAttachment *)object).data;
        if ([data isKindOfClass:NSDictionary.class]) {
            return data;
        }
    }
    return @{};
}

- (PVAppInfo *)currentAppInfoWithImages:(BOOL)needImages localIdentifiers:(NSArray<NSNumber *> *)localIdentifiers {
    return [PVAppInfoCollector currentInfoWithImages:needImages
                                    localIdentifiers:localIdentifiers ?: @[]];
}

@end

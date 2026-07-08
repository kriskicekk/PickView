//
//  PVHeartbeatHandler.m
//  PickViewServer
//
//  Created by kris cheng on 2026/7/8.
//

#import "PVHeartbeatHandler.h"
#import "PVRequestType.h"

@implementation PVHeartbeatHandler

- (BOOL)canHandleRequestType:(uint32_t)type {
    return type == PVRequestTypeHeartbeat;
}

- (void)handleRequestType:(uint32_t)type
                  payload:(NSData *)payload
               completion:(void (^)(NSData * _Nullable, NSError * _Nullable))completion {
    NSMutableDictionary *response = [NSMutableDictionary dictionary];

    if (payload.length) {
        NSError *parseError = nil;
        id request = [NSPropertyListSerialization propertyListWithData:payload
                                                                options:NSPropertyListImmutable
                                                                 format:nil
                                                                  error:&parseError];
        if (parseError) {
            if (completion) completion(nil, parseError);
            return;
        }

        if ([request isKindOfClass:NSDictionary.class]) {
            id sequence = request[@"sequence"];
            if (sequence) response[@"sequence"] = sequence;
            id timestamp = request[@"timestamp"];
            if (timestamp) response[@"timestamp"] = timestamp;
        }
    }

    response[@"status"] = @"ok";
    response[@"serverTimestamp"] = @([[NSDate date] timeIntervalSince1970]);

    NSError *error = nil;
    NSData *responsePayload = [NSPropertyListSerialization dataWithPropertyList:response
                                                                         format:NSPropertyListBinaryFormat_v1_0
                                                                        options:0
                                                                          error:&error];
    if (completion) completion(responsePayload, error);
}

@end

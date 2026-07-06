//
//  PVMessageHandler.m
//  PickViewServer
//
//  Created by kris cheng on 2026/7/6.
//

#import "PVMessageHandler.h"
#import "PVRequestType.h"

@interface PVMessageHandler ()
@property (nonatomic, copy, nullable) PVMessageReceiveBlock receiveBlock;
@end

@implementation PVMessageHandler

- (instancetype)initWithReceiveBlock:(PVMessageReceiveBlock)receiveBlock {
    self = [super init];
    if (self) {
        _receiveBlock = [receiveBlock copy];
    }
    return self;
}

- (BOOL)canHandleRequestType:(uint32_t)type {
    return type == PVRequestTypeMessage;
}

- (void)handleRequestType:(uint32_t)type
                  payload:(NSData *)payload
               completion:(void (^)(NSData * _Nullable, NSError * _Nullable))completion {
    NSError *error = nil;
    NSString *message = @"";

    if (payload.length) {
        id request = [NSPropertyListSerialization propertyListWithData:payload
                                                                options:NSPropertyListImmutable
                                                                 format:nil
                                                                  error:&error];
        if ([request isKindOfClass:NSDictionary.class]) {
            id value = request[@"message"];
            if ([value isKindOfClass:NSString.class]) {
                message = value;
            }
        }
    }

    if (error) {
        if (completion) completion(nil, error);
        return;
    }

    if (self.receiveBlock) {
        self.receiveBlock(message);
    }

    NSDictionary *response = @{
        @"echo": message,
        @"received": @YES
    };
    NSData *responsePayload = [NSPropertyListSerialization dataWithPropertyList:response
                                                                         format:NSPropertyListBinaryFormat_v1_0
                                                                        options:0
                                                                          error:&error];
    if (completion) completion(responsePayload, error);
}

@end

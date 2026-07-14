//
//  PVInspectionRequestClient.m
//  PickViewClient
//
//  Created by kris cheng on 2026/7/10.
//

#import "PVInspectionRequestClient.h"

#import "PVArchiveCodec.h"
#import "PVClientSession.h"
#import "PVInspectionDefines.h"
#import "PVResponseAttachment.h"

@interface PVInspectionRequestClient ()

@property(nonatomic, strong) PVClientSession *session;

@end

@implementation PVInspectionRequestClient

- (instancetype)initWithSession:(PVClientSession *)session {
    self = [super init];
    if (self) {
        _session = session;
    }
    return self;
}

- (void)sendRequestType:(uint32_t)type
                 object:(id<NSSecureCoding>)object
        timeoutInterval:(NSTimeInterval)timeoutInterval
              completion:(PVInspectionRequestCompletion)completion {
    NSError *error = nil;
    NSData *payload = object ? [PVArchiveCodec archivedDataWithObject:object error:&error] : nil;
    if (object && !payload) {
        NSLog(@"PickView request archive failed type=%u error=%@", type, error);
        if (completion) completion(nil, YES, error ?: PVInspectErr_Inner);
        return;
    }
    [self sendRequestType:type payload:payload timeoutInterval:timeoutInterval completion:completion];
}

- (void)sendRequestType:(uint32_t)type
                payload:(NSData *)payload
        timeoutInterval:(NSTimeInterval)timeoutInterval
              completion:(PVInspectionRequestCompletion)completion {
    if (self.session.state != PVClientSessionStateReady) {
        NSLog(@"PickView request rejected type=%u session=%@ state=%@", type,
              self.session.identifier ?: @"", @(self.session.state));
        if (completion) completion(nil, YES, PVInspectErr_NoConnect);
        return;
    }

    __block NSUInteger receivedDataCount = 0;
    [self.session sendRequestType:type payload:payload timeoutInterval:timeoutInterval completion:^(NSData *responsePayload, NSError *error) {
        if (error) {
            if (completion) completion(nil, YES, error);
            return;
        }

        NSError *decodeError = nil;
        PVResponseAttachment *attachment = [self responseAttachmentFromPayload:responsePayload error:&decodeError];
        if (!attachment || decodeError) {
            if (completion) completion(nil, YES, decodeError ?: PVInspectErr_Inner);
            return;
        }
        if (attachment.error) {
            if (completion) completion(nil, YES, [self translatedError:attachment.error]);
            return;
        }

        BOOL finished = YES;
        if (attachment.dataTotalCount > 0) {
            NSUInteger currentCount = attachment.currentDataCount > 0 ? attachment.currentDataCount : 1;
            receivedDataCount += currentCount;
            finished = receivedDataCount >= attachment.dataTotalCount;
        }
        if (completion) completion(attachment.data, finished, nil);
    }];
}

- (void)cancelRequestType:(uint32_t)requestType pushType:(uint32_t)pushType {
    if (self.session.state != PVClientSessionStateReady) {
        return;
    }
    [self.session cancelPendingRequestsWithType:requestType];
    [self.session sendPushType:pushType payload:nil completion:nil];
}

- (PVResponseAttachment *)responseAttachmentFromPayload:(NSData *)payload error:(NSError **)error {
    NSError *archiveError = nil;
    id object = [PVArchiveCodec unarchivedObjectFromData:payload
                                          allowedClasses:[PVArchiveCodec defaultAllowedClasses]
                                                   error:&archiveError];
    if ([object isKindOfClass:PVResponseAttachment.class]) {
        return object;
    }

    NSError *plistError = nil;
    id plist = payload.length ? [NSPropertyListSerialization propertyListWithData:payload options:0 format:nil error:&plistError] : nil;
    if ([plist isKindOfClass:NSDictionary.class]) {
        NSString *message = plist[@"error"];
        if (!message.length) {
            message = [NSString stringWithFormat:@"Unexpected property-list response with keys: %@", [[plist allKeys] componentsJoinedByString:@", "]];
        }
        if (error) *error = PVInspectErrorMake(@"Request failed", message);
        return nil;
    }

    NSString *detail = payload.length ?
        [NSString stringWithFormat:@"The connected app returned %lu bytes that are not a PickView response. Rebuild and reinstall the PickView server app, then reconnect.", (unsigned long)payload.length] :
        @"The connected app returned an empty response.";
    if (error) *error = PVInspectErrorMake(@"Invalid PickView response", detail);
    return nil;
}

- (NSError *)translatedError:(NSError *)error {
    if (error.code == PVInspectErrCode_ObjectNotFound) {
        return PVInspectErr_ObjNotFound;
    }
    if (error.code == PVInspectErrCode_Inner) {
        return PVInspectErr_Inner;
    }
    return error ?: PVInspectErr_Inner;
}

@end

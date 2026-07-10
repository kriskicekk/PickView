//
//  PVServerSession.m
//  PickViewServer
//
//  Created by kris cheng on 2026/7/6.
//

#import "PVServerSession.h"
#import "PVRequestHandlerProtocol.h"
#import "PVConnectionProtocol.h"
#import "PVFrame.h"
#import "PVErrorCode.h"
#import "PVArchiveCodec.h"
#import "PVResponseAttachment.h"

@interface PVServerSession ()
@property (nonatomic, strong) id<PVConnectionProtocol> connection;
@property (nonatomic, strong) id<PVRequestHandlerProtocol> requestHandler;
@end

@implementation PVServerSession

- (instancetype)initWithConnection:(id<PVConnectionProtocol>)connection requestHandler:(id<PVRequestHandlerProtocol>)requestHandler {
    self = [super init];
    if (self) {
        _connection = connection;
        _requestHandler = requestHandler;
        _connection.delegate = self;
    }
    return self;
}

- (void)start {
    // Accepted connections are already open. The session becomes active once it is the connection delegate.
    [self.connection connectWithCompletion:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"[PickView Server] session start failed: %@", error.localizedDescription);
        }
    }];
}

- (void)close {
    [self.connection close];
}

#pragma mark - PVConnectionDelegate

- (void)connection:(id<PVConnectionProtocol>)connection didReceiveFrame:(PVFrame *)frame {
    if (![self.requestHandler canHandleRequestType:frame.type]) {
        NSError *error = [NSError errorWithDomain:PVErrorDomain code:PVErrorCodeUnknown userInfo:@{NSLocalizedDescriptionKey: @"Unsupported request type."}];
        PVFrame *response = [[PVFrame alloc] initWithType:frame.type tag:frame.tag payload:[self payloadForError:error]];
        [connection sendFrame:response completion:nil];
        return;
    }

    if (frame.tag == 0) {
        [self.requestHandler handleRequestType:frame.type payload:frame.payload completion:nil];
        return;
    }

    [self.requestHandler handleRequestType:frame.type payload:frame.payload completion:^(NSData *responsePayload, NSError *error) {
        NSError *responseError = error;
        if (!responsePayload.length && !responseError) {
            responseError = [NSError errorWithDomain:PVErrorDomain code:PVErrorCodeUnknown userInfo:@{NSLocalizedDescriptionKey: @"Empty response payload."}];
        }
        NSData *payload = responseError ? [self payloadForError:responseError] : responsePayload;
        PVFrame *response = [[PVFrame alloc] initWithType:frame.type tag:frame.tag payload:payload];
        [connection sendFrame:response completion:nil];
    }];
}

- (NSData *)payloadForError:(NSError *)error {
    PVResponseAttachment *attachment = [PVResponseAttachment attachmentWithError:error];
    NSError *archiveError = nil;
    NSData *payload = [PVArchiveCodec archivedDataWithObject:attachment error:&archiveError];
    if (payload) {
        return payload;
    }
    return [NSPropertyListSerialization dataWithPropertyList:@{@"error": error.localizedDescription ?: @"Unknown error"}
                                                      format:NSPropertyListBinaryFormat_v1_0
                                                     options:0
                                                       error:nil];
}

- (void)connection:(id<PVConnectionProtocol>)connection didCloseWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(serverSession:didCloseWithError:)]) {
        [self.delegate serverSession:self didCloseWithError:error];
    }
}

@end

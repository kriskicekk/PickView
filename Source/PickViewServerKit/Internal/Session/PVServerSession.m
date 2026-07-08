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
        NSData *payload = [NSPropertyListSerialization dataWithPropertyList:@{@"error": error.localizedDescription} format:NSPropertyListBinaryFormat_v1_0 options:0 error:nil];
        PVFrame *response = [[PVFrame alloc] initWithType:frame.type tag:frame.tag payload:payload];
        [connection sendFrame:response completion:nil];
        return;
    }

    [self.requestHandler handleRequestType:frame.type payload:frame.payload completion:^(NSData *responsePayload, NSError *error) {
        NSData *payload = responsePayload;
        if (error) {
            payload = [NSPropertyListSerialization dataWithPropertyList:@{@"error": error.localizedDescription} format:NSPropertyListBinaryFormat_v1_0 options:0 error:nil];
        }
        PVFrame *response = [[PVFrame alloc] initWithType:frame.type tag:frame.tag payload:payload];
        [connection sendFrame:response completion:nil];
    }];
}

- (void)connection:(id<PVConnectionProtocol>)connection didCloseWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(serverSession:didCloseWithError:)]) {
        [self.delegate serverSession:self didCloseWithError:error];
    }
}

@end

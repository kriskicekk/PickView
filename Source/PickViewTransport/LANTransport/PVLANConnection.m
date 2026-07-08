#import "PVLANConnection.h"
#import "PVLANEndpoint.h"
#import "PVFrame.h"
#import "PVFrameCodec.h"
#import "PVErrorCode.h"
#import "PVConnectionDelegate.h"
#import <Network/Network.h>

static NSError *PVNSErrorFromNWError(nw_error_t error);

static NSError *PVNSErrorFromNWError(nw_error_t error) {
    if (!error) {
        return nil;
    }
    CFErrorRef cfError = nw_error_copy_cf_error(error);
    if (cfError) {
        return CFBridgingRelease(cfError);
    }
    return [NSError errorWithDomain:PVErrorDomain code:PVErrorCodeUnknown userInfo:@{NSLocalizedDescriptionKey: @"Network.framework error."}];
}

@interface PVLANConnection ()
@property (nonatomic, strong, nullable) nw_connection_t networkConnection;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, copy, nullable) void(^connectCompletion)(NSError * _Nullable error);
@property (nonatomic, assign) BOOL didStartConnection;
@end

@implementation PVLANConnection

- (instancetype)initWithEndpoint:(PVLANEndpoint *)endpoint {
    self = [super init];
    if (self) {
        self.endpoint = endpoint;
        self.queue = dispatch_queue_create("com.pickview.lan.connection", DISPATCH_QUEUE_SERIAL);
        [self updateState:PVConnectionStateIdle];
    }
    return self;
}

- (instancetype)initWithAcceptedConnection:(nw_connection_t)connection {
    self = [super init];
    if (self) {
        _networkConnection = connection;
        _queue = dispatch_queue_create("com.pickview.lan.accepted-connection", DISPATCH_QUEUE_SERIAL);
        [self updateState:PVConnectionStateIdle];
    }
    return self;
}

- (NSString *)connectionIdentifier {
    if (self.endpoint) {
        return self.endpoint.identifier;
    }
    return [NSString stringWithFormat:@"lan:accepted:%p", self.networkConnection];
}

- (void)connectWithCompletion:(void (^)(NSError * _Nullable))completion {
    if (self.state == PVConnectionStateConnected || self.state == PVConnectionStateConnecting) {
        if (completion) completion(nil);
        return;
    }
    
    PVLANEndpoint *endpoint = (PVLANEndpoint *)self.endpoint;
    if (!self.networkConnection) {
        if (!endpoint.networkEndpoint) {
            if (completion) {
                NSError *error = [NSError errorWithDomain:PVErrorDomain code:PVErrorCodeUnknown userInfo:@{NSLocalizedDescriptionKey: @"LAN endpoint is missing."}];
                completion(error);
            }
            return;
        }
        nw_parameters_t parameters = nw_parameters_create_secure_tcp(NW_PARAMETERS_DISABLE_PROTOCOL, NW_PARAMETERS_DEFAULT_CONFIGURATION);
//        nw_parameters_set_include_peer_to_peer(parameters, false);
        self.networkConnection = nw_connection_create(endpoint.networkEndpoint, parameters);
    }

    self.connectCompletion = completion;
    [self updateState:PVConnectionStateConnecting];
    [self startNetworkConnectionIfNeeded];
}

- (void)sendFrame:(PVFrame *)frame completion:(void (^)(NSError * _Nullable))completion {
    if (self.state != PVConnectionStateConnected || !self.networkConnection) {
        if (completion) {
            NSError *error = [NSError errorWithDomain:PVErrorDomain code:PVErrorCodeDisconnected userInfo:@{NSLocalizedDescriptionKey: @"LAN connection is not connected."}];
            completion(error);
        }
        return;
    }

    NSData *data = [PVFrameCodec dataWithFrame:frame];
    dispatch_data_t content = dispatch_data_create(data.bytes, data.length, self.queue, DISPATCH_DATA_DESTRUCTOR_DEFAULT);
    nw_connection_send(self.networkConnection, content, NW_CONNECTION_DEFAULT_MESSAGE_CONTEXT, true, ^(nw_error_t error) {
        if (completion) {
            completion(error ? PVNSErrorFromNWError(error) : nil);
        }
    });
}

- (void)close {
    [self updateState:PVConnectionStateClosing];
    if (self.networkConnection) {
        nw_connection_cancel(self.networkConnection);
        self.networkConnection = nil;
    }
    [self updateState:PVConnectionStateClosed];
}

- (void)startNetworkConnectionIfNeeded {
    if (self.didStartConnection || !self.networkConnection) {
        return;
    }
    self.didStartConnection = YES;

    nw_connection_set_queue(self.networkConnection, self.queue);

    __weak typeof(self) weakSelf = self;
    nw_connection_set_state_changed_handler(self.networkConnection, ^(nw_connection_state_t state, nw_error_t error) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return;

        switch (state) {
            case nw_connection_state_ready:
                [self updateState:PVConnectionStateConnected];
                [self completeOpenWithError:nil];
                [self notifyConnectionDidOpen];
                [self receiveNextFrame];
                break;
            case nw_connection_state_failed:
                [self updateState:PVConnectionStateFailed];
                [self completeOpenWithError:error ? PVNSErrorFromNWError(error) : [self genericNetworkError:@"LAN connection failed."]];
                [self notifyConnectionClosedWithError:error ? PVNSErrorFromNWError(error) : [self genericNetworkError:@"LAN connection failed."]];
                break;
            case nw_connection_state_cancelled:
                [self updateState:PVConnectionStateClosed];
                [self completeOpenWithError:[self genericNetworkError:@"LAN connection cancelled."]];
                [self notifyConnectionClosedWithError:nil];
                break;
            default:
                break;
        }
    });

    nw_connection_start(self.networkConnection);
}

- (void)receiveNextFrame {
    if (self.state != PVConnectionStateConnected || !self.networkConnection) {
        return;
    }

    __weak typeof(self) weakSelf = self;
    [self receiveLength:PVFrameCodec.headerLength completion:^(NSData *headerData, NSError *error, BOOL isComplete) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return;

        if (error || isComplete) {
            [self handleReceiveError:error];
            return;
        }

        NSError *payloadError = nil;
        NSUInteger payloadLength = [PVFrameCodec payloadLengthFromHeaderData:headerData error:&payloadError];
        if (payloadError) {
            [self handleReceiveError:payloadError];
            return;
        }

        if (payloadLength == 0) {
            [self emitFrameWithHeaderData:headerData payloadData:nil];
            [self receiveNextFrame];
            return;
        }

        [self receiveLength:payloadLength completion:^(NSData *payloadData, NSError *payloadReceiveError, BOOL payloadIsComplete) {
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) return;

            if (payloadReceiveError || payloadIsComplete) {
                [self handleReceiveError:payloadReceiveError];
                return;
            }

            [self emitFrameWithHeaderData:headerData payloadData:payloadData];
            [self receiveNextFrame];
        }];
    }];
}

- (void)receiveLength:(NSUInteger)length completion:(void(^)(NSData *data, NSError * _Nullable error, BOOL isComplete))completion {
    NSMutableData *buffer = [NSMutableData dataWithCapacity:length];
    [self receiveLength:length buffer:buffer completion:completion];
}

- (void)receiveLength:(NSUInteger)length
               buffer:(NSMutableData *)buffer
           completion:(void(^)(NSData *data, NSError * _Nullable error, BOOL isComplete))completion {
    if (!self.networkConnection) {
        completion(buffer.copy, [self genericNetworkError:@"LAN connection is closed."], YES);
        return;
    }

    NSUInteger remaining = length - buffer.length;
    nw_connection_receive(self.networkConnection, 1, (uint32_t)remaining, ^(dispatch_data_t content, nw_content_context_t context, bool isComplete, nw_error_t error) {
        if (error) {
            completion(buffer.copy, PVNSErrorFromNWError(error), isComplete);
            return;
        }

        if (content) {
            dispatch_data_apply(content, ^bool(dispatch_data_t region, size_t offset, const void *bytes, size_t size) {
                [buffer appendBytes:bytes length:size];
                return true;
            });
        }

        if (buffer.length >= length) {
            completion([buffer subdataWithRange:NSMakeRange(0, length)], nil, NO);
            return;
        }

        if (isComplete) {
            completion(buffer.copy, nil, YES);
            return;
        }

        [self receiveLength:length buffer:buffer completion:completion];
    });
}

- (void)emitFrameWithHeaderData:(NSData *)headerData payloadData:(NSData *)payloadData {
    NSMutableData *frameData = [headerData mutableCopy];
    if (payloadData.length) {
        [frameData appendData:payloadData];
    }

    NSError *error = nil;
    PVFrame *frame = [PVFrameCodec frameWithData:frameData error:&error];
    if (!frame) {
        [self handleReceiveError:error];
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(connection:didReceiveFrame:)]) {
            [self.delegate connection:self didReceiveFrame:frame];
        }
    });
}

- (void)handleReceiveError:(NSError *)error {
    if (self.state == PVConnectionStateClosed || self.state == PVConnectionStateClosing) {
        return;
    }
    [self updateState:error ? PVConnectionStateFailed : PVConnectionStateClosed];
    [self notifyConnectionClosedWithError:error];
}

- (void)completeOpenWithError:(NSError *)error {
    void(^completion)(NSError *) = self.connectCompletion;
    self.connectCompletion = nil;
    if (completion) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(error);
        });
    }
}

- (void)notifyConnectionDidOpen {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(connectionDidOpen:)]) {
            [self.delegate connectionDidOpen:self];
        }
    });
}

- (void)notifyConnectionClosedWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(connection:didCloseWithError:)]) {
            [self.delegate connection:self didCloseWithError:error];
        }
    });
}

- (NSError *)genericNetworkError:(NSString *)message {
    return [NSError errorWithDomain:PVErrorDomain code:PVErrorCodeUnknown userInfo:@{NSLocalizedDescriptionKey: message ?: @"LAN network error."}];
}

@end

#import "PVLANListener.h"
#import "PVLANConnection.h"
#import "PVLANConstants.h"

#import <Network/Network.h>

static NSError *PVLANNSErrorFromNWError(nw_error_t error);

static NSError *PVLANNSErrorFromNWError(nw_error_t error) {
    if (!error) {
        return nil;
    }
    CFErrorRef cfError = nw_error_copy_cf_error(error);
    if (cfError) {
        return CFBridgingRelease(cfError);
    }
    return [NSError errorWithDomain:NSPOSIXErrorDomain code:EINVAL userInfo:@{NSLocalizedDescriptionKey: @"Network.framework listener error."}];
}

@interface PVLANListener ()
@property (nonatomic, strong, nullable) nw_listener_t listener;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, assign) int listeningPort;
@property (nonatomic, copy) NSString *serviceName;
@property (nonatomic, copy, nullable) void(^startCompletion)(NSError * _Nullable error);
@property (nonatomic, assign) BOOL didCallStartCompletion;
@end

@implementation PVLANListener

- (instancetype)init {
    return [self initWithServiceName:@"PickView"];
}

- (instancetype)initWithServiceName:(NSString *)serviceName {
    self = [super init];
    if (self) {
        _serviceName = serviceName.length ? [serviceName copy] : @"PickView";
        _queue = dispatch_queue_create("com.pickview.lan.listener", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)startWithCompletion:(void (^)(NSError * _Nullable))completion {
    if (self.listener) {
        if (completion) completion(nil);
        return;
    }

    self.startCompletion = completion;
    self.didCallStartCompletion = NO;

    nw_parameters_t parameters = nw_parameters_create_secure_tcp(NW_PARAMETERS_DISABLE_PROTOCOL, NW_PARAMETERS_DEFAULT_CONFIGURATION);
//    nw_parameters_set_include_peer_to_peer(parameters, false);

    nw_listener_t listener = nw_listener_create(parameters);
    if (!listener) {
        NSError *error = [NSError errorWithDomain:NSPOSIXErrorDomain code:EINVAL userInfo:@{NSLocalizedDescriptionKey: @"Failed to create LAN listener."}];
        [self completeStartWithError:error];
        return;
    }
    self.listener = listener;

    nw_advertise_descriptor_t advertiseDescriptor = nw_advertise_descriptor_create_bonjour_service(self.serviceName.UTF8String, PVLANBonjourServiceType, NULL);
    nw_listener_set_advertise_descriptor(listener, advertiseDescriptor);
    nw_listener_set_queue(listener, self.queue);

    __weak typeof(self) weakSelf = self;
    nw_listener_set_state_changed_handler(listener, ^(nw_listener_state_t state, nw_error_t error) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return;

        if (state == nw_listener_state_ready) {
            self.listeningPort = nw_listener_get_port(listener);
            [self completeStartWithError:nil];
        } else if (state == nw_listener_state_failed) {
            [self completeStartWithError:error ? PVLANNSErrorFromNWError(error) : [self listenerError:@"LAN listener failed."]];
        } else if (state == nw_listener_state_cancelled) {
            self.listeningPort = 0;
        }
    });

    nw_listener_set_new_connection_handler(listener, ^(nw_connection_t connection) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return;

        PVLANConnection *lanConnection = [[PVLANConnection alloc] initWithAcceptedConnection:connection];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate listener:self didAcceptConnection:lanConnection];
        });
    });

    nw_listener_start(listener);
}

- (void)stop {
    if (self.listener) {
        nw_listener_cancel(self.listener);
        self.listener = nil;
    }
    self.listeningPort = 0;
    self.startCompletion = nil;
}

- (void)completeStartWithError:(NSError *)error {
    if (self.didCallStartCompletion) {
        return;
    }
    self.didCallStartCompletion = YES;

    void(^completion)(NSError *) = self.startCompletion;
    self.startCompletion = nil;
    if (completion) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(error);
        });
    }
}

- (NSError *)listenerError:(NSString *)message {
    return [NSError errorWithDomain:NSPOSIXErrorDomain code:EINVAL userInfo:@{NSLocalizedDescriptionKey: message ?: @"LAN listener error."}];
}

- (NSString *)listeningInfo {
    return @"start bonjour service";
}

@end

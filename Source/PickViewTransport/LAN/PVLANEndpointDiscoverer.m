#import "PVLANEndpointDiscoverer.h"
#import "PVEndpointDiscovererDelegate.h"
#import "PVLANConstants.h"
#import "PVLANEndpoint.h"

#import <Network/Network.h>

static NSError *PVLANBrowserErrorFromNWError(nw_error_t error);
static NSTimeInterval const PVLANEndpointRemovalGraceInterval = 1.0;

static NSError *PVLANBrowserErrorFromNWError(nw_error_t error) {
    if (!error) {
        return nil;
    }
    CFErrorRef cfError = nw_error_copy_cf_error(error);
    if (cfError) {
        return CFBridgingRelease(cfError);
    }
    return [NSError errorWithDomain:NSPOSIXErrorDomain code:EINVAL userInfo:@{NSLocalizedDescriptionKey: @"Network.framework browser error."}];
}

@interface PVLANEndpointDiscoverer ()
@property (nonatomic, strong, nullable) nw_browser_t browser;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) NSMutableDictionary<NSString *, PVLANEndpoint *> *endpointsByID;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSUUID *> *pendingRemovalTokensByID;
@end

@implementation PVLANEndpointDiscoverer

- (instancetype)init {
    self = [super init];
    if (self) {
        _queue = dispatch_queue_create("com.pickview.lan.discovery", DISPATCH_QUEUE_SERIAL);
        _endpointsByID = [NSMutableDictionary dictionary];
        _pendingRemovalTokensByID = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)start {
    if (self.browser) {
        return;
    }

    nw_browse_descriptor_t descriptor = nw_browse_descriptor_create_bonjour_service(PVLANBonjourServiceType, NULL);
    nw_parameters_t parameters = nw_parameters_create_secure_tcp(NW_PARAMETERS_DISABLE_PROTOCOL, NW_PARAMETERS_DEFAULT_CONFIGURATION);
//    nw_parameters_set_include_peer_to_peer(parameters, false);

    nw_browser_t browser = nw_browser_create(descriptor, parameters);
    self.browser = browser;

    nw_browser_set_queue(browser, self.queue);

    __weak typeof(self) weakSelf = self;
    nw_browser_set_browse_results_changed_handler(browser, ^(nw_browse_result_t oldResult, nw_browse_result_t newResult, bool batchComplete) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return;

        nw_browse_result_change_t changes = nw_browse_result_get_changes(oldResult, newResult);
        NSLog(@"[PickView LAN Discoverer] changes=0x%llx batchComplete=%@ old=%@ new=%@",
              changes,
              batchComplete ? @"YES" : @"NO",
              oldResult ? @"YES" : @"NO",
              newResult ? @"YES" : @"NO");

        // Network.framework describes newResult as a replacement for oldResult.
        // Apply the replacement before considering removal so a service update does
        // not briefly disappear from the client UI.
        if (newResult && (changes & (nw_browse_result_change_result_added | nw_browse_result_change_txt_record_changed | nw_browse_result_change_interface_added | nw_browse_result_change_interface_removed))) {
            [self addOrUpdateEndpointForBrowseResult:newResult];
        }

        if ((changes & nw_browse_result_change_result_removed) && oldResult) {
            [self scheduleRemovalForBrowseResult:oldResult replacingResult:newResult];
        }
    });

    nw_browser_set_state_changed_handler(browser, ^(nw_browser_state_t state, nw_error_t error) {
        if (state == nw_browser_state_ready) {
            NSLog(@"[PickView LAN Discoverer] browser ready for %@", PVLANBonjourServiceTypeString);
        } else if (state == nw_browser_state_failed) {
            NSLog(@"[PickView LAN Discoverer] browser failed: %@", PVLANBrowserErrorFromNWError(error));
        } else if (state == nw_browser_state_cancelled) {
            NSLog(@"[PickView LAN Discoverer] browser cancelled");
        }
    });

    nw_browser_start(browser);
}

- (void)stop {
    if (self.browser) {
        nw_browser_cancel(self.browser);
        self.browser = nil;
    }

    NSArray<PVLANEndpoint *> *endpoints = nil;
    @synchronized (self.endpointsByID) {
        endpoints = self.endpointsByID.allValues;
        [self.endpointsByID removeAllObjects];
        [self.pendingRemovalTokensByID removeAllObjects];
    }

    for (PVLANEndpoint *endpoint in endpoints) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate discoverer:self didRemoveEndpoint:endpoint];
        });
    }
}

- (void)addOrUpdateEndpointForBrowseResult:(nw_browse_result_t)result {
    nw_endpoint_t networkEndpoint = nw_browse_result_copy_endpoint(result);
    PVLANEndpoint *endpoint = [[PVLANEndpoint alloc] initWithNetworkEndpoint:networkEndpoint];

    @synchronized (self.endpointsByID) {
        [self.pendingRemovalTokensByID removeObjectForKey:endpoint.identifier];
        self.endpointsByID[endpoint.identifier] = endpoint;
    }

    NSLog(@"[PickView LAN Discoverer] found %@", endpoint.identifier);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate discoverer:self didFindEndpoint:endpoint];
    });
}

- (void)scheduleRemovalForBrowseResult:(nw_browse_result_t)result
                       replacingResult:(nullable nw_browse_result_t)replacementResult {
    nw_endpoint_t networkEndpoint = nw_browse_result_copy_endpoint(result);
    PVLANEndpoint *endpoint = [[PVLANEndpoint alloc] initWithNetworkEndpoint:networkEndpoint];

    if (replacementResult) {
        nw_endpoint_t replacementNetworkEndpoint = nw_browse_result_copy_endpoint(replacementResult);
        PVLANEndpoint *replacementEndpoint = [[PVLANEndpoint alloc] initWithNetworkEndpoint:replacementNetworkEndpoint];
        if ([replacementEndpoint.identifier isEqualToString:endpoint.identifier]) {
            return;
        }
    }

    NSUUID *token = NSUUID.UUID;
    @synchronized (self.endpointsByID) {
        self.pendingRemovalTokensByID[endpoint.identifier] = token;
    }

    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                 (int64_t)(PVLANEndpointRemovalGraceInterval * NSEC_PER_SEC)),
                   self.queue, ^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return;

        PVLANEndpoint *removedEndpoint = nil;
        @synchronized (self.endpointsByID) {
            NSUUID *currentToken = self.pendingRemovalTokensByID[endpoint.identifier];
            if (![currentToken isEqual:token]) {
                return;
            }
            [self.pendingRemovalTokensByID removeObjectForKey:endpoint.identifier];
            removedEndpoint = self.endpointsByID[endpoint.identifier];
            [self.endpointsByID removeObjectForKey:endpoint.identifier];
        }

        if (removedEndpoint) {
            NSLog(@"[PickView LAN Discoverer] removed %@ after %.1fs grace",
                  removedEndpoint.identifier, PVLANEndpointRemovalGraceInterval);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate discoverer:self didRemoveEndpoint:removedEndpoint];
            });
        }
    });
}

@end

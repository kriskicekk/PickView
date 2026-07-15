//
//  PVLANSessionCellModel.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/7.
//

#import "PVLANSessionCellModel.h"

#import "PVEndpointProtocol.h"
#import "PVLANEndpoint.h"

@interface PVLANSessionCellModel ()

@property (nonatomic, strong) id<PVEndpointProtocol> endpoint;
@property (nonatomic, strong, nullable) PVClientSession *session;
@property (nonatomic, copy) NSString *endpointIdentifier;
@property (nonatomic, copy) NSString *LANNameText;
@property (nonatomic, copy) NSString *deviceInfoText;
@property (nonatomic, copy) NSString *buttonTitle;
@property (nonatomic, assign) BOOL buttonEnabled;

@end

@implementation PVLANSessionCellModel

- (instancetype)initWithEndpoint:(id<PVEndpointProtocol>)endpoint
                          session:(PVClientSession *)session
                       connecting:(BOOL)connecting
    connectedEndpointIdentifier:(NSString *)connectedEndpointIdentifier {
    self = [super init];
    if (self) {
        _endpoint = endpoint;
        _session = session;
        _endpointIdentifier = endpoint.identifier ?: @"";
        _LANNameText = endpoint.displayName.length ? endpoint.displayName : @"Device";
        if ([endpoint isKindOfClass:PVLANEndpoint.class]) {
            PVLANEndpoint *LANEndpoint = (PVLANEndpoint *)endpoint;
            if (LANEndpoint.deviceName.length &&
                LANEndpoint.systemVersion.length) {
                _deviceInfoText = [NSString stringWithFormat:@"%@ %@",
                    LANEndpoint.deviceName,
                    LANEndpoint.systemVersion];
            } else {
                _deviceInfoText = LANEndpoint.deviceName.length
                    ? LANEndpoint.deviceName
                    : LANEndpoint.systemVersion ?: @"";
            }
        } else {
            _deviceInfoText = @"";
        }

        BOOL isConnected = [_endpointIdentifier isEqualToString:connectedEndpointIdentifier ?: @""];
        if (isConnected && session.state == PVClientSessionStateReady) {
            _buttonTitle = @"Open";
            _buttonEnabled = YES;
        } else if (connecting) {
            _buttonTitle = @"Connecting";
            _buttonEnabled = NO;
        } else if (session.state == PVClientSessionStateReady) {
            _buttonTitle = @"Open";
            _buttonEnabled = YES;
        } else {
            _buttonTitle = @"Connect";
            _buttonEnabled = YES;
        }
    }
    return self;
}

@end

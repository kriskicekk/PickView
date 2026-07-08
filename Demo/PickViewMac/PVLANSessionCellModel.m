//
//  PVLANSessionCellModel.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/7.
//

#import "PVLANSessionCellModel.h"

#import "PVConnectionProtocol.h"
#import "PVPeerIdentity.h"

@interface PVLANSessionCellModel ()

@property (nonatomic, strong) PVClientSession *session;
@property (nonatomic, copy) NSString *endpointIdentifier;
@property (nonatomic, copy) NSString *deviceNameText;
@property (nonatomic, copy) NSString *appNameText;
@property (nonatomic, copy) NSString *bundleIDText;
@property (nonatomic, copy) NSString *peerIDText;
@property (nonatomic, copy) NSString *protocolVersionText;
@property (nonatomic, copy) NSString *statusText;
@property (nonatomic, copy) NSString *buttonTitle;
@property (nonatomic, assign) BOOL buttonEnabled;

@end

@implementation PVLANSessionCellModel

- (instancetype)initWithSession:(PVClientSession *)session
    connectedEndpointIdentifier:(NSString *)connectedEndpointIdentifier {
    self = [super init];
    if (self) {
        _session = session;
        _endpointIdentifier = session.connection.connectionIdentifier ?: @"";
        _deviceNameText = [self.class displayTextWithValue:session.peerIdentity.deviceName placeholder:@"Checking"];
        _appNameText = [self.class displayTextWithValue:session.peerIdentity.appName placeholder:@""];
        _bundleIDText = [self.class displayTextWithValue:session.peerIdentity.bundleID placeholder:@""];
        _peerIDText = [self.class displayTextWithValue:session.peerIdentity.uuid placeholder:@""];
        _protocolVersionText = [self.class displayTextWithValue:session.peerIdentity.protocolVersion placeholder:@""];

        BOOL isConnected = [_endpointIdentifier isEqualToString:connectedEndpointIdentifier ?: @""];
        _statusText = [self.class statusTextWithSessionState:session.state isConnected:isConnected];
        _buttonTitle = [self.class buttonTitleWithSessionState:session.state isConnected:isConnected];
        _buttonEnabled = [self.class buttonEnabledWithSessionState:session.state isConnected:isConnected];
    }
    return self;
}

+ (NSString *)displayTextWithValue:(NSString *)value placeholder:(NSString *)placeholder {
    return value.length ? value : placeholder;
}

+ (NSString *)statusTextWithSessionState:(PVClientSessionState)state isConnected:(BOOL)isConnected {
    if (state == PVClientSessionStateBlocked) {
        return @"USB Connected";
    }
    if (isConnected) {
        return @"Connected";
    }

    switch (state) {
        case PVClientSessionStateIdle:
        case PVClientSessionStateConnecting:
        case PVClientSessionStateHandshaking:
            return @"Connecting";
        case PVClientSessionStateReady:
            return @"Ready";
        case PVClientSessionStateBlocked:
            return @"USB Connected";
        case PVClientSessionStateDisconnected:
        case PVClientSessionStateFailed:
            return @"Unavailable";
    }
}

+ (NSString *)buttonTitleWithSessionState:(PVClientSessionState)state isConnected:(BOOL)isConnected {
    if (state == PVClientSessionStateBlocked) {
        return @"USB Connected";
    }
    if (isConnected) {
        return @"Connected";
    }

    switch (state) {
        case PVClientSessionStateIdle:
        case PVClientSessionStateConnecting:
        case PVClientSessionStateHandshaking:
            return @"Connecting";
        case PVClientSessionStateReady:
            return @"Connect";
        case PVClientSessionStateBlocked:
            return @"USB Connected";
        case PVClientSessionStateDisconnected:
        case PVClientSessionStateFailed:
            return @"Connect";
    }
}

+ (BOOL)buttonEnabledWithSessionState:(PVClientSessionState)state isConnected:(BOOL)isConnected {
    if (isConnected) {
        return NO;
    }
    return state == PVClientSessionStateReady;
}

@end

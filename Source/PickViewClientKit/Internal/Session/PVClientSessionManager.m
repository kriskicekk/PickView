//
//  PVClientSessionManager.m
//  PickViewClient
//
//  Created by kris cheng on 2026/7/7.
//

#import "PVClientSessionManager.h"

#import "PVClientSession.h"
#import "PVConnectionProtocol.h"
#import "PVPeerIdentity.h"
#import "PVUSBEndpoint.h"
#import "PVLANEndpoint.h"

@interface PVClientSessionManager ()

@property (nonatomic, strong) NSMutableArray<PVClientSession *> *sessions;
@property (nonatomic, strong) NSMutableDictionary<NSString *, id<PVEndpointProtocol>> *endpointsByID;
@property (nonatomic, strong) NSMutableSet<NSString *> *connectingEndpointIDs;
@property (nonatomic, strong) NSMutableSet<NSString *> *connectedEndpointIDs;

@end

@implementation PVClientSessionManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _sessions = [NSMutableArray array];
        _endpointsByID = [NSMutableDictionary dictionary];
        _connectingEndpointIDs = [NSMutableSet set];
        _connectedEndpointIDs = [NSMutableSet set];
    }
    return self;
}

- (NSArray<PVClientSession *> *)allSessions {
    return self.sessions.copy;
}

- (NSArray<PVClientSession *> *)lanSessions {
    return [self sessionsForEndpointIdentifierPrefix:@"lan:"];
}

- (NSArray<PVClientSession *> *)usbSessions {
    return [self sessionsForEndpointIdentifierPrefix:@"usb:"];
}

- (NSArray<id<PVEndpointProtocol>> *)allEndpoints {
    return self.endpointsByID.allValues;
}

- (void)addSession:(PVClientSession *)session {
    if (!session || [self.sessions containsObject:session] || !session.identifier || !self.endpointsByID[session.identifier]) return;

    [self.sessions addObject:session];
    [self notifySessionsChanged];
}

- (void)closeAndRemoveSession:(PVClientSession *)session {
    if (!session) return;

    [session close];
    [self removeClosedSession:session];
}

- (void)removeClosedSession:(PVClientSession *)session {
    if (!session) return;

    BOOL hadSession = [self.sessions containsObject:session];
    [self.sessions removeObject:session];
    [self clearEndpointStateForIdentifier:session.identifier];

    if (hadSession) {
        [self notifySessionsChanged];
    }
}

- (void)removeAllSessions {
    NSArray<PVClientSession *> *sessions = self.sessions.copy;
    [sessions enumerateObjectsUsingBlock:^(PVClientSession * _Nonnull session, NSUInteger idx, BOOL * _Nonnull stop) {
        [self closeAndRemoveSession:session];
    }];
}

- (nullable PVClientSession *)sessionForEndpointIdentifier:(NSString *)endpointIdentifier {
    return [self sessionsForEndpointIdentifier:endpointIdentifier].firstObject;
}

- (NSArray<PVClientSession *> *)sessionsForEndpointIdentifier:(NSString *)endpointIdentifier {
    if (!endpointIdentifier.length) {
        return @[];
    }

    return [self sessionsMatchingBlock:^BOOL(PVClientSession *session) {
        return [session.connection.connectionIdentifier isEqualToString:endpointIdentifier];
    }];
}

- (NSArray<PVClientSession *> *)sessionsForEndpointIdentifierPrefix:(NSString *)endpointIdentifierPrefix {
    if (!endpointIdentifierPrefix.length) {
        return @[];
    }

    return [self sessionsMatchingBlock:^BOOL(PVClientSession *session) {
        return [session.identifier hasPrefix:endpointIdentifierPrefix];
    }];
}

- (void)removeSessionsForEndpointIdentifier:(NSString *)endpointIdentifier {
    NSArray<PVClientSession *> *sessions = [self sessionsForEndpointIdentifier:endpointIdentifier];
    for (PVClientSession *session in sessions) {
        [self closeAndRemoveSession:session];
    }
}

- (NSArray<PVClientSession *> *)sessionsMatchingBlock:(BOOL (^)(PVClientSession *session))block {
    if (!block) {
        return @[];
    }

    NSMutableArray<PVClientSession *> *matchedSessions = [NSMutableArray array];
    for (PVClientSession *session in self.sessions) {
        if (block(session)) {
            [matchedSessions addObject:session];
        }
    }
    return matchedSessions.copy;
}

- (void)notifySessionsChanged {
    if ([self.delegate respondsToSelector:@selector(clientSessionManagerDidUpdateSessions:)]) {
        [self.delegate clientSessionManagerDidUpdateSessions:self];
    }
}

- (void)addEndpoint:(id<PVEndpointProtocol>)endpoint {
    if (!endpoint.identifier.length) return;
    self.endpointsByID[endpoint.identifier] = endpoint;
}

- (nullable id<PVEndpointProtocol>)endpointForIdentifier:(NSString *)endpointIdentifier {
    if (!endpointIdentifier.length) return nil;
    return self.endpointsByID[endpointIdentifier];
}

- (void)removeEndpointForIdentifier:(NSString *)endpointIdentifier {
    if (!endpointIdentifier.length) return;
    [self forgetEndpointForIdentifier:endpointIdentifier];
    [self removeSessionsForEndpointIdentifier:endpointIdentifier];
}

- (void)forgetEndpointForIdentifier:(NSString *)endpointIdentifier {
    if (!endpointIdentifier.length) return;
    [self.endpointsByID removeObjectForKey:endpointIdentifier];
}

- (void)removeAllEndpoints {
    [self.endpointsByID removeAllObjects];
    [self removeAllSessions];
}

- (void)markEndpointConnectingWithIdentifier:(NSString *)endpointIdentifier {
    if (!endpointIdentifier.length) return;
    [self.connectingEndpointIDs addObject:endpointIdentifier];
}

- (void)removeConnectingEndpointWithIdentifier:(NSString *)endpointIdentifier {
    if (!endpointIdentifier.length) return;
    [self.connectingEndpointIDs removeObject:endpointIdentifier];
}

- (BOOL)isEndpointConnectingWithIdentifier:(NSString *)endpointIdentifier {
    if (!endpointIdentifier.length) return NO;
    return [self.connectingEndpointIDs containsObject:endpointIdentifier];
}

- (void)markEndpointConnectedWithIdentifier:(NSString *)endpointIdentifier {
    if (!endpointIdentifier.length) return;
    [self.connectedEndpointIDs addObject:endpointIdentifier];
}

- (void)removeConnectedEndpointWithIdentifier:(NSString *)endpointIdentifier {
    if (!endpointIdentifier.length) return;
    [self.connectedEndpointIDs removeObject:endpointIdentifier];
}

- (BOOL)isEndpointConnectedWithIdentifier:(NSString *)endpointIdentifier {
    if (!endpointIdentifier.length) return NO;
    return [self.connectedEndpointIDs containsObject:endpointIdentifier];
}

- (void)clearEndpointStateForIdentifier:(NSString *)endpointIdentifier {
    [self removeConnectingEndpointWithIdentifier:endpointIdentifier];
    [self removeConnectedEndpointWithIdentifier:endpointIdentifier];
}

- (void)clearAllEndpointStates {
    [self.connectingEndpointIDs removeAllObjects];
    [self.connectedEndpointIDs removeAllObjects];
}

- (void)clear {
    [self removeAllEndpoints];
}

- (PVClientSession *)findLanSessionByPeerIdentityUUID:(NSString *)uuid {
    return [self sessionsMatchingBlock:^BOOL(PVClientSession *session) {
        return [session.identifier hasPrefix:@"lan:"]
        && [session.peerIdentity.uuid isEqualToString:uuid];
    }].firstObject;
}

- (PVClientSession *)findUSBSessionByPeerIdentityUUID:(NSString *)uuid {
    return [self sessionsMatchingBlock:^BOOL(PVClientSession *session) {
        return [session.identifier hasPrefix:@"usb:"]
        && [session.peerIdentity.uuid isEqualToString:uuid];
    }].firstObject;
}

@end

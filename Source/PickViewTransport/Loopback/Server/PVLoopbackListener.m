//
//  PVLoopbackListener.m
//  PickViewServer
//
//  Created by kris cheng on 2026/7/6.
//

#import "PVLoopbackListener.h"

#import "PVLoopbackConnection.h"
#import "PVPortConstant.h"

#import <PeerTalk/PTChannel.h>

@interface PVLoopbackListener () <PTChannelDelegate>
@property (nonatomic, assign) int startPort;
@property (nonatomic, assign) int endPort;
@property (nonatomic, assign) int listeningPort;
@property (nonatomic, strong) PTChannel *serverChannel;
@property (nonatomic, strong, nullable) PVLoopbackConnection *activeConnection;
@property (nonatomic, copy) void (^startCompletion)(NSError *);
@end

@implementation PVLoopbackListener

- (instancetype)init {
    return [self initWithPortRangeStart:PVDefaultPortStart end:PVDefaultPortEnd];
}

- (instancetype)initWithPortRangeStart:(int)startPort end:(int)endPort {
    self = [super init];
    if (self) {
        _startPort = startPort;
        _endPort = endPort;
    }
    return self;
}

- (void)startWithCompletion:(void (^)(NSError * _Nullable))completion {
    self.startCompletion = completion;
    [self tryListenOnPort:self.startPort];
}

- (void)stop {
    [self cleanupServerChannel];
    self.listeningPort = 0;
    [self.activeConnection close];
    self.activeConnection = nil;
    self.startCompletion = nil;
}

- (void)tryListenOnPort:(int)port {
    PTChannel *channel = [PTChannel channelWithDelegate:self];
    __weak typeof(self) weakSelf = self;
    [channel listenOnPort:port IPv4Address:INADDR_LOOPBACK callback:^(NSError *error) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) {
            return;
        }

        if (error) {
            channel.delegate = nil;
            [channel close];
            if (port < self.endPort) {
                [self tryListenOnPort:port + 1];
                return;
            }
            [self finishStartWithError:error];
            return;
        }

        self.serverChannel = channel;
        self.listeningPort = port;
        [self finishStartWithError:nil];
    }];
}

- (void)cleanupServerChannel {
    PTChannel *channel = self.serverChannel;
    if (!channel) {
        return;
    }

    self.serverChannel = nil;
    channel.delegate = nil;
    [channel close];
}

- (void)finishStartWithError:(NSError *)error {
    void (^completion)(NSError *) = self.startCompletion;
    self.startCompletion = nil;
    if (completion) {
        completion(error);
    }
}

- (void)dealloc {
    [self stop];
}

+ (NSString *)description {
    return @"LoopbackListener";
}

- (NSString *)listeningInfo {
    return [[NSString alloc] initWithFormat:@"listening on %@:%d", @"127.0.0.1", self.listeningPort];
}

#pragma mark - PTChannelDelegate

- (void)ioFrameChannel:(PTChannel *)channel didReceiveFrameOfType:(uint32_t)type tag:(uint32_t)tag payload:(NSData *)payload {
}

- (void)ioFrameChannel:(PTChannel *)channel didAcceptConnection:(PTChannel *)otherChannel fromAddress:(PTAddress *)address {
    if (self.activeConnection) {
        if ([self.delegate respondsToSelector:@selector(listener:closeConnection:)]) {
            [self.delegate listener:self closeConnection:self.activeConnection];
            self.activeConnection = nil;
        }
    }

    PVLoopbackConnection *connection = [[PVLoopbackConnection alloc] initWithAcceptedChannel:otherChannel];
    self.activeConnection = connection;
    if ([self.delegate respondsToSelector:@selector(listener:didAcceptConnection:)]) {
        [self.delegate listener:self didAcceptConnection:connection];
    }
}

@end

//
//  PVConnection.h
//  PickView
//
//  Created by kris cheng on 2026/7/6.
//

#ifndef PVConnection_h
#define PVConnection_h

#import <Foundation/Foundation.h>
#import "PVConnectionProtocol.h"

@class PTChannel;

NS_ASSUME_NONNULL_BEGIN

@interface PVConnection : NSObject <PVConnectionProtocol> {
@protected
    PVConnectionState _state;
}

@property (nonatomic, copy, readonly) NSString *connectionIdentifier;
@property (nonatomic, assign, readonly) PVConnectionState state;
@property (nonatomic, weak, nullable) id<PVConnectionDelegate> delegate;
@property (nonatomic, strong, nullable) PTChannel *channel;

- (void)cleanupChannel;

@end

NS_ASSUME_NONNULL_END

#endif /* PVConnection_h */

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

NS_ASSUME_NONNULL_BEGIN

@interface PVConnection : NSObject <PVConnectionProtocol>

@property (nonatomic, copy, readonly) NSString *connectionIdentifier;
@property (nonatomic, assign, readonly) PVConnectionState state;
@property (nonatomic, weak, nullable) id<PVConnectionDelegate> delegate;

@end

NS_ASSUME_NONNULL_END

#endif /* PVConnection_h */

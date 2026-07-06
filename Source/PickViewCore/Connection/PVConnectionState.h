//
//  PVConnectionState.h
//  PickView
//
//  Created by kris cheng on 2026/7/6.
//

#ifndef PVConnectionState_h
#define PVConnectionState_h

typedef NS_ENUM(NSUInteger, PVConnectionState) {
    PVConnectionStateIdle,
    PVConnectionStateConnecting,
    PVConnectionStateConnected,
    PVConnectionStateClosing,
    PVConnectionStateClosed,
    PVConnectionStateFailed
};

#endif /* PVConnectionState_h */

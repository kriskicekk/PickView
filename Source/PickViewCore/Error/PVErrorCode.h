//
//  PVErrorCode.h
//  PickView
//
//  Created by kris cheng on 2026/7/6.
//

#ifndef PVErrorCode_h
#define PVErrorCode_h

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSErrorDomain const PVErrorDomain;

typedef NS_ENUM(NSInteger, PVErrorCode) {
    PVErrorCodeUnknown = -1,
    PVErrorCodeDisconnected = -100,
    PVErrorCodeTimeout = -101,
    PVErrorCodeIncompatibleVersion = -102,
    PVErrorCodeDiscarded = -103,
    PVErrorCodePeerTalk = -200,
    PVErrorCodeUnsupportedEndpoint = -300
};

#endif /* PVErrorCode_h */

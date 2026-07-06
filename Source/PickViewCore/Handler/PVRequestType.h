//
//  PVRequestType.h
//  PickView
//
//  Created by kris cheng on 2026/7/6.
//

#ifndef PVRequestType_h
#define PVRequestType_h

typedef NS_ENUM(uint32_t, PVRequestType) {
    PVRequestTypePing = 200,
    PVRequestTypeAppInfo = 201,
    PVRequestTypeHierarchy = 202,
    PVRequestTypeHierarchyDetails = 203,
    PVRequestTypeModifyAttribute = 204,
    PVRequestTypeMessage = 205,
    PVRequestTypeInvokeMethod = 206
};

#endif /* PVRequestType_h */

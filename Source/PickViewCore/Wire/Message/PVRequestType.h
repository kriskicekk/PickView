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
    PVRequestTypeAttrModificationPatch = 205,
    PVRequestTypeInvokeMethod = 206,
    PVRequestTypeFetchObject = 207,
    PVRequestTypeFetchImageViewImage = 208,
    PVRequestTypeModifyRecognizerEnable = 209,
    PVRequestTypeAllAttrGroups = 210,
    PVRequestTypeAllSelectorNames = 213,
    PVRequestTypeCustomAttrModification = 214,

    PVRequestTypeMessage = 230,
    PVRequestTypeHeartbeat = 231,
    PVRequestTypeWindowList = 232,

    PVRequestTypeCancelHierarchyDetails = 304
};

#endif /* PVRequestType_h */

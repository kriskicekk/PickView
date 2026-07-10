//
//  PVHierarchyDetailsHandler.h
//  PickViewServer
//
//  Created by kris cheng on 2026/7/9.
//

#ifndef PVHierarchyDetailsHandler_h
#define PVHierarchyDetailsHandler_h

#import "PVRequestHandlerProtocol.h"

@protocol PVHierarchyProvider;

NS_ASSUME_NONNULL_BEGIN

@interface PVHierarchyDetailsHandler : NSObject <PVRequestHandlerProtocol>

- (instancetype)initWithProvider:(id<PVHierarchyProvider>)provider NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

#endif /* PVHierarchyDetailsHandler_h */

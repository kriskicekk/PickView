//
//  PVWindowListHandler.h
//  PickViewServer
//
//  Created by kris cheng on 2026/7/9.
//

#ifndef PVWindowListHandler_h
#define PVWindowListHandler_h

#import "PVRequestHandlerProtocol.h"

@protocol PVHierarchyProvider;

NS_ASSUME_NONNULL_BEGIN

@interface PVWindowListHandler : NSObject <PVRequestHandlerProtocol>

- (instancetype)initWithProvider:(id<PVHierarchyProvider>)provider NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

#endif /* PVWindowListHandler_h */

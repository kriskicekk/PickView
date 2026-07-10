//
//  PVCompositeRequestHandler.m
//  PickViewServer
//
//  Created by kris cheng on 2026/7/6.
//

#import "PVCompositeRequestHandler.h"
#import "PVErrorCode.h"

@interface PVCompositeRequestHandler ()
@property (nonatomic, strong) NSMutableArray<id<PVRequestHandlerProtocol>> *handlers;
@end

@implementation PVCompositeRequestHandler

- (instancetype)initWithHandlers:(NSArray<id<PVRequestHandlerProtocol>> *)handlers {
    self = [super init];
    if (self) {
        _handlers = [handlers mutableCopy] ?: [NSMutableArray array];
    }
    return self;
}

- (void)addHandler:(id<PVRequestHandlerProtocol>)handler {
    if (handler) {
        [self.handlers addObject:handler];
    }
}

- (BOOL)canHandleRequestType:(uint32_t)type {
    return [self handlerForType:type] != nil;
}

- (void)handleRequestType:(uint32_t)type payload:(NSData *)payload completion:(void (^)(NSData * _Nullable, NSError * _Nullable))completion {
    id<PVRequestHandlerProtocol> handler = [self handlerForType:type];
    if (!handler) {
        NSError *error = [NSError errorWithDomain:PVErrorDomain code:PVErrorCodeUnknown userInfo:@{NSLocalizedDescriptionKey: @"No handler for request type."}];
        if (completion) completion(nil, error);
        return;
    }
    [handler handleRequestType:type payload:payload completion:completion];
}

- (id<PVRequestHandlerProtocol>)handlerForType:(uint32_t)type {
    for (id<PVRequestHandlerProtocol> handler in self.handlers) {
        if ([handler canHandleRequestType:type]) {
            return handler;
        }
    }
    return nil;
}

@end

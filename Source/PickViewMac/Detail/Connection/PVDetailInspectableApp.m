#import "PVDetailPrefix.h"

#import "PVDetailInspectableApp.h"

#import "PVAttributeModification.h"
#import "PVClientSession.h"
#import "PVCustomAttrModification.h"
#import "PVDisplayItem.h"
#import "PVDisplayItemDetail.h"
#import "PVErrorCode.h"
#import "PVHierarchyInfo.h"
#import "PVInspectionRequestClient.h"
#import "PVInspectionDefines.h"
#import "PVObject.h"
#import "PVRequestType.h"
#import "PVStaticAsyncUpdateTask.h"

@interface PVDetailInspectableApp ()

@property(nonatomic, strong) NSMutableArray<id<RACSubscriber>> *activeDetailSubscribers;
@property(nonatomic, strong) PVInspectionRequestClient *requestClient;

@end

static NSError *PVDetailUnsupportedCapabilityError(void) {
    return [NSError errorWithDomain:PVErrorDomain
                               code:PVErrorCodeUnsupportedEndpoint
                           userInfo:@{NSLocalizedDescriptionKey: @"The inspected app does not support this operation."}];
}

@implementation PVDetailInspectableApp

- (BOOL)supportsCapability:(PVPeerCapability)capability {
    PVPeerCapability capabilities = self.session.peerIdentity.capabilities;
    return capabilities == 0 || (capabilities & capability) == capability;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _activeDetailSubscribers = [NSMutableArray array];
    }
    return self;
}

- (void)setSession:(PVClientSession *)session {
    _session = session;
    self.requestClient = session ? [[PVInspectionRequestClient alloc] initWithSession:session] : nil;
}

- (RACSignal *)fetchHierarchyData {
    return [self requestWithType:PVRequestTypeHierarchy payload:nil timeoutInterval:10];
}

- (RACSignal *)submitInbuiltModification:(PVAttributeModification *)modification {
    if (![self supportsCapability:PVPeerCapabilityAttributeModification]) {
        return [RACSignal error:PVDetailUnsupportedCapabilityError()];
    }
    return [self requestWithType:PVRequestTypeModifyAttribute object:modification timeoutInterval:10];
}

- (RACSignal *)submitCustomModification:(PVCustomAttrModification *)modification {
    if (![self supportsCapability:PVPeerCapabilityCustomAttributes]) {
        return [RACSignal error:PVDetailUnsupportedCapabilityError()];
    }
    return [self requestWithType:PVRequestTypeCustomAttrModification object:modification timeoutInterval:10];
}

- (RACSignal *)fetchHierarchyDetailWithTaskPackages:(NSArray<PVStaticAsyncUpdateTasksPackage *> *)packages {
    NSUInteger taskCount = 0;
    for (PVStaticAsyncUpdateTasksPackage *package in packages) {
        taskCount += package.tasks.count;
    }
    if (taskCount == 0) {
        return [RACSignal return:@[]];
    }

    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        if (!self) {
            [subscriber sendError:PVInspectErr_NoConnect];
            return nil;
        }

        @synchronized (self) {
            [self.activeDetailSubscribers addObject:subscriber];
        }

        __block BOOL disposed = NO;
        [self.requestClient sendRequestType:PVRequestTypeHierarchyDetails
                                     object:(id<NSSecureCoding>)packages
                            timeoutInterval:15
                                 completion:^(id data, BOOL finished, NSError *error) {
            @strongify(self);
            if (!self) return;

            BOOL shouldSend = NO;
            @synchronized (self) {
                shouldSend = !disposed && [self.activeDetailSubscribers containsObject:subscriber];
                if (error || finished) {
                    [self.activeDetailSubscribers removeObject:subscriber];
                }
            }
            if (!shouldSend) {
                return;
            }

            if (error) {
                [subscriber sendError:error];
                return;
            }
            [subscriber sendNext:[data isKindOfClass:NSArray.class] ? data : @[]];
            if (finished) {
                [subscriber sendCompleted];
            }
        }];

        return [RACDisposable disposableWithBlock:^{
            disposed = YES;
            @strongify(self);
            @synchronized (self) {
                [self.activeDetailSubscribers removeObject:subscriber];
            }
        }];
    }];
}

- (void)cancelHierarchyDetailFetching {
    NSArray<id<RACSubscriber>> *subscribers = nil;
    @synchronized (self) {
        subscribers = self.activeDetailSubscribers.copy;
        [self.activeDetailSubscribers removeAllObjects];
    }
    for (id<RACSubscriber> subscriber in subscribers) {
        [subscriber sendCompleted];
    }

    [self.requestClient cancelRequestType:PVRequestTypeHierarchyDetails
                                 pushType:PVRequestTypeCancelHierarchyDetails];
}

- (RACSignal *)fetchModificationPatchWithTasks:(NSArray<PVStaticAsyncUpdateTask *> *)tasks {
    if (tasks.count == 0) {
        return [RACSignal empty];
    }
    return [self requestWithType:PVRequestTypeAttrModificationPatch object:(id<NSSecureCoding>)tasks timeoutInterval:15];
}

- (RACSignal *)fetchObjectWithOid:(unsigned long)oid {
    if (!oid) {
        return [RACSignal error:PVInspectErr_Inner];
    }
    return [self requestWithType:PVRequestTypeFetchObject object:@(oid) timeoutInterval:10];
}

- (RACSignal *)fetchSelectorNamesWithClass:(NSString *)className hasArg:(BOOL)hasArg {
    if (!className.length) {
        return [RACSignal error:PVInspectErr_Inner];
    }
    NSDictionary *params = @{@"className": className, @"hasArg": @(hasArg)};
    return [self requestWithType:PVRequestTypeAllSelectorNames object:params timeoutInterval:10];
}

- (RACSignal *)invokeMethodWithOid:(unsigned long)oid text:(NSString *)text {
    if (![self supportsCapability:PVPeerCapabilityMethodInvocation]) {
        return [RACSignal error:PVDetailUnsupportedCapabilityError()];
    }
    if (oid == 0 || !text.length) {
        return [RACSignal error:PVInspectErr_Inner];
    }
    NSDictionary *params = @{@"oid": @(oid), @"text": text};
    return [[self requestWithType:PVRequestTypeInvokeMethod object:params timeoutInterval:10] map:^id(NSDictionary *value) {
        if ([value[@"description"] isEqualToString:PVInspectStringFlag_VoidReturn]) {
            NSMutableDictionary *newValue = [value mutableCopy];
            newValue[@"description"] = NSLocalizedString(@"The method was invoked successfully and no value was returned.", nil);
            return newValue;
        }
        return value;
    }];
}

- (RACSignal *)fetchAttrGroupListWithOid:(unsigned long)oid {
    if (!oid) {
        return [RACSignal error:PVInspectErr_Inner];
    }
    return [self requestWithType:PVRequestTypeAllAttrGroups object:@(oid) timeoutInterval:10];
}

- (RACSignal *)fetchImageWithImageViewOid:(unsigned long)oid {
    if (![self supportsCapability:PVPeerCapabilityImageExtraction]) {
        return [RACSignal error:PVDetailUnsupportedCapabilityError()];
    }
    if (!oid) {
        return [RACSignal error:PVInspectErr_Inner];
    }
    return [self requestWithType:PVRequestTypeFetchImageViewImage object:@(oid) timeoutInterval:10];
}

- (RACSignal *)modifyGestureRecognizer:(unsigned long)oid toBeEnabled:(BOOL)shouldBeEnabled {
    if (![self supportsCapability:PVPeerCapabilityGestureModification]) {
        return [RACSignal error:PVDetailUnsupportedCapabilityError()];
    }
    if (!oid) {
        return [RACSignal error:PVInspectErr_Inner];
    }
    NSDictionary *params = @{@"oid": @(oid), @"enable": @(shouldBeEnabled)};
    return [self requestWithType:PVRequestTypeModifyRecognizerEnable object:params timeoutInterval:10];
}

#pragma mark - Private

- (RACSignal *)requestWithType:(uint32_t)type object:(id<NSSecureCoding>)object timeoutInterval:(NSTimeInterval)timeoutInterval {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        if (!self) {
            [subscriber sendError:PVInspectErr_NoConnect];
            return nil;
        }

        __block BOOL disposed = NO;
        [self.requestClient sendRequestType:type object:object timeoutInterval:timeoutInterval completion:^(id data, BOOL finished, NSError *error) {
            if (disposed) return;
            if (error) {
                [subscriber sendError:error];
                return;
            }
            if (data) [subscriber sendNext:data];
            if (finished) [subscriber sendCompleted];
        }];
        return [RACDisposable disposableWithBlock:^{
            disposed = YES;
        }];
    }];
}

- (RACSignal *)requestWithType:(uint32_t)type payload:(NSData *)payload timeoutInterval:(NSTimeInterval)timeoutInterval {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        if (!self) {
            [subscriber sendError:PVInspectErr_NoConnect];
            return nil;
        }

        __block BOOL disposed = NO;
        [self sendRequestWithType:type payload:payload timeoutInterval:timeoutInterval completion:^(id data, BOOL finished, NSError *error) {
            if (disposed) {
                return;
            }
            if (error) {
                [subscriber sendError:error];
                return;
            }
            if (data) {
                [subscriber sendNext:data];
            }
            if (finished) {
                [subscriber sendCompleted];
            }
        }];

        return [RACDisposable disposableWithBlock:^{
            disposed = YES;
        }];
    }];
}

- (void)sendRequestWithType:(uint32_t)type
                    payload:(NSData *)payload
            timeoutInterval:(NSTimeInterval)timeoutInterval
                 completion:(void (^)(id data, BOOL finished, NSError *error))completion {
    [self.requestClient sendRequestType:type payload:payload timeoutInterval:timeoutInterval completion:completion];
}

@end

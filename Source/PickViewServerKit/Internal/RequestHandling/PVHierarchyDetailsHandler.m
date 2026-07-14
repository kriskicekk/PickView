//
//  PVHierarchyDetailsHandler.m
//  PickViewServer
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVHierarchyDetailsHandler.h"

#import "PVArchiveCodec.h"
#import "PVAttributeModification.h"
#import "PVCustomAttrModification.h"
#import "PVDisplayItemDetail.h"
#import "PVDisplayItemDetailRequest.h"
#import "PVErrorCode.h"
#import "PVHierarchyProvider.h"
#import "PVInspectionDefines.h"
#import "PVObject.h"
#import "PVRequestType.h"
#import "PVResponseAttachment.h"
#import "PVStaticAsyncUpdateTask.h"

@interface PVHierarchyDetailsOperation : NSObject
@property (nonatomic, copy) NSArray<PVStaticAsyncUpdateTasksPackage *> *packages;
@property (nonatomic, assign) NSUInteger packageIndex;
@property (nonatomic, assign) NSUInteger totalTaskCount;
@property (atomic, assign, getter=isCancelled) BOOL cancelled;
@property (nonatomic, copy) void (^completion)(NSData * _Nullable, NSError * _Nullable);
@end

@implementation PVHierarchyDetailsOperation
@end

@interface PVHierarchyDetailsHandler ()
@property (nonatomic, strong) id<PVHierarchyProvider> provider;
@property (nonatomic, strong) NSMutableSet<PVHierarchyDetailsOperation *> *activeDetailOperations;
@property (nonatomic, strong) dispatch_queue_t detailQueue;
@end

@implementation PVHierarchyDetailsHandler

- (instancetype)initWithProvider:(id<PVHierarchyProvider>)provider {
    self = [super init];
    if (self) {
        _provider = provider;
        _activeDetailOperations = [NSMutableSet set];
        _detailQueue = dispatch_queue_create("com.pickview.hierarchy-details", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (BOOL)canHandleRequestType:(uint32_t)type {
    return type == PVRequestTypeHierarchyDetails ||
           type == PVRequestTypeModifyAttribute ||
           type == PVRequestTypeAttrModificationPatch ||
           type == PVRequestTypeInvokeMethod ||
           type == PVRequestTypeFetchObject ||
           type == PVRequestTypeFetchImageViewImage ||
           type == PVRequestTypeModifyRecognizerEnable ||
           type == PVRequestTypeAllAttrGroups ||
           type == PVRequestTypeAllSelectorNames ||
           type == PVRequestTypeCustomAttrModification ||
           type == PVRequestTypeCancelHierarchyDetails;
}

- (void)handleRequestType:(uint32_t)type
                  payload:(NSData *)payload
               completion:(void (^)(NSData * _Nullable, NSError * _Nullable))completion {
    if (type == PVRequestTypeCancelHierarchyDetails) {
        [self cancelActiveDetailOperations];
        return;
    }

    NSError *decodeError = nil;
    id request = [self objectFromPayload:payload error:&decodeError];
    if (!request) {
        [self finishWithAttachment:[PVResponseAttachment attachmentWithError:decodeError ?: [self invalidRequestError]] completion:completion];
        return;
    }

    if (type == PVRequestTypeHierarchyDetails) {
        if ([request isKindOfClass:NSArray.class]) {
            BOOL isValidPackages = YES;
            for (id package in (NSArray *)request) {
                if (![package isKindOfClass:PVStaticAsyncUpdateTasksPackage.class]) {
                    isValidPackages = NO;
                    break;
                }
            }
            if (!isValidPackages) {
                [self finishWithAttachment:[PVResponseAttachment attachmentWithError:[self invalidRequestError]] completion:completion];
                return;
            }
            [self startDetailOperationWithPackages:request completion:completion];
            return;
        } else if ([request isKindOfClass:PVDisplayItemDetailRequest.class]) {
            PVDisplayItemDetailRequest *detailRequest = request;
            if ([self.provider respondsToSelector:@selector(detailsForDisplayItemIDs:needsSoloImage:needsGroupImage:lowImageQuality:completion:)]) {
                [self.provider detailsForDisplayItemIDs:detailRequest.displayItemIDs
                                         needsSoloImage:detailRequest.needsSoloImage
                                        needsGroupImage:detailRequest.needsGroupImage
                                        lowImageQuality:detailRequest.lowImageQuality
                                             completion:^(NSArray<PVDisplayItemDetail *> *details) {
                    [self finishWithAttachment:[PVResponseAttachment attachmentWithData:details ?: @[]]
                                    completion:completion];
                }];
                return;
            }
            NSArray *details = [self.provider detailsForDisplayItemIDs:detailRequest.displayItemIDs
                                                         needsSoloImage:detailRequest.needsSoloImage
                                                        needsGroupImage:detailRequest.needsGroupImage
                                                        lowImageQuality:detailRequest.lowImageQuality] ?: @[];
            [self finishWithAttachment:[PVResponseAttachment attachmentWithData:details] completion:completion];
            return;
        } else {
            [self finishWithAttachment:[PVResponseAttachment attachmentWithError:[self invalidRequestError]] completion:completion];
            return;
        }
    }

    if (type == PVRequestTypeModifyAttribute) {
        if (![request isKindOfClass:PVAttributeModification.class]) {
            [self finishWithAttachment:[PVResponseAttachment attachmentWithError:[self invalidRequestError]] completion:completion];
            return;
        }
        NSError *operationError = nil;
        PVDisplayItemDetail *detail = [self.provider modifyAttribute:request error:&operationError];
        [self finishWithObject:detail error:operationError completion:completion];
        return;
    }

    if (type == PVRequestTypeAttrModificationPatch) {
        if (![request isKindOfClass:NSArray.class]) {
            [self finishWithAttachment:[PVResponseAttachment attachmentWithError:[self invalidRequestError]] completion:completion];
            return;
        }
        PVStaticAsyncUpdateTasksPackage *package = [[PVStaticAsyncUpdateTasksPackage alloc] init];
        package.tasks = request;
        NSArray *details = [self.provider detailsForTaskPackages:@[package] lowImageQuality:NO] ?: @[];
        if (details.count == 0) {
            [self finishWithAttachment:[PVResponseAttachment attachmentWithData:nil] completion:completion];
            return;
        }
        for (PVDisplayItemDetail *detail in details) {
            PVResponseAttachment *attachment = [PVResponseAttachment attachmentWithData:detail];
            attachment.dataTotalCount = details.count;
            attachment.currentDataCount = 1;
            [self finishWithAttachment:attachment completion:completion];
        }
        return;
    }

    if (type == PVRequestTypeFetchObject) {
        NSError *operationError = nil;
        PVObject *object = [self.provider objectWithOid:[request unsignedLongValue] error:&operationError];
        [self finishWithObject:object error:operationError completion:completion];
        return;
    }

    if (type == PVRequestTypeAllAttrGroups) {
        NSError *operationError = nil;
        NSArray *groups = [self.provider attributesForObjectWithOid:[request unsignedLongValue] error:&operationError];
        [self finishWithObject:groups error:operationError completion:completion];
        return;
    }

    if (type == PVRequestTypeFetchImageViewImage) {
        NSError *operationError = nil;
        NSData *imageData = [self.provider imageDataForImageViewWithOid:[request unsignedLongValue] error:&operationError];
        [self finishWithObject:imageData error:operationError completion:completion];
        return;
    }

    if (type == PVRequestTypeAllSelectorNames) {
        if (![request isKindOfClass:NSDictionary.class]) {
            [self finishWithAttachment:[PVResponseAttachment attachmentWithError:[self invalidRequestError]] completion:completion];
            return;
        }
        NSDictionary *params = request;
        NSError *operationError = nil;
        NSArray *names = [self.provider selectorNamesForClassName:params[@"className"]
                                                           hasArg:[params[@"hasArg"] boolValue]
                                                            error:&operationError];
        [self finishWithObject:names error:operationError completion:completion];
        return;
    }

    if (type == PVRequestTypeInvokeMethod) {
        if (![request isKindOfClass:NSDictionary.class]) {
            [self finishWithAttachment:[PVResponseAttachment attachmentWithError:[self invalidRequestError]] completion:completion];
            return;
        }
        NSDictionary *params = request;
        NSError *operationError = nil;
        NSDictionary *result = [self.provider invokeMethodWithOid:[params[@"oid"] unsignedLongValue]
                                                              text:params[@"text"]
                                                             error:&operationError];
        [self finishWithObject:result error:operationError completion:completion];
        return;
    }

    if (type == PVRequestTypeModifyRecognizerEnable) {
        if (![request isKindOfClass:NSDictionary.class]) {
            [self finishWithAttachment:[PVResponseAttachment attachmentWithError:[self invalidRequestError]] completion:completion];
            return;
        }
        NSDictionary *params = request;
        NSError *operationError = nil;
        NSNumber *enabled = [self.provider modifyGestureRecognizerWithOid:[params[@"oid"] unsignedLongValue]
                                                                  enabled:[params[@"enable"] boolValue]
                                                                    error:&operationError];
        [self finishWithObject:enabled error:operationError completion:completion];
        return;
    }

    if (type == PVRequestTypeCustomAttrModification) {
        if (![request isKindOfClass:PVCustomAttrModification.class]) {
            [self finishWithAttachment:[PVResponseAttachment attachmentWithError:[self invalidRequestError]] completion:completion];
            return;
        }
        NSError *operationError = nil;
        BOOL success = [self.provider modifyCustomAttribute:request error:&operationError];
        [self finishWithObject:@(success) error:operationError completion:completion];
        return;
    }

    [self finishWithAttachment:[PVResponseAttachment attachmentWithError:[self invalidRequestError]] completion:completion];
}

- (void)startDetailOperationWithPackages:(NSArray<PVStaticAsyncUpdateTasksPackage *> *)packages
                              completion:(void (^)(NSData * _Nullable, NSError * _Nullable))completion {
    PVHierarchyDetailsOperation *operation = [[PVHierarchyDetailsOperation alloc] init];
    operation.packages = packages.copy;
    operation.completion = completion;
    for (PVStaticAsyncUpdateTasksPackage *package in packages) {
        operation.totalTaskCount += package.tasks.count;
    }

    if (operation.totalTaskCount == 0) {
        [self finishWithAttachment:[PVResponseAttachment attachmentWithData:@[]] completion:completion];
        return;
    }

    @synchronized (self) {
        [self.activeDetailOperations addObject:operation];
    }
    dispatch_async(self.detailQueue, ^{
        [self processDetailOperation:operation];
    });
}

- (void)processDetailOperation:(PVHierarchyDetailsOperation *)operation {
    if (operation.isCancelled || operation.packageIndex >= operation.packages.count) {
        [self finishDetailOperation:operation];
        return;
    }

    PVStaticAsyncUpdateTasksPackage *package = operation.packages[operation.packageIndex];
    operation.packageIndex += 1;
    if ([self.provider respondsToSelector:@selector(detailsForTaskPackages:lowImageQuality:completion:)]) {
        [self.provider detailsForTaskPackages:@[package]
                              lowImageQuality:NO
                                   completion:^(NSArray<PVDisplayItemDetail *> *details) {
            if (!operation.isCancelled) {
                PVResponseAttachment *attachment = [PVResponseAttachment attachmentWithData:details ?: @[]];
                attachment.dataTotalCount = operation.totalTaskCount;
                attachment.currentDataCount = MAX(details.count, package.tasks.count);
                [self finishWithAttachment:attachment completion:operation.completion];
            }
            dispatch_async(self.detailQueue, ^{
                [self processDetailOperation:operation];
            });
        }];
        return;
    }
    NSArray<PVDisplayItemDetail *> *details = [self.provider detailsForTaskPackages:@[package] lowImageQuality:NO] ?: @[];
    if (!operation.isCancelled) {
        PVResponseAttachment *attachment = [PVResponseAttachment attachmentWithData:details];
        attachment.dataTotalCount = operation.totalTaskCount;
        attachment.currentDataCount = MAX(details.count, package.tasks.count);
        [self finishWithAttachment:attachment completion:operation.completion];
    }

    dispatch_async(self.detailQueue, ^{
        [self processDetailOperation:operation];
    });
}

- (void)finishDetailOperation:(PVHierarchyDetailsOperation *)operation {
    @synchronized (self) {
        [self.activeDetailOperations removeObject:operation];
    }
}

- (void)cancelActiveDetailOperations {
    @synchronized (self) {
        for (PVHierarchyDetailsOperation *operation in self.activeDetailOperations) {
            operation.cancelled = YES;
        }
        [self.activeDetailOperations removeAllObjects];
    }
}

- (id)requestFromPayload:(NSData *)payload error:(NSError **)error {
    if (!payload.length) {
        return nil;
    }

    id object = [PVArchiveCodec unarchivedObjectFromData:payload
                                          allowedClasses:[PVArchiveCodec defaultAllowedClasses]
                                                   error:error];
    if ([object isKindOfClass:NSArray.class]) {
        BOOL isValidPackages = YES;
        for (id package in (NSArray *)object) {
            if (![package isKindOfClass:PVStaticAsyncUpdateTasksPackage.class]) {
                isValidPackages = NO;
                break;
            }
        }
        return isValidPackages ? object : nil;
    }
    if ([object isKindOfClass:PVDisplayItemDetailRequest.class]) {
        return object;
    }
    return nil;
}

- (id)objectFromPayload:(NSData *)payload error:(NSError **)error {
    if (!payload.length) {
        return nil;
    }
    return [PVArchiveCodec unarchivedObjectFromData:payload
                                    allowedClasses:[PVArchiveCodec defaultAllowedClasses]
                                             error:error];
}

- (void)finishWithObject:(id<NSSecureCoding>)object
                   error:(NSError *)error
              completion:(void (^)(NSData * _Nullable, NSError * _Nullable))completion {
    PVResponseAttachment *attachment = error ? [PVResponseAttachment attachmentWithError:error] : [PVResponseAttachment attachmentWithData:object];
    [self finishWithAttachment:attachment completion:completion];
}

- (void)finishWithAttachment:(PVResponseAttachment *)attachment
                  completion:(void (^)(NSData * _Nullable, NSError * _Nullable))completion {
    NSError *archiveError = nil;
    NSData *data = [PVArchiveCodec archivedDataWithObject:attachment error:&archiveError];
    if (completion) completion(data, archiveError);
}

- (NSError *)invalidRequestError {
    return [NSError errorWithDomain:PVErrorDomain
                               code:PVErrorCodeUnknown
                           userInfo:@{NSLocalizedDescriptionKey: @"Invalid hierarchy details request."}];
}

- (NSError *)unsupportedRequestErrorWithName:(NSString *)name {
    NSString *message = [NSString stringWithFormat:@"%@ is not supported yet.", name ?: @"Operation"];
    return PVInspectErrorMake(message, @"PickView server has not implemented this PickView detail capability yet.");
}

@end

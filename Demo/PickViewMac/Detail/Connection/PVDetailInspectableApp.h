//
//  PVDetailInspectableApp.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import <Foundation/Foundation.h>
#import "PVAppInfo.h"
#import "PVAttributeModification.h"
#import "PVCustomAttrModification.h"
#import "PVAttributesGroup.h"

@class PVClientChannel, PVClientSession, PVDisplayItemTrace, PVInvocationRequest, PVHierarchyInfo, PVStaticAsyncUpdateTasksPackage, PVStaticAsyncUpdateTask;

@interface PVDetailInspectableApp : NSObject

@property(nonatomic, strong) NSError *serverVersionError;

@property(nonatomic, strong) PVAppInfo *appInfo;

@property(nonatomic, weak) PVClientChannel *channel;
@property(nonatomic, strong) PVClientSession *session;

- (RACSignal *)fetchHierarchyData;

- (RACSignal *)submitInbuiltModification:(PVAttributeModification *)modification;
- (RACSignal *)submitCustomModification:(PVCustomAttrModification *)modification;

- (RACSignal *)fetchHierarchyDetailWithTaskPackages:(NSArray<PVStaticAsyncUpdateTasksPackage *> *)packages;
- (void)cancelHierarchyDetailFetching;

- (RACSignal *)fetchModificationPatchWithTasks:(NSArray<PVStaticAsyncUpdateTask *> *)tasks;

- (RACSignal *)fetchObjectWithOid:(unsigned long)oid;

- (RACSignal *)fetchSelectorNamesWithClass:(NSString *)className hasArg:(BOOL)hasArg;

- (RACSignal *)invokeMethodWithOid:(unsigned long)oid text:(NSString *)text;

- (RACSignal *)fetchAttrGroupListWithOid:(unsigned long)oid;

/// 获取某个 imageView 的 image 对象，oid 是 imageView 的 oid
- (RACSignal *)fetchImageWithImageViewOid:(unsigned long)oid;

/// 修改一个 gestureRecognizer 的 enable 属性。如果 shouldBeEnabled 为 YES 则表示想要把它的 enable 属性修改为 YES
- (RACSignal *)modifyGestureRecognizer:(unsigned long)oid toBeEnabled:(BOOL)shouldBeEnabled;

#pragma mark - Push From iOS

@end

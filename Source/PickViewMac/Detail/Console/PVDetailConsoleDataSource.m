//
//  PVDetailConsoleDataSource.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailConsoleDataSource.h"
#import "PVDetailConsoleDataSourceRowItem.h"
#import "PVDetailStaticHierarchyDataSource.h"
#import "PVDisplayItem.h"
#import "PVDetailAppsManager.h"
#import "PVDetailPreferenceManager.h"

@interface PVDetailConsoleDataSource ()

/**
 @{
     @"UIView": @{
         @"selector": @[@"layoutSubviews", ...],
         @"ivar": @[@"_name", ...]
     },
     @"UIViewController": @{
         @"selector": @[@"viewDidAppear:", ...],
         @"ivar": @[@"_didAppear", ...]
     },
     ...
 };
 */
@property(nonatomic, strong) NSMutableDictionary<NSString *, NSArray<NSString *> *> *classesToSelsDict;
@property(nonatomic, strong, readwrite) PVObject *currentObject;
@property(nonatomic, strong, readwrite) NSArray<PVObject *> *selectedObjects;

@end

@implementation PVDetailConsoleDataSource

- (instancetype)initWithHierarchyDataSource:(PVDetailHierarchyDataSource *)hierarchyDataSource {
    if (self = [self init]) {
        self.classesToSelsDict = [NSMutableDictionary dictionary];
        
        PVDetailConsoleDataSourceRowItem *item = [PVDetailConsoleDataSourceRowItem new];
        item.type = PVDetailConsoleDataSourceRowItemTypeInput;
        self.rowItems = @[item];
        
        RAC(self, selectedObjects) = [RACObserve(hierarchyDataSource, selectedItem)
                                      map:^id _Nullable(PVDisplayItem *item) {
                                          if (!item) {
                                              return nil;
                                          }
                                          NSArray<PVObject *> *objs = $(item.hostViewControllerObject, item.layerObject, item.viewObject).array;
                                          return objs;
                                      }];
    }
    return self;
}

- (RACSignal *)submit:(NSString *)text {
    return [self submitWithObj:self.currentObject text:text];
}

- (RACSignal *)submitWithObj:(PVObject *)obj text:(NSString *)text {
    if (!self.currentObject) {
        return [RACSignal error:PVInspectErr_Inner];
    }
    if (!text.length) {
        return [RACSignal error:PVInspectErrorMake(NSLocalizedString(@"Content is empty.", nil), @"")];
    }
    if (![PVDetailAppsManager sharedInstance].inspectingApp) {
        return [RACSignal error:PVInspectErr_NoConnect];
    }
    if ([text containsString:@":"]) {
        NSString *className = obj.rawClassName;
        NSString *address = obj.memoryAddress;
        NSString *errDesc = [NSString stringWithFormat:NSLocalizedString(@"You can click \"Pause\" button near the bottom-left corner in Xcode to pause your iOS app, and input in Xcode console like the contents below:\nexpr [((%@ *)%@) %@]", nil), className, address, text];
        return [RACSignal error:PVInspectErrorMake(NSLocalizedString(@"PickView doesn't support invoking methods with arguments yet.", nil), errDesc)];
    }
    if ([text containsString:@"."]) {
        return [RACSignal error:PVInspectErrorMake(NSLocalizedString(@"PickView doesn't support this syntax yet. Please input a method or property name.", nil), @"")];
    }
    @weakify(self);
    return [[[PVDetailAppsManager sharedInstance].inspectingApp invokeMethodWithOid:obj.oid text:text] doNext:^(NSDictionary *dict) {
        NSString *returnDescription = dict[@"description"];
        PVObject *returnObject = dict[@"object"];

        @strongify(self);
        NSMutableArray<PVDetailConsoleDataSourceRowItem *> *rowItems = self.rowItems.mutableCopy;
        [rowItems insertObject:({
            PVDetailConsoleDataSourceRowItem *item = [PVDetailConsoleDataSourceRowItem new];
            item.type = PVDetailConsoleDataSourceRowItemTypeSubmit;
            item.normalText = text;
            item.highlightText = [NSString stringWithFormat:@"<%@: %@>", obj.lk_simpleDemangledClassName, obj.memoryAddress];
            item;
        }) atIndex:(rowItems.count - 1)];
        if (returnDescription.length) {
            [rowItems insertObject:({
                PVDetailConsoleDataSourceRowItem *item = [PVDetailConsoleDataSourceRowItem new];
                item.type = PVDetailConsoleDataSourceRowItemTypeReturn;
                item.normalText = returnDescription;
                item;
            }) atIndex:(rowItems.count - 1)];
        }
        if (returnObject) {
            NSString *message = [NSString stringWithFormat:@"<%@: %@> => %@", obj.lk_simpleDemangledClassName, obj.memoryAddress, text];
            [self _addRecentObject:returnObject message:message];
        }
        
        self.rowItems = rowItems;
    }];
}

- (RACSignal *)makeObjectAsCurrent:(PVObject *)obj {
    NSString *className = obj.rawClassName;
    if (!className.length) {
        return [RACSignal error:PVInspectErr_Inner];
    }
    if (![PVDetailAppsManager sharedInstance].inspectingApp) {
        return [RACSignal error:PVInspectErr_NoConnect];
    }
    if ([self.classesToSelsDict objectForKey:className]) {
        self.currentObject = obj;
        return [RACSignal return:nil];
    }
    
    @weakify(self);
    return [[[PVDetailAppsManager sharedInstance].inspectingApp fetchSelectorNamesWithClass:obj.rawClassName hasArg:YES] doNext:^(NSArray<NSString *> *sels) {
        @strongify(self);
        self.classesToSelsDict[className] = sels;
        self.currentObject = obj;
    }];
}

- (NSArray<NSString *> *)currentObjectSelectorNameList {
    return self.classesToSelsDict[self.currentObject.rawClassName];
}

- (void)clearHistoryContents {
    PVDetailConsoleDataSourceRowItem *item = [PVDetailConsoleDataSourceRowItem new];
    item.type = PVDetailConsoleDataSourceRowItemTypeInput;
    self.rowItems = @[item];
}

- (void)setSelectedObjects:(NSArray<PVObject *> *)selectedObjects {
    _selectedObjects = selectedObjects.copy;
    [self _syncConsoleTargetIfNeeded];
}

- (void)setIsShowingConsole:(BOOL)isShowingConsole {
    _isShowingConsole = isShowingConsole;
    [self _syncConsoleTargetIfNeeded];
}

- (void)_syncConsoleTargetIfNeeded {
    if (self.isShowingConsole && self.selectedObjects.count) {
        if ([PVDetailPreferenceManager mainManager].syncConsoleTarget || !self.currentObject) {
            [[self makeObjectAsCurrent:self.selectedObjects.lastObject] subscribeNext:^(id  _Nullable x) {
                
            } error:^(NSError * _Nullable error) {
                
            }];
        }
    }
}

- (void)_addRecentObject:(PVObject *)object message:(NSString *)message {
    if (!object) {
        return;
    }
    NSUInteger sameObjIdx = [self.recentObjects indexOfObjectPassingTest:^BOOL(RACTwoTuple * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return ((PVObject *)obj.first).oid == object.oid;
    }];
    if (sameObjIdx != NSNotFound) {
        [self.recentObjects removeObjectAtIndex:sameObjIdx];
    }
    
    NSUInteger maxCount = 5;
    if (!self.recentObjects) {
        _recentObjects = [NSMutableArray arrayWithCapacity:maxCount];
    }
    
    RACTwoTuple *newTuple = [RACTwoTuple tupleWithObjectsFromArray:@[object, message]];
    [self.recentObjects insertObject:newTuple atIndex:0];
    
    if (self.recentObjects.count > maxCount) {
        [self.recentObjects removeLastObject];
    }
}

@end

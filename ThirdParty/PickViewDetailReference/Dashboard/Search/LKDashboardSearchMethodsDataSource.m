//
//  LKDashboardSearchMethodsDataSource.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "LKDashboardSearchMethodsDataSource.h"
#import "LKAppsManager.h"

@interface LKDashboardSearchMethodsDataSource ()

/**
 @{
 @"UIView": @[@"layoutSubviews", @"addSubview:", ...],
 @"UIViewController": @[@"viewDidAppear:", ...],
 ...
 };
 */
@property(nonatomic, strong) NSMutableDictionary<NSString *, NSArray<NSString *> *> *classesToSelsDict;

@end

@implementation LKDashboardSearchMethodsDataSource

- (instancetype)init {
    if (self = [super init]) {
        self.classesToSelsDict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (RACSignal *)fetchNonArgMethodsListWithClass:(NSString *)className {
    if (!className.length) {
        return [RACSignal error:PickViewErr_Inner];
    }
    if (![LKAppsManager sharedInstance].inspectingApp) {
        return [RACSignal error:PickViewErr_NoConnect];
    }
    if ([self.classesToSelsDict objectForKey:className]) {
        return [RACSignal return:self.classesToSelsDict[className]];
    }
    
    @weakify(self);
    return [[[LKAppsManager sharedInstance].inspectingApp fetchSelectorNamesWithClass:className hasArg:NO] doNext:^(NSArray<NSString *> *sels) {
        @strongify(self);
        self.classesToSelsDict[className] = sels;
    }];
}

- (void)clearAllCache {
    [self.classesToSelsDict removeAllObjects];
}

@end

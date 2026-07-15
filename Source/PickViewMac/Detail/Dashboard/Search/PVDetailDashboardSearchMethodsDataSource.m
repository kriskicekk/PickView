//
//  PVDetailDashboardSearchMethodsDataSource.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailDashboardSearchMethodsDataSource.h"
#import "PVDetailAppsManager.h"

@interface PVDetailDashboardSearchMethodsDataSource ()

/**
 @{
 @"UIView": @[@"layoutSubviews", @"addSubview:", ...],
 @"UIViewController": @[@"viewDidAppear:", ...],
 ...
 };
 */
@property(nonatomic, strong) NSMutableDictionary<NSString *, NSArray<NSString *> *> *classesToSelsDict;

@end

@implementation PVDetailDashboardSearchMethodsDataSource

- (instancetype)init {
    if (self = [super init]) {
        self.classesToSelsDict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (RACSignal *)fetchNonArgMethodsListWithClass:(NSString *)className {
    if (!className.length) {
        return [RACSignal error:PVInspectErr_Inner];
    }
    if (![PVDetailAppsManager sharedInstance].inspectingApp) {
        return [RACSignal error:PVInspectErr_NoConnect];
    }
    if ([self.classesToSelsDict objectForKey:className]) {
        return [RACSignal return:self.classesToSelsDict[className]];
    }
    
    @weakify(self);
    return [[[PVDetailAppsManager sharedInstance].inspectingApp fetchSelectorNamesWithClass:className hasArg:NO] doNext:^(NSArray<NSString *> *sels) {
        @strongify(self);
        self.classesToSelsDict[className] = sels;
    }];
}

- (void)clearAllCache {
    [self.classesToSelsDict removeAllObjects];
}

@end

//
//  LKDashboardSearchMethodsDataSource.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import <Foundation/Foundation.h>

@interface LKDashboardSearchMethodsDataSource : NSObject

- (RACSignal *)fetchNonArgMethodsListWithClass:(NSString *)className;

- (void)clearAllCache;

@end

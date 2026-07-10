//
//  PVDetailDashboardSearchMethodsDataSource.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import <Foundation/Foundation.h>

@interface PVDetailDashboardSearchMethodsDataSource : NSObject

- (RACSignal *)fetchNonArgMethodsListWithClass:(NSString *)className;

- (void)clearAllCache;

@end

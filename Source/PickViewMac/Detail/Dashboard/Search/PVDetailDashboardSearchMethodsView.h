//
//  PVDetailDashboardSearchMethodsView.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailDashboardSearchCardView.h"

@class PVDetailDashboardSearchMethodsView;

@protocol PVDetailDashboardSearchMethodsViewDelegate <NSObject>

- (void)dashboardSearchMethodsView:(PVDetailDashboardSearchMethodsView *)view requestToInvokeMethod:(NSString *)method oid:(unsigned long)oid;

@end

@interface PVDetailDashboardSearchMethodsView : PVDetailDashboardSearchCardView

@property(nonatomic, weak) id<PVDetailDashboardSearchMethodsViewDelegate> delegate;

- (void)renderWithMethods:(NSArray<NSString *> *)methods oid:(unsigned long)oid;

- (void)renderWithError:(NSError *)error;

@end

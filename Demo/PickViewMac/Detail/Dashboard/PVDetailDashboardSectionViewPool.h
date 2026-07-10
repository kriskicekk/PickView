//
//  PVDetailDashboardSectionViewPool.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import <Foundation/Foundation.h>
#import "PVAttributesSection.h"
#import "PVDetailDashboardSectionView.h"

NS_ASSUME_NONNULL_BEGIN

@interface PVDetailDashboardSectionViewPool : NSObject

- (void)recycleAll;

- (PVDetailDashboardSectionView *)dequeViewForSection:(PVAttributesSection *)section;

@end

NS_ASSUME_NONNULL_END

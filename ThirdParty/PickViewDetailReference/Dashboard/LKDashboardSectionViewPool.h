//
//  LKDashboardSectionViewPool.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import <Foundation/Foundation.h>
#import "PVAttributesSection.h"
#import "LKDashboardSectionView.h"

NS_ASSUME_NONNULL_BEGIN

@interface LKDashboardSectionViewPool : NSObject

- (void)recycleAll;

- (LKDashboardSectionView *)dequeViewForSection:(PVAttributesSection *)section;

@end

NS_ASSUME_NONNULL_END

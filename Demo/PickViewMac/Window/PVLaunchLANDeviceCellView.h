//
//  PVLaunchLANDeviceCellView.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/10.
//

#import <Cocoa/Cocoa.h>

@class PVLANSessionCellModel;

NS_ASSUME_NONNULL_BEGIN

@interface PVLaunchLANDeviceCellView : NSView

- (void)configureWithModel:(PVLANSessionCellModel *)model
                       row:(NSInteger)row
                    target:(nullable id)target
                    action:(nullable SEL)action;

@end

NS_ASSUME_NONNULL_END

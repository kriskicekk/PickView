//
//  PVLaunchDeviceCellView.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import <Cocoa/Cocoa.h>

@class PVClientSession;

NS_ASSUME_NONNULL_BEGIN

@interface PVLaunchDeviceCellView : NSControl

- (void)configureWithSession:(PVClientSession *)session
                previewImage:(nullable NSImage *)previewImage
                         row:(NSInteger)row
                      target:(nullable id)target
                      action:(nullable SEL)action;

@end

NS_ASSUME_NONNULL_END

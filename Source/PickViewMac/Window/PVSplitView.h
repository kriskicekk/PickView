//
//  PVSplitView.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface PVSplitView : NSSplitView

@property (nonatomic, copy, nullable) void (^didFinishFirstLayout)(PVSplitView *view);

@end

NS_ASSUME_NONNULL_END

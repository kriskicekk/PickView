//
//  PVDetailSplitView.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import <Cocoa/Cocoa.h>

@interface PVDetailSplitView : NSSplitView

@property(nonatomic, copy) void (^didFinishFirstLayout)(PVDetailSplitView *view);

@end

//
//  LKSplitView.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import <Cocoa/Cocoa.h>

@interface LKSplitView : NSSplitView

@property(nonatomic, copy) void (^didFinishFirstLayout)(LKSplitView *view);

@end

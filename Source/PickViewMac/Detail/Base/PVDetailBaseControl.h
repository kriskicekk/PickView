//
//  PVDetailBaseControl.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import <Cocoa/Cocoa.h>

@interface PVDetailBaseControl : NSControl

@property(nonatomic, assign) SEL clickAction;

- (void)triggerClickAction;

- (void)addTarget:(id)target clickAction:(SEL)action;

@property(nonatomic, assign) BOOL adjustAlphaWhenClick;

@property(nonatomic, copy) void (^didChangeAppearance)(PVDetailBaseControl *control, BOOL isDarkMode);

@end

@interface PVDetailBaseControl (NSSubclassingHooks)

/// 如果子类返回 YES，则 mouseEntered: 和 mouseExited: 会被调用。默认为 NO
- (BOOL)shouldTrackMouseEnteredAndExited;

@end

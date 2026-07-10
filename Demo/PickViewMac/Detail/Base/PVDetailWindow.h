//
//  PVDetailWindow.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import <Cocoa/Cocoa.h>

@class PVDetailPanelContentView;

@interface PVDetailWindow : NSWindow

+ (instancetype)panelWindowWithWidth:(CGFloat)width height:(CGFloat)height contentView:(PVDetailPanelContentView *)contentView;

@end

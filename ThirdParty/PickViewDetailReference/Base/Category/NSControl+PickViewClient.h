//
//  NSControl+PickViewClient.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import <AppKit/AppKit.h>
#import <Cocoa/Cocoa.h>

@interface NSControl (PickViewClient)

- (CGFloat)heightForWidth:(CGFloat)width;

- (CGFloat)bestHeight;

- (CGFloat)bestWidth;

- (NSSize)bestSize;

@end

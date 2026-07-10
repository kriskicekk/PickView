//
//  NSButton+PVClient.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "NSButton+PVClient.h"

@implementation NSButton (PVClient)

+ (instancetype)lk_normalButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action {
    NSButton *button = [NSButton new];
    button.bezelStyle = NSBezelStyleRounded;
    button.title = title;
    button.font = [NSFont systemFontOfSize:13];
    button.target = target;
    button.action = action;
    button.frame = NSMakeRect(0, 0, 84, 40);
    return button;
}

+ (instancetype)lk_buttonWithImage:(NSImage *)image target:(id)target action:(SEL)action {
    NSButton *button = [NSButton new];
    button.image = image;
    button.bezelStyle = NSBezelStyleRoundRect;
    button.bordered = NO;
    button.target = target;
    button.action = action;
    return button;
}

@end

//
//  PVDetailConsoleSubmitRowView.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailConsoleSubmitRowView.h"

@implementation PVDetailConsoleSubmitRowView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        self.titleLabel.selectable = YES;
        self.titleLabel.font = NSFontMake(13);

        self.subtitleLabel.selectable = YES;        
        self.subtitleLabel.textColor = [NSColor labelColor];
        self.subtitleLabel.font = NSFontMake(13);
        
//        self.layer.borderColor = [NSColor blueColor].CGColor;
//        self.layer.borderWidth = 1;
    }
    return self;
}

- (void)layout {
    [super layout];
    NSSize titleSize = [self.titleLabel sizeThatFits:NSSizeMax];
    titleSize.width = MIN(titleSize.width, self.$width * .5);
    $(self.titleLabel).x(ConsoleInsetLeft).width(titleSize.width).height(titleSize.height).verAlign;
    $(self.subtitleLabel).x(self.titleLabel.$maxX + 5).toRight(ConsoleInsetRight).heightToFit.verAlign;
}

- (void)setIsDarkMode:(BOOL)isDarkMode {
    [super setIsDarkMode:isDarkMode];
    self.titleLabel.textColor = isDarkMode ? PVColorMake(85, 200, 95) : PVColorMake(54, 155, 62);
}

@end

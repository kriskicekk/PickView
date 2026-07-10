//
//  PVDetailBaseView.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailBaseView.h"

@interface PVDetailBaseView ()

@property(nonatomic, strong) CALayer *customBorderLayer;
@property(nonatomic, strong) PVDetailVisualEffectView *backgroundEffectView;

@end

@implementation PVDetailBaseView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        self.wantsLayer = YES;
        
        self.borderColors = PVDetailColorsCombine(SeparatorLightModeColor, SeparatorDarkModeColor);
        
//        self.layer.borderWidth = 1;
//        self.layer.borderColor = [NSColor redColor].CGColor;
    }
    return self;
}

- (BOOL)isVisible {
    BOOL isVisible = self.superview && !self.hidden && self.alphaValue >= 0.01;
    return isVisible;
}

- (void)setBackgroundColor:(NSColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    self.layer.backgroundColor = backgroundColor.CGColor;
}

- (void)setBackgroundColors:(PVDetailTwoColors *)backgroundColors {
    _backgroundColors = backgroundColors;
    [self updateColors];
}

- (void)setBorderColors:(PVDetailTwoColors *)borderColors {
    _borderColors = borderColors;
    [self updateColors];
}

- (void)setBorderPosition:(PVDetailViewBorderPosition)borderPosition {
    _borderPosition = borderPosition;
    if (borderPosition == PVDetailViewBorderPositionNone) {
        [self.customBorderLayer removeFromSuperlayer];
        return;
    }
    if (!self.customBorderLayer) {
        self.customBorderLayer = [CALayer layer];
        [self.customBorderLayer pv_inspect_removeImplicitAnimations];
        [self updateColors];
        [self.layer addSublayer:self.customBorderLayer];
    }
    [self setNeedsLayout:YES];
}

- (BOOL)isFlipped {
    return YES;
}

- (NSView *)hitTest:(NSPoint)point {
    if (self.hidden || self.alphaValue <= 0) {
        return nil;
    }
    return [super hitTest:point];
}

- (void)layout {
    [super layout];
    
    if (self.backgroundEffectView) {
        $(self.backgroundEffectView).fullFrame;        
    }
    
    if (self.tooltipString) {
        [self addToolTipRect:self.bounds owner:self userData:nil];
    } else {
        [self removeAllToolTips];
    }
    
    switch (self.borderPosition) {
        case PVDetailViewBorderPositionNone:
            break;
        case PVDetailViewBorderPositionTop:
            $(self.customBorderLayer).fullWidth.height(1).y(0);
            break;
        case PVDetailViewBorderPositionLeft:
            $(self.customBorderLayer).fullHeight.width(1).x(0);
            break;
        case PVDetailViewBorderPositionBottom:
            $(self.customBorderLayer).fullFrame.height(1).bottom(0);
            break;
        case PVDetailViewBorderPositionRight:
            $(self.customBorderLayer).fullHeight.width(1).right(0);
            break;
    }
    
    if (self.didLayout) {
        self.didLayout();
    }
}

- (NSString *)view:(NSView *)view stringForToolTip:(NSToolTipTag)tag point:(NSPoint)point userData:(void *)data {
    return self.tooltipString;
}

- (void)setTooltipString:(NSString *)tooltipString {
    _tooltipString = tooltipString;
    if (tooltipString) {
        [self addToolTipRect:self.bounds owner:self userData:nil];
    } else {
        [self removeAllToolTips];
    }
}

- (CGFloat)heightForWidth:(CGFloat)width {
    CGFloat height = [self sizeThatFits:NSMakeSize(width, CGFLOAT_MAX)].height;
    return height;
}

- (void)updateLayer {
    [super updateLayer];
    if (self.backgroundColorName) {
        self.layer.backgroundColor = [NSColor colorNamed:self.backgroundColorName].CGColor;
    }
}

- (void)viewDidChangeEffectiveAppearance {
    [self _triggerDidChangeAppearanceBlock];
}

- (void)setDidChangeAppearanceBlock:(void (^)(PVDetailBaseView *, BOOL))didChangeAppearance {
    _didChangeAppearanceBlock = didChangeAppearance;
    [self _triggerDidChangeAppearanceBlock];
}

- (void)_triggerDidChangeAppearanceBlock {
    if (self.didChangeAppearanceBlock) {
        self.didChangeAppearanceBlock(self, [self isDarkMode]);
    }
    [self updateColors];
}

- (void)updateColors {
    if (self.backgroundColors) {
        self.layer.backgroundColor = self.backgroundColors.color.CGColor;
    }
    if (self.borderColors) {
        self.layer.borderColor = self.borderColors.color.CGColor;
        self.customBorderLayer.backgroundColor = self.borderColors.color.CGColor;
    }
}

- (BOOL)isDarkMode {
    return [self.effectiveAppearance lk_isDarkMode];
}

- (void)setHasEffectedBackground:(BOOL)hasEffectedBackground {
    _hasEffectedBackground = hasEffectedBackground;
    if (hasEffectedBackground) {
        if (self.backgroundEffectView) {
            return;
        }
        self.backgroundEffectView = [PVDetailVisualEffectView new];
        self.backgroundEffectView.blendingMode = NSVisualEffectBlendingModeWithinWindow;
        self.backgroundEffectView.state = NSVisualEffectStateActive;
        [self lk_insertSubviewAtBottom:self.backgroundEffectView];
        [self setNeedsLayout:YES];
    } else {
        [self.backgroundEffectView removeFromSuperview];
        self.backgroundEffectView = nil;
    }
}

@end

@implementation PVDetailBaseView (SubslassingHooks)

- (NSSize)sizeThatFits:(NSSize)limitedSize {
    return NSZeroSize;
}

- (void)sizeToFit {
}

@end

@implementation PVDetailVisualEffectView

- (BOOL)isFlipped {
    return YES;
}

@end

//
//  PVDetailTableRowView.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailTableRowView.h"
#import "PVInspectionDefines.h"

@interface PVDetailTableRowView ()

@property(nonatomic, strong) CALayer *backgroundColorLayer;

@property(nonatomic, assign, readwrite) BOOL isDarkMode;

@end

@implementation PVDetailTableRowView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        self.wantsLayer = YES;
        
        self.backgroundColorLayer = [CALayer layer];
        [self.backgroundColorLayer pv_inspect_removeImplicitAnimations];
        [self.layer addSublayer:self.backgroundColorLayer];
        
        _titleLabel = [PVDetailLabel new];
        self.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [self addSubview:self.titleLabel];
        
        _subtitleLabel = [PVDetailLabel new];
        [self addSubview:self.subtitleLabel];
        
        self.isDarkMode = self.effectiveAppearance.lk_isDarkMode;
        
        [self _updateBackgroundLayerColor];
    }
    return self;
}

- (void)layout {
    [super layout];
    $(self.backgroundColorLayer).fullFrame;
}

- (BOOL)isFlipped {
    return YES;
}

- (void)viewDidChangeEffectiveAppearance {
    [super viewDidChangeEffectiveAppearance];
    self.isDarkMode = self.effectiveAppearance.lk_isDarkMode;
    [self _updateBackgroundLayerColor];
}

- (void)setIsSelected:(BOOL)isSelected {
    if (_isSelected == isSelected) {
        return;
    }
    _isSelected = isSelected;
    [self _updateBackgroundLayerColor];
}

- (void)setIsHovered:(BOOL)isHovered {
    if (_isHovered == isHovered) {
        return;
    }
    _isHovered = isHovered;
    [self _updateBackgroundLayerColor];
}

- (void)_updateBackgroundLayerColor {
    if (self.isSelected) {
        self.backgroundColorLayer.backgroundColor = [PVDetailHelper accentColor].CGColor;
    } else if (self.isHovered) {
        self.backgroundColorLayer.backgroundColor = self.isDarkMode ? PVColorRGBAMake(255, 255, 255, .15).CGColor : PVColorRGBAMake(0, 0, 0, .1).CGColor;
    } else {
        self.backgroundColorLayer.backgroundColor = [NSColor clearColor].CGColor;
    }
}

@end

@implementation PVDetailTableBlankRowView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
    }
    return self;
}

@end

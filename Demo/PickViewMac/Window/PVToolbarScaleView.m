//
//  PVToolbarScaleView.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVToolbarScaleView.h"

@interface PVToolbarScaleView ()

@property (nonatomic, strong, readwrite) NSButton *decreaseButton;
@property (nonatomic, strong, readwrite) NSSlider *slider;
@property (nonatomic, strong, readwrite) NSButton *increaseButton;

@end

@implementation PVToolbarScaleView

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        [self buildViews];
    }
    return self;
}

- (NSSize)intrinsicContentSize {
    return NSMakeSize(160.0, 30.0);
}

- (void)buildViews {
    self.decreaseButton = [NSButton buttonWithImage:[NSImage imageNamed:NSImageNameRemoveTemplate] target:nil action:nil];
    self.decreaseButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.decreaseButton.bezelStyle = NSBezelStyleTexturedRounded;
    [self addSubview:self.decreaseButton];

    self.slider = [[NSSlider alloc] init];
    self.slider.translatesAutoresizingMaskIntoConstraints = NO;
    self.slider.minValue = 0.0;
    self.slider.maxValue = 1.0;
    [self addSubview:self.slider];

    self.increaseButton = [NSButton buttonWithImage:[NSImage imageNamed:NSImageNameAddTemplate] target:nil action:nil];
    self.increaseButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.increaseButton.bezelStyle = NSBezelStyleTexturedRounded;
    [self addSubview:self.increaseButton];

    [NSLayoutConstraint activateConstraints:@[
        [self.decreaseButton.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.decreaseButton.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        [self.decreaseButton.widthAnchor constraintEqualToConstant:28.0],

        [self.slider.leadingAnchor constraintEqualToAnchor:self.decreaseButton.trailingAnchor constant:6.0],
        [self.slider.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        [self.slider.widthAnchor constraintEqualToConstant:92.0],

        [self.increaseButton.leadingAnchor constraintEqualToAnchor:self.slider.trailingAnchor constant:6.0],
        [self.increaseButton.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        [self.increaseButton.widthAnchor constraintEqualToConstant:28.0],
        [self.increaseButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor]
    ]];
}

@end

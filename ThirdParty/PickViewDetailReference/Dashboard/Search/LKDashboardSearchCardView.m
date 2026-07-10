//
//  LKDashboardSearchCardView.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "LKDashboardSearchCardView.h"

@interface LKDashboardSearchCardView ()

@property(nonatomic, strong) LKVisualEffectView *backgroundEffectView;

@end

@implementation LKDashboardSearchCardView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        self.layer.cornerRadius = DashboardCardCornerRadius;
        
        self.backgroundEffectView = [LKVisualEffectView new];
        self.backgroundEffectView.blendingMode = NSVisualEffectBlendingModeWithinWindow;
        self.backgroundEffectView.state = NSVisualEffectStateActive;
        [self addSubview:self.backgroundEffectView];
    }
    return self;
}

- (void)layout {
    [super layout];
    $(self.backgroundEffectView).fullFrame;
}

@end

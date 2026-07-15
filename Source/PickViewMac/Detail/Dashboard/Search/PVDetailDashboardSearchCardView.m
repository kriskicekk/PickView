//
//  PVDetailDashboardSearchCardView.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailDashboardSearchCardView.h"

@interface PVDetailDashboardSearchCardView ()

@property(nonatomic, strong) PVDetailVisualEffectView *backgroundEffectView;

@end

@implementation PVDetailDashboardSearchCardView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        self.layer.cornerRadius = DashboardCardCornerRadius;
        
        self.backgroundEffectView = [PVDetailVisualEffectView new];
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

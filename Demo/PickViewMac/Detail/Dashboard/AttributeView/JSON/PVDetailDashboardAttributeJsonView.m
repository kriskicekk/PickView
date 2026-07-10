//
//  PVDetailDashboardAttributeJsonView.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailDashboardAttributeJsonView.h"
#import "PVDetailNavigationManager.h"
#import "PVDetailJSONAttributeContentView.h"
#import "PVDetailDashboardViewController.h"

@interface PVDetailDashboardAttributeJsonView ()

@property(nonatomic, strong) PVDetailJSONAttributeContentView *contentView;

@end

@implementation PVDetailDashboardAttributeJsonView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        //        self.layer.borderWidth = 1;
        //        self.layer.borderColor = [NSColor redColor].CGColor;
        self.layer.cornerRadius = DashboardCardControlCornerRadius;
        
        self.contentView = [[PVDetailJSONAttributeContentView alloc] initWithBigFont:NO];
        @weakify(self);
        self.contentView.didReloadData = ^{
            @strongify(self);
            [self.dashboardViewController.view setNeedsLayout:YES];
        };
        [self addSubview:self.contentView];
    }
    return self;
}

- (void)layout {
    [super layout];
    $(self.contentView).fullFrame;
}

- (NSSize)sizeThatFits:(NSSize)limitedSize {
    CGFloat height = [self.contentView queryContentHeight];
    limitedSize.height = height;
    return limitedSize;
}

- (void)renderWithAttribute {
    [super renderWithAttribute];
    NSString *json = self.attribute.value;
    if (![json isKindOfClass:[NSString class]]) {
        [self.contentView renderWithJSON:nil];
        NSAssert(NO, @"");
        return;
    }
    [self.contentView renderWithJSON:json];
}

- (void)showInNewWindow {
    NSString *json = self.attribute.value;
    if (![json isKindOfClass:[NSString class]]) {
        NSAssert(NO, @"");
        return;
    }

    [[PVDetailNavigationManager sharedInstance] showJsonWindow:json];
}

@end

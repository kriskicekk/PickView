//
//  PVDetailMeasureTutorialView.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailMeasureTutorialView.h"

@interface PVDetailMeasureTutorialView ()

@property(nonatomic, strong) NSImageView *imageView;
@property(nonatomic, strong) PVDetailLabel *titleLabel;
@property(nonatomic, strong) PVDetailLabel *subtitleLabel;

@end

@implementation PVDetailMeasureTutorialView {
    NSEdgeInsets _insets;
    CGFloat _titleTop;
    CGFloat _subtitleTop;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        _insets = NSEdgeInsetsMake(15, 5, 12, 5);
        _titleTop = 11;
        _subtitleTop = 6;
        
        self.hasEffectedBackground = YES;
        self.layer.cornerRadius = DashboardCardCornerRadius;
        
        self.imageView = [NSImageView new];
        [self addSubview:self.imageView];
        
        self.titleLabel = [PVDetailLabel new];
        self.titleLabel.font = [NSFont boldSystemFontOfSize:14];
        self.titleLabel.alignment = NSTextAlignmentCenter;
        [self addSubview:self.titleLabel];
        
        self.subtitleLabel = [PVDetailLabel new];
        self.subtitleLabel.font = NSFontMake(12);
        self.subtitleLabel.alignment = NSTextAlignmentCenter;
        [self addSubview:self.subtitleLabel];
    }
    return self;
}

- (void)renderWithImage:(NSImage *)image title:(NSString *)title subtitle:(NSString *)subtitle {
    self.imageView.image = image;
    self.titleLabel.stringValue = title;
    self.subtitleLabel.stringValue = subtitle;
    [self setNeedsLayout:YES];
}

- (void)layout {
    [super layout];
    $(self.imageView).sizeToFit.horAlign.y(_insets.top);
    $(self.titleLabel).sizeToFit.horAlign.y(self.imageView.$maxY + _titleTop);
    $(self.subtitleLabel).x(_insets.left).toRight(_insets.right).heightToFit.y(self.titleLabel.$maxY + _subtitleTop);
}

- (NSSize)sizeThatFits:(NSSize)limitedSize {
    CGFloat contentWidth = limitedSize.width - _insets.left - _insets.right;
    CGFloat resultHeight = _insets.top + _insets.bottom;
    resultHeight += [self.imageView bestHeight];
    resultHeight += _titleTop;
    resultHeight += [self.titleLabel heightForWidth:contentWidth];
    resultHeight += _subtitleTop;
    resultHeight += [self.subtitleLabel heightForWidth:contentWidth];
    limitedSize.height = resultHeight;
    return limitedSize;
}

@end

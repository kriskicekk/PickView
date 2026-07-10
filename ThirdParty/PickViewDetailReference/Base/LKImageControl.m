//
//  LKImageControl.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "LKImageControl.h"

@interface LKImageControl ()

@end

@implementation LKImageControl

+  (instancetype)buttonWithImage:(NSImage *)image {
    LKImageControl *button = [[LKImageControl alloc] init];
    button.image = image;
    return button;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {        
        _imageView = [NSImageView new];
        _imageView.wantsLayer = YES;
        [self addSubview:_imageView];
    }
    return self;
}

- (void)setImage:(NSImage *)image {
    _image = image;
    _imageView.image = image;
    
    [self setNeedsLayout:YES];
}

- (void)layout {
    [super layout];
    _imageView.frame = self.bounds;
    _imageView.layer.anchorPoint = NSMakePoint(.5, .5);
    _imageView.layer.frame = _imageView.frame;
}

- (NSSize)sizeThatFits:(NSSize)size {
    return _imageView.image.size;
}

@end

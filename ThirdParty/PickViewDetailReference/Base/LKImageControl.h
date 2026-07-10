//
//  LKImageControl.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "LKBaseControl.h"

@interface LKImageControl : LKBaseControl {
    @protected
    NSImageView *_imageView;
}

@property(nonatomic, strong) NSImage *image;

@end

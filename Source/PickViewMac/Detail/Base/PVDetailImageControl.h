//
//  PVDetailImageControl.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailBaseControl.h"

@interface PVDetailImageControl : PVDetailBaseControl {
    @protected
    NSImageView *_imageView;
}

@property(nonatomic, strong) NSImage *image;

@end

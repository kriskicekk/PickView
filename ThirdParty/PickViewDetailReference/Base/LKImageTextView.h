//
//  LKImageTextView.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "LKBaseView.h"

@interface LKImageTextView : LKBaseView

@property(nonatomic, strong, readonly) NSImageView *imageView;
@property(nonatomic, strong, readonly) LKLabel *label;

@property(nonatomic, assign) HorizontalMargins imageMargins;

@end

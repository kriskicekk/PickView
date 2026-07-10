//
//  LKTextControl.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "LKBaseControl.h"

@interface LKTextControl : LKBaseControl

@property(nonatomic, strong, readonly) LKLabel *label;

@property(nonatomic, assign) NSEdgeInsets insets;

@property(nonatomic, strong) NSImage *rightImage;
@property(nonatomic, assign) CGFloat spaceBetweenLabelAndImage;
@property(nonatomic, assign) CGFloat rightImageOffsetY;

@end

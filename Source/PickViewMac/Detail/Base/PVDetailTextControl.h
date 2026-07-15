//
//  PVDetailTextControl.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailBaseControl.h"

@interface PVDetailTextControl : PVDetailBaseControl

@property(nonatomic, strong, readonly) PVDetailLabel *label;

@property(nonatomic, assign) NSEdgeInsets insets;

@property(nonatomic, strong) NSImage *rightImage;
@property(nonatomic, assign) CGFloat spaceBetweenLabelAndImage;
@property(nonatomic, assign) CGFloat rightImageOffsetY;

@end

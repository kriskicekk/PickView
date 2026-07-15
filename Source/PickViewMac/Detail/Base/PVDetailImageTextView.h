//
//  PVDetailImageTextView.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailBaseView.h"

@interface PVDetailImageTextView : PVDetailBaseView

@property(nonatomic, strong, readonly) NSImageView *imageView;
@property(nonatomic, strong, readonly) PVDetailLabel *label;

@property(nonatomic, assign) HorizontalMargins imageMargins;

@end

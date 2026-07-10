//
//  PVDetailTextFieldView.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailBaseView.h"

@interface PVDetailTextFieldView : PVDetailBaseView

+ (instancetype)labelView;

@property(nonatomic, strong, readonly) NSTextField *textField;

@property(nonatomic, assign) NSEdgeInsets insets;

@property(nonatomic, strong) PVDetailTwoColors *textColors;

@property(nonatomic, strong) NSImage *image;

/// 调用该方法后，当输入框内有文字时右侧会有 closeButton
- (void)initCloseButton;
@property(nonatomic, strong, readonly) NSButton *closeButton;

@end

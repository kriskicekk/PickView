//
//  PVDetailNumberInputView.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailBaseView.h"
#import "PVAttrType.h"

typedef NS_ENUM(NSUInteger, PVDetailNumberInputViewStyle) {
    PVDetailNumberInputViewStyleHorizontal,    // titleLabel 在输入框内部的右侧
    PVDetailNumberInputViewStyleVertical     // titleLabel 在输入框的下面
};

@class PVDetailTextFieldView;

extern const CGFloat PVDetailNumberInputHorizontalHeight;
extern const CGFloat PVDetailNumberInputVerticalHeight;

@interface PVDetailNumberInputView : PVDetailBaseView

@property(nonatomic, assign) PVDetailNumberInputViewStyle viewStyle;

@property(nonatomic, copy) NSString *title;

@property(nonatomic, strong, readonly) PVDetailTextFieldView *textFieldView;

/// 将当前 string 转换成 attrType 格式的对象并返回，如果返回 nil 则说明转换失败
+ (id)parsedValueWithString:(NSString *)string attrType:(PVAttrType)attrType;

@end

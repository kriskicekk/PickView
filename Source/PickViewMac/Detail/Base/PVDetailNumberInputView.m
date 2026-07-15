//
//  PVDetailNumberInputView.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailNumberInputView.h"
#import "PVDetailTextFieldView.h"

const CGFloat PVDetailNumberInputHorizontalHeight = 21;
const CGFloat PVDetailNumberInputVerticalHeight = 38;

@interface PVDetailNumberInputView ()

@property(nonatomic, strong) PVDetailLabel *titleLabel;

@end

@implementation PVDetailNumberInputView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
//        self.layer.borderWidth = 1;
//        self.layer.borderColor = [NSColor greenColor].CGColor;
        
        _textFieldView = [PVDetailTextFieldView new];
        self.textFieldView.backgroundColorName = @"DashboardCardValueBGColor";
        self.textFieldView.layer.cornerRadius = DashboardCardControlCornerRadius;
        self.textFieldView.textField.cell = [NSTextFieldCell new];
        self.textFieldView.textField.cell.focusRingType = NSFocusRingTypeNone;
        self.textFieldView.textField.cell.usesSingleLineMode = YES;
        self.textFieldView.textField.cell.lineBreakMode = NSLineBreakByTruncatingTail;
        self.textFieldView.textField.cell.scrollable = YES;
        self.textFieldView.textField.cell.editable = YES;
        self.textFieldView.textField.cell.selectable = YES;
        self.textFieldView.textField.drawsBackground = NO;
        self.textFieldView.textField.textColor = [NSColor colorNamed:@"DashboardCardValueColor"];
        self.textFieldView.textField.font = NSFontMake(12);
//        self.textFieldView.layer.borderColor = DashboardCardControlBorderColor.CGColor;
//        self.textFieldView.layer.borderWidth = 1;
        [self addSubview:self.textFieldView];
        
        self.titleLabel = [PVDetailLabel new];
        self.titleLabel.alignment = NSTextAlignmentCenter;
//        self.titleLabel.layer.borderWidth = 1;
//        self.titleLabel.layer.borderColor = [NSColor purpleColor].CGColor;
        [self addSubview:self.titleLabel];
    }
    return self;
}

- (void)layout {
    [super layout];
    $(self.textFieldView).fullWidth.height(PVDetailNumberInputHorizontalHeight);
    if (self.viewStyle == PVDetailNumberInputViewStyleHorizontal) {
        $(self.titleLabel).sizeToFit.lk_minWidth(15).verAlign.right(2);
        self.textFieldView.insets = ({
            CGFloat right = self.$width - self.titleLabel.$x + 2;
            NSEdgeInsets insets = self.textFieldView.insets;
            insets.right = right;
            insets;
        });
    } else if (self.viewStyle == PVDetailNumberInputViewStyleVertical) {
        $(self.titleLabel).sizeToFit.horAlign.y(self.textFieldView.$maxY + 3);
    } else {
        NSAssert(NO, @"");
    }
}

- (NSSize)sizeThatFits:(NSSize)limitedSize {
    if (self.viewStyle == PVDetailNumberInputViewStyleHorizontal) {
        limitedSize.height = PVDetailNumberInputHorizontalHeight;
    } else if (self.viewStyle == PVDetailNumberInputViewStyleVertical) {
        limitedSize.height = PVDetailNumberInputVerticalHeight;
    } else {
        NSAssert(NO, @"");
    }
    return limitedSize;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.stringValue = title;
    [self _updateTitleLabelFontAndColor];
    [self setNeedsLayout:YES];
}

- (void)setViewStyle:(PVDetailNumberInputViewStyle)viewStyle {
    _viewStyle = viewStyle;
    if (viewStyle == PVDetailNumberInputViewStyleHorizontal) {
        self.textFieldView.textField.alignment = NSTextAlignmentLeft;
        self.textFieldView.insets = NSEdgeInsetsMake(3, 3, 3, 3);
        
    } else if (viewStyle == PVDetailNumberInputViewStyleVertical) {
        self.textFieldView.textField.alignment = NSTextAlignmentCenter;
        self.textFieldView.insets = NSEdgeInsetsMake(2, 0, 2, 0);
    }
    [self _updateTitleLabelFontAndColor];
    [self setNeedsLayout:YES];
}

+ (id)parsedValueWithString:(NSString *)string attrType:(PVAttrType)attrType {
    switch (attrType) {
        case PVAttrTypeInt:
        case PVAttrTypeLong:
        case PVAttrTypeLongLong: {
            NSScanner *scanner = [NSScanner scannerWithString:string];
            long long newValue;
            BOOL isSucc = [scanner scanLongLong:&newValue];
            if (isSucc) {
                return @(newValue);
            }
            return nil;
        }
        case PVAttrTypeFloat:
        case PVAttrTypeDouble: {
            NSScanner *scanner = [NSScanner scannerWithString:string];
            double newValue;
            BOOL isSucc = [scanner scanDouble:&newValue];
            if (isSucc) {
                return @(newValue);
            }
            return nil;
        }
        default:
            NSAssert(NO, @"不支持该 AttrType");
            return nil;
    }
}

- (void)_updateTitleLabelFontAndColor {
    if (self.viewStyle == PVDetailNumberInputViewStyleHorizontal) {
        if (self.title.length > 1) {
            self.titleLabel.textColor = [NSColor colorNamed:@"DashboardCardValueColor"];
            self.titleLabel.font = NSFontMake(12);
        } else {
            self.titleLabel.textColor = [NSColor colorNamed:@"DashboardInputAccessoryColor"];
            self.titleLabel.font = NSFontMake(10);
        }
    } else {
        self.titleLabel.font = NSFontMake(11);
        self.titleLabel.textColor = [NSColor colorNamed:@"DashboardCardValueColor"];
    }
    [self setNeedsLayout:YES];
}

@end

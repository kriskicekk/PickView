//
//  PVDetailDashboardAttributeRectView.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailDashboardAttributeRectView.h"
#import "PVDetailNumberInputView.h"
#import "PVDetailTextFieldView.h"
#import "PVDetailDashboardViewController.h"
#import "PVDetailDashboardTextControlEditingFlag.h"

@interface PVDetailDashboardAttributeRectView () <NSTextFieldDelegate>

@property(nonatomic, copy) NSArray<PVDetailNumberInputView *> *mainInputsView;

@end

@implementation PVDetailDashboardAttributeRectView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        //        self.layer.borderWidth = 1;
        //        self.layer.borderColor = [NSColor redColor].CGColor;
        
        NSArray<NSString *> *titles = @[@"X", @"Y", @"W", @"H"];
        self.mainInputsView = [NSArray pv_inspect_arrayWithCount:4 block:^id(NSUInteger idx) {
            PVDetailNumberInputView *view = [PVDetailNumberInputView new];
            view.title = titles[idx];
            view.viewStyle = PVDetailNumberInputViewStyleHorizontal;
            view.textFieldView.textField.delegate = self;
            view.textFieldView.backgroundColorName = @"DashboardCardValueBGColor";
            [self addSubview:view];
            return view;
        }];
    }
    return self;
}

- (void)layout {
    [super layout];
    CGFloat itemWidth = (self.$width - DashboardAttrItemHorInterspace) / 2.0;
    [self.mainInputsView enumerateObjectsUsingBlock:^(PVDetailNumberInputView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat x, y;
        if (idx == 0 || idx == 2) {
            x = 0;
        } else {
            x = itemWidth + DashboardAttrItemHorInterspace;
        }
        if (idx == 0 || idx == 1) {
            y = 0;
        } else {
            y = PVDetailNumberInputHorizontalHeight + DashboardAttrItemVerInterspace;
        }
        $(view).width(itemWidth).height(PVDetailNumberInputHorizontalHeight).x(x).y(y);
    }];
}

- (NSSize)sizeThatFits:(NSSize)limitedSize {
    CGFloat height = PVDetailNumberInputHorizontalHeight * 2 + DashboardAttrItemVerInterspace;
    limitedSize.height = height;
    return limitedSize;
}

- (void)renderWithAttribute {
    if (!self.attribute) {
        NSAssert(NO, @"");
        return;
    }
    if (![self.attribute.value isKindOfClass:[NSValue class]]) {
        NSAssert(NO, @"");
        return;
    }
    NSRect rect = ((NSValue *)self.attribute.value).rectValue;
    NSArray<NSString *> *mainStrs = @[[NSString pv_inspect_stringFromDouble:rect.origin.x decimal:3],
                                  [NSString pv_inspect_stringFromDouble:rect.origin.y decimal:3],
                                  [NSString pv_inspect_stringFromDouble:rect.size.width decimal:3],
                                  [NSString pv_inspect_stringFromDouble:rect.size.height decimal:3]];
    
    [self.mainInputsView enumerateObjectsUsingBlock:^(PVDetailNumberInputView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.textFieldView.textField.editable = [self canEdit];
        obj.textFieldView.textField.stringValue = mainStrs[idx];
    }];
}

#pragma mark - <NSTextFieldDelegate>

- (BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor {
    return self.canEdit;
}

- (void)controlTextDidEndEditing:(NSNotification *)notification {
    if (PVDetailDashboardTextControlEditingFlag.sharedInstance.shouldIgnoreTextEditingChangeEvent) {
        NSLog(@"忽略 controlTextDidEndEditing 事件，驳回");
        return;
    }
    
    NSTextField *editingTextField = notification.object;
    NSNumber *inputValue = [PVDetailNumberInputView parsedValueWithString:editingTextField.stringValue attrType:PVAttrTypeDouble];
    if (inputValue == nil) {
        NSLog(@"输入格式校验不通过，驳回");
        [self renderWithAttribute];
        return;
    }
    
    double inputDouble = [inputValue doubleValue];
    NSUInteger editingTextFieldIdx = [[self.mainInputsView pv_inspect_map:^id(NSUInteger idx, PVDetailNumberInputView *value) {
        return value.textFieldView.textField;
    }] indexOfObject:editingTextField];
    
    CGRect expectedRect = ((NSValue *)self.attribute.value).rectValue;
    switch (editingTextFieldIdx) {
        case 0:
            // x
            expectedRect.origin.x = inputDouble;
            break;
        case 1:
            // y
            expectedRect.origin.y = inputDouble;
            break;
        case 2:
            // width
            expectedRect.size.width = inputDouble;
            break;
        case 3:
            // height
            expectedRect.size.height = inputDouble;
            break;
        default:
            [self renderWithAttribute];
            NSAssert(NO, @"");
            break;
    }
    
    NSValue *expectedValue = [NSValue valueWithRect:expectedRect];
    if ([expectedValue isEqual:self.attribute.value]) {
        NSLog(@"修改没有变化，不做任何提交");
        [self renderWithAttribute];
        return;
    }

    // 提交修改
    @weakify(self);
    
    CGRect oldRect = [self.attribute.value rectValue];
    
    [[self.dashboardViewController modifyAttribute:self.attribute newValue:expectedValue] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        CGRect currentRect = [self.attribute.value rectValue];
        if ([self _rectA:oldRect isAlmostEqualToRectB:currentRect] && ![self _rectA:expectedRect isAlmostEqualToRectB:currentRect]) {
            // PickView 更改了 value 之后，又被 iOS 里的业务改回去了，这个在修改 frame 时经常出现，就像 PickView 更改失败了一样，为了避免用户迷惑，这里特意弹窗告知一下
            AlertErrorText(NSLocalizedString(@"The modification seems to have no effect.", nil), NSLocalizedString(@"After modifying successfully by PickView, the value seems to be recovered by the code in your iOS app. For example, modifying \"frame\" of a view may trigger \"layoutSubviews\", and \"layoutSubviews\" may modify the value again.", nil), self.window);
        }
        
    } error:^(NSError * _Nullable error) {
        @strongify(self);
        NSLog(@"修改返回 error");
        [self renderWithAttribute];
        
    }];
}

/// 比较 rectA 和 rectB 是否相等
- (BOOL)_rectA:(CGRect)rectA isAlmostEqualToRectB:(CGRect)rectB {
    if (ABS(rectA.origin.x - rectB.origin.x) > 0.1) {
        return NO;
    }
    if (ABS(rectA.origin.y - rectB.origin.y) > 0.1) {
        return NO;
    }
    if (ABS(rectA.size.width - rectB.size.width) > 0.1) {
        return NO;
    }
    if (ABS(rectA.size.height - rectB.size.height) > 0.1) {
        return NO;
    }
    return YES;
}

@end

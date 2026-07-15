//
//  PVDetailDashboardAttributeInsetsView.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailDashboardAttributeInsetsView.h"
#import "PVDetailNumberInputView.h"
#import "PVDetailTextFieldView.h"
#import "PVDetailDashboardViewController.h"
#import "PVDetailDashboardTextControlEditingFlag.h"

@interface PVDetailDashboardAttributeInsetsView () <NSTextFieldDelegate>

@property(nonatomic, copy) NSArray<PVDetailNumberInputView *> *mainInputsView;

@end

@implementation PVDetailDashboardAttributeInsetsView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        //        self.layer.borderWidth = 1;
        //        self.layer.borderColor = [NSColor redColor].CGColor;
        
        NSArray<NSString *> *titles = @[@"T", @"L", @"B", @"R"];
        self.mainInputsView = [NSArray pv_inspect_arrayWithCount:4 block:^id(NSUInteger idx) {
            PVDetailNumberInputView *view = [PVDetailNumberInputView new];
            view.title = titles[idx];
            view.viewStyle = PVDetailNumberInputViewStyleHorizontal;
            view.textFieldView.textField.delegate = self;
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
    NSEdgeInsets insets = ((NSValue *)self.attribute.value).edgeInsetsValue;
    NSArray<NSString *> *mainStrs = @[[NSString pv_inspect_stringFromDouble:insets.top decimal:3],
                                  [NSString pv_inspect_stringFromDouble:insets.left decimal:3],
                                  [NSString pv_inspect_stringFromDouble:insets.bottom decimal:3],
                                  [NSString pv_inspect_stringFromDouble:insets.right decimal:3]];
    
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
    if (![self canEdit]) {
        return;
    }
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
    
    NSEdgeInsets expectedInsets = ((NSValue *)self.attribute.value).edgeInsetsValue;
    switch (editingTextFieldIdx) {
        case 0:
            // top
            expectedInsets.top = inputDouble;
            break;
        case 1:
            // left
            expectedInsets.left = inputDouble;
            break;
        case 2:
            // bottom
            expectedInsets.bottom = inputDouble;
            break;
        case 3:
            // right
            expectedInsets.right = inputDouble;
            break;
        default:
            [self renderWithAttribute];
            NSAssert(NO, @"");
            break;
    }
    
    NSEdgeInsets originInsets = ((NSValue *)self.attribute.value).edgeInsetsValue;
    // 这里 NSValue 的 isEqual: 方法不准，要手动判断
    BOOL valueDidChange = (originInsets.top != expectedInsets.top ||
                           originInsets.left != expectedInsets.left ||
                           originInsets.bottom != expectedInsets.bottom ||
                           originInsets.right != expectedInsets.right);
    if (!valueDidChange) {
        NSLog(@"修改没有变化，不做任何提交");
        [self renderWithAttribute];
        return;
    }
    NSValue *expectedValue = [NSValue valueWithEdgeInsets:expectedInsets];
    
    // 提交修改
    @weakify(self);
    [[self.dashboardViewController modifyAttribute:self.attribute newValue:expectedValue] subscribeError:^(NSError * _Nullable error) {
        @strongify(self);
        NSLog(@"修改返回 error");
        [self renderWithAttribute];
    }];
}

#pragma mark - Others

- (void)setDashboardViewController:(PVDetailDashboardViewController *)dashboardViewController {
    [super setDashboardViewController:dashboardViewController];
    [self.mainInputsView enumerateObjectsUsingBlock:^(PVDetailNumberInputView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.textFieldView.backgroundColorName = @"DashboardCardValueBGColor";
    }];
}

@end

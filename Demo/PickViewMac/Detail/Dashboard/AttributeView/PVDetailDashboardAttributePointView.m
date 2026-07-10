//
//  PVDetailDashboardAttributePointView.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailDashboardAttributePointView.h"
#import "PVDetailNumberInputView.h"
#import "PVDetailTextFieldView.h"
#import "PVDetailDashboardViewController.h"
#import "PVDetailDashboardTextControlEditingFlag.h"

@interface PVDetailDashboardAttributePointView () <NSTextFieldDelegate>

@property(nonatomic, copy) NSArray<PVDetailNumberInputView *> *inputsView;

@end

@implementation PVDetailDashboardAttributePointView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        //        self.layer.borderWidth = 1;
        //        self.layer.borderColor = [NSColor redColor].CGColor;
        
        NSArray<NSString *> *titles = @[@"X", @"Y"];
        self.inputsView = [NSArray pv_inspect_arrayWithCount:2 block:^id(NSUInteger idx) {
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
    [self.inputsView enumerateObjectsUsingBlock:^(PVDetailNumberInputView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat x = idx ? (itemWidth + DashboardAttrItemHorInterspace) : 0;
        $(view).width(itemWidth).height(PVDetailNumberInputHorizontalHeight).x(x).y(0);
    }];
}

- (NSSize)sizeThatFits:(NSSize)limitedSize {
    CGFloat height = PVDetailNumberInputHorizontalHeight;
    limitedSize.height = height;
    return limitedSize;
}

- (void)renderWithAttribute {
    if (![self.attribute.value isKindOfClass:[NSValue class]]) {
        NSAssert(NO, @"");
        return;
    }
    NSPoint point = ((NSValue *)self.attribute.value).pointValue;
    NSArray<NSString *> *mainStrs = @[[NSString pv_inspect_stringFromDouble:point.x decimal:3],
                                      [NSString pv_inspect_stringFromDouble:point.y decimal:3]];
    
    [self.inputsView enumerateObjectsUsingBlock:^(PVDetailNumberInputView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
    NSUInteger editingTextFieldIdx = [[self.inputsView pv_inspect_map:^id(NSUInteger idx, PVDetailNumberInputView *value) {
        return value.textFieldView.textField;
    }] indexOfObject:editingTextField];
    
    NSPoint expectedPoint = ((NSValue *)self.attribute.value).pointValue;
    switch (editingTextFieldIdx) {
        case 0:
            // x
            expectedPoint.x = inputDouble;
            break;
        case 1:
            // y
            expectedPoint.y = inputDouble;
            break;
        default:
            [self renderWithAttribute];
            NSAssert(NO, @"");
            break;
    }
    
    NSValue *expectedValue = [NSValue valueWithPoint:expectedPoint];
    if ([expectedValue isEqual:self.attribute.value]) {
        NSLog(@"修改没有变化，不做任何提交");
        [self renderWithAttribute];
        return;
    }
    
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
    [self.inputsView enumerateObjectsUsingBlock:^(PVDetailNumberInputView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.textFieldView.backgroundColorName = @"DashboardCardValueBGColor";
    }];
}

@end

//
//  PVDetailDashboardAttributeRowsCountView.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailDashboardAttributeRowsCountView.h"
#import "PVDetailNumberInputView.h"
#import "PVDetailTextFieldView.h"
#import "PVDetailDashboardViewController.h"

@interface PVDetailDashboardAttributeRowsCountView ()

@property(nonatomic, copy) NSArray<PVDetailNumberInputView *> *inputsView;

@end

@implementation PVDetailDashboardAttributeRowsCountView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        //        self.layer.borderWidth = 1;
        //        self.layer.borderColor = [NSColor redColor].CGColor;
        
        self.inputsView = [NSArray array];
    }
    return self;
}

- (void)layout {
    [super layout];
    [self.inputsView enumerateObjectsUsingBlock:^(PVDetailNumberInputView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat y = idx * (PVDetailNumberInputHorizontalHeight + DashboardAttrItemVerInterspace);
        $(view).fullWidth.height(PVDetailNumberInputHorizontalHeight).y(y);
    }];
}

- (NSSize)sizeThatFits:(NSSize)limitedSize {
    CGFloat height = (PVDetailNumberInputHorizontalHeight + DashboardAttrItemVerInterspace) * self.inputsView.count - DashboardAttrItemVerInterspace;
    limitedSize.height = MAX(height, 0);
    return limitedSize;
}

- (void)renderWithAttribute {
    if (!self.attribute) {
        NSAssert(NO, @"");
        return;
    }
    if (![self.attribute.value isKindOfClass:[NSArray class]]) {
        NSAssert(NO, @"");
        return;
    }
    
    NSArray<NSNumber *> *numbers = self.attribute.value;
    self.inputsView = [self.inputsView pv_inspect_resizeWithCount:numbers.count add:^PVDetailNumberInputView *(NSUInteger idx) {
        PVDetailNumberInputView *view = [PVDetailNumberInputView new];
        view.textFieldView.textField.editable = NO;
        view.viewStyle = PVDetailNumberInputViewStyleHorizontal;
        view.textFieldView.backgroundColorName = @"DashboardCardValueBGColor";
        [self addSubview:view];
        return view;
        
    } remove:^(NSUInteger idx, PVDetailNumberInputView *obj) {
        [obj removeFromSuperview];
        
    } doNext:^(NSUInteger idx, PVDetailNumberInputView *obj) {
        obj.title = [NSString stringWithFormat:@"Section %@", @(idx)];
        obj.textFieldView.textField.stringValue = [NSString stringWithFormat:@"%@", numbers[idx]];
    }];
    
    [self setNeedsLayout:YES];
}

#pragma mark - Others

- (void)setDashboardViewController:(PVDetailDashboardViewController *)dashboardViewController {
    [super setDashboardViewController:dashboardViewController];
    [self.inputsView enumerateObjectsUsingBlock:^(PVDetailNumberInputView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.textFieldView.backgroundColorName = @"DashboardCardValueBGColor";
    }];
}

@end

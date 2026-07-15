//
//  PVDetailDashboardAttributeShadowView.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailDashboardAttributeShadowView.h"
#import "PVDetailColorIndicatorLayer.h"
#import "PVDetailPreferenceManager.h"
#import "PVDetailNumberInputView.h"
#import "PVDetailTextFieldView.h"

@interface PVDetailDashboardAttributeShadowView ()

@property(nonatomic, strong) PVDetailBaseView *colorContainerView;
@property(nonatomic, strong) PVDetailColorIndicatorLayer *colorIndicatorLayer;
@property(nonatomic, strong) PVDetailLabel *colorDescLabel;
@property(nonatomic, strong) NSArray<PVDetailNumberInputView *> *inputViews;

@end

@implementation PVDetailDashboardAttributeShadowView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
//        self.layer.borderWidth = 1;
//        self.layer.borderColor = [NSColor redColor].CGColor;
        
        self.colorContainerView = [PVDetailBaseView new];
        self.colorContainerView.layer.cornerRadius = DashboardCardControlCornerRadius;
        self.colorContainerView.backgroundColorName = @"DashboardCardValueBGColor";
        [self addSubview:self.colorContainerView];
        
        self.colorIndicatorLayer = [PVDetailColorIndicatorLayer new];
        [self.colorContainerView.layer addSublayer:self.colorIndicatorLayer];
        
        self.colorDescLabel = [PVDetailLabel new];
        self.colorDescLabel.textColor = [NSColor colorNamed:@"DashboardCardValueColor"];
        self.colorDescLabel.font = NSFontMake(13);
        [self.colorContainerView addSubview:self.colorDescLabel];
        
        NSArray<NSString *> *titles = @[@"Opacity", @"Radius", @"OffsetW", @"OffsetH"];
        self.inputViews = [NSArray pv_inspect_arrayWithCount:4 block:^id(NSUInteger idx) {
            PVDetailNumberInputView *view = [PVDetailNumberInputView new];
            view.textFieldView.textField.editable = NO;
            view.title = titles[idx];
            view.viewStyle = PVDetailNumberInputViewStyleVertical;
            [self addSubview:view];
            return view;
        }];
        
        @weakify(self);
        [[RACObserve([PVDetailPreferenceManager mainManager], rgbaFormat) skip:1] subscribeNext:^(NSNumber *bool_rgbaFormat) {
            @strongify(self);
            [self renderWithAttribute];
        }];
    }
    return self;
}

- (void)layout {
    [super layout];
    $(self.colorContainerView).fullWidth.height(30).y(0);
    $(self.colorIndicatorLayer).width(16).height(16).x(8).verAlign;
    $(self.colorDescLabel).x(28).toRight(20).heightToFit.verAlign.offsetY(-1);
    
    CGFloat itemWidth = (self.$width - DashboardAttrItemHorInterspace * 3) / 4.0;
    CGFloat y = self.colorContainerView.$maxY + DashboardAttrItemVerInterspace;
    __block CGFloat x = 0;
    [self.inputViews enumerateObjectsUsingBlock:^(PVDetailNumberInputView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        $(view).width(itemWidth).height(PVDetailNumberInputVerticalHeight).x(x).y(y);
        x += itemWidth + DashboardAttrItemHorInterspace;
    }];
}

- (NSSize)sizeThatFits:(NSSize)limitedSize {
    CGFloat height = 30;
    height += DashboardAttrItemVerInterspace;
    height += PVDetailNumberInputVerticalHeight;
    limitedSize.height = height;
    return limitedSize;
}

- (void)renderWithAttribute {
    if (!self.attribute) {
        NSAssert(NO, @"");
        return;
    }
    NSDictionary *info = self.attribute.value;
    if (![info isKindOfClass:[NSDictionary class]]) {
        NSAssert(NO, @"");
        return;
    }
    // 可能为 nil
    NSColor *color = [NSColor lk_colorFromRGBAComponents:info[@"color"]];
    
    NSValue *offsetValue = info[@"offset"];
    if (![offsetValue isKindOfClass:[NSValue class]]) {
        NSAssert(NO, @"");
        return;
    }
    CGSize offset = [offsetValue sizeValue];
    
    NSNumber *opacityNumber = info[@"opacity"];
    if (![opacityNumber isKindOfClass:[NSNumber class]]) {
        NSAssert(NO, @"");
        return;
    }
    CGFloat opacity = [opacityNumber doubleValue];
    
    NSNumber *radiusNumber = info[@"radius"];
    if (![radiusNumber isKindOfClass:[NSNumber class]]) {
        NSAssert(NO, @"");
        return;
    }
    CGFloat radius = [radiusNumber doubleValue];
    
    self.colorIndicatorLayer.color = color;
    if (color) {
        self.colorDescLabel.stringValue = [PVDetailPreferenceManager mainManager].rgbaFormat ? color.rgbaString : color.hexString;
    } else {
        self.colorDescLabel.stringValue = @"nil";
    }
    
    NSArray<NSString *> *strs = @[[NSString pv_inspect_stringFromDouble:opacity decimal:2],
                                  [NSString pv_inspect_stringFromDouble:radius decimal:2],
                                  [NSString pv_inspect_stringFromDouble:offset.width decimal:2],
                                  [NSString pv_inspect_stringFromDouble:offset.height decimal:2]];
    [self.inputViews enumerateObjectsUsingBlock:^(PVDetailNumberInputView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.textFieldView.textField.stringValue = strs[idx];
    }];
}

@end

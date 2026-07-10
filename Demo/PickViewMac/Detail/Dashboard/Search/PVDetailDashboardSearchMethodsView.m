//
//  PVDetailDashboardSearchMethodsView.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailDashboardSearchMethodsView.h"

@interface PVDetailDashboardSearchMethodsView ()

@property(nonatomic, strong) PVDetailLabel *titleLabel;
@property(nonatomic, strong) PVDetailLabel *errorLabel;
@property(nonatomic, strong) NSMutableArray<PVDetailTextControl *> *itemViews;
@property(nonatomic, assign) unsigned long oid;

@end

@implementation PVDetailDashboardSearchMethodsView {
    CGFloat _insetTop;
    CGFloat _contentMarginTop;
    CGFloat _itemInterspace;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        _insetTop = 5;
        _contentMarginTop = 10;
        _itemInterspace = 8;
        self.itemViews = [NSMutableArray array];
        
        self.titleLabel = [PVDetailLabel new];
        self.titleLabel.font = NSFontMake(12);
        self.titleLabel.textColor = [NSColor secondaryLabelColor];
        self.titleLabel.stringValue = NSLocalizedString(@"Click to invoke methods below and get the return value.", nil);
        [self addSubview:self.titleLabel];
    }
    return self;
}

- (void)layout {
    [super layout];
    
    CGFloat width = self.$width - DashboardSearchCardInset * 2;
    if (self.titleLabel.isVisible) {
        $(self.titleLabel).x(DashboardSearchCardInset).width(width).heightToFit.y(_insetTop);
        
        __block CGFloat y = self.titleLabel.$maxY + _contentMarginTop;
        [self.itemViews enumerateObjectsUsingBlock:^(PVDetailTextControl * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
            if (view.hidden) {
                return;
            }
            NSSize methodControlSize = [view sizeThatFits:NSMakeSize(width, CGFLOAT_MAX)];
            $(view).size(methodControlSize).x(DashboardSearchCardInset).y(y);
            y = view.$maxY + self->_itemInterspace;
        }];
    
    } else if (self.errorLabel.isVisible) {
        $(self.errorLabel).x(DashboardSearchCardInset).width(width).heightToFit.y(_insetTop);
    }
}

- (NSSize)sizeThatFits:(NSSize)limitedSize {
    CGFloat contentWidth = limitedSize.width - DashboardSearchCardInset * 2;
    if (self.titleLabel.isVisible) {
        CGFloat height = [self.titleLabel heightForWidth:contentWidth] + _insetTop + _contentMarginTop;
        limitedSize.height = [self.itemViews pv_inspect_reduceCGFloat:^CGFloat(CGFloat accumulator, NSUInteger idx, PVDetailTextControl *view) {
            accumulator += [view heightForWidth:contentWidth] + self->_itemInterspace;
            return accumulator;
        } initialAccumlator:height];
    } else {
        limitedSize.height = [self.errorLabel heightForWidth:contentWidth] + _insetTop * 2;
    }
    
    return limitedSize;
}

- (void)renderWithMethods:(NSArray<NSString *> *)methods oid:(unsigned long)oid {
    self.oid = oid;
    
    self.titleLabel.hidden = NO;
    self.errorLabel.hidden = YES;
    
    [self.itemViews pv_inspect_dequeueWithCount:methods.count add:^PVDetailTextControl *(NSUInteger idx) {
        PVDetailTextControl *control = [PVDetailTextControl new];
        control.label.alignment = NSTextAlignmentLeft;
        control.label.maximumNumberOfLines = 0;
        control.adjustAlphaWhenClick = YES;
        [control addTarget:self clickAction:@selector(_handleMethodControl:)];
        [self addSubview:control];
        
        return control;
        
    } notDequeued:^(NSUInteger idx, PVDetailTextControl *view) {
        view.hidden = YES;
        
    } doNext:^(NSUInteger idx, PVDetailTextControl *view) {
        view.hidden = NO;
        [view pv_inspect_bindObject:methods[idx] forKey:@"methodName"];
        view.label.attributedStringValue = $(methods[idx]).font(@13).textColor(@"74, 144, 226").addImage(@"icon_arrowRight_blue", -1, 2, 0).attrString;
        [view setNeedsLayout:YES];
    }];
    
    [self setNeedsLayout:YES];
}

- (void)renderWithError:(NSError *)error {
    NSLog(@"%@", error);
    [self.itemViews enumerateObjectsUsingBlock:^(PVDetailTextControl * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hidden = YES;
    }];
    self.titleLabel.hidden = YES;
    if (!self.errorLabel) {
        self.errorLabel = [PVDetailLabel new];
        self.errorLabel.textColor = [NSColor labelColor];
        self.errorLabel.font = NSFontMake(12);
        [self addSubview:self.errorLabel];
    }
    self.errorLabel.hidden = NO;
    self.errorLabel.stringValue = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"Failed to search related methods: ", nil), error.localizedDescription];
    [self setNeedsLayout:YES];
}

- (void)_handleMethodControl:(NSControl *)control {
    NSString *methodName = [control pv_inspect_getBindObjectForKey:@"methodName"];
    if (methodName.length == 0) {
        NSAssert(NO, @"");
        return;
    }
    if ([self.delegate respondsToSelector:@selector(dashboardSearchMethodsView:requestToInvokeMethod:oid:)]) {
        [self.delegate dashboardSearchMethodsView:self requestToInvokeMethod:methodName oid:self.oid];
    }
}

@end

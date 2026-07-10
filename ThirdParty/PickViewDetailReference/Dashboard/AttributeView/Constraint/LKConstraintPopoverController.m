//
//  LKConstraintPopoverController.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "LKConstraintPopoverController.h"
#import "PickViewAutoLayoutConstraint.h"
#import "LKTextsMenuView.h"
#import "LKTextFieldView.h"
#import "PickViewObject.h"
#import "PickViewAutoLayoutConstraint+PickViewClient.h"

@interface LKConstraintPopoverController ()

@property(nonatomic, strong) LKTextFieldView *titleView;
@property(nonatomic, strong) LKTextsMenuView *textsView;
@property(nonatomic, strong) PickViewAutoLayoutConstraint *constraint;

@end

@implementation LKConstraintPopoverController {
    CGFloat _horInset;
    CGFloat _insetBottom;
    CGFloat _titleHeight;
    CGFloat _textsViewMarginTop;
}

- (instancetype)initWithConstraint:(PickViewAutoLayoutConstraint *)constraint {
    if (self = [self initWithContainerView:nil]) {
        _horInset = 5;
        _insetBottom = 10;
        _titleHeight = 26;
        _textsViewMarginTop = 10;
        self.constraint = constraint;
        
        if (!constraint.effective) {
            self.titleView = [LKTextFieldView labelView];
            self.titleView.textField.font = NSFontMake(IsEnglish ? 12 : 13);
            self.titleView.textColors = LKColorsCombine(NSColorGray1, NSColorGray9);
            self.titleView.textField.alignment = NSTextAlignmentCenter;
            self.titleView.textField.stringValue = NSLocalizedString(@"The layout of selected view is not affected by this constraint.", nil);
            self.titleView.backgroundColors = LKColorsCombine(PickViewColorRGBAMake(0, 0, 0, 0.1), PickViewColorRGBAMake(0, 0, 0, 0.2));
            self.titleView.image = NSImageMake(@"Constraint_Popover_Info");
            self.titleView.insets = NSEdgeInsetsMake(0, _horInset, 0, _horInset);
            [self.view addSubview:self.titleView];
        }
        
        self.textsView = [LKTextsMenuView new];
        self.textsView.verSpace = 8;
        self.textsView.horSpace = 4;
        self.textsView.font = NSFontMake(13);
        self.textsView.type = LKTextsMenuViewTypeCenter;
        [self.view addSubview:self.textsView];
    
        NSMutableArray<PickViewStringTwoTuple *> *texts = [NSMutableArray array];
        [texts addObject:[PickViewStringTwoTuple tupleWithFirst:@"FirstItem" second:[PickViewAutoLayoutConstraint descriptionWithItemObject:constraint.firstItem type:constraint.firstItemType detailed:YES]]];
        [texts addObject:[PickViewStringTwoTuple tupleWithFirst:@"FirstAttribute" second:[PickViewAutoLayoutConstraint descriptionWithAttributeInt:constraint.firstAttribute].lk_capitalizedString]];
        [texts addObject:[PickViewStringTwoTuple tupleWithFirst:@"Relation" second:[PickViewAutoLayoutConstraint descriptionWithRelation:constraint.relation]]];
        [texts addObject:[PickViewStringTwoTuple tupleWithFirst:@"SecondItem" second:[PickViewAutoLayoutConstraint descriptionWithItemObject:constraint.secondItem type:constraint.secondItemType detailed:YES]]];
        [texts addObject:[PickViewStringTwoTuple tupleWithFirst:@"SecondAttribute" second:[PickViewAutoLayoutConstraint descriptionWithAttributeInt:constraint.secondAttribute].lk_capitalizedString]];
        [texts addObject:[PickViewStringTwoTuple tupleWithFirst:@"Multiplier" second:[NSString stringWithFormat:@"%@", @(constraint.multiplier)]]];
        [texts addObject:[PickViewStringTwoTuple tupleWithFirst:@"Constant" second:[NSString stringWithFormat:@"%@", @(constraint.constant)]]];
        [texts addObject:[PickViewStringTwoTuple tupleWithFirst:@"Priority" second:[NSString stringWithFormat:@"%@", @(constraint.priority)]]];
        [texts addObject:[PickViewStringTwoTuple tupleWithFirst:@"Active" second:constraint.active ? @"YES" : @"NO"]];
        [texts addObject:[PickViewStringTwoTuple tupleWithFirst:@"ShouldBeArchived" second:constraint.shouldBeArchived ? @"YES" : @"NO"]];
        [texts addObject:[PickViewStringTwoTuple tupleWithFirst:@"Identifier" second:constraint.identifier ? : @""]];
        
        if (constraint.firstItemType == PickViewConstraintItemTypeView) {
            NSButton *button = [NSButton lk_buttonWithImage:NSImageMake(@"Icon_JumpDisclosure") target:self action:@selector(_handleJumpButton:)];
            [button pickview_bindObject:constraint.firstItem forKey:@"jumpObject"];
            [self.textsView addButton:button atIndex:0];
            
        }
        if (constraint.secondItemType == PickViewConstraintItemTypeView) {
            NSButton *button = [NSButton lk_buttonWithImage:NSImageMake(@"Icon_JumpDisclosure") target:self action:@selector(_handleJumpButton:)];
            [button pickview_bindObject:constraint.firstItem forKey:@"jumpObject"];
            [self.textsView addButton:button atIndex:3];
        }
        
        self.textsView.texts = texts;
    }
    return self;
}

- (void)viewDidLayout {
    [super viewDidLayout];
    if (self.titleView) {
        $(self.titleView).fullWidth.height(_titleHeight).y(0);
    }
    
    CGFloat y = (self.titleView ? _titleHeight : 0);
    $(self.textsView).sizeToFit.horAlign.y(y + _textsViewMarginTop);
}

- (NSSize)contentSize {
    NSSize resultSize = [self.textsView sizeThatFits:NSSizeMax];
    
    if (self.titleView) {
        CGFloat titleWidth = [self.titleView sizeThatFits:NSSizeMax].width;
        resultSize.width = MAX(titleWidth, resultSize.width);
        resultSize.height += _titleHeight;
    }
    
    resultSize.width += _horInset * 2;
    resultSize.height += (_insetBottom + _textsViewMarginTop);
    
    return resultSize;
}

- (void)_handleJumpButton:(NSButton *)button {
    PickViewObject *object = [button pickview_getBindObjectForKey:@"jumpObject"];
    if (!object) {
        NSAssert(NO, @"");
        return;
    }
    if (self.requestJumpingToObject) {
        self.requestJumpingToObject(object);
    }
}

@end

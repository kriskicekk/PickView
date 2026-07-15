//
//  PVDetailConstraintPopoverController.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailConstraintPopoverController.h"
#import "PVAutoLayoutConstraint.h"
#import "PVDetailTextsMenuView.h"
#import "PVDetailTextFieldView.h"
#import "PVObject.h"
#import "PVAutoLayoutConstraint+PVClient.h"

@interface PVDetailConstraintPopoverController ()

@property(nonatomic, strong) PVDetailTextFieldView *titleView;
@property(nonatomic, strong) PVDetailTextsMenuView *textsView;
@property(nonatomic, strong) PVAutoLayoutConstraint *constraint;

@end

@implementation PVDetailConstraintPopoverController {
    CGFloat _horInset;
    CGFloat _insetBottom;
    CGFloat _titleHeight;
    CGFloat _textsViewMarginTop;
}

- (instancetype)initWithConstraint:(PVAutoLayoutConstraint *)constraint {
    if (self = [self initWithContainerView:nil]) {
        _horInset = 5;
        _insetBottom = 10;
        _titleHeight = 26;
        _textsViewMarginTop = 10;
        self.constraint = constraint;
        
        if (!constraint.effective) {
            self.titleView = [PVDetailTextFieldView labelView];
            self.titleView.textField.font = NSFontMake(IsEnglish ? 12 : 13);
            self.titleView.textColors = PVDetailColorsCombine(NSColorGray1, NSColorGray9);
            self.titleView.textField.alignment = NSTextAlignmentCenter;
            self.titleView.textField.stringValue = NSLocalizedString(@"The layout of selected view is not affected by this constraint.", nil);
            self.titleView.backgroundColors = PVDetailColorsCombine(PVColorRGBAMake(0, 0, 0, 0.1), PVColorRGBAMake(0, 0, 0, 0.2));
            self.titleView.image = NSImageMake(@"Constraint_Popover_Info");
            self.titleView.insets = NSEdgeInsetsMake(0, _horInset, 0, _horInset);
            [self.view addSubview:self.titleView];
        }
        
        self.textsView = [PVDetailTextsMenuView new];
        self.textsView.verSpace = 8;
        self.textsView.horSpace = 4;
        self.textsView.font = NSFontMake(13);
        self.textsView.type = PVDetailTextsMenuViewTypeCenter;
        [self.view addSubview:self.textsView];
    
        NSMutableArray<PVStringTwoTuple *> *texts = [NSMutableArray array];
        [texts addObject:[PVStringTwoTuple tupleWithFirst:@"FirstItem" second:[PVAutoLayoutConstraint descriptionWithItemObject:constraint.firstItem type:constraint.firstItemType detailed:YES]]];
        [texts addObject:[PVStringTwoTuple tupleWithFirst:@"FirstAttribute" second:[PVAutoLayoutConstraint descriptionWithAttributeInt:constraint.firstAttribute].lk_capitalizedString]];
        [texts addObject:[PVStringTwoTuple tupleWithFirst:@"Relation" second:[PVAutoLayoutConstraint descriptionWithRelation:constraint.relation]]];
        [texts addObject:[PVStringTwoTuple tupleWithFirst:@"SecondItem" second:[PVAutoLayoutConstraint descriptionWithItemObject:constraint.secondItem type:constraint.secondItemType detailed:YES]]];
        [texts addObject:[PVStringTwoTuple tupleWithFirst:@"SecondAttribute" second:[PVAutoLayoutConstraint descriptionWithAttributeInt:constraint.secondAttribute].lk_capitalizedString]];
        [texts addObject:[PVStringTwoTuple tupleWithFirst:@"Multiplier" second:[NSString stringWithFormat:@"%@", @(constraint.multiplier)]]];
        [texts addObject:[PVStringTwoTuple tupleWithFirst:@"Constant" second:[NSString stringWithFormat:@"%@", @(constraint.constant)]]];
        [texts addObject:[PVStringTwoTuple tupleWithFirst:@"Priority" second:[NSString stringWithFormat:@"%@", @(constraint.priority)]]];
        [texts addObject:[PVStringTwoTuple tupleWithFirst:@"Active" second:constraint.active ? @"YES" : @"NO"]];
        [texts addObject:[PVStringTwoTuple tupleWithFirst:@"ShouldBeArchived" second:constraint.shouldBeArchived ? @"YES" : @"NO"]];
        [texts addObject:[PVStringTwoTuple tupleWithFirst:@"Identifier" second:constraint.identifier ? : @""]];
        
        if (constraint.firstItemType == PVConstraintItemTypeView) {
            NSButton *button = [NSButton lk_buttonWithImage:NSImageMake(@"Icon_JumpDisclosure") target:self action:@selector(_handleJumpButton:)];
            [button pv_inspect_bindObject:constraint.firstItem forKey:@"jumpObject"];
            [self.textsView addButton:button atIndex:0];
            
        }
        if (constraint.secondItemType == PVConstraintItemTypeView) {
            NSButton *button = [NSButton lk_buttonWithImage:NSImageMake(@"Icon_JumpDisclosure") target:self action:@selector(_handleJumpButton:)];
            [button pv_inspect_bindObject:constraint.firstItem forKey:@"jumpObject"];
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
    PVObject *object = [button pv_inspect_getBindObjectForKey:@"jumpObject"];
    if (!object) {
        NSAssert(NO, @"");
        return;
    }
    if (self.requestJumpingToObject) {
        self.requestJumpingToObject(object);
    }
}

@end

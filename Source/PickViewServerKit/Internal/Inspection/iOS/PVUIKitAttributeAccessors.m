//
//  PVUIKitAttributeAccessors.m
//  PickViewServer
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVUIKitAttributeAccessors.h"

#import "CALayer+PVInspect.h"
#import "Color+PVInspect.h"
#import "NSArray+PVInspect.h"
#import "PVAutoLayoutConstraint.h"
#import "PVObject.h"
#import "PVInspectionObjectFactory.h"

#import <TargetConditionals.h>

#if TARGET_OS_IPHONE
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface UIView (PVUIKitAttributeAccessors)

@property(nonatomic, strong) NSMutableArray<NSLayoutConstraint *> *pv_lks_involvedRawConstraints;

- (UIViewController *)pv_lks_findHostViewController;
- (NSArray<PVAutoLayoutConstraint *> *)pv_lks_constraints;
- (float)pv_lks_horizontalContentHuggingPriority;
- (float)pv_lks_verticalContentHuggingPriority;
- (float)pv_lks_horizontalContentCompressionResistancePriority;
- (float)pv_lks_verticalContentCompressionResistancePriority;

@end

@implementation NSObject (PVUIKitAttributeAccessors)

- (NSArray<NSString *> *)pv_lks_classChainList {
    NSMutableArray<NSString *> *classNames = [NSMutableArray array];
    Class cls = self.class;
    while (cls) {
        [classNames addObject:NSStringFromClass(cls)];
        cls = class_getSuperclass(cls);
    }
    return classNames.copy;
}

@end

@implementation CALayer (PVUIKitAttributeAccessors)

- (NSArray<NSArray<NSString *> *> *)pv_lks_relatedClassChainList {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:2];
    if (self.pv_inspect_hostView) {
        [array addObject:[self.class pv_lks_classListOfObject:self.pv_inspect_hostView endingClass:@"UIView"]];
        UIViewController *viewController = [self.pv_inspect_hostView pv_lks_findHostViewController];
        if (viewController) {
            [array addObject:[self.class pv_lks_classListOfObject:viewController endingClass:@"UIViewController"]];
        }
    } else {
        [array addObject:[self.class pv_lks_classListOfObject:self endingClass:@"CALayer"]];
    }
    return array.copy;
}

+ (NSArray<NSString *> *)pv_lks_classListOfObject:(id)object endingClass:(NSString *)endingClass {
    NSArray<NSString *> *completedList = [object pv_lks_classChainList];
    NSUInteger endingIndex = [completedList indexOfObject:endingClass];
    if (endingIndex != NSNotFound) {
        completedList = [completedList subarrayWithRange:NSMakeRange(0, endingIndex + 1)];
    }
    return completedList;
}

- (NSArray<NSString *> *)pv_lks_selfRelation {
    NSMutableArray *array = [NSMutableArray array];
    if (self.pv_inspect_hostView) {
        UIViewController *viewController = [self.pv_inspect_hostView pv_lks_findHostViewController];
        if (viewController) {
            [array addObject:[NSString stringWithFormat:@"(%@ *).view", NSStringFromClass(viewController.class)]];
        }
        [array addObject:[NSString stringWithFormat:@"self: (%@ *) %p", NSStringFromClass(self.pv_inspect_hostView.class), self.pv_inspect_hostView]];
        if (self.pv_inspect_hostView.superview) {
            [array addObject:[NSString stringWithFormat:@"superview: (%@ *) %p", NSStringFromClass(self.pv_inspect_hostView.superview.class), self.pv_inspect_hostView.superview]];
        }
        if (self.pv_inspect_hostView.window) {
            [array addObject:[NSString stringWithFormat:@"window: (%@ *) %p", NSStringFromClass(self.pv_inspect_hostView.window.class), self.pv_inspect_hostView.window]];
        }
    } else {
        [array addObject:[NSString stringWithFormat:@"self: (%@ *) %p", NSStringFromClass(self.class), self]];
        if (self.superlayer) {
            [array addObject:[NSString stringWithFormat:@"superlayer: (%@ *) %p", NSStringFromClass(self.superlayer.class), self.superlayer]];
        }
    }
    return array.count ? array.copy : nil;
}

- (UIColor *)pv_lks_backgroundColor {
    return self.backgroundColor ? [UIColor colorWithCGColor:self.backgroundColor] : nil;
}

- (UIColor *)pv_lks_borderColor {
    return self.borderColor ? [UIColor colorWithCGColor:self.borderColor] : nil;
}

- (UIColor *)pv_lks_shadowColor {
    return self.shadowColor ? [UIColor colorWithCGColor:self.shadowColor] : nil;
}

- (CGFloat)pv_lks_shadowOffsetWidth {
    return self.shadowOffset.width;
}

- (CGFloat)pv_lks_shadowOffsetHeight {
    return self.shadowOffset.height;
}

- (void)setLks_backgroundColor:(UIColor *)color {
    self.backgroundColor = color.CGColor;
}

- (void)setLks_borderColor:(UIColor *)color {
    self.borderColor = color.CGColor;
}

- (void)setLks_shadowColor:(UIColor *)color {
    self.shadowColor = color.CGColor;
}

- (void)setLks_shadowOffsetWidth:(CGFloat)width {
    CGSize offset = self.shadowOffset;
    offset.width = width;
    self.shadowOffset = offset;
}

- (void)setLks_shadowOffsetHeight:(CGFloat)height {
    CGSize offset = self.shadowOffset;
    offset.height = height;
    self.shadowOffset = offset;
}

@end

@implementation UIView (PVUIKitAttributeAccessors)

- (UIViewController *)pv_lks_findHostViewController {
    UIResponder *responder = self.nextResponder;
    if (![responder isKindOfClass:UIViewController.class]) {
        return nil;
    }
    UIViewController *viewController = (UIViewController *)responder;
    return viewController.view == self ? viewController : nil;
}

- (void)setPv_lks_involvedRawConstraints:(NSMutableArray<NSLayoutConstraint *> *)constraints {
    objc_setAssociatedObject(self, @selector(pv_lks_involvedRawConstraints), constraints, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray<NSLayoutConstraint *> *)pv_lks_involvedRawConstraints {
    NSMutableArray<NSLayoutConstraint *> *constraints = objc_getAssociatedObject(self, @selector(pv_lks_involvedRawConstraints));
    if (!constraints) {
        constraints = [NSMutableArray array];
        self.pv_lks_involvedRawConstraints = constraints;
    }
    return constraints;
}

+ (void)pv_lks_rebuildGlobalInvolvedRawConstraintsWithWindows:(NSArray<UIWindow *> *)windows {
    for (UIWindow *window in windows) {
        [self pv_lks_removeInvolvedRawConstraintsForViewsRootedByView:window];
    }
    for (UIWindow *window in windows) {
        [self pv_lks_addInvolvedRawConstraintsForViewsRootedByView:window];
    }
}

+ (void)pv_lks_addInvolvedRawConstraintsForViewsRootedByView:(UIView *)rootView {
    for (NSLayoutConstraint *constraint in rootView.constraints) {
        UIView *firstView = [constraint.firstItem isKindOfClass:UIView.class] ? constraint.firstItem : nil;
        if (firstView && ![firstView.pv_lks_involvedRawConstraints containsObject:constraint]) {
            [firstView.pv_lks_involvedRawConstraints addObject:constraint];
        }

        UIView *secondView = [constraint.secondItem isKindOfClass:UIView.class] ? constraint.secondItem : nil;
        if (secondView && ![secondView.pv_lks_involvedRawConstraints containsObject:constraint]) {
            [secondView.pv_lks_involvedRawConstraints addObject:constraint];
        }
    }

    for (UIView *subview in rootView.subviews) {
        [self pv_lks_addInvolvedRawConstraintsForViewsRootedByView:subview];
    }
}

+ (void)pv_lks_removeInvolvedRawConstraintsForViewsRootedByView:(UIView *)rootView {
    [rootView.pv_lks_involvedRawConstraints removeAllObjects];
    for (UIView *subview in rootView.subviews) {
        [self pv_lks_removeInvolvedRawConstraintsForViewsRootedByView:subview];
    }
}

- (NSArray<PVAutoLayoutConstraint *> *)pv_lks_constraints {
    NSMutableArray<NSLayoutConstraint *> *effectiveConstraints = [NSMutableArray array];
    [effectiveConstraints addObjectsFromArray:[self constraintsAffectingLayoutForAxis:UILayoutConstraintAxisHorizontal]];
    [effectiveConstraints addObjectsFromArray:[self constraintsAffectingLayoutForAxis:UILayoutConstraintAxisVertical]];

    NSArray<PVAutoLayoutConstraint *> *constraints = [self.pv_lks_involvedRawConstraints pv_inspect_map:^id(NSUInteger idx, NSLayoutConstraint *constraint) {
        if (!constraint.active) {
            return nil;
        }
        BOOL isEffective = [effectiveConstraints containsObject:constraint];
        PVConstraintItemType firstItemType = [self pv_lks_constraintItemTypeForItem:constraint.firstItem];
        PVConstraintItemType secondItemType = [self pv_lks_constraintItemTypeForItem:constraint.secondItem];
        return [PVInspectionObjectFactory constraintForConstraint:constraint
                                                      isEffective:isEffective
                                                    firstItemType:firstItemType
                                                   secondItemType:secondItemType];
    }];
    return constraints.count ? constraints : nil;
}

- (PVConstraintItemType)pv_lks_constraintItemTypeForItem:(id)item {
    if (!item) {
        return PVConstraintItemTypeNil;
    }
    if (item == self) {
        return PVConstraintItemTypeSelf;
    }
    if (item == self.superview) {
        return PVConstraintItemTypeSuper;
    }
    if (@available(iOS 9.0, *)) {
        if ([item isKindOfClass:UILayoutGuide.class]) {
            return PVConstraintItemTypeLayoutGuide;
        }
    }
    NSString *className = NSStringFromClass([item class]);
    if ([className hasSuffix:@"_UILayoutGuide"]) {
        return PVConstraintItemTypeLayoutGuide;
    }
    if ([item isKindOfClass:UIView.class]) {
        return PVConstraintItemTypeView;
    }
    return PVConstraintItemTypeUnknown;
}

- (float)pv_lks_horizontalContentHuggingPriority {
    return [self contentHuggingPriorityForAxis:UILayoutConstraintAxisHorizontal];
}

- (float)pv_lks_verticalContentHuggingPriority {
    return [self contentHuggingPriorityForAxis:UILayoutConstraintAxisVertical];
}

- (float)pv_lks_horizontalContentCompressionResistancePriority {
    return [self contentCompressionResistancePriorityForAxis:UILayoutConstraintAxisHorizontal];
}

- (float)pv_lks_verticalContentCompressionResistancePriority {
    return [self contentCompressionResistancePriorityForAxis:UILayoutConstraintAxisVertical];
}

- (void)setLks_horizontalContentHuggingPriority:(float)priority {
    [self setContentHuggingPriority:priority forAxis:UILayoutConstraintAxisHorizontal];
}

- (void)setLks_verticalContentHuggingPriority:(float)priority {
    [self setContentHuggingPriority:priority forAxis:UILayoutConstraintAxisVertical];
}

- (void)setLks_horizontalContentCompressionResistancePriority:(float)priority {
    [self setContentCompressionResistancePriority:priority forAxis:UILayoutConstraintAxisHorizontal];
}

- (void)setLks_verticalContentCompressionResistancePriority:(float)priority {
    [self setContentCompressionResistancePriority:priority forAxis:UILayoutConstraintAxisVertical];
}

@end

@implementation UIImageView (PVUIKitAttributeAccessors)

- (NSString *)pv_lks_imageSourceName {
    return nil;
}

- (NSNumber *)pv_lks_imageViewOidIfHasImage {
    return self.image ? @((unsigned long)(uintptr_t)self) : nil;
}

@end

@implementation UILabel (PVUIKitAttributeAccessors)

- (CGFloat)pv_lks_fontSize {
    return self.font.pointSize;
}

- (void)setLks_fontSize:(CGFloat)fontSize {
    UIFont *font = self.font ?: [UIFont systemFontOfSize:UIFont.systemFontSize];
    self.font = [UIFont fontWithName:font.fontName size:fontSize] ?: [UIFont systemFontOfSize:fontSize];
}

- (NSString *)pv_lks_fontName {
    return self.font.fontName;
}

@end

@implementation UITextView (PVUIKitAttributeAccessors)

- (CGFloat)pv_lks_fontSize {
    return self.font.pointSize;
}

- (void)setLks_fontSize:(CGFloat)fontSize {
    UIFont *font = self.font ?: [UIFont systemFontOfSize:UIFont.systemFontSize];
    self.font = [UIFont fontWithName:font.fontName size:fontSize] ?: [UIFont systemFontOfSize:fontSize];
}

- (NSString *)pv_lks_fontName {
    return self.font.fontName;
}

@end

@implementation UITextField (PVUIKitAttributeAccessors)

- (CGFloat)pv_lks_fontSize {
    return self.font.pointSize;
}

- (void)setLks_fontSize:(CGFloat)fontSize {
    UIFont *font = self.font ?: [UIFont systemFontOfSize:UIFont.systemFontSize];
    self.font = [UIFont fontWithName:font.fontName size:fontSize] ?: [UIFont systemFontOfSize:fontSize];
}

- (NSString *)pv_lks_fontName {
    return self.font.fontName;
}

@end

@implementation UITableView (PVUIKitAttributeAccessors)

- (NSArray<NSNumber *> *)pv_lks_numberOfRows {
    NSUInteger sectionsCount = MIN(self.numberOfSections, 10);
    NSArray<NSNumber *> *rowsCount = [NSArray pv_inspect_arrayWithCount:sectionsCount block:^id(NSUInteger idx) {
        return @([self numberOfRowsInSection:idx]);
    }];
    return rowsCount.count ? rowsCount : nil;
}

@end

@implementation UIVisualEffectView (PVUIKitAttributeAccessors)

- (NSNumber *)pv_lks_blurEffectStyleNumber {
    UIVisualEffect *effect = self.effect;
    if (![effect isKindOfClass:UIBlurEffect.class]) {
        return nil;
    }
    id style = [effect valueForKey:@"style"];
    return [style isKindOfClass:NSNumber.class] ? style : nil;
}

- (void)setLks_blurEffectStyleNumber:(NSNumber *)styleNumber {
    if (![styleNumber isKindOfClass:NSNumber.class]) {
        return;
    }
    self.effect = [UIBlurEffect effectWithStyle:styleNumber.integerValue];
}

@end

#endif

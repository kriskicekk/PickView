//
//  LKDashboardAttributeConstraintsItemControl.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "LKDashboardAttributeConstraintsItemControl.h"
#import "PickViewAutoLayoutConstraint.h"
#import "PickViewObject.h"
#import "PickViewAutoLayoutConstraint+PickViewClient.h"

@implementation LKDashboardAttributeConstraintsItemControl

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        @weakify(self);
        self.label.alignment = NSTextAlignmentLeft;
        self.label.font = NSFontMake(12);
        self.didChangeAppearance = ^(LKBaseControl *control, BOOL isDarkMode) {
            @strongify(self);
            [self _updateLabelColor];
        };
    }
    return self;
}

- (void)setConstraint:(PickViewAutoLayoutConstraint *)constraint {
    _constraint = constraint;
    self.label.stringValue = [self _stringFromConstraint:constraint];
    [self _updateLabelColor];
}

- (void)_updateLabelColor {
    if (self.constraint.effective) {
        self.label.textColor = [NSColor labelColor];
    } else {
        if ([self.effectiveAppearance lk_isDarkMode]) {
            self.label.textColor = PickViewColorMake(130, 131, 132);
        } else {
            self.label.textColor = PickViewColorMake(150, 151, 152);
        }
    }
}

- (NSString *)_stringFromConstraint:(PickViewAutoLayoutConstraint *)constraint {
    NSMutableString *string = [NSMutableString string];
    [string appendFormat:@"%@.%@ %@",
     [PickViewAutoLayoutConstraint descriptionWithItemObject:constraint.firstItem type:constraint.firstItemType detailed:NO],
     [PickViewAutoLayoutConstraint descriptionWithAttributeInt:constraint.firstAttribute],
     [PickViewAutoLayoutConstraint symbolWithRelation:constraint.relation]];
    
    if (constraint.secondAttribute == 0) {
        [string appendFormat:@" %@", [NSString pickview_stringFromDouble:constraint.constant decimal:3]];
    } else {
        [string appendFormat:@" %@.%@",
         [PickViewAutoLayoutConstraint descriptionWithItemObject:constraint.secondItem type:constraint.secondItemType detailed:NO],
         [PickViewAutoLayoutConstraint descriptionWithAttributeInt:constraint.secondAttribute]];
        
        if (constraint.multiplier != 1) {
            [string appendFormat:@" * %@", [NSString pickview_stringFromDouble:constraint.multiplier decimal:3]];
        }
        if (constraint.constant > 0) {
            [string appendFormat:@" + %@", [NSString pickview_stringFromDouble:constraint.constant decimal:3]];
        } else if (constraint.constant < 0) {
            [string appendFormat:@" - %@", [NSString pickview_stringFromDouble:-constraint.constant decimal:3]];
        }
    }
    
    if (constraint.priority != 1000) {
        [string appendFormat:@" @ %@", @(constraint.priority)];
    }
    
    return string;
}

- (BOOL)shouldTrackMouseEnteredAndExited {
    return YES;
}

- (void)mouseEntered:(NSEvent *)event {
    [super mouseEntered:event];
    self.alphaValue = .5;
}

- (void)mouseExited:(NSEvent *)event {
    [super mouseExited:event];
    self.alphaValue = 1;
}

@end

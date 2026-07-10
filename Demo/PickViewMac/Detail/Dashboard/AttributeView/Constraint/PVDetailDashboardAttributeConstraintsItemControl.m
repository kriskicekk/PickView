//
//  PVDetailDashboardAttributeConstraintsItemControl.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailDashboardAttributeConstraintsItemControl.h"
#import "PVAutoLayoutConstraint.h"
#import "PVObject.h"
#import "PVAutoLayoutConstraint+PVClient.h"

@implementation PVDetailDashboardAttributeConstraintsItemControl

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        @weakify(self);
        self.label.alignment = NSTextAlignmentLeft;
        self.label.font = NSFontMake(12);
        self.didChangeAppearance = ^(PVDetailBaseControl *control, BOOL isDarkMode) {
            @strongify(self);
            [self _updateLabelColor];
        };
    }
    return self;
}

- (void)setConstraint:(PVAutoLayoutConstraint *)constraint {
    _constraint = constraint;
    self.label.stringValue = [self _stringFromConstraint:constraint];
    [self _updateLabelColor];
}

- (void)_updateLabelColor {
    if (self.constraint.effective) {
        self.label.textColor = [NSColor labelColor];
    } else {
        if ([self.effectiveAppearance lk_isDarkMode]) {
            self.label.textColor = PVColorMake(130, 131, 132);
        } else {
            self.label.textColor = PVColorMake(150, 151, 152);
        }
    }
}

- (NSString *)_stringFromConstraint:(PVAutoLayoutConstraint *)constraint {
    NSMutableString *string = [NSMutableString string];
    [string appendFormat:@"%@.%@ %@",
     [PVAutoLayoutConstraint descriptionWithItemObject:constraint.firstItem type:constraint.firstItemType detailed:NO],
     [PVAutoLayoutConstraint descriptionWithAttributeInt:constraint.firstAttribute],
     [PVAutoLayoutConstraint symbolWithRelation:constraint.relation]];
    
    if (constraint.secondAttribute == 0) {
        [string appendFormat:@" %@", [NSString pv_inspect_stringFromDouble:constraint.constant decimal:3]];
    } else {
        [string appendFormat:@" %@.%@",
         [PVAutoLayoutConstraint descriptionWithItemObject:constraint.secondItem type:constraint.secondItemType detailed:NO],
         [PVAutoLayoutConstraint descriptionWithAttributeInt:constraint.secondAttribute]];
        
        if (constraint.multiplier != 1) {
            [string appendFormat:@" * %@", [NSString pv_inspect_stringFromDouble:constraint.multiplier decimal:3]];
        }
        if (constraint.constant > 0) {
            [string appendFormat:@" + %@", [NSString pv_inspect_stringFromDouble:constraint.constant decimal:3]];
        } else if (constraint.constant < 0) {
            [string appendFormat:@" - %@", [NSString pv_inspect_stringFromDouble:-constraint.constant decimal:3]];
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

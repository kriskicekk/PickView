//
//  LKDashboardAttributeView.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "LKDashboardAttributeView.h"
#import "PickViewDisplayItem.h"
#import "LKDashboardViewController.h"
#import "PickViewDashboardBlueprint.h"

@implementation LKDashboardAttributeView

- (void)setAttribute:(PVAttribute *)attribute {
    _attribute = attribute;
    [self renderWithAttribute];
}

- (BOOL)canEdit {
    if (self.attribute.isUserCustom) {
        if (self.attribute.customSetterID.length > 0) {
            return YES;
        } else {
            return NO;            
        }
    }
    SEL setter = [PickViewDashboardBlueprint setterWithAttrID:self.attribute.identifier];
    return setter && self.dashboardViewController.isStaticMode;
}

- (void)renderWithAttribute {
    // do nothing
}

- (NSUInteger)numberOfColumnsOccupied {
    return 1;
}

@end

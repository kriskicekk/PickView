//
//  PVDetailDashboardAttributeView.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailDashboardAttributeView.h"
#import "PVDisplayItem.h"
#import "PVDetailDashboardViewController.h"
#import "PVDashboardBlueprint.h"

@implementation PVDetailDashboardAttributeView

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
    SEL setter = [PVDashboardBlueprint setterWithAttrID:self.attribute.identifier];
    return setter && self.dashboardViewController.isStaticMode;
}

- (void)renderWithAttribute {
    // do nothing
}

- (NSUInteger)numberOfColumnsOccupied {
    return 1;
}

@end

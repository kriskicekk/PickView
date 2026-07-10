//
//  PVAttributesGroup+PickViewClient.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVAttributesGroup+PickViewClient.h"
#import "PickViewDashboardBlueprint.h"

@implementation PVAttributesGroup (PickViewClient)

- (NSString *)queryDisplayTitle {
    if (self.userCustomTitle.length > 0) {
        return self.userCustomTitle;
    } else {
        return [PickViewDashboardBlueprint groupTitleWithGroupID:self.identifier];
    }
}

@end

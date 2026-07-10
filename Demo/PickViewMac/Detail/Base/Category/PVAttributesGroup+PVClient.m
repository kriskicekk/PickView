//
//  PVAttributesGroup+PVClient.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVAttributesGroup+PVClient.h"
#import "PVDashboardBlueprint.h"

@implementation PVAttributesGroup (PVClient)

- (NSString *)queryDisplayTitle {
    if (self.userCustomTitle.length > 0) {
        return self.userCustomTitle;
    } else {
        return [PVDashboardBlueprint groupTitleWithGroupID:self.identifier];
    }
}

@end

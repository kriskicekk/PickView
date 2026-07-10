//
//  PVAttributesGroup+PVClient.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVAttributesGroup+PVClient.h"
#import "PVDashboardBlueprint.h"
#import "PVDetailAppsManager.h"
#import "PVClientSession.h"
#import "PVPeerIdentity.h"

@implementation PVAttributesGroup (PVClient)

- (NSString *)queryDisplayTitle {
    if (self.userCustomTitle.length > 0) {
        return self.userCustomTitle;
    }
    if ([PVDetailAppsManager sharedInstance].inspectingApp.session.peerIdentity.uiFramework == PVPeerUIFrameworkAppKit) {
        NSDictionary<PVAttrGroupIdentifier, NSString *> *titles = @{
            PVAttrGroup_ViewLayer: @"CALayer / NSView",
            PVAttrGroup_UIStackView: @"NSStackView",
            PVAttrGroup_UIImageView: @"NSImageView",
            PVAttrGroup_UILabel: @"NSTextField / NSButton",
            PVAttrGroup_UIControl: @"NSControl",
            PVAttrGroup_UIButton: @"NSButton",
            PVAttrGroup_UIScrollView: @"NSScrollView",
            PVAttrGroup_UITextView: @"NSTextView",
            PVAttrGroup_UITextField: @"NSTextField"
        };
        NSString *title = titles[self.identifier];
        if (title.length) {
            return title;
        }
    }
    return [PVDashboardBlueprint groupTitleWithGroupID:self.identifier];
}

@end

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

    PVPeerUIFramework framework = [PVDetailAppsManager sharedInstance].inspectingApp.session.peerIdentity.uiFramework;
    if (framework == PVPeerUIFrameworkUIKit) {
        NSDictionary<PVAttrGroupIdentifier, NSString *> *titles = @{
            PVAttrGroup_ViewLayer: @"CALayer / UIView",
            PVAttrGroup_UIStackView: @"UIStackView",
            PVAttrGroup_UIVisualEffectView: @"UIVisualEffectView",
            PVAttrGroup_UIImageView: @"UIImageView",
            PVAttrGroup_UILabel: @"UILabel",
            PVAttrGroup_UIControl: @"UIControl",
            PVAttrGroup_UIButton: @"UIButton",
            PVAttrGroup_UIScrollView: @"UIScrollView",
            PVAttrGroup_UITableView: @"UITableView",
            PVAttrGroup_UITextView: @"UITextView",
            PVAttrGroup_UITextField: @"UITextField",
            PVAttrGroup_UIWindowScene: @"UIWindowScene",
            PVAttrGroup_UITraitCollection: @"UITraitCollection"
        };
        NSString *title = titles[self.identifier];
        if (title.length) {
            return title;
        }
    } else if (framework == PVPeerUIFrameworkAppKit) {
        NSDictionary<PVAttrGroupIdentifier, NSString *> *legacyTitles = @{
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
        NSString *title = legacyTitles[self.identifier];
        if (title.length) {
            return title;
        }
    }
    return [PVDashboardBlueprint groupTitleWithGroupID:self.identifier];
}

@end

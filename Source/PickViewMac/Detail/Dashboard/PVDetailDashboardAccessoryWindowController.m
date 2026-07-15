//
//  PVDetailDashboardAccessoryWindowController.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailDashboardAccessoryWindowController.h"
#import "PVDetailDashboardSectionView.h"
#import "PVAttributesSection.h"
#import "PVDashboardBlueprint.h"
#import "PVDetailPopPanel.h"

@interface PVDetailDashboardAccessoryWindowController () <NSWindowDelegate>

@property(nonatomic, copy) PVAttrGroupIdentifier groupID;
@property(nonatomic, weak) PVDetailDashboardViewController *dashboardController;
/// key 是 PVAttrSectionIdentifier
@property(nonatomic, strong) NSMutableDictionary<PVAttrSectionIdentifier, PVDetailDashboardSectionView *> *sectionViews;

@end

@implementation PVDetailDashboardAccessoryWindowController

- (instancetype)initWithDashboardController:(PVDetailDashboardViewController *)dashboardController attrGroupID:(PVAttrGroupIdentifier)groupID {
    self.groupID = groupID;
    self.dashboardController = dashboardController;
    self.sectionViews = [NSMutableDictionary dictionary];
    
    PVDetailPopPanel *panel = [[PVDetailPopPanel alloc] initWithSize:NSMakeSize(400, 100)];
    panel.delegate = self;

    return [self initWithWindow:panel];
}

- (NSSize)renderWithAttrSections:(NSArray<PVAttributesSection *> *)sections {
    NSMutableArray<PVDetailDashboardSectionView *> *needlessViews = [self.sectionViews allValues].mutableCopy;
    
    [sections enumerateObjectsUsingBlock:^(PVAttributesSection * _Nonnull attrSec, NSUInteger idx, BOOL * _Nonnull stop) {
        PVDetailDashboardSectionView *view = self.sectionViews[attrSec.identifier];
        if (view) {
            [needlessViews removeObject:view];
            view.hidden = NO;
        } else {
            view = [PVDetailDashboardSectionView new];
            self.sectionViews[attrSec.identifier] = view;
        }
        
        view.dashboardViewController = self.dashboardController;
        view.manageState = PVDetailDashboardSectionManageState_CanAdd;
        view.attrSection = attrSec;
        view.showTopSeparator = (idx != 0);
        [self.window.contentView addSubview:view];
    }];
    
    [needlessViews enumerateObjectsUsingBlock:^(PVDetailDashboardSectionView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hidden = YES;
    }];
    
    // layout
    CGFloat normalSecWidth = DashboardViewWidth - DashboardHorInset * 2;
    __block CGFloat y = 8;
    [[PVDashboardBlueprint sectionIDsForGroupID:self.groupID] enumerateObjectsUsingBlock:^(PVAttrSectionIdentifier _Nonnull secID, NSUInteger idx, BOOL * _Nonnull stop) {
        PVDetailDashboardSectionView *view = self.sectionViews[secID];
        if (!view || view.hidden) {
            return;
        }
        $(view).x(DashboardHorInset).width(normalSecWidth - DashboardHorInset * 2).heightToFit.y(y);
        y = view.$maxY + DashboardSectionMarginTop;
    }];
    
    return NSMakeSize(normalSecWidth + 23, y);
}

#pragma mark - <NSWindowDelegate>

- (void)windowWillClose:(NSNotification *)notification {
    if ([self.delegate respondsToSelector:@selector(dashboardAccessoryWindowControllerWillClose:)]) {
        [self.delegate dashboardAccessoryWindowControllerWillClose:self];
    }
}

@end

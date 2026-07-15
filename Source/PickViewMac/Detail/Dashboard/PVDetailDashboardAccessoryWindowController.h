//
//  PVDetailDashboardAccessoryWindowController.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailWindowController.h"
#import "PVAttrIdentifiers.h"

@class PVAttributesSection, PVDetailDashboardViewController, PVDetailDashboardAccessoryWindowController;

@protocol PVDetailDashboardAccessoryWindowControllerDelegate <NSObject>

- (void)dashboardAccessoryWindowControllerWillClose:(PVDetailDashboardAccessoryWindowController *)controller;

@end

@interface PVDetailDashboardAccessoryWindowController : PVDetailWindowController

@property(nonatomic, weak) id<PVDetailDashboardAccessoryWindowControllerDelegate> delegate;

/// contentSize 是内容所需的窗口大小，由该方法返回
- (instancetype)initWithDashboardController:(PVDetailDashboardViewController *)dashboardController attrGroupID:(PVAttrGroupIdentifier)groupID;

- (NSSize)renderWithAttrSections:(NSArray<PVAttributesSection *> *)sections;

@end

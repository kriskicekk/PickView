//
//  LKDashboardAccessoryWindowController.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "LKWindowController.h"
#import "PVAttrIdentifiers.h"

@class PVAttributesSection, LKDashboardViewController, LKDashboardAccessoryWindowController;

@protocol LKDashboardAccessoryWindowControllerDelegate <NSObject>

- (void)dashboardAccessoryWindowControllerWillClose:(LKDashboardAccessoryWindowController *)controller;

@end

@interface LKDashboardAccessoryWindowController : LKWindowController

@property(nonatomic, weak) id<LKDashboardAccessoryWindowControllerDelegate> delegate;

/// contentSize 是内容所需的窗口大小，由该方法返回
- (instancetype)initWithDashboardController:(LKDashboardViewController *)dashboardController attrGroupID:(PVAttrGroupIdentifier)groupID;

- (NSSize)renderWithAttrSections:(NSArray<PVAttributesSection *> *)sections;

@end

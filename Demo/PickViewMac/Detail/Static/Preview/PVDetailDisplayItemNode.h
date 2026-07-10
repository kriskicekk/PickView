//
//  PVDetailDisplayItemNode.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import <SceneKit/SceneKit.h>

@class PVDisplayItem, PVDetailPreferenceManager, PVDetailHierarchyDataSource;

@interface PVDetailDisplayItemNode : SCNNode

- (instancetype)initWithDataSource:(PVDetailHierarchyDataSource *)dataSource;

/// 在全部 displayItems 里的 idx
@property(nonatomic, assign) NSUInteger index;

@property(nonatomic, assign) CGSize screenSize;

@property(nonatomic, weak) PVDetailPreferenceManager *preferenceManager;

@property(nonatomic, strong) PVDisplayItem *displayItem;

@property(nonatomic, assign) BOOL isDarkMode;

@end

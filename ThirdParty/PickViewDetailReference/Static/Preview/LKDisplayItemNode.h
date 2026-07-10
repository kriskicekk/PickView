//
//  LKDisplayItemNode.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import <SceneKit/SceneKit.h>

@class PickViewDisplayItem, LKPreferenceManager, LKHierarchyDataSource;

@interface LKDisplayItemNode : SCNNode

- (instancetype)initWithDataSource:(LKHierarchyDataSource *)dataSource;

/// 在全部 displayItems 里的 idx
@property(nonatomic, assign) NSUInteger index;

@property(nonatomic, assign) CGSize screenSize;

@property(nonatomic, weak) LKPreferenceManager *preferenceManager;

@property(nonatomic, strong) PickViewDisplayItem *displayItem;

@property(nonatomic, assign) BOOL isDarkMode;

@end

//
//  PVDetailConsoleDataSource.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import <Foundation/Foundation.h>

@class PVDetailConsoleDataSourceRowItem, PVObject, PVDetailHierarchyDataSource;

@interface PVDetailConsoleDataSource : NSObject

- (instancetype)initWithHierarchyDataSource:(PVDetailHierarchyDataSource *)hierarchyDataSource;

@property(nonatomic, copy) NSArray<PVDetailConsoleDataSourceRowItem *> *rowItems;

@property(nonatomic, strong, readonly) PVObject *currentObject;
- (RACSignal *)makeObjectAsCurrent:(PVObject *)obj;
- (NSArray<NSString *> *)currentObjectSelectorNameList;

- (RACSignal *)submit:(NSString *)text;
- (RACSignal *)submitWithObj:(PVObject *)obj text:(NSString *)text;

/// 越晚被加入的 object 在 recentObjects 数组中的 idx 越小，tuple.first 是 PVObject，tuple.second 是当初返回这个对象时输入的命令文字
@property(nonatomic, strong, readonly) NSMutableArray<RACTwoTuple *> *recentObjects;

/// 当前在主窗口中高亮选择的 View/Layer/ViewController 对象
@property(nonatomic, strong, readonly) NSArray<PVObject *> *selectedObjects;

/// 清空记录
- (void)clearHistoryContents;

/// 当 console 被显示和隐藏时请及时设置该属性，当该属性为 YES 时，该 dataSource 会自动拉取当前所选 UI 对象的数据（当 syncConsoleTarget 为 YES 时）
@property(nonatomic, assign) BOOL isShowingConsole;

@end

//
//  PVDetailConsoleDataSourceRowItem.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PVDetailConsoleDataSourceRowItemType) {
    PVDetailConsoleDataSourceRowItemTypeInput,
    PVDetailConsoleDataSourceRowItemTypeSubmit,
    PVDetailConsoleDataSourceRowItemTypeReturn,
};

@interface PVDetailConsoleDataSourceRowItem : NSObject

@property(nonatomic, assign) PVDetailConsoleDataSourceRowItemType type;

/// 仅 type 为 PVDetailConsoleDataSourceRowItemTypeReturn 时，该属性有效
@property(nonatomic, copy) NSString *highlightText;

@property(nonatomic, copy) NSString *normalText;

@end

//
//  PVDetailWindowToolbarHelper.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import <Foundation/Foundation.h>

extern NSToolbarItemIdentifier const PVDetailToolBarIdentifier_Dimension;
extern NSToolbarItemIdentifier const PVDetailToolBarIdentifier_Scale;
extern NSToolbarItemIdentifier const PVDetailToolBarIdentifier_Rotation;
extern NSToolbarItemIdentifier const PVDetailToolBarIdentifier_Setting;
extern NSToolbarItemIdentifier const PVDetailToolBarIdentifier_Reload;
extern NSToolbarItemIdentifier const PVDetailToolBarIdentifier_App;
extern NSToolbarItemIdentifier const PVDetailToolBarIdentifier_AppInReadMode;
extern NSToolbarItemIdentifier const PVDetailToolBarIdentifier_Console;
extern NSToolbarItemIdentifier const PVDetailToolBarIdentifier_Add;
extern NSToolbarItemIdentifier const PVDetailToolBarIdentifier_Remove;
extern NSToolbarItemIdentifier const PVDetailToolBarIdentifier_Measure;
extern NSToolbarItemIdentifier const PVDetailToolBarIdentifier_Message;
extern NSToolbarItemIdentifier const PVDetailToolBarIdentifier_FastMode;

@class PVDetailPreferenceManager, PVAppInfo;

@interface PVDetailWindowToolbarHelper : NSObject

+ (instancetype)sharedInstance;

/**
 通过以下 identifier 创建的 toolBarItem 需要业务自己设置点击 action:
 - Reload
 - App
 - Expansion
 - DynamicMode
 - StaticMode
 - RemoteSelect
 - Add
 - Remove
 - Setting
 - Change
 */
- (NSToolbarItem *)makeToolBarItemWithIdentifier:(NSToolbarItemIdentifier)identifier preferenceManager:(PVDetailPreferenceManager *)manager;

/// 请使用该方法初始化 AppInReadMode 这个 item
- (NSToolbarItem *)makeAppInReadModeItemWithAppInfo:(PVAppInfo *)appInfo;

@end

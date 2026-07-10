//
//  PVDetailUserActionManager.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import <Foundation/Foundation.h>

@class PVDetailUserActionManager;

typedef NS_ENUM(NSInteger, PVDetailUserActionType) {
    PVDetailUserActionType_None,
    PVDetailUserActionType_PreviewOperation,  // 在 preview 里执行了 click、double click、pan 之类的操作
    PVDetailUserActionType_DashboardClick,    // 点击了 dashboard
    PVDetailUserActionType_SelectedItemChange,    // selectedItem 改变了
};

@protocol PVDetailUserActionManagerDelegate <NSObject>

/// 当 sendAction 被业务调用时，该 delegate 方法也会被调用
- (void)PVDetailUserActionManager:(PVDetailUserActionManager *)manager didAct:(PVDetailUserActionType)type;

@end

@interface PVDetailUserActionManager : NSObject

+ (instancetype)sharedInstance;

/// 业务调用该方法
- (void)sendAction:(PVDetailUserActionType)type;

/// delegate 不会被该类强引用，也无需在 delegate 对象被 dealloc 时设法 removeDelegate 之类的，相同的 delegate 被重复添加只会视为被添加一次
- (void)addDelegate:(id<PVDetailUserActionManagerDelegate>)delegate;

@end

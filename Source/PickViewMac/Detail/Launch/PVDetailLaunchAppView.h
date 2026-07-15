//
//  PVDetailLaunchAppView.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailBaseView.h"

@class PVDetailInspectableApp;

@interface PVDetailLaunchAppView : PVDetailBaseControl

/// 默认为 NO
@property(nonatomic, assign) BOOL compactLayout;

@property(nonatomic, strong) PVDetailInspectableApp *app;

@end

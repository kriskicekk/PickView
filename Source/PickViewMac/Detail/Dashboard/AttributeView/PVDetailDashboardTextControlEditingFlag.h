//
//  PVDetailDashboardTextControlEditingFlag.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PVDetailDashboardTextControlEditingFlag : NSObject

+ (instancetype)sharedInstance;

@property(nonatomic, assign) BOOL shouldIgnoreTextEditingChangeEvent;

@end

NS_ASSUME_NONNULL_END

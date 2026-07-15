//
//  PVDetailMsgTargetAction.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import <Foundation/Foundation.h>

/// target 和 relatedObject 相等，action 名字相同则认为 equal
@interface PVDetailMsgTargetAction : NSObject

@property(nonatomic, weak) id target;

@property(nonatomic, assign) SEL action;

@property(nonatomic, weak) id relatedObject;

@end


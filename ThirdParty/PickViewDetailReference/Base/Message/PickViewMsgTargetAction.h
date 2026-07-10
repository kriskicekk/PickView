//
//  PickViewMsgTargetAction.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#ifdef SHOULD_COMPILE_PICKVIEW_SERVER 

#import <Foundation/Foundation.h>

/// target 和 relatedObject 相等，action 名字相同则认为 equal
@interface PickViewMsgTargetAction : NSObject

@property(nonatomic, weak) id target;

@property(nonatomic, assign) SEL action;

@property(nonatomic, weak) id relatedObject;

@end

#endif /* SHOULD_COMPILE_PICKVIEW_SERVER */

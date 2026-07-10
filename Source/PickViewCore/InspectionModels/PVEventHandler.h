//
//  PVEventHandler.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import <Foundation/Foundation.h>

@class PVObject, PVIvarTrace, PVStringTwoTuple;

typedef NS_ENUM(NSInteger, PVEventHandlerType) {
    PVEventHandlerTypeTargetAction,
    PVEventHandlerTypeGesture
};

@interface PVEventHandler : NSObject <NSSecureCoding>

@property(nonatomic, assign) PVEventHandlerType handlerType;

/// 比如 "UIControlEventTouchUpInside", "UITapGestureRecognizer"
@property(nonatomic, copy) NSString *eventName;
/// tuple.first => @"<WRHomeView: 0xff>"，tuple.second => @"handleTap"
@property(nonatomic, copy) NSArray<PVStringTwoTuple *> *targetActions;

/// 返回当前 recognizer 是继承自哪一个基本款 recognizer。
/// 基本款 recognizer 指的是 TapRecognizer, PinchRecognizer 之类的常见 recognizer
/// 如果当前 recognizer 本身就是基本款 recognizer，则该属性为 nil
@property(nonatomic, copy) NSString *inheritedRecognizerName;
@property(nonatomic, assign) BOOL gestureRecognizerIsEnabled;
@property(nonatomic, copy) NSString *gestureRecognizerDelegator;
@property(nonatomic, copy) NSArray<NSString *> *recognizerIvarTraces;
/// recognizer 对象
@property(nonatomic, assign) unsigned long long recognizerOid;

@end


//
//  PickViewMsgAttribute.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#ifdef SHOULD_COMPILE_PICKVIEW_SERVER 

#import "PickViewMsgAttribute.h"



#import "PickViewMsgTargetAction.h"

@implementation PickViewMsgActionParams

- (double)doubleValue {
    if (![self.value isKindOfClass:[NSNumber class]]) {
        NSAssert(NO, @"");
        return 0;
    }
    return ((NSNumber *)self.value).doubleValue;
}

- (NSInteger)integerValue {
    if (![self.value isKindOfClass:[NSNumber class]]) {
        NSAssert(NO, @"");
        return 0;
    }
    return ((NSNumber *)self.value).integerValue;
}

- (BOOL)boolValue {
    if (![self.value isKindOfClass:[NSNumber class]]) {
        NSAssert(NO, @"");
        return 0;
    }
    return ((NSNumber *)self.value).boolValue;
}

@end

@interface PickViewMsgAttribute ()

@property(nonatomic, strong, readwrite) id currentValue;

@property(nonatomic, strong) NSMutableArray<PickViewMsgTargetAction *> *subscribers;

@end

@implementation PickViewMsgAttribute

+ (instancetype)attributeWithValue:(id)value {
    PickViewMsgAttribute *attr = [PickViewMsgAttribute new];
    attr.currentValue = value;
    return attr;
}

- (instancetype)init {
    if (self = [super init]) {
        self.subscribers = [NSMutableArray array];
    }
    return self;
}

- (void)setValue:(id)value ignoreSubscriber:(id)ignoreSubscriber userInfo:(id)userInfo {
    if ([self.currentValue isEqual:value]) {
        // value 相等的话直接拒绝
        return;
    }
    self.currentValue = value;
    
    __block NSMutableIndexSet *invalidIdxs = nil;
    [self.subscribers enumerateObjectsUsingBlock:^(PickViewMsgTargetAction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id subscriberTarget = obj.target;
        SEL subscriberAction = obj.action;
        
        if (!subscriberTarget) {
            // target 已被释放，删掉这组 target-action 吧
            if (!invalidIdxs) {
                invalidIdxs = [NSMutableIndexSet indexSet];
            }
            [invalidIdxs addIndex:idx];
            return;
        }
        
        if (subscriberTarget == ignoreSubscriber) {
            // 不要通知 ignoreSubscriber
            return;
        }
        
        PickViewMsgActionParams *params = [PickViewMsgActionParams new];
        params.userInfo = userInfo;
        params.value = value;
        params.relatedObject = obj.relatedObject;
#if TARGET_OS_IPHONE
        [[UIApplication sharedApplication] sendAction:subscriberAction to:subscriberTarget from:params forEvent:nil];
#elif TARGET_OS_MAC
        [NSApp sendAction:subscriberAction to:subscriberTarget from:params];
#endif
    }];
    
    if (invalidIdxs.count) {
        [self.subscribers removeObjectsAtIndexes:invalidIdxs];
    }
}

- (void)subscribe:(id)target action:(SEL)action relatedObject:(id)relatedObject {
    [self subscribe:target action:action relatedObject:relatedObject sendAtOnce:NO];
}

- (void)subscribe:(id)target action:(SEL)action relatedObject:(id)relatedObject sendAtOnce:(BOOL)sendAtOnce {
    if (!target || !action) {
        return;
    }
    PickViewMsgTargetAction *newOne = [PickViewMsgTargetAction new];
    newOne.target = target;
    newOne.action = action;
    newOne.relatedObject = relatedObject;
    if ([self.subscribers containsObject:newOne]) {
        return;
    }
    [self.subscribers addObject:newOne];
    
    if (sendAtOnce) {
        PickViewMsgActionParams *params = [PickViewMsgActionParams new];
        params.value = self.currentValue;
        params.relatedObject = relatedObject;
#if TARGET_OS_IPHONE
        [[UIApplication sharedApplication] sendAction:action to:target from:params forEvent:nil];
#elif TARGET_OS_MAC
        [NSApp sendAction:action to:target from:params];
#endif
    }
}

@end

@implementation PickViewDoubleMsgAttribute

+ (instancetype)attributeWithDouble:(double)value {
    PickViewDoubleMsgAttribute *attr = [PickViewDoubleMsgAttribute new];
    attr.currentValue = @(value);
    return attr;
}

- (void)setDoubleValue:(double)doubleValue ignoreSubscriber:(id)ignoreSubscriber {
    [self setValue:@(doubleValue) ignoreSubscriber:ignoreSubscriber userInfo:nil];
}

- (double)currentDoubleValue {
    return ((NSNumber *)self.currentValue).doubleValue;
}

@end

@implementation PickViewIntegerMsgAttribute

+ (instancetype)attributeWithInteger:(NSInteger)value {
    PickViewIntegerMsgAttribute *attr = [PickViewIntegerMsgAttribute new];
    attr.currentValue = @(value);
    return attr;
}

- (void)setIntegerValue:(NSInteger)integerValue ignoreSubscriber:(id)ignoreSubscriber {
    [self setValue:@(integerValue) ignoreSubscriber:ignoreSubscriber userInfo:nil];
}

- (NSInteger)currentIntegerValue {
    return ((NSNumber *)self.currentValue).integerValue;
}

@end

@implementation PickViewBOOLMsgAttribute

+ (instancetype)attributeWithBOOL:(BOOL)value {
    PickViewBOOLMsgAttribute *attr = [PickViewBOOLMsgAttribute new];
    attr.currentValue = @(value);
    return attr;
}

- (void)setBOOLValue:(BOOL)BOOLValue ignoreSubscriber:(id)ignoreSubscriber {
    [self setValue:@(BOOLValue) ignoreSubscriber:ignoreSubscriber userInfo:nil];
}

- (BOOL)currentBOOLValue {
    return ((NSNumber *)self.currentValue).boolValue;
}

@end

#endif /* SHOULD_COMPILE_PICKVIEW_SERVER */

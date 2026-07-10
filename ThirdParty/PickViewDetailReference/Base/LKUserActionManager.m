//
//  LKUserActionManager.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "LKUserActionManager.h"

@interface LKUserActionManager ()

@property(nonatomic, strong) NSPointerArray *delegators;

@end

@implementation LKUserActionManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static LKUserActionManager *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self sharedInstance];
}

- (instancetype)init {
    if (self = [super init]) {
        self.delegators = [NSPointerArray weakObjectsPointerArray];
    }
    return self;
}

- (void)addDelegate:(id<LKUserActionManagerDelegate>)delegate {
    if (!delegate) {
        NSAssert(NO, @"");
        return;
    }
    if ([self.delegators lk_containsPointer:(void *)delegate]) {
        return;
    }
    [self.delegators addPointer:(void *)delegate];
}

- (void)sendAction:(LKUserActionType)type {
    if (type == LKUserActionType_None) {
        NSAssert(NO, @"");
        return;
    }
    [[self.delegators allObjects] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(LKUserActionManager:didAct:)]) {
            [obj LKUserActionManager:self didAct:type];
        }
    }];
}

@end

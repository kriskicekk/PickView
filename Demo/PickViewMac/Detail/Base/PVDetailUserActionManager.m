//
//  PVDetailUserActionManager.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailUserActionManager.h"

@interface PVDetailUserActionManager ()

@property(nonatomic, strong) NSPointerArray *delegators;

@end

@implementation PVDetailUserActionManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static PVDetailUserActionManager *instance = nil;
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

- (void)addDelegate:(id<PVDetailUserActionManagerDelegate>)delegate {
    if (!delegate) {
        NSAssert(NO, @"");
        return;
    }
    if ([self.delegators lk_containsPointer:(void *)delegate]) {
        return;
    }
    [self.delegators addPointer:(void *)delegate];
}

- (void)sendAction:(PVDetailUserActionType)type {
    if (type == PVDetailUserActionType_None) {
        NSAssert(NO, @"");
        return;
    }
    [[self.delegators allObjects] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(PVDetailUserActionManager:didAct:)]) {
            [obj PVDetailUserActionManager:self didAct:type];
        }
    }];
}

@end

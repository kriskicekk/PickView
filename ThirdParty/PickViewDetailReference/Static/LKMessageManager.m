//
//  LKMessageManager.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "LKMessageManager.h"

NSString *const LKMessage_Jobs = @"LKMessage_Jobs";
NSString *const LKMessage_NewServerVersion = @"LKMessage_NewServerVersion";
NSString *const LKMessage_SwiftSubspec = @"LKMessage_SwiftSubspec";

@interface LKMessageManager ()

@property(nonatomic, strong) NSMutableSet<NSString *> *messages;

@end

@implementation LKMessageManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static LKMessageManager *instance = nil;
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
        self.messages = [NSMutableSet set];
        
//        BOOL hasReadJobs = [[NSUserDefaults standardUserDefaults] boolForKey:@"LKMessageManager_HasReadJobs"];
//        if (!hasReadJobs) {
//            [self addMessage:LKMessage_Jobs];
//        }
    }
    return self;
}

- (void)addMessage:(nonnull NSString *)message {
    [self.messages addObject:message];
}

- (void)removeMessage:(nonnull NSString *)message {
    [self.messages removeObject:message];
    
    if ([message isEqualToString:LKMessage_Jobs]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"LKMessageManager_HasReadJobs"];
    }
}

- (NSArray<NSString *> *)queryMessages {
    NSArray *ret = [[self.messages allObjects] pickview_sortedArrayByStringLength];
    return ret;
}

#if DEBUG
- (void)reset {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"LKMessageManager_HasReadJobs"];
}
#endif

@end

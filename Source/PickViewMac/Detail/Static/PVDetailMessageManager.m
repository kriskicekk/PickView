//
//  PVDetailMessageManager.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailMessageManager.h"

NSString *const PVDetailMessage_Jobs = @"PVDetailMessage_Jobs";
NSString *const PVDetailMessage_NewServerVersion = @"PVDetailMessage_NewServerVersion";
NSString *const PVDetailMessage_SwiftSubspec = @"PVDetailMessage_SwiftSubspec";

@interface PVDetailMessageManager ()

@property(nonatomic, strong) NSMutableSet<NSString *> *messages;

@end

@implementation PVDetailMessageManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static PVDetailMessageManager *instance = nil;
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
        
//        BOOL hasReadJobs = [[NSUserDefaults standardUserDefaults] boolForKey:@"PVDetailMessageManager_HasReadJobs"];
//        if (!hasReadJobs) {
//            [self addMessage:PVDetailMessage_Jobs];
//        }
    }
    return self;
}

- (void)addMessage:(nonnull NSString *)message {
    [self.messages addObject:message];
}

- (void)removeMessage:(nonnull NSString *)message {
    [self.messages removeObject:message];
    
    if ([message isEqualToString:PVDetailMessage_Jobs]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"PVDetailMessageManager_HasReadJobs"];
    }
}

- (NSArray<NSString *> *)queryMessages {
    NSArray *ret = [[self.messages allObjects] pv_inspect_sortedArrayByStringLength];
    return ret;
}

#if DEBUG
- (void)reset {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PVDetailMessageManager_HasReadJobs"];
}
#endif

@end

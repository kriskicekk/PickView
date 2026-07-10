//
//  PVObject+PVClient.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVObject+PVClient.h"
#import "PVDetailSwiftDemangler.h"

@implementation PVObject (PVClient)

- (NSString *)lk_completedDemangledClassName {
    return [PVDetailSwiftDemangler completedParseWithInput:self.rawClassName];
}

- (NSString *)lk_simpleDemangledClassName {
    NSString *name = [PVDetailSwiftDemangler simpleParseWithInput:self.rawClassName];
    // 理论上可能有 bad case，比如 xx<aaa.bbb>，期望拿到 xx 但是这里会拿到 bbb……不过似乎没发现过，所以先这样简单处理吧
    NSString *result = [name componentsSeparatedByString:@"."].lastObject;
    return result;
}

@end

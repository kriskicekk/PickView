//
//  LKDashboardAttributeClassView.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "LKDashboardAttributeClassView.h"
#import "PickView-Swift.h"

@implementation LKDashboardAttributeClassView

- (NSArray<NSString *> *)stringListWithAttribute:(PVAttribute *)attribute {
    NSArray<NSArray<NSString *> *> *lists = attribute.value;
    NSArray<NSString *> *result = [lists pickview_map:^id(NSUInteger idx, NSArray<NSString *> *rawClassList) {
        NSArray<NSString *> *demangled = [rawClassList pickview_map:^id(NSUInteger idx, NSString *rawClass) {
            return [LKSwiftDemangler completedParseWithInput:rawClass];
        }];
        return [demangled componentsJoinedByString:@"\n"];
    }];
    return result;
}

@end

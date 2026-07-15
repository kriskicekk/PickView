//
//  PVDetailDashboardAttributeClassView.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailDashboardAttributeClassView.h"
#import "PVDetailSwiftDemangler.h"

@implementation PVDetailDashboardAttributeClassView

- (NSArray<NSString *> *)stringListWithAttribute:(PVAttribute *)attribute {
    NSArray<NSArray<NSString *> *> *lists = attribute.value;
    NSArray<NSString *> *result = [lists pv_inspect_map:^id(NSUInteger idx, NSArray<NSString *> *rawClassList) {
        NSArray<NSString *> *demangled = [rawClassList pv_inspect_map:^id(NSUInteger idx, NSString *rawClass) {
            return [PVDetailSwiftDemangler completedParseWithInput:rawClass];
        }];
        return [demangled componentsJoinedByString:@"\n"];
    }];
    return result;
}

@end

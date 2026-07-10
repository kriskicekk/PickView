//
//  PVDetailDanceUIAttrMaker.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailDanceUIAttrMaker.h"
#import "PVAttributesGroup.h"
#import "PVAttributesSection.h"
#import "PVAttribute.h"

@implementation PVDetailDanceUIAttrMaker

+ (void)makeDanceUIJumpAttribute:(PVDisplayItem *)item danceSource:(NSString *)source {
    NSString *className = [self getClassFromSource:source];
    if (!className) {
        return;
    }
    
    __block BOOL alreadyHas = NO;
    [item.attributesGroupList enumerateObjectsUsingBlock:^(PVAttributesGroup * _Nonnull group, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([group.identifier isEqualToString:PVAttrGroup_Class]) {
            alreadyHas = YES;
            *stop = YES;
        }
    }];
    if (alreadyHas) {
//        NSAssert(NO, @"");
        return;
    }
    PVAttribute *attr = [PVAttribute new];
    attr.identifier = PVAttr_Class_Class_Class;
    attr.attrType = PVAttrTypeCustomObj;
    attr.value = @[@[className]];
    
    PVAttributesSection *sec = [PVAttributesSection new];
    sec.identifier = PVAttrSec_Class_Class;
    sec.attributes = @[attr];
    
    PVAttributesGroup *group = [PVAttributesGroup new];
    group.identifier = PVAttrGroup_Class;
    group.attrSections = @[sec];
    
    if (item.attributesGroupList) {
        item.attributesGroupList = [item.attributesGroupList arrayByAddingObject:group];
    } else {
        item.attributesGroupList = @[group];
    }
}

+ (NSString *)getClassFromSource:(NSString *)json {
    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    if (error) {
        NSAssert(NO, @"");
        return nil;
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        NSAssert(NO, @"");
        return nil;
    }
    NSString *type = dict[@"type"];
    if (!type) {
        NSAssert(NO, @"");
        return nil;
    }
    return type;
}

@end

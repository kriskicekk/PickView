//
//  PVCustomAttrGroupsMaker.m
//  PickViewServer
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVCustomAttrGroupsMaker.h"

#if TARGET_OS_IPHONE

#import "CALayer+PVInspect.h"
#import "Color+PVInspect.h"
#import "PVAttribute.h"
#import "PVAttributesGroup.h"
#import "PVAttributesSection.h"
#import "PVAttrIdentifiers.h"
#import "PVCustomAttrSetterManager.h"

#import <UIKit/UIKit.h>

@interface PVCustomAttrGroupsMaker ()

@property(nonatomic, weak) CALayer *layer;
@property(nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<PVAttribute *> *> *sectionAndAttrs;
@property(nonatomic, copy) NSString *resolvedCustomDisplayTitle;
@property(nonatomic, copy) NSString *resolvedDanceUISource;
@property(nonatomic, copy) NSArray<PVAttributesGroup *> *resolvedGroups;

@end

@implementation PVCustomAttrGroupsMaker

- (instancetype)initWithLayer:(CALayer *)layer {
    self = [super init];
    if (self) {
        _layer = layer;
        _sectionAndAttrs = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)execute {
    if (!self.layer) {
        NSAssert(NO, @"");
        return;
    }

    NSMutableArray<NSString *> *selectors = [NSMutableArray arrayWithObjects:@"pickview_customDebugInfos", @"lookin_customDebugInfos", nil];
    for (NSInteger index = 0; index < 5; index++) {
        [selectors addObject:[NSString stringWithFormat:@"pickview_customDebugInfos_%@", @(index)]];
        [selectors addObject:[NSString stringWithFormat:@"lookin_customDebugInfos_%@", @(index)]];
    }

    for (NSString *selectorName in selectors) {
        [self makeAttrsForViewOrLayer:self.layer selectorName:selectorName];
        UIView *view = self.layer.pv_inspect_hostView;
        if (view) {
            [self makeAttrsForViewOrLayer:view selectorName:selectorName];
        }
    }

    if (!self.sectionAndAttrs.count) {
        return;
    }

    NSMutableArray<PVAttributesGroup *> *groups = [NSMutableArray array];
    [self.sectionAndAttrs enumerateKeysAndObjectsUsingBlock:^(NSString *groupTitle, NSMutableArray<PVAttribute *> *attrs, BOOL *stop) {
        PVAttributesGroup *group = [[PVAttributesGroup alloc] init];
        group.userCustomTitle = groupTitle;
        group.identifier = PVAttrGroup_UserCustom;

        NSMutableArray<PVAttributesSection *> *sections = [NSMutableArray arrayWithCapacity:attrs.count];
        for (PVAttribute *attr in attrs) {
            PVAttributesSection *section = [[PVAttributesSection alloc] init];
            section.identifier = PVAttrSec_UserCustom;
            section.attributes = @[attr];
            [sections addObject:section];
        }
        group.attrSections = sections;
        [groups addObject:group];
    }];

    [groups sortUsingComparator:^NSComparisonResult(PVAttributesGroup *first, PVAttributesGroup *second) {
        return [first.userCustomTitle compare:second.userCustomTitle];
    }];
    self.resolvedGroups = groups.copy;
}

- (void)makeAttrsForViewOrLayer:(id)viewOrLayer selectorName:(NSString *)selectorName {
    if (!viewOrLayer || !selectorName.length) {
        return;
    }
    if (![viewOrLayer isKindOfClass:UIView.class] && ![viewOrLayer isKindOfClass:CALayer.class]) {
        return;
    }

    SEL selector = NSSelectorFromString(selectorName);
    if (![viewOrLayer respondsToSelector:selector]) {
        return;
    }

    NSMethodSignature *signature = [viewOrLayer methodSignatureForSelector:selector];
    if (signature.numberOfArguments > 2) {
        NSAssert(NO, @"PickViewServer - custom debug infos selector should not have parameters.");
        return;
    }

    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = viewOrLayer;
    invocation.selector = selector;
    [invocation invoke];

    NSDictionary<NSString *, id> *__unsafe_unretained tempRawData = nil;
    [invocation getReturnValue:&tempRawData];
    if (![tempRawData isKindOfClass:NSDictionary.class]) {
        return;
    }

    NSDictionary<NSString *, id> *rawData = tempRawData;
    NSString *customTitle = rawData[@"title"];
    if ([customTitle isKindOfClass:NSString.class] && customTitle.length) {
        self.resolvedCustomDisplayTitle = customTitle;
    }

    NSString *danceSource = rawData[@"pickview_source"] ?: rawData[@"lookin_source"];
    if ([danceSource isKindOfClass:NSString.class] && danceSource.length) {
        self.resolvedDanceUISource = danceSource;
    }

    [self makeAttrsFromRawProperties:rawData[@"properties"]];
}

- (void)makeAttrsFromRawProperties:(NSArray *)rawProperties {
    if (![rawProperties isKindOfClass:NSArray.class]) {
        return;
    }

    for (NSDictionary<NSString *, id> *dict in rawProperties) {
        NSString *groupTitle = nil;
        PVAttribute *attr = [PVCustomAttrGroupsMaker attrFromRawDict:dict saveCustomSetter:YES groupTitle:&groupTitle];
        if (!attr || !groupTitle.length) {
            continue;
        }
        if (!self.sectionAndAttrs[groupTitle]) {
            self.sectionAndAttrs[groupTitle] = [NSMutableArray array];
        }
        [self.sectionAndAttrs[groupTitle] addObject:attr];
    }
}

+ (PVAttribute *)attrFromRawDict:(NSDictionary *)dict saveCustomSetter:(BOOL)saveCustomSetter groupTitle:(NSString **)groupTitle {
    if (![dict isKindOfClass:NSDictionary.class]) {
        return nil;
    }

    NSString *title = dict[@"title"];
    NSString *type = dict[@"valueType"];
    NSString *section = dict[@"section"];
    id value = dict[@"value"];

    if (![title isKindOfClass:NSString.class] || ![type isKindOfClass:NSString.class]) {
        return nil;
    }
    if (groupTitle) {
        *groupTitle = ([section isKindOfClass:NSString.class] && section.length) ? section : @"Custom";
    }

    PVAttribute *attr = [[PVAttribute alloc] init];
    attr.identifier = PVAttr_UserCustom;
    attr.displayTitle = title;

    NSString *fixedType = type.lowercaseString;
    if ([fixedType isEqualToString:@"string"]) {
        if (value != nil && ![value isKindOfClass:NSString.class]) {
            return nil;
        }
        attr.attrType = PVAttrTypeNSString;
        attr.value = value;
        if (saveCustomSetter && dict[@"retainedSetter"]) {
            NSString *uniqueID = [[NSUUID UUID] UUIDString];
            [[PVCustomAttrSetterManager sharedInstance] saveStringSetter:dict[@"retainedSetter"] uniqueID:uniqueID];
            attr.customSetterID = uniqueID;
        }
        return attr;
    }

    if ([fixedType isEqualToString:@"number"]) {
        if (![value isKindOfClass:NSNumber.class]) {
            return nil;
        }
        attr.attrType = PVAttrTypeDouble;
        attr.value = value;
        if (saveCustomSetter && dict[@"retainedSetter"]) {
            NSString *uniqueID = [[NSUUID UUID] UUIDString];
            [[PVCustomAttrSetterManager sharedInstance] saveNumberSetter:dict[@"retainedSetter"] uniqueID:uniqueID];
            attr.customSetterID = uniqueID;
        }
        return attr;
    }

    if ([fixedType isEqualToString:@"bool"]) {
        if (![value isKindOfClass:NSNumber.class]) {
            return nil;
        }
        attr.attrType = PVAttrTypeBOOL;
        attr.value = value;
        if (saveCustomSetter && dict[@"retainedSetter"]) {
            NSString *uniqueID = [[NSUUID UUID] UUIDString];
            [[PVCustomAttrSetterManager sharedInstance] saveBoolSetter:dict[@"retainedSetter"] uniqueID:uniqueID];
            attr.customSetterID = uniqueID;
        }
        return attr;
    }

    if ([fixedType isEqualToString:@"color"]) {
        if (value != nil && ![value isKindOfClass:UIColor.class]) {
            return nil;
        }
        attr.attrType = PVAttrTypeUIColor;
        attr.value = [(UIColor *)value pv_inspect_rgbaComponents];
        if (saveCustomSetter && dict[@"retainedSetter"]) {
            NSString *uniqueID = [[NSUUID UUID] UUIDString];
            [[PVCustomAttrSetterManager sharedInstance] saveColorSetter:dict[@"retainedSetter"] uniqueID:uniqueID];
            attr.customSetterID = uniqueID;
        }
        return attr;
    }

    if ([fixedType isEqualToString:@"rect"]) {
        if (![value isKindOfClass:NSValue.class]) {
            return nil;
        }
        attr.attrType = PVAttrTypeCGRect;
        attr.value = value;
        if (saveCustomSetter && dict[@"retainedSetter"]) {
            NSString *uniqueID = [[NSUUID UUID] UUIDString];
            [[PVCustomAttrSetterManager sharedInstance] saveRectSetter:dict[@"retainedSetter"] uniqueID:uniqueID];
            attr.customSetterID = uniqueID;
        }
        return attr;
    }

    if ([fixedType isEqualToString:@"size"]) {
        if (![value isKindOfClass:NSValue.class]) {
            return nil;
        }
        attr.attrType = PVAttrTypeCGSize;
        attr.value = value;
        if (saveCustomSetter && dict[@"retainedSetter"]) {
            NSString *uniqueID = [[NSUUID UUID] UUIDString];
            [[PVCustomAttrSetterManager sharedInstance] saveSizeSetter:dict[@"retainedSetter"] uniqueID:uniqueID];
            attr.customSetterID = uniqueID;
        }
        return attr;
    }

    if ([fixedType isEqualToString:@"point"]) {
        if (![value isKindOfClass:NSValue.class]) {
            return nil;
        }
        attr.attrType = PVAttrTypeCGPoint;
        attr.value = value;
        if (saveCustomSetter && dict[@"retainedSetter"]) {
            NSString *uniqueID = [[NSUUID UUID] UUIDString];
            [[PVCustomAttrSetterManager sharedInstance] savePointSetter:dict[@"retainedSetter"] uniqueID:uniqueID];
            attr.customSetterID = uniqueID;
        }
        return attr;
    }

    if ([fixedType isEqualToString:@"insets"]) {
        if (![value isKindOfClass:NSValue.class]) {
            return nil;
        }
        attr.attrType = PVAttrTypeUIEdgeInsets;
        attr.value = value;
        if (saveCustomSetter && dict[@"retainedSetter"]) {
            NSString *uniqueID = [[NSUUID UUID] UUIDString];
            [[PVCustomAttrSetterManager sharedInstance] saveInsetsSetter:dict[@"retainedSetter"] uniqueID:uniqueID];
            attr.customSetterID = uniqueID;
        }
        return attr;
    }

    if ([fixedType isEqualToString:@"shadow"]) {
        if (![value isKindOfClass:NSDictionary.class]) {
            return nil;
        }
        NSDictionary *shadowInfo = value;
        if (![shadowInfo[@"offset"] isKindOfClass:NSValue.class] ||
            ![shadowInfo[@"opacity"] isKindOfClass:NSNumber.class] ||
            ![shadowInfo[@"radius"] isKindOfClass:NSNumber.class]) {
            return nil;
        }
        NSMutableDictionary *checkedShadowInfo = [@{
            @"offset": shadowInfo[@"offset"],
            @"opacity": shadowInfo[@"opacity"],
            @"radius": shadowInfo[@"radius"]
        } mutableCopy];
        if ([shadowInfo[@"color"] isKindOfClass:UIColor.class]) {
            checkedShadowInfo[@"color"] = [(UIColor *)shadowInfo[@"color"] pv_inspect_rgbaComponents];
        }
        attr.attrType = PVAttrTypeShadow;
        attr.value = checkedShadowInfo;
        return attr;
    }

    if ([fixedType isEqualToString:@"enum"]) {
        if (![value isKindOfClass:NSString.class]) {
            return nil;
        }
        attr.attrType = PVAttrTypeEnumString;
        attr.value = value;
        NSArray<NSString *> *allEnumCases = dict[@"allEnumCases"];
        if ([allEnumCases isKindOfClass:NSArray.class]) {
            attr.extraValue = allEnumCases;
        }
        if (saveCustomSetter && dict[@"retainedSetter"]) {
            NSString *uniqueID = [[NSUUID UUID] UUIDString];
            [[PVCustomAttrSetterManager sharedInstance] saveEnumSetter:dict[@"retainedSetter"] uniqueID:uniqueID];
            attr.customSetterID = uniqueID;
        }
        return attr;
    }

    if ([fixedType isEqualToString:@"json"]) {
        if (![value isKindOfClass:NSString.class]) {
            return nil;
        }
        attr.attrType = PVAttrTypeJson;
        attr.value = value;
        return attr;
    }

    return nil;
}

- (NSArray<PVAttributesGroup *> *)getGroups {
    return self.resolvedGroups;
}

- (NSString *)getCustomDisplayTitle {
    return self.resolvedCustomDisplayTitle;
}

- (NSString *)getDanceUISource {
    return self.resolvedDanceUISource;
}

+ (NSArray<PVAttributesGroup *> *)makeGroupsFromRawProperties:(NSArray *)rawProperties saveCustomSetter:(BOOL)saveCustomSetter {
    if (![rawProperties isKindOfClass:NSArray.class]) {
        return nil;
    }

    NSMutableDictionary<NSString *, NSMutableArray<PVAttribute *> *> *groupTitleAndAttrs = [NSMutableDictionary dictionary];
    for (NSDictionary<NSString *, id> *dict in rawProperties) {
        NSString *groupTitle = nil;
        PVAttribute *attr = [PVCustomAttrGroupsMaker attrFromRawDict:dict saveCustomSetter:saveCustomSetter groupTitle:&groupTitle];
        if (!attr || !groupTitle.length) {
            continue;
        }
        if (!groupTitleAndAttrs[groupTitle]) {
            groupTitleAndAttrs[groupTitle] = [NSMutableArray array];
        }
        [groupTitleAndAttrs[groupTitle] addObject:attr];
    }

    if (!groupTitleAndAttrs.count) {
        return nil;
    }

    NSMutableArray<PVAttributesGroup *> *groups = [NSMutableArray array];
    [groupTitleAndAttrs enumerateKeysAndObjectsUsingBlock:^(NSString *groupTitle, NSMutableArray<PVAttribute *> *attrs, BOOL *stop) {
        PVAttributesGroup *group = [[PVAttributesGroup alloc] init];
        group.userCustomTitle = groupTitle;
        group.identifier = PVAttrGroup_UserCustom;

        NSMutableArray<PVAttributesSection *> *sections = [NSMutableArray arrayWithCapacity:attrs.count];
        for (PVAttribute *attr in attrs) {
            PVAttributesSection *section = [[PVAttributesSection alloc] init];
            section.identifier = PVAttrSec_UserCustom;
            section.attributes = @[attr];
            [sections addObject:section];
        }
        group.attrSections = sections;
        [groups addObject:group];
    }];

    [groups sortUsingComparator:^NSComparisonResult(PVAttributesGroup *first, PVAttributesGroup *second) {
        return [first.userCustomTitle compare:second.userCustomTitle];
    }];
    return groups.copy;
}

@end

#endif

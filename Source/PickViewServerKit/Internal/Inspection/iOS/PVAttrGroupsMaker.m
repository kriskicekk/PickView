//
//  PVAttrGroupsMaker.m
//  PickViewServer
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVAttrGroupsMaker.h"

#import "CALayer+PVInspect.h"
#import "Color+PVInspect.h"
#import "NSArray+PVInspect.h"
#import "NSString+PVInspect.h"
#import "PVAttribute.h"
#import "PVAttributesGroup.h"
#import "PVAttributesSection.h"
#import "PVDashboardBlueprint.h"

#import <TargetConditionals.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

@implementation PVAttrGroupsMaker

+ (NSArray<PVAttributesGroup *> *)attrGroupsForLayer:(CALayer *)layer {
#if TARGET_OS_IPHONE
    if (!layer) {
        NSAssert(NO, @"");
        return @[];
    }

    NSArray<PVAttributesGroup *> *groups = [[PVDashboardBlueprint groupIDs] pv_inspect_map:^id(NSUInteger idx, PVAttrGroupIdentifier groupID) {
        PVAttributesGroup *group = [[PVAttributesGroup alloc] init];
        group.identifier = groupID;

        NSArray<PVAttrSectionIdentifier> *secIDs = [PVDashboardBlueprint sectionIDsForGroupID:groupID];
        group.attrSections = [secIDs pv_inspect_map:^id(NSUInteger idx, PVAttrSectionIdentifier secID) {
            PVAttributesSection *section = [[PVAttributesSection alloc] init];
            section.identifier = secID;

            NSArray<PVAttrIdentifier> *attrIDs = [PVDashboardBlueprint attrIDsForSectionID:secID];
            section.attributes = [attrIDs pv_inspect_map:^id(NSUInteger idx, PVAttrIdentifier attrID) {
                NSInteger minAvailableVersion = [PVDashboardBlueprint minAvailableOSVersionWithAttrID:attrID];
                if (minAvailableVersion > 0 && NSProcessInfo.processInfo.operatingSystemVersion.majorVersion < minAvailableVersion) {
                    return nil;
                }

                id targetObject = nil;
                if ([PVDashboardBlueprint isUIViewPropertyWithAttrID:attrID]) {
                    targetObject = layer.pv_inspect_hostView;
                } else {
                    targetObject = layer;
                }

                if (!targetObject) {
                    return nil;
                }

                Class targetClass = NSClassFromString([PVDashboardBlueprint classNameWithAttrID:attrID]);
                if (![targetObject isKindOfClass:targetClass]) {
                    return nil;
                }

                return [self attributeWithIdentifier:attrID targetObject:targetObject];
            }];

            return section.attributes.count ? section : nil;
        }];

        if ([groupID isEqualToString:PVAttrGroup_AutoLayout]) {
            BOOL hasConstraints = [group.attrSections pv_inspect_any:^BOOL(PVAttributesSection *section) {
                return [section.identifier isEqualToString:PVAttrSec_AutoLayout_Constraints];
            }];
            if (!hasConstraints) {
                return nil;
            }
        }

        return group.attrSections.count ? group : nil;
    }];

    return groups ?: @[];
#else
    return @[];
#endif
}

+ (PVAttribute *)attributeWithIdentifier:(PVAttrIdentifier)identifier targetObject:(id)target {
#if TARGET_OS_IPHONE
    if (!target) {
        NSAssert(NO, @"");
        return nil;
    }

    PVAttribute *attribute = [[PVAttribute alloc] init];
    attribute.identifier = identifier;

    SEL getter = [PVDashboardBlueprint getterWithAttrID:identifier];
    if (!getter) {
        NSAssert(NO, @"");
        return nil;
    }
    if (![target respondsToSelector:getter]) {
        return nil;
    }

    NSMethodSignature *signature = [target methodSignatureForSelector:getter];
    if (signature.numberOfArguments > 2) {
        NSAssert(NO, @"getter 不可以有参数");
        return nil;
    }
    if (strcmp(signature.methodReturnType, @encode(void)) == 0) {
        NSAssert(NO, @"getter 返回值不能为 void");
        return nil;
    }

    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = target;
    invocation.selector = getter;
    [invocation invoke];

    const char *returnType = signature.methodReturnType;

    if (strcmp(returnType, @encode(char)) == 0) {
        char value;
        [invocation getReturnValue:&value];
        attribute.attrType = PVAttrTypeChar;
        attribute.value = @(value);
    } else if (strcmp(returnType, @encode(int)) == 0) {
        int value;
        [invocation getReturnValue:&value];
        attribute.value = @(value);
        attribute.attrType = [PVDashboardBlueprint enumListNameWithAttrID:identifier] ? PVAttrTypeEnumInt : PVAttrTypeInt;
    } else if (strcmp(returnType, @encode(short)) == 0) {
        short value;
        [invocation getReturnValue:&value];
        attribute.attrType = PVAttrTypeShort;
        attribute.value = @(value);
    } else if (strcmp(returnType, @encode(long)) == 0) {
        long value;
        [invocation getReturnValue:&value];
        attribute.value = @(value);
        attribute.attrType = [PVDashboardBlueprint enumListNameWithAttrID:identifier] ? PVAttrTypeEnumLong : PVAttrTypeLong;
    } else if (strcmp(returnType, @encode(long long)) == 0) {
        long long value;
        [invocation getReturnValue:&value];
        attribute.attrType = PVAttrTypeLongLong;
        attribute.value = @(value);
    } else if (strcmp(returnType, @encode(unsigned char)) == 0) {
        unsigned char value;
        [invocation getReturnValue:&value];
        attribute.attrType = PVAttrTypeUnsignedChar;
        attribute.value = @(value);
    } else if (strcmp(returnType, @encode(unsigned int)) == 0) {
        unsigned int value;
        [invocation getReturnValue:&value];
        attribute.attrType = PVAttrTypeUnsignedInt;
        attribute.value = @(value);
    } else if (strcmp(returnType, @encode(unsigned short)) == 0) {
        unsigned short value;
        [invocation getReturnValue:&value];
        attribute.attrType = PVAttrTypeUnsignedShort;
        attribute.value = @(value);
    } else if (strcmp(returnType, @encode(unsigned long)) == 0) {
        unsigned long value;
        [invocation getReturnValue:&value];
        attribute.attrType = PVAttrTypeUnsignedLong;
        attribute.value = @(value);
    } else if (strcmp(returnType, @encode(unsigned long long)) == 0) {
        unsigned long long value;
        [invocation getReturnValue:&value];
        attribute.attrType = PVAttrTypeUnsignedLongLong;
        attribute.value = @(value);
    } else if (strcmp(returnType, @encode(float)) == 0) {
        float value;
        [invocation getReturnValue:&value];
        attribute.attrType = PVAttrTypeFloat;
        attribute.value = @(value);
    } else if (strcmp(returnType, @encode(double)) == 0) {
        double value;
        [invocation getReturnValue:&value];
        attribute.attrType = PVAttrTypeDouble;
        attribute.value = @(value);
    } else if (strcmp(returnType, @encode(BOOL)) == 0) {
        BOOL value;
        [invocation getReturnValue:&value];
        attribute.attrType = PVAttrTypeBOOL;
        attribute.value = @(value);
    } else if (strcmp(returnType, @encode(SEL)) == 0) {
        SEL value;
        [invocation getReturnValue:&value];
        attribute.attrType = PVAttrTypeSel;
        attribute.value = NSStringFromSelector(value);
    } else if (strcmp(returnType, @encode(Class)) == 0) {
        Class value;
        [invocation getReturnValue:&value];
        attribute.attrType = PVAttrTypeClass;
        attribute.value = NSStringFromClass(value);
    } else if (strcmp(returnType, @encode(CGPoint)) == 0) {
        CGPoint value;
        [invocation getReturnValue:&value];
        attribute.attrType = PVAttrTypeCGPoint;
        attribute.value = [NSValue valueWithCGPoint:value];
    } else if (strcmp(returnType, @encode(CGVector)) == 0) {
        CGVector value;
        [invocation getReturnValue:&value];
        attribute.attrType = PVAttrTypeCGVector;
        attribute.value = [NSValue valueWithCGVector:value];
    } else if (strcmp(returnType, @encode(CGSize)) == 0) {
        CGSize value;
        [invocation getReturnValue:&value];
        attribute.attrType = PVAttrTypeCGSize;
        attribute.value = [NSValue valueWithCGSize:value];
    } else if (strcmp(returnType, @encode(CGRect)) == 0) {
        CGRect value;
        [invocation getReturnValue:&value];
        attribute.attrType = PVAttrTypeCGRect;
        attribute.value = [NSValue valueWithCGRect:value];
    } else if (strcmp(returnType, @encode(CGAffineTransform)) == 0) {
        CGAffineTransform value;
        [invocation getReturnValue:&value];
        attribute.attrType = PVAttrTypeCGAffineTransform;
        attribute.value = [NSValue valueWithCGAffineTransform:value];
    } else if (strcmp(returnType, @encode(UIEdgeInsets)) == 0) {
        UIEdgeInsets value;
        [invocation getReturnValue:&value];
        attribute.attrType = PVAttrTypeUIEdgeInsets;
        attribute.value = [NSValue valueWithUIEdgeInsets:value];
    } else if (strcmp(returnType, @encode(UIOffset)) == 0) {
        UIOffset value;
        [invocation getReturnValue:&value];
        attribute.attrType = PVAttrTypeUIOffset;
        attribute.value = [NSValue valueWithUIOffset:value];
    } else {
        NSString *typeString = [[NSString alloc] pv_inspect_safeInitWithUTF8String:returnType];
        if ([typeString hasPrefix:@"@"]) {
            __unsafe_unretained id objectValue;
            [invocation getReturnValue:&objectValue];

            if (!objectValue && [PVDashboardBlueprint hideIfNilWithAttrID:identifier]) {
                return nil;
            }

            attribute.attrType = [PVDashboardBlueprint objectAttrTypeWithAttrID:identifier];
            if (attribute.attrType == PVAttrTypeUIColor) {
                if (!objectValue) {
                    attribute.value = nil;
                } else if ([objectValue isKindOfClass:UIColor.class] && [objectValue respondsToSelector:@selector(pv_inspect_rgbaComponents)]) {
                    attribute.value = [objectValue pv_inspect_rgbaComponents];
                } else {
                    return nil;
                }
            } else {
                attribute.value = objectValue;
            }
        } else {
            NSAssert(NO, @"不支持解析该类型的返回值");
            return nil;
        }
    }

    return attribute;
#else
    return nil;
#endif
}

@end

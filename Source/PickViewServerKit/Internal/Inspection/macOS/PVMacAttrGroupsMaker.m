//
//  PVMacAttrGroupsMaker.m
//  PickViewServer
//
//  Created by kris cheng on 2026/7/10.
//

#import "PVMacAttrGroupsMaker.h"

#import "Color+PVInspect.h"
#import "NSArray+PVInspect.h"
#import "NSString+PVInspect.h"
#import "PVAttribute.h"
#import "PVAttributesGroup.h"
#import "PVAttributesSection.h"
#import "PVDashboardBlueprint.h"
#import "PVInspectionDefines.h"

#import <AppKit/AppKit.h>

@implementation PVMacAttrGroupsMaker

+ (NSArray<PVAttributesGroup *> *)attrGroupsForView:(NSView *)view {
    if (!view) {
        return @[];
    }
    return [self attrGroupsForTarget:view groupIDs:[self viewGroupIDs]];
}

+ (NSArray<PVAttributesGroup *> *)attrGroupsForWindow:(NSWindow *)window {
    if (!window) {
        return @[];
    }
    return [self attrGroupsForTarget:window groupIDs:@[PVAttrGroup_NSWindow]];
}

+ (NSArray<PVAttrGroupIdentifier> *)viewGroupIDs {
    return @[
        PVAttrGroup_NSImageView,
        PVAttrGroup_NSControl,
        PVAttrGroup_NSButton,
        PVAttrGroup_NSScrollView,
        PVAttrGroup_NSTableView,
        PVAttrGroup_NSTextView,
        PVAttrGroup_NSTextField,
        PVAttrGroup_NSVisualEffectView,
        PVAttrGroup_NSStackView
    ];
}

+ (NSArray<PVAttributesGroup *> *)attrGroupsForTarget:(id)target
                                             groupIDs:(NSArray<PVAttrGroupIdentifier> *)groupIDs {
    return [groupIDs pv_inspect_map:^id(NSUInteger groupIndex, PVAttrGroupIdentifier groupID) {
        PVAttributesGroup *group = [[PVAttributesGroup alloc] init];
        group.identifier = groupID;
        group.attrSections = [[PVDashboardBlueprint sectionIDsForGroupID:groupID] pv_inspect_map:^id(NSUInteger sectionIndex, PVAttrSectionIdentifier sectionID) {
            PVAttributesSection *section = [[PVAttributesSection alloc] init];
            section.identifier = sectionID;
            section.attributes = [[PVDashboardBlueprint attrIDsForSectionID:sectionID] pv_inspect_map:^id(NSUInteger attrIndex, PVAttrIdentifier attrID) {
                NSInteger minimumVersion = [PVDashboardBlueprint minAvailableOSVersionWithAttrID:attrID];
                if (minimumVersion > 0 && NSProcessInfo.processInfo.operatingSystemVersion.majorVersion < minimumVersion) {
                    return nil;
                }

                Class targetClass = NSClassFromString([PVDashboardBlueprint classNameWithAttrID:attrID]);
                if (!targetClass || ![target isKindOfClass:targetClass]) {
                    return nil;
                }
                return [self attributeWithIdentifier:attrID targetObject:target];
            }];
            return section.attributes.count ? section : nil;
        }];
        return group.attrSections.count ? group : nil;
    }];
}

+ (PVAttribute *)attributeWithIdentifier:(PVAttrIdentifier)identifier targetObject:(id)target {
    SEL getter = [PVDashboardBlueprint getterWithAttrID:identifier];
    if (!getter || ![target respondsToSelector:getter]) {
        return nil;
    }

    NSMethodSignature *signature = [target methodSignatureForSelector:getter];
    if (!signature || signature.numberOfArguments != 2 || strcmp(signature.methodReturnType, @encode(void)) == 0) {
        return nil;
    }

    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = target;
    invocation.selector = getter;
    @try {
        [invocation invoke];
    } @catch (__unused NSException *exception) {
        return nil;
    }

    PVAttribute *attribute = [[PVAttribute alloc] init];
    attribute.identifier = identifier;
    const char *returnType = signature.methodReturnType;

#define PV_READ_VALUE(TYPE, ATTR_TYPE) \
    TYPE value; \
    [invocation getReturnValue:&value]; \
    attribute.attrType = ATTR_TYPE; \
    attribute.value = @(value)

    if (strcmp(returnType, @encode(char)) == 0) {
        PV_READ_VALUE(char, PVAttrTypeChar);
    } else if (strcmp(returnType, @encode(int)) == 0) {
        PV_READ_VALUE(int, [PVDashboardBlueprint enumListNameWithAttrID:identifier] ? PVAttrTypeEnumInt : PVAttrTypeInt);
    } else if (strcmp(returnType, @encode(short)) == 0) {
        PV_READ_VALUE(short, PVAttrTypeShort);
    } else if (strcmp(returnType, @encode(long)) == 0) {
        PV_READ_VALUE(long, [PVDashboardBlueprint enumListNameWithAttrID:identifier] ? PVAttrTypeEnumLong : PVAttrTypeLong);
    } else if (strcmp(returnType, @encode(long long)) == 0) {
        PV_READ_VALUE(long long, PVAttrTypeLongLong);
    } else if (strcmp(returnType, @encode(unsigned char)) == 0) {
        PV_READ_VALUE(unsigned char, PVAttrTypeUnsignedChar);
    } else if (strcmp(returnType, @encode(unsigned int)) == 0) {
        PV_READ_VALUE(unsigned int, [PVDashboardBlueprint enumListNameWithAttrID:identifier] ? PVAttrTypeEnumInt : PVAttrTypeUnsignedInt);
    } else if (strcmp(returnType, @encode(unsigned short)) == 0) {
        PV_READ_VALUE(unsigned short, PVAttrTypeUnsignedShort);
    } else if (strcmp(returnType, @encode(unsigned long)) == 0) {
        PV_READ_VALUE(unsigned long, [PVDashboardBlueprint enumListNameWithAttrID:identifier] ? PVAttrTypeEnumLong : PVAttrTypeUnsignedLong);
    } else if (strcmp(returnType, @encode(unsigned long long)) == 0) {
        PV_READ_VALUE(unsigned long long, PVAttrTypeUnsignedLongLong);
    } else if (strcmp(returnType, @encode(float)) == 0) {
        PV_READ_VALUE(float, PVAttrTypeFloat);
    } else if (strcmp(returnType, @encode(double)) == 0) {
        PV_READ_VALUE(double, PVAttrTypeDouble);
    } else if (strcmp(returnType, @encode(BOOL)) == 0) {
        PV_READ_VALUE(BOOL, PVAttrTypeBOOL);
    } else if (strcmp(returnType, @encode(SEL)) == 0) {
        SEL value;
        [invocation getReturnValue:&value];
        attribute.attrType = PVAttrTypeSel;
        attribute.value = value ? NSStringFromSelector(value) : nil;
    } else if (strcmp(returnType, @encode(Class)) == 0) {
        Class value;
        [invocation getReturnValue:&value];
        attribute.attrType = PVAttrTypeClass;
        attribute.value = value ? NSStringFromClass(value) : nil;
    } else if (strcmp(returnType, @encode(CGPoint)) == 0) {
        CGPoint value;
        [invocation getReturnValue:&value];
        attribute.attrType = PVAttrTypeCGPoint;
        attribute.value = [NSValue valueWithPoint:value];
    } else if (strcmp(returnType, @encode(CGVector)) == 0) {
        CGVector value;
        [invocation getReturnValue:&value];
        attribute.attrType = PVAttrTypeCGVector;
        attribute.value = [NSValue value:&value withObjCType:@encode(CGVector)];
    } else if (strcmp(returnType, @encode(CGSize)) == 0) {
        CGSize value;
        [invocation getReturnValue:&value];
        attribute.attrType = PVAttrTypeCGSize;
        attribute.value = [NSValue valueWithSize:value];
    } else if (strcmp(returnType, @encode(CGRect)) == 0) {
        CGRect value;
        [invocation getReturnValue:&value];
        attribute.attrType = PVAttrTypeCGRect;
        attribute.value = [NSValue valueWithRect:value];
    } else if (strcmp(returnType, @encode(CGAffineTransform)) == 0) {
        CGAffineTransform value;
        [invocation getReturnValue:&value];
        attribute.attrType = PVAttrTypeCGAffineTransform;
        attribute.value = [NSValue value:&value withObjCType:@encode(CGAffineTransform)];
    } else if (strcmp(returnType, @encode(NSEdgeInsets)) == 0) {
        NSEdgeInsets value;
        [invocation getReturnValue:&value];
        attribute.attrType = PVAttrTypeUIEdgeInsets;
        attribute.value = [NSValue valueWithEdgeInsets:value];
    } else {
        NSString *typeString = [[NSString alloc] pv_inspect_safeInitWithUTF8String:returnType];
        if (![typeString hasPrefix:@"@"] ) {
            return nil;
        }

        __unsafe_unretained id objectValue = nil;
        [invocation getReturnValue:&objectValue];
        if (!objectValue && [PVDashboardBlueprint hideIfNilWithAttrID:identifier]) {
            return nil;
        }
        attribute.attrType = [PVDashboardBlueprint objectAttrTypeWithAttrID:identifier];
        if (attribute.attrType == PVAttrTypeUIColor) {
            if (!objectValue) {
                attribute.value = nil;
            } else if ([objectValue isKindOfClass:NSColor.class]) {
                attribute.value = [objectValue pv_inspect_rgbaComponents];
            } else {
                return nil;
            }
        } else {
            attribute.value = objectValue;
        }
    }

#undef PV_READ_VALUE
    return attribute;
}

@end

//
//  PVAutoLayoutConstraint+PVClient.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVAutoLayoutConstraint+PVClient.h"

@implementation PVAutoLayoutConstraint (PVAutoLayoutConstraint)


+ (NSString *)descriptionWithItemObject:(PVObject *)object type:(PVConstraintItemType)type detailed:(BOOL)detailed {
    switch (type) {
        case PVConstraintItemTypeNil:
            return detailed ? @"Nil" : @"nil";
            
        case PVConstraintItemTypeSelf:
            return detailed ? @"Self" : @"self";
            
        case PVConstraintItemTypeSuper:
            return detailed ? @"Superview" : @"super";
            
        case PVConstraintItemTypeView:
        case PVConstraintItemTypeLayoutGuide:
            return detailed ? [NSString stringWithFormat:@"<%@: %@>", object.rawClassName, object.memoryAddress] : [NSString stringWithFormat:@"(%@*)", object.lk_simpleDemangledClassName];
            
        default:
            NSAssert(NO, @"");
            return detailed ? [NSString stringWithFormat:@"<%@: %@>", object.rawClassName, object.memoryAddress] : [NSString stringWithFormat:@"(%@*)", object.rawClassName];
    }
}

// 注意 iOS 和 macOS 虽然都有 NSLayoutAttribute 但是 value 非常不同，这里应该去 iOS 平台查看 NSLayoutAttribute 的对应
+ (NSString *)descriptionWithAttributeInt:(NSInteger)attribute {
    switch (attribute) {
        case 0 :
            // 在某些业务里确实会出现这种情况，在 Reveal 和 UI Debugger 里也是这么显示的
            return @"notAnAttribute";
        case 1:
            return @"left";
        case 2:
            return @"right";
        case 3:
            return @"top";
        case 4:
            return @"bottom";
        case 5:
            return @"leading";
        case 6:
            return @"trailing";
        case 7:
            return @"width";
        case 8:
            return @"height";
        case 9:
            return @"centerX";
        case 10:
            return @"centerY";
        case 11:
            return @"lastBaseline";
        case 12:
            return @"firstBaseline";
        case 13:
            return @"leftMargin";
        case 14:
            return @"rightMargin";
        case 15:
            return @"topMargin";
        case 16:
            return @"bottomMargin";
        case 17:
            return @"leadingMargin";
        case 18:
            return @"trailingMargin";
        case 19:
            return @"centerXWithinMargins";
        case 20:
            return @"centerYWithinMargins";
            
            // 以下都是和 AutoResizingMask 有关的，这里的定义是从系统 UI Debugger 里抄过来的，暂时没在官方文档里发现它们的公开定义
        case 32:
            return @"minX";
        case 33:
            return @"minY";
        case 34:
            return @"midX";
        case 35:
            return @"midY";
        case 36:
            return @"maxX";
        case 37:
            return @"maxY";
        default:
            NSAssert(NO, @"");
            return [NSString stringWithFormat:@"unknownAttr(%@)", @(attribute)];
    }
}

+ (NSString *)symbolWithRelation:(NSLayoutRelation)relation {
    switch (relation) {
        case -1:
            return @"<=";
        case 0:
            return @"=";
        case 1:
            return @">=";
        default:
            NSAssert(NO, @"");
            return @"?";
    }
}

+ (NSString *)descriptionWithRelation:(NSLayoutRelation)relation {
    switch (relation) {
        case -1:
            return @"LessThanOrEqual";
        case 0:
            return @"Equal";
        case 1:
            return @"GreaterThanOrEqual";
        default:
            NSAssert(NO, @"");
            return @"?";
    }
}

@end

//
//  PVDisplayItem+PVClient.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDisplayItem+PVClient.h"
#import "PVIvarTrace.h"

@implementation PVDisplayItem (PVClient)

- (NSString *)title {
    if (self.customInfo) {
        return self.customInfo.title;
    } else if (self.customDisplayTitle.length > 0) {
        return self.customDisplayTitle;
    } else if (self.windowObject) {
        return self.windowObject.lk_simpleDemangledClassName;
    } else if (self.viewObject) {
        return self.viewObject.lk_simpleDemangledClassName;
    } else if (self.layerObject) {
        return self.layerObject.lk_simpleDemangledClassName;
    } else {
        return nil;
    }
}

- (NSString *)subtitle {
    if (self.customInfo) {
        return self.customInfo.subtitle;
    }
    
    NSString *windowControllerName = self.hostWindowControllerObject.lk_simpleDemangledClassName;
    if (windowControllerName.length) {
        return [NSString stringWithFormat:@"%@.window", windowControllerName];
    }
    NSString *text = self.hostViewControllerObject.lk_simpleDemangledClassName;
    if (text.length) {
        return [NSString stringWithFormat:@"%@.view", text];
    }
    
    PVObject *representedObject = self.windowObject ?: self.viewObject ?: self.layerObject;
    if (representedObject.specialTrace.length) {
        return representedObject.specialTrace;
        
    }
    if (representedObject.ivarTraces.count) {
        NSArray<NSString *> *ivarNameList = [representedObject.ivarTraces pv_inspect_map:^id(NSUInteger idx, PVIvarTrace *value) {
            return value.ivarName;
        }];
        return [[[NSSet setWithArray:ivarNameList] allObjects] componentsJoinedByString:@"   "];
    }
    
    return nil;
}

- (BOOL)representedForSystemClass {
    return [self.title hasPrefix:@"UI"] ||
        [self.title hasPrefix:@"NS"] ||
        [self.title hasPrefix:@"CA"] ||
        [self.title hasPrefix:@"_"];
}

- (NSImage *)appropriateScreenshot {
    if (self.isExpandable && self.isExpanded) {
        return self.soloScreenshot;
    }
    return self.groupScreenshot;
}

- (BOOL)isUserCustom {
    return self.customInfo != nil;
}

- (BOOL)hasPreviewBoxAbility {
    if (!self.customInfo) {
        return YES;
    }
    if ([self.customInfo hasValidFrame]) {
        return YES;
    }
    return NO;
}

- (BOOL)hasValidFrameToRoot {
    if (self.customInfo) {
        return [self.customInfo hasValidFrame];
    }
    return [PVDetailHelper validateFrame:self.frame];
}

- (CGRect)calculateFrameToRoot {
    if (self.customInfo) {
        return [self.customInfo.frameInWindow rectValue];
    }
    if (!self.superItem) {
        return self.frame;
    }
    CGRect superFrameToRoot = [self.superItem calculateFrameToRoot];
    CGRect superBounds = self.superItem.bounds;
    CGRect selfFrame = self.frame;
    
    CGFloat x = selfFrame.origin.x - superBounds.origin.x + superFrameToRoot.origin.x;
    CGFloat y = selfFrame.origin.y - superBounds.origin.y + superFrameToRoot.origin.y;
    
    CGFloat width = selfFrame.size.width;
    CGFloat height = selfFrame.size.height;
    return CGRectMake(x, y, width, height);
}

- (BOOL)isMatchedWithSearchString:(NSString *)string {
    if (string.length == 0) {
        NSAssert(NO, @"");
        return NO;
    }
    NSString *searchString = string.lowercaseString;
    if ([self.title.lowercaseString containsString:searchString]) {
        return YES;
    }
    if ([self.subtitle.lowercaseString containsString:searchString]) {
        return YES;
    }
    if ([self.viewObject.memoryAddress containsString:searchString]) {
        return YES;
    }
    if ([self.layerObject.memoryAddress containsString:searchString]) {
        return YES;
    }
    return NO;
}

- (void)enumerateSelfAndAncestors:(void (^)(PVDisplayItem *, BOOL *))block {
    if (!block) {
        return;
    }
    PVDisplayItem *item = self;
    while (item) {
        BOOL shouldStop = NO;
        block(item, &shouldStop);
        if (shouldStop) {
            break;
        }
        item = item.superItem;
    }
}

- (void)enumerateAncestors:(void (^)(PVDisplayItem *, BOOL *))block {
    [self.superItem enumerateSelfAndAncestors:block];
}

- (void)enumerateSelfAndChildren:(void (^)(PVDisplayItem *item))block {
    if (!block) {
        return;
    }
    
    block(self);
    [self.subitems enumerateObjectsUsingBlock:^(PVDisplayItem * _Nonnull subitem, NSUInteger idx, BOOL * _Nonnull stop) {
        [subitem enumerateSelfAndChildren:block];
    }];
}

- (BOOL)itemIsKindOfClassWithName:(NSString *)className {
    if (!className) {
        NSAssert(NO, @"");
        return NO;
    }
    return [self itemIsKindOfClassesWithNames:[NSSet setWithObject:className]];
}

- (BOOL)itemIsKindOfClassesWithNames:(NSSet<NSString *> *)targetClassNames {
    if (!targetClassNames.count) {
        return NO;
    }
    PVObject *selfObj = self.windowObject ?: self.viewObject ?: self.layerObject;
    if (!selfObj) {
        return NO;
    }
    
    __block BOOL boolValue = NO;
    [targetClassNames enumerateObjectsUsingBlock:^(NSString * _Nonnull targetClassName, BOOL * _Nonnull stop_outer) {
        [selfObj.classChainList enumerateObjectsUsingBlock:^(NSString * _Nonnull selfClass, NSUInteger idx, BOOL * _Nonnull stop_inner) {
            NSString *nonPrefixSelfClass = [selfClass componentsSeparatedByString:@"."].lastObject;
            if ([nonPrefixSelfClass isEqualToString:targetClassName]) {
                boolValue = YES;
                *stop_inner = YES;
            }
        }];
        if (boolValue) {
            *stop_outer = YES;
        }
    }];
    
    return boolValue;
}

- (unsigned long)bestObjectOidPreferView:(BOOL)preferView {
    if (self.windowObject.oid) {
        return self.windowObject.oid;
    }
    if (preferView && self.viewObject.oid) {
        return self.viewObject.oid;
    }
    if (self.layerObject.oid) {
        return self.layerObject.oid;
    }
    return self.viewObject.oid;
}

- (NSArray<NSNumber *> *)availableObjectOidsPreferView:(BOOL)preferView {
    NSMutableOrderedSet<NSNumber *> *oids = [NSMutableOrderedSet orderedSet];
    unsigned long preferredOid = [self bestObjectOidPreferView:preferView];
    if (preferredOid) {
        [oids addObject:@(preferredOid)];
    }
    if (self.windowObject.oid) {
        [oids addObject:@(self.windowObject.oid)];
    }
    if (self.viewObject.oid) {
        [oids addObject:@(self.viewObject.oid)];
    }
    if (self.layerObject.oid) {
        [oids addObject:@(self.layerObject.oid)];
    }
    return oids.array;
}

@end

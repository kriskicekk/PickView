//
//  NSObject+PVInspect.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "NSObject+PVInspect.h"
#import "Image+PVInspect.h"
#import <objc/runtime.h>
#import "TargetConditionals.h"
#import "PVWeakContainer.h"

@implementation NSObject (PickView)

#pragma mark - Data Bind

static char kAssociatedObjectKey_PickViewAllBindObjects;
- (NSMutableDictionary<id, id> *)pv_inspect_allBindObjects {
    NSMutableDictionary<id, id> *dict = objc_getAssociatedObject(self, &kAssociatedObjectKey_PickViewAllBindObjects);
    if (!dict) {
        dict = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, &kAssociatedObjectKey_PickViewAllBindObjects, dict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return dict;
}

- (void)pv_inspect_bindObject:(id)object forKey:(NSString *)key {
    if (!key.length) {
        NSAssert(NO, @"");
        return;
    }
    @synchronized (self) {
        if (object) {
            [[self pv_inspect_allBindObjects] setObject:object forKey:key];
        } else {
            [[self pv_inspect_allBindObjects] removeObjectForKey:key];
        }
    }
}

- (id)pv_inspect_getBindObjectForKey:(NSString *)key {
    if (!key.length) {
        NSAssert(NO, @"");
        return nil;
    }
    @synchronized (self) {
        id storedObj = [[self pv_inspect_allBindObjects] objectForKey:key];
        if ([storedObj isKindOfClass:[PVWeakContainer class]]) {
            storedObj = [(PVWeakContainer *)storedObj object];
        }
        return storedObj;
    }
}

- (void)pv_inspect_bindObjectWeakly:(id)object forKey:(NSString *)key {
    if (!key.length) {
        NSAssert(NO, @"");
        return;
    }
    if (object) {
        PVWeakContainer *container = [[PVWeakContainer alloc] init];
        container.object = object;
        [self pv_inspect_bindObject:container forKey:key];
    } else {
        [self pv_inspect_bindObject:nil forKey:key];
    }
}

- (void)pv_inspect_bindDouble:(double)doubleValue forKey:(NSString *)key {
    [self pv_inspect_bindObject:@(doubleValue) forKey:key];
}

- (double)pv_inspect_getBindDoubleForKey:(NSString *)key {
    id object = [self pv_inspect_getBindObjectForKey:key];
    if ([object isKindOfClass:[NSNumber class]]) {
        double doubleValue = [(NSNumber *)object doubleValue];
        return doubleValue;
        
    } else {
        return 0.0;
    }
}

- (void)pv_inspect_bindBOOL:(BOOL)boolValue forKey:(NSString *)key {
    [self pv_inspect_bindObject:@(boolValue) forKey:key];
}

- (BOOL)pv_inspect_getBindBOOLForKey:(NSString *)key {
    id object = [self pv_inspect_getBindObjectForKey:key];
    if ([object isKindOfClass:[NSNumber class]]) {
        BOOL boolValue = [(NSNumber *)object boolValue];
        return boolValue;
        
    } else {
        return NO;
    }
}

- (void)pv_inspect_bindLong:(long)longValue forKey:(NSString *)key {
    [self pv_inspect_bindObject:@(longValue) forKey:key];
}

- (long)pv_inspect_getBindLongForKey:(NSString *)key {
    id object = [self pv_inspect_getBindObjectForKey:key];
    if ([object isKindOfClass:[NSNumber class]]) {
        long longValue = [(NSNumber *)object longValue];
        return longValue;
        
    } else {
        return 0;
    }
}

- (void)pv_inspect_bindPoint:(CGPoint)pointValue forKey:(NSString *)key {
#if TARGET_OS_IPHONE
    [self pv_inspect_bindObject:[NSValue valueWithCGPoint:pointValue] forKey:key];
#elif TARGET_OS_OSX
    NSPoint nsPoint = NSMakePoint(pointValue.x, pointValue.y);
    [self pv_inspect_bindObject:[NSValue valueWithPoint:nsPoint] forKey:key];
#endif
}

- (CGPoint)pv_inspect_getBindPointForKey:(NSString *)key {
    id object = [self pv_inspect_getBindObjectForKey:key];
    if ([object isKindOfClass:[NSValue class]]) {
#if TARGET_OS_IPHONE
        CGPoint pointValue = [(NSValue *)object CGPointValue];
#elif TARGET_OS_OSX
        NSPoint nsPointValue = [(NSValue *)object pointValue];
        CGPoint pointValue = CGPointMake(nsPointValue.x, nsPointValue.y);
#endif
        return pointValue;
    } else {
        return CGPointZero;
    }
}

- (void)pv_inspect_clearBindForKey:(NSString *)key {
    [self pv_inspect_bindObject:nil forKey:key];
}

@end

@implementation NSObject (PickView_Coding)

- (id)pv_inspect_encodedObjectWithType:(PVCodingValueType)type {
    if (type == PVCodingValueTypeColor) {
        if ([self isKindOfClass:[PVColor class]]) {
            CGFloat r, g, b, a;
#if TARGET_OS_IPHONE
            CGFloat white;
            if ([(UIColor *)self getRed:&r green:&g blue:&b alpha:&a]) {
                // valid
            } else if ([(UIColor *)self getWhite:&white alpha:&a]) {
                r = white;
                g = white;
                b = white;
            } else {
                NSAssert(NO, @"");
                r = 0;
                g = 0;
                b = 0;
                a = 0;
            }
#elif TARGET_OS_OSX
            NSColor *color = [((NSColor *)self) colorUsingColorSpace:NSColorSpace.sRGBColorSpace];
            [color getRed:&r green:&g blue:&b alpha:&a];
#endif
            NSArray<NSNumber *> *rgba = @[@(r), @(g), @(b), @(a)];
            return rgba;
            
        } else {
            NSAssert(NO, @"");
            return nil;
        }
        
    } else if (type == PVCodingValueTypeImage) {
#if TARGET_OS_IPHONE
        if ([self isKindOfClass:[UIImage class]]) {
            UIImage *image = (UIImage *)self;
            return [image pv_inspect_data];
            
        } else {
            NSAssert(NO, @"");
            return nil;
        }
#elif TARGET_OS_OSX
        if ([self isKindOfClass:[NSImage class]]) {
            NSImage *image = (NSImage *)self;
            return [image pv_inspect_data];
            
        } else {
            NSAssert(NO, @"");
            return nil;
        }
#endif
        
    } else {
        return self;
    }
}

- (id)pv_inspect_decodedObjectWithType:(PVCodingValueType)type {
    if (type == PVCodingValueTypeColor) {
        if ([self isKindOfClass:[NSArray class]]) {
            NSArray<NSNumber *> *rgba = (NSArray *)self;
            CGFloat r = [rgba[0] doubleValue];
            CGFloat g = [rgba[1] doubleValue];
            CGFloat b = [rgba[2] doubleValue];
            CGFloat a = [rgba[3] doubleValue];
            PVColor *color = [PVColor colorWithRed:r green:g blue:b alpha:a];
            return color;
            
        } else {
            NSAssert(NO, @"");
            return nil;
        }
        
    } else if (type == PVCodingValueTypeImage) {
        if ([self isKindOfClass:[NSData class]]) {
            PVImage *image = [[PVImage alloc] initWithData:(NSData *)self];
            return image;
        } else {
            NSAssert(NO, @"");
            return nil;
        }
            
    } else {
        return self;
    }
}

@end

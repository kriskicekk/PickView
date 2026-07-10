//
//  PVMacAttributeAccessors.m
//  PickViewServer
//
//  Created by kris cheng on 2026/7/10.
//

#import "PVMacAttributeAccessors.h"

@implementation NSImageView (PVInspectServer)

- (NSString *)pv_lks_imageSourceName {
    return self.image.name;
}

- (NSNumber *)pv_lks_imageViewOidIfHasImage {
    return self.image ? @((unsigned long)(uintptr_t)self) : nil;
}

@end

@implementation NSControl (PVInspectServer)

- (NSString *)pv_lks_fontName {
    return self.font.fontName;
}

- (CGFloat)pv_lks_fontSize {
    return self.font.pointSize;
}

- (void)setLks_fontSize:(CGFloat)fontSize {
    NSFont *font = self.font ?: [NSFont systemFontOfSize:NSFont.systemFontSize];
    self.font = [NSFont fontWithDescriptor:font.fontDescriptor size:fontSize];
}

@end

@implementation NSTextView (PVInspectServer)

- (NSString *)pv_lks_fontName {
    return self.font.fontName;
}

- (CGFloat)pv_lks_fontSize {
    return self.font.pointSize;
}

- (void)setLks_fontSize:(CGFloat)fontSize {
    NSFont *font = self.font ?: [NSFont systemFontOfSize:NSFont.systemFontSize];
    self.font = [NSFont fontWithDescriptor:font.fontDescriptor size:fontSize];
}

@end

@implementation NSButton (PVInspectServer)

- (NSButtonType)pv_lks_buttonType {
    @try {
        return [[self valueForKeyPath:@"cell._buttonType"] unsignedIntegerValue];
    } @catch (__unused NSException *exception) {
        return NSButtonTypeMomentaryLight;
    }
}

@end

@implementation NSScrollView (PVInspectServer)

- (CGPoint)pv_lks_contentOffset {
    return self.contentView.bounds.origin;
}

- (CGSize)pv_lks_contentSize {
    return self.documentView.frame.size;
}

- (void)setLks_contentOffset:(CGPoint)contentOffset {
    [self.contentView scrollToPoint:contentOffset];
    [self reflectScrolledClipView:self.contentView];
}

- (void)setLks_contentSize:(CGSize)contentSize {
    [self.documentView setFrameSize:contentSize];
}

@end

@implementation NSWindow (PVInspectServer)

- (NSView *)pv_inspect_rootView {
    return self.contentView.superview ?: self.contentView;
}

- (CGRect)pv_inspect_bounds {
    CGRect bounds = self.frame;
    bounds.origin = CGPointZero;
    return bounds;
}

#define PV_STYLE_GETTER(NAME, MASK) - (BOOL)NAME { return (self.styleMask & MASK) != 0; }
PV_STYLE_GETTER(pv_lks_styleMaskTitled, NSWindowStyleMaskTitled)
PV_STYLE_GETTER(pv_lks_styleMaskClosable, NSWindowStyleMaskClosable)
PV_STYLE_GETTER(pv_lks_styleMaskMiniaturizable, NSWindowStyleMaskMiniaturizable)
PV_STYLE_GETTER(pv_lks_styleMaskResizable, NSWindowStyleMaskResizable)
PV_STYLE_GETTER(pv_lks_styleMaskUnifiedTitleAndToolbar, NSWindowStyleMaskUnifiedTitleAndToolbar)
PV_STYLE_GETTER(pv_lks_styleMaskFullScreen, NSWindowStyleMaskFullScreen)
PV_STYLE_GETTER(pv_lks_styleMaskFullSizeContentView, NSWindowStyleMaskFullSizeContentView)
PV_STYLE_GETTER(pv_lks_styleMaskUtilityWindow, NSWindowStyleMaskUtilityWindow)
PV_STYLE_GETTER(pv_lks_styleMaskDocModalWindow, NSWindowStyleMaskDocModalWindow)
PV_STYLE_GETTER(pv_lks_styleMaskNonactivatingPanel, NSWindowStyleMaskNonactivatingPanel)
PV_STYLE_GETTER(pv_lks_styleMaskHUDWindow, NSWindowStyleMaskHUDWindow)
#undef PV_STYLE_GETTER

#define PV_STYLE_SETTER(NAME, MASK) \
    - (void)NAME:(BOOL)value { \
        self.styleMask = value ? self.styleMask | MASK : self.styleMask & ~MASK; \
    }
PV_STYLE_SETTER(setLks_styleMaskTitled, NSWindowStyleMaskTitled)
PV_STYLE_SETTER(setLks_styleMaskClosable, NSWindowStyleMaskClosable)
PV_STYLE_SETTER(setLks_styleMaskMiniaturizable, NSWindowStyleMaskMiniaturizable)
PV_STYLE_SETTER(setLks_styleMaskResizable, NSWindowStyleMaskResizable)
PV_STYLE_SETTER(setLks_styleMaskUnifiedTitleAndToolbar, NSWindowStyleMaskUnifiedTitleAndToolbar)
PV_STYLE_SETTER(setLks_styleMaskFullSizeContentView, NSWindowStyleMaskFullSizeContentView)
#undef PV_STYLE_SETTER

#define PV_BEHAVIOR_GETTER(NAME, MASK) - (BOOL)NAME { return (self.collectionBehavior & MASK) != 0; }
PV_BEHAVIOR_GETTER(pv_lks_collectionBehaviorCanJoinAllSpaces, NSWindowCollectionBehaviorCanJoinAllSpaces)
PV_BEHAVIOR_GETTER(pv_lks_collectionBehaviorMoveToActiveSpace, NSWindowCollectionBehaviorMoveToActiveSpace)
PV_BEHAVIOR_GETTER(pv_lks_collectionBehaviorParticipatesInCycle, NSWindowCollectionBehaviorParticipatesInCycle)
PV_BEHAVIOR_GETTER(pv_lks_collectionBehaviorIgnoresCycle, NSWindowCollectionBehaviorIgnoresCycle)
PV_BEHAVIOR_GETTER(pv_lks_collectionBehaviorFullScreenPrimary, NSWindowCollectionBehaviorFullScreenPrimary)
PV_BEHAVIOR_GETTER(pv_lks_collectionBehaviorFullScreenAuxiliary, NSWindowCollectionBehaviorFullScreenAuxiliary)
PV_BEHAVIOR_GETTER(pv_lks_collectionBehaviorFullScreenNone, NSWindowCollectionBehaviorFullScreenNone)
PV_BEHAVIOR_GETTER(pv_lks_collectionBehaviorFullScreenAllowsTiling, NSWindowCollectionBehaviorFullScreenAllowsTiling)
PV_BEHAVIOR_GETTER(pv_lks_collectionBehaviorFullScreenDisallowsTiling, NSWindowCollectionBehaviorFullScreenDisallowsTiling)
#undef PV_BEHAVIOR_GETTER

@end

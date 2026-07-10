//
//  PVMacAttributeAccessors.h
//  PickViewServer
//
//  Created by kris cheng on 2026/7/10.
//

#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSImageView (PVInspectServer)
- (nullable NSString *)pv_lks_imageSourceName;
- (nullable NSNumber *)pv_lks_imageViewOidIfHasImage;
@end

@interface NSControl (PVInspectServer)
- (nullable NSString *)pv_lks_fontName;
- (CGFloat)pv_lks_fontSize;
- (void)setLks_fontSize:(CGFloat)fontSize;
@end

@interface NSTextView (PVInspectServer)
- (nullable NSString *)pv_lks_fontName;
- (CGFloat)pv_lks_fontSize;
- (void)setLks_fontSize:(CGFloat)fontSize;
@end

@interface NSButton (PVInspectServer)
- (NSButtonType)pv_lks_buttonType;
@end

@interface NSScrollView (PVInspectServer)
- (CGPoint)pv_lks_contentOffset;
- (CGSize)pv_lks_contentSize;
- (void)setLks_contentOffset:(CGPoint)contentOffset;
- (void)setLks_contentSize:(CGSize)contentSize;
@end

@interface NSWindow (PVInspectServer)
- (NSView *)pv_inspect_rootView;
- (CGRect)pv_inspect_bounds;
- (BOOL)pv_lks_styleMaskTitled;
- (BOOL)pv_lks_styleMaskClosable;
- (BOOL)pv_lks_styleMaskMiniaturizable;
- (BOOL)pv_lks_styleMaskResizable;
- (BOOL)pv_lks_styleMaskUnifiedTitleAndToolbar;
- (BOOL)pv_lks_styleMaskFullScreen;
- (BOOL)pv_lks_styleMaskFullSizeContentView;
- (BOOL)pv_lks_styleMaskUtilityWindow;
- (BOOL)pv_lks_styleMaskDocModalWindow;
- (BOOL)pv_lks_styleMaskNonactivatingPanel;
- (BOOL)pv_lks_styleMaskHUDWindow;
- (void)setLks_styleMaskTitled:(BOOL)value;
- (void)setLks_styleMaskClosable:(BOOL)value;
- (void)setLks_styleMaskMiniaturizable:(BOOL)value;
- (void)setLks_styleMaskResizable:(BOOL)value;
- (void)setLks_styleMaskUnifiedTitleAndToolbar:(BOOL)value;
- (void)setLks_styleMaskFullSizeContentView:(BOOL)value;
- (BOOL)pv_lks_collectionBehaviorCanJoinAllSpaces;
- (BOOL)pv_lks_collectionBehaviorMoveToActiveSpace;
- (BOOL)pv_lks_collectionBehaviorParticipatesInCycle;
- (BOOL)pv_lks_collectionBehaviorIgnoresCycle;
- (BOOL)pv_lks_collectionBehaviorFullScreenPrimary;
- (BOOL)pv_lks_collectionBehaviorFullScreenAuxiliary;
- (BOOL)pv_lks_collectionBehaviorFullScreenNone;
- (BOOL)pv_lks_collectionBehaviorFullScreenAllowsTiling;
- (BOOL)pv_lks_collectionBehaviorFullScreenDisallowsTiling;
@end

NS_ASSUME_NONNULL_END

//
//  PVDetailTableRowView.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import <Cocoa/Cocoa.h>

@class PVDetailTableViewHorizontalScrollWidthManager;

@interface PVDetailTableRowView : NSTableRowView

@property(nonatomic, strong, readonly) PVDetailLabel *titleLabel;
@property(nonatomic, strong, readonly) PVDetailLabel *subtitleLabel;

@property(nonatomic, assign) BOOL isSelected;
@property(nonatomic, assign) BOOL isHovered;

@property(nonatomic, assign, readonly) BOOL isDarkMode;
/// 子类可在该方法里更新 UI
- (void)setIsDarkMode:(BOOL)isDarkMode NS_REQUIRES_SUPER;

@property(nonatomic, weak) PVDetailTableViewHorizontalScrollWidthManager* horizontalScrollWidthManager;

@end

@interface PVDetailTableBlankRowView : PVDetailTableRowView

@end

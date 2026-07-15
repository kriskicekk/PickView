//
//  PVDetailOutlineRowView.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailTableRowView.h"

typedef NS_ENUM(NSUInteger, PVDetailOutlineRowViewStatus) {
    PVDetailOutlineRowViewStatusNotExpandable,
    PVDetailOutlineRowViewStatusExpanded,
    PVDetailOutlineRowViewStatusCollapsed
};

@interface PVDetailOutlineRowView : PVDetailTableRowView {
    @protected
    CGFloat _imageLeft;
    CGFloat _imageRight;
    CGFloat _titleLeft;
    CGFloat _subtitleLeft;
}

- (instancetype)initWithCompactUI:(BOOL)compact;

@property(nonatomic, strong, readonly) NSButton *disclosureButton;

@property(nonatomic, strong) NSImage *image;
@property(nonatomic, strong, readonly) NSImageView *imageView;

@property(nonatomic, assign) PVDetailOutlineRowViewStatus status;

@property(nonatomic, assign) NSUInteger indentLevel;

+ (CGFloat)dislosureMidXWithIndentLevel:(NSUInteger)level;

@end

@interface PVDetailOutlineRowView (NSSubclassingHooks)

+ (CGFloat)insetLeft;

@end

//
//  LKOutlineRowView.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "LKTableRowView.h"

typedef NS_ENUM(NSUInteger, LKOutlineRowViewStatus) {
    LKOutlineRowViewStatusNotExpandable,
    LKOutlineRowViewStatusExpanded,
    LKOutlineRowViewStatusCollapsed
};

@interface LKOutlineRowView : LKTableRowView {
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

@property(nonatomic, assign) LKOutlineRowViewStatus status;

@property(nonatomic, assign) NSUInteger indentLevel;

+ (CGFloat)dislosureMidXWithIndentLevel:(NSUInteger)level;

@end

@interface LKOutlineRowView (NSSubclassingHooks)

+ (CGFloat)insetLeft;

@end

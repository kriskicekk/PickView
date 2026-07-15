//
//  PVDetailInputSearchSuggestionsRowView.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import <Cocoa/Cocoa.h>

@interface PVDetailInputSearchSuggestionsRowView : NSTableRowView

@property(nonatomic, strong, readonly) PVDetailLabel *titleLabel;
@property(nonatomic, strong, readonly) NSImageView *imageView;

- (CGFloat)bestWidth;

@end

//
//  LKInputSearchSuggestionsRowView.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import <Cocoa/Cocoa.h>

@interface LKInputSearchSuggestionsRowView : NSTableRowView

@property(nonatomic, strong, readonly) LKLabel *titleLabel;
@property(nonatomic, strong, readonly) NSImageView *imageView;

- (CGFloat)bestWidth;

@end

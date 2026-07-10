//
//  PVToolbarScaleView.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface PVToolbarScaleView : NSView

@property (nonatomic, strong, readonly) NSButton *decreaseButton;
@property (nonatomic, strong, readonly) NSSlider *slider;
@property (nonatomic, strong, readonly) NSButton *increaseButton;

@end

NS_ASSUME_NONNULL_END

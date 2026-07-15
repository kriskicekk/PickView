//
//  PVDetailWindowToolbarScaleView.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailBaseView.h"

@interface PVDetailWindowToolbarScaleView : PVDetailBaseView

@property(nonatomic, strong, readonly) NSSlider *slider;
@property(nonatomic, strong, readonly) NSButton *decreaseButton;
@property(nonatomic, strong, readonly) NSButton *increaseButton;

@end

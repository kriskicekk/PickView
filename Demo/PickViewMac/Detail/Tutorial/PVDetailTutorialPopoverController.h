//
//  PVDetailTutorialPopoverController.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailBaseViewController.h"

@interface PVDetailTutorialPopoverController : PVDetailBaseViewController

- (instancetype)initWithText:(NSString *)text popover:(NSPopover *)popover;

- (NSSize)contentSize;

/// 外部可通过该属性来记录 popover 打开的时间
@property(nonatomic, assign) NSTimeInterval showTimestamp;
/// 在点击了 closeButton 后，该属性会被置为 YES
@property(nonatomic, assign) BOOL hasClickedCloseButton;

@property(nonatomic, copy) void (^learnedBlock)(void);

@end

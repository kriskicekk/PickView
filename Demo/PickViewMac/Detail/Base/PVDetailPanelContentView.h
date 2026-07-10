//
//  PVDetailPanelContentView.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailBaseView.h"

@interface PVDetailPanelContentView : PVDetailBaseView

@property(nonatomic, strong, readonly) NSButton *submitButton;

@property(nonatomic, strong) NSImage *titleImage;

@property(nonatomic, copy) NSString *titleText;

@property(nonatomic, strong, readonly) PVDetailBaseView *contentView;

@property(nonatomic, copy) void (^needExit)(void);

@end

@interface PVDetailPanelContentView (NSSubclassingHooks)

- (void)didClickSubmitButton;

@end

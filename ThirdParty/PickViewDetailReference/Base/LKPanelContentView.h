//
//  LKPanelContentView.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "LKBaseView.h"

@interface LKPanelContentView : LKBaseView

@property(nonatomic, strong, readonly) NSButton *submitButton;

@property(nonatomic, strong) NSImage *titleImage;

@property(nonatomic, copy) NSString *titleText;

@property(nonatomic, strong, readonly) LKBaseView *contentView;

@property(nonatomic, copy) void (^needExit)(void);

@end

@interface LKPanelContentView (NSSubclassingHooks)

- (void)didClickSubmitButton;

@end

//
//  PVDetailPreferenceSwitchView.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailBaseView.h"

@interface PVDetailPreferenceSwitchView : PVDetailBaseView

- (instancetype)initWithTitle:(NSString *)title checkedMessage:(NSString *)checkedMessage uncheckedMessage:(NSString *)uncheckedMessage;
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message;

@property(nonatomic, assign) BOOL isChecked;
@property(nonatomic, copy) void (^didChange)(BOOL isChecked);

@end

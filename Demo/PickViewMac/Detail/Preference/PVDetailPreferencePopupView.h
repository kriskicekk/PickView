//
//  PVDetailPreferencePopupView.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailBaseView.h"

@interface PVDetailPreferencePopupView : PVDetailBaseView

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message options:(NSArray<NSString *> *)options;

- (instancetype)initWithTitle:(NSString *)title messages:(NSArray<NSString *> *)messages options:(NSArray<NSString *> *)options;

@property(nonatomic, assign) NSUInteger selectedIndex;
@property(nonatomic, copy) void (^didChange)(NSUInteger selectedIndex);

@property(nonatomic, assign) BOOL isEnabled;

@property(nonatomic, assign) CGFloat buttonX;

@end

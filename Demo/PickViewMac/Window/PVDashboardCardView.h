//
//  PVDashboardCardView.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface PVDashboardCardView : NSView

- (instancetype)initWithTitle:(NSString *)title
                         rows:(NSArray<NSArray<NSString *> *> *)rows NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithFrame:(NSRect)frameRect NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

- (nullable NSTextField *)valueLabelForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END

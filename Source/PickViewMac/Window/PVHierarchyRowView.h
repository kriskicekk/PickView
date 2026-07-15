//
//  PVHierarchyRowView.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface PVHierarchyRowView : NSTableCellView

- (void)configureWithTitle:(NSString *)title
                  subtitle:(NSString *)subtitle
                    hidden:(BOOL)hidden
                     alpha:(CGFloat)alpha;

- (void)configureWithTitle:(NSString *)title
                  subtitle:(NSString *)subtitle
                 className:(nullable NSString *)className
                    hidden:(BOOL)hidden
                     alpha:(CGFloat)alpha;

@end

NS_ASSUME_NONNULL_END

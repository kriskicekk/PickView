//
//  LKTableViewHorizontalScrollWidthManager.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "LKTableViewHorizontalScrollWidthManager.h"

@implementation LKTableViewHorizontalScrollWidthManager

- (void)rowDidLayoutWithWidth:(CGFloat)width {
    if (width > self.maxRowWidth) {
        self.maxRowWidth = width;
        if (self.didReachNewMaxWidth) {
            self.didReachNewMaxWidth();            
        }
    }
}

@end

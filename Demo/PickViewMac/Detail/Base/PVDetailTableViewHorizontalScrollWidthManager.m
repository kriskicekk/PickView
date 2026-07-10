//
//  PVDetailTableViewHorizontalScrollWidthManager.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailTableViewHorizontalScrollWidthManager.h"

@implementation PVDetailTableViewHorizontalScrollWidthManager

- (void)rowDidLayoutWithWidth:(CGFloat)width {
    if (width > self.maxRowWidth) {
        self.maxRowWidth = width;
        if (self.didReachNewMaxWidth) {
            self.didReachNewMaxWidth();            
        }
    }
}

@end

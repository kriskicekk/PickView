//
//  PVSplitView.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVSplitView.h"

@implementation PVSplitView {
    BOOL _hasLayouted;
}

- (CGFloat)dividerThickness {
    return 0.0;
}

- (void)layout {
    [super layout];

    if (!_hasLayouted) {
        if (self.didFinishFirstLayout) {
            self.didFinishFirstLayout(self);
        }
        _hasLayouted = YES;
    }
}

@end

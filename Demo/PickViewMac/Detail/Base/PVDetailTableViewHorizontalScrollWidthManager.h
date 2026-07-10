//
//  PVDetailTableViewHorizontalScrollWidthManager.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import <Foundation/Foundation.h>

@interface PVDetailTableViewHorizontalScrollWidthManager : NSObject

@property(nonatomic, assign) CGFloat maxRowWidth;

@property (nonatomic, copy) void (^didReachNewMaxWidth)(void);

- (void)rowDidLayoutWithWidth:(CGFloat)width;

@end

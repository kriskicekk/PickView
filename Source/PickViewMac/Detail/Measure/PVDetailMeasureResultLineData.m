//
//  PVDetailMeasureResultLineData.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailMeasureResultLineData.h"

@implementation PVDetailMeasureResultHorLineData

+ (instancetype)dataWithStartX:(CGFloat)startX endX:(CGFloat)endX y:(CGFloat)y value:(CGFloat)value {
    PVDetailMeasureResultHorLineData *data = [PVDetailMeasureResultHorLineData new];
    data.startX = startX;
    data.endX = endX;
    data.y = y;
    data.displayValue = value;
    return data;
}

@end

@implementation PVDetailMeasureResultVerLineData

+ (instancetype)dataWithStartY:(CGFloat)startY endY:(CGFloat)endY x:(CGFloat)x value:(CGFloat)value {
    PVDetailMeasureResultVerLineData *data = [PVDetailMeasureResultVerLineData new];
    data.startY = startY;
    data.endY = endY;
    data.x = x;
    data.displayValue = value;
    return data;
}

@end

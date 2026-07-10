//
//  PVDisplayItemDetail.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDisplayItemDetail.h"

#import "Image+PVInspect.h"
#import <TargetConditionals.h>


static NSValue *PVValueFromCGRect(CGRect rect) {
#if TARGET_OS_IPHONE
    return [NSValue valueWithCGRect:rect];
#elif TARGET_OS_OSX
    return [NSValue valueWithRect:NSRectFromCGRect(rect)];
#endif
}

@implementation PVDisplayItemDetail

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _displayItemID = @"";
        _frame = CGRectZero;
        _bounds = CGRectZero;
        _alpha = 1;
        _attributesGroupList = @[];
        _customAttrGroupList = @[];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.displayItemID forKey:@"displayItemID"];
    [coder encodeObject:self.soloImageData ?: self.soloScreenshot.pv_inspect_data forKey:@"soloImageData"];
    [coder encodeObject:self.groupImageData ?: self.groupScreenshot.pv_inspect_data forKey:@"groupImageData"];
    [self pv_encodeRect:self.frame coder:coder keyPrefix:@"frame"];
    [self pv_encodeRect:self.bounds coder:coder keyPrefix:@"bounds"];
    [coder encodeBool:self.hidden forKey:@"hidden"];
    [coder encodeDouble:self.alpha forKey:@"alpha"];
    [coder encodeInteger:self.failureCode forKey:@"failureCode"];

    [coder encodeObject:@(self.displayItemOid) forKey:@"displayItemOid"];
    [coder encodeObject:self.groupImageData ?: self.groupScreenshot.pv_inspect_data forKey:@"groupScreenshot"];
    [coder encodeObject:self.soloImageData ?: self.soloScreenshot.pv_inspect_data forKey:@"soloScreenshot"];
    [coder encodeObject:self.frameValue ?: PVValueFromCGRect(self.frame) forKey:@"frameValue"];
    [coder encodeObject:self.boundsValue ?: PVValueFromCGRect(self.bounds) forKey:@"boundsValue"];
    [coder encodeObject:self.hiddenValue ?: @(self.hidden) forKey:@"hiddenValue"];
    [coder encodeObject:self.alphaValue ?: @(self.alpha) forKey:@"alphaValue"];
    [coder encodeObject:self.attributesGroupList forKey:@"attributesGroupList"];
    [coder encodeObject:self.customAttrGroupList forKey:@"customAttrGroupList"];
    [coder encodeObject:self.customDisplayTitle forKey:@"customDisplayTitle"];
    [coder encodeObject:self.danceUISource forKey:@"danceUISource"];
    if (self.subitems) {
        [coder encodeObject:self.subitems forKey:@"subitems"];
    }
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _displayItemID = [[coder decodeObjectForKey:@"displayItemID"] copy] ?: @"";
        _soloImageData = [[coder decodeObjectForKey:@"soloImageData"] copy] ?: [[coder decodeObjectForKey:@"soloScreenshot"] copy];
        _groupImageData = [[coder decodeObjectForKey:@"groupImageData"] copy] ?: [[coder decodeObjectForKey:@"groupScreenshot"] copy];
        _soloScreenshot = _soloImageData.length ? [[PVImage alloc] initWithData:_soloImageData] : nil;
        _groupScreenshot = _groupImageData.length ? [[PVImage alloc] initWithData:_groupImageData] : nil;
        _frame = [self pv_decodeRectWithCoder:coder keyPrefix:@"frame"];
        _bounds = [self pv_decodeRectWithCoder:coder keyPrefix:@"bounds"];
        _hidden = [coder decodeBoolForKey:@"hidden"];
        _alpha = [coder containsValueForKey:@"alpha"] ? (CGFloat)[coder decodeDoubleForKey:@"alpha"] : 1;
        _failureCode = [coder decodeIntegerForKey:@"failureCode"];

        _displayItemOid = [[coder decodeObjectForKey:@"displayItemOid"] unsignedLongValue];
        _frameValue = [coder decodeObjectForKey:@"frameValue"] ?: PVValueFromCGRect(_frame);
        _boundsValue = [coder decodeObjectForKey:@"boundsValue"] ?: PVValueFromCGRect(_bounds);
        _hiddenValue = [coder decodeObjectForKey:@"hiddenValue"] ?: @(_hidden);
        _alphaValue = [coder decodeObjectForKey:@"alphaValue"] ?: @(_alpha);
        _attributesGroupList = [coder decodeObjectForKey:@"attributesGroupList"] ?: @[];
        _customAttrGroupList = [coder decodeObjectForKey:@"customAttrGroupList"] ?: @[];
        _customDisplayTitle = [[coder decodeObjectForKey:@"customDisplayTitle"] copy];
        _danceUISource = [[coder decodeObjectForKey:@"danceUISource"] copy];
        if ([coder containsValueForKey:@"subitems"]) {
            _subitems = [coder decodeObjectForKey:@"subitems"];
        }
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    PVDisplayItemDetail *detail = [[[self class] allocWithZone:zone] init];
    detail.displayItemID = self.displayItemID;
    detail.soloImageData = self.soloImageData;
    detail.groupImageData = self.groupImageData;
    detail.frame = self.frame;
    detail.bounds = self.bounds;
    detail.hidden = self.hidden;
    detail.alpha = self.alpha;
    detail.failureCode = self.failureCode;
    detail.displayItemOid = self.displayItemOid;
    detail.groupScreenshot = self.groupScreenshot;
    detail.soloScreenshot = self.soloScreenshot;
    detail.frameValue = self.frameValue;
    detail.boundsValue = self.boundsValue;
    detail.hiddenValue = self.hiddenValue;
    detail.alphaValue = self.alphaValue;
    detail.customDisplayTitle = self.customDisplayTitle;
    detail.danceUISource = self.danceUISource;
    detail.attributesGroupList = self.attributesGroupList;
    detail.customAttrGroupList = self.customAttrGroupList;
    detail.subitems = self.subitems;
    return detail;
}

- (void)pv_encodeRect:(CGRect)rect coder:(NSCoder *)coder keyPrefix:(NSString *)keyPrefix {
    [coder encodeDouble:rect.origin.x forKey:[keyPrefix stringByAppendingString:@"X"]];
    [coder encodeDouble:rect.origin.y forKey:[keyPrefix stringByAppendingString:@"Y"]];
    [coder encodeDouble:rect.size.width forKey:[keyPrefix stringByAppendingString:@"Width"]];
    [coder encodeDouble:rect.size.height forKey:[keyPrefix stringByAppendingString:@"Height"]];
}

- (CGRect)pv_decodeRectWithCoder:(NSCoder *)coder keyPrefix:(NSString *)keyPrefix {
    CGFloat x = (CGFloat)[coder decodeDoubleForKey:[keyPrefix stringByAppendingString:@"X"]];
    CGFloat y = (CGFloat)[coder decodeDoubleForKey:[keyPrefix stringByAppendingString:@"Y"]];
    CGFloat width = (CGFloat)[coder decodeDoubleForKey:[keyPrefix stringByAppendingString:@"Width"]];
    CGFloat height = (CGFloat)[coder decodeDoubleForKey:[keyPrefix stringByAppendingString:@"Height"]];
    return CGRectMake(x, y, width, height);
}

@end

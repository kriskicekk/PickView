//
//  PVWindowInfo.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVWindowInfo.h"

@implementation PVWindowInfo

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _windowID = @"";
        _title = @"";
        _className = @"";
        _frame = CGRectZero;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.windowID forKey:@"windowID"];
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.className forKey:@"className"];
    [self pv_encodeRect:self.frame coder:coder keyPrefix:@"frame"];
    [coder encodeBool:self.keyWindow forKey:@"keyWindow"];
    [coder encodeBool:self.mainWindow forKey:@"mainWindow"];
    [coder encodeBool:self.visible forKey:@"visible"];
    [coder encodeInteger:self.level forKey:@"level"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _windowID = [[coder decodeObjectOfClass:NSString.class forKey:@"windowID"] copy] ?: @"";
        _title = [[coder decodeObjectOfClass:NSString.class forKey:@"title"] copy] ?: @"";
        _className = [[coder decodeObjectOfClass:NSString.class forKey:@"className"] copy] ?: @"";
        _frame = [self pv_decodeRectWithCoder:coder keyPrefix:@"frame"];
        _keyWindow = [coder decodeBoolForKey:@"keyWindow"];
        _mainWindow = [coder decodeBoolForKey:@"mainWindow"];
        _visible = [coder decodeBoolForKey:@"visible"];
        _level = [coder decodeIntegerForKey:@"level"];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    PVWindowInfo *info = [[[self class] allocWithZone:zone] init];
    info.windowID = self.windowID;
    info.title = self.title;
    info.className = self.className;
    info.frame = self.frame;
    info.keyWindow = self.keyWindow;
    info.mainWindow = self.mainWindow;
    info.visible = self.visible;
    info.level = self.level;
    return info;
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

//
//  PVDetailWindowToolbarAppButton.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailWindowToolbarAppButton.h"
#import "PVAppInfo.h"

@interface PVDetailWindowToolbarAppButton ()

@property(nonatomic, strong) NSImageView *appImageView;
@property(nonatomic, strong) PVDetailLabel *appNameLabel;
@property(nonatomic, strong) NSImageView *sepImageView;
@property(nonatomic, strong) NSImageView *deviceImageView;
@property(nonatomic, strong) PVDetailLabel *deviceLabel;

@property(nonatomic, assign) CGFloat appImageWidth;
@property(nonatomic, copy) NSArray<NSNumber *> *spaces;

@end

@implementation PVDetailWindowToolbarAppButton

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        self.title = @"";
        self.appImageWidth = 14;
        self.spaces = @[@7, @3, @3, @4, @1];
        
        self.appImageView = [NSImageView new];
        self.appImageView.wantsLayer = YES;
        self.appImageView.layer.cornerRadius = 2;
        self.appImageView.layer.masksToBounds = YES;
        [self addSubview:self.appImageView];
        
        self.appNameLabel = [PVDetailLabel new];
        self.appNameLabel.textColors = PVDetailColorsCombine(PVColorMake(65, 65, 65), [NSColor labelColor]);
        [self addSubview:self.appNameLabel];
        
        self.sepImageView = [NSImageView new];
        self.sepImageView.image = NSImageMake(@"icon_go_forward");
        self.sepImageView.image.template = YES;
        [self addSubview:self.sepImageView];
        
        self.deviceImageView = [NSImageView new];
        [self addSubview:self.deviceImageView];
        
        self.deviceLabel = [PVDetailLabel new];
        self.deviceLabel.textColors = PVDetailColorsCombine(PVColorMake(65, 65, 65), [NSColor labelColor]);
        self.deviceLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [self addSubview:self.deviceLabel];
    }
    return self;
}

- (void)layout {
    [super layout];
    $(self.appImageView).width(self.appImageWidth).height(self.appImageWidth).x([self.spaces[0] doubleValue]).verAlign.offsetY(-.5);
    $(self.appNameLabel).sizeToFit.verAlign.x(self.appImageView.$maxX + [self.spaces[1] doubleValue]).offsetY(-1);
    $(self.sepImageView).sizeToFit.verAlign.x(self.appNameLabel.$maxX + [self.spaces[2] doubleValue]).offsetY(-.5);
    $(self.deviceImageView).sizeToFit.x(self.sepImageView.$maxX + [self.spaces[3] doubleValue]).verAlign;
    $(self.deviceLabel).sizeToFit.verAlign.x(self.deviceImageView.$maxX + [self.spaces[4] doubleValue]).toMaxX(self.$width).offsetY(-1);
}

- (void)setAppInfo:(PVAppInfo *)appInfo {
    _appInfo = appInfo;
    
    if (appInfo) {
        $(self.appImageView, self.appNameLabel, self.sepImageView, self.deviceImageView, self.deviceLabel).show;
        self.image = nil;
        
        NSImage *appIcon = appInfo.appIcon;
        if (!appIcon) {
            appIcon = NSImageMake(@"Icon_EmptyProject");
        }
        self.appImageView.image = appIcon;
        
        self.appNameLabel.stringValue = appInfo.appName;
        
        self.deviceLabel.stringValue = [NSString stringWithFormat:@"%@ (%@)", appInfo.deviceDescription, appInfo.osDescription];
        
        NSImage *deviceIcon = nil;
        switch (appInfo.deviceType) {
            case PVAppInfoDeviceSimulator:
                deviceIcon = NSImageMake(@"icon_simulator_small");
                break;
            case PVAppInfoDeviceIPad:
                deviceIcon = NSImageMake(@"icon_ipad_small");
                break;
            case PVAppInfoDeviceOthers:
                deviceIcon = NSImageMake(@"icon_iphone_small");
                break;
            case PVAppInfoDeviceMac:
                deviceIcon = [NSImage imageWithSystemSymbolName:@"desktopcomputer" accessibilityDescription:@"Mac"];
                break;
            default:
                deviceIcon = NSImageMake(@"icon_simulator_small");
                break;
        }
        self.deviceImageView.image = deviceIcon;
        
    } else {
        $(self.appImageView, self.appNameLabel, self.sepImageView, self.deviceImageView, self.deviceLabel).hide;
        self.image = NSImageMake(@"icon_app");
    }
    [self setNeedsLayout:YES];
}

- (NSSize)sizeThatFits:(NSSize)size {
    __block CGFloat width = 0;
    
    [self.spaces enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        width += [obj doubleValue];
    }];
    
    width += self.appImageWidth + self.appNameLabel.bestWidth  + self.sepImageView.bestWidth + self.deviceImageView.bestWidth + self.deviceLabel.bestWidth;
    
    size.width = width;
    return size;
}

@end

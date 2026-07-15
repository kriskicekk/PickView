//
//  PVDetailDashboardAttributeSwitchView.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailDashboardAttributeSwitchView.h"
#import "PVDetailDashboardCardView.h"
#import "PVDetailDashboardViewController.h"
#import "PVDashboardBlueprint.h"

@interface PVDetailDashboardAttributeSwitchView ()

@property(nonatomic, strong) NSButton *button;

@end

@implementation PVDetailDashboardAttributeSwitchView

- (instancetype)initWithFrame:(NSRect)frame {
    if (self = [super initWithFrame:frame]) {
//        [self setBackgroundColor:[NSColor blueColor]];
        
        self.button = [NSButton new];
        self.button.ignoresMultiClick = YES;
        [self.button setButtonType:NSButtonTypeSwitch];
        self.button.target = self;
        self.button.action = @selector(_handleButton);
        self.button.font = NSFontMake(13);
        [self addSubview:self.button];
    }
    return self;
}

- (void)layout {
    [super layout];
    $(self.button).fullFrame;
}

- (void)renderWithAttribute {
    NSString *title;
    if (self.attribute.isUserCustom) {
        title = self.attribute.displayTitle;
    } else {
        title = [PVDashboardBlueprint briefTitleWithAttrID:self.attribute.identifier];
    }
    [self.button setAttributedTitle:$(title).textColor([NSColor colorNamed:@"DashboardCardValueColor"]).attrString];
    
    BOOL boolValue = ((NSNumber *)self.attribute.value).boolValue;
    self.button.state = boolValue ? NSControlStateValueOn : NSControlStateValueOff;
    self.button.enabled = [self canEdit];
    
    [self setNeedsLayout:YES];
}

- (NSSize)sizeThatFits:(NSSize)limitedSize {
    NSSize size = [self.button sizeThatFits:limitedSize];
    // 不知道为什么，sizeThatFits: 返回的 size 并不够
    return NSMakeSize(size.width + 3, size.height + 2);
}

- (NSUInteger)numberOfColumnsOccupied {
    if (self.attribute.isUserCustom) {
        return 1;
    }
    if ([self.attribute.identifier isEqualToString:PVAttr_UIScrollView_Zoom_Bounce]) {
        return 1;
    }
    return 0;
}

#pragma mark - Private

- (void)_handleButton {
    NSValue *expectedValue;
    if (self.button.state == NSControlStateValueOff) {
        expectedValue = @(NO);
    } else if (self.button.state == NSControlStateValueOn) {
        expectedValue = @(YES);
    } else {
        NSAssert(NO, @"");
        return;
    }
    
    // 提交修改
    @weakify(self);
    [[self.dashboardViewController modifyAttribute:self.attribute newValue:expectedValue] subscribeError:^(NSError * _Nullable error) {
        @strongify(self);
        [self renderWithAttribute];
    }];
}

@end

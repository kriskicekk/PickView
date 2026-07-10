//
//  PVDetailDashboardAttributeOpenImageView.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailDashboardAttributeOpenImageView.h"
#import "PVDetailNumberInputView.h"
#import "PVDetailDashboardViewController.h"
#import "PVDetailAppsManager.h"

@interface PVDetailDashboardAttributeOpenImageView ()

@property(nonatomic, strong) PVDetailTextControl *control;

@end

@implementation PVDetailDashboardAttributeOpenImageView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        self.layer.borderWidth = 1;
        self.layer.cornerRadius = DashboardCardControlCornerRadius;
        self.borderColors = PVDetailColorsCombine(PVColorMake(181, 181, 181), PVColorMake(83, 83, 83));
        
        self.control = [PVDetailTextControl new];
        self.control.adjustAlphaWhenClick = YES;
        self.control.label.stringValue = NSLocalizedString(@"Open Image with Preview…", nil);
        self.control.label.font = NSFontMake(11);
        [self.control addTarget:self clickAction:@selector(_handleClick)];
        [self addSubview:self.control];
    }
    return self;
}

- (void)layout {
    [super layout];
    $(self.control).fullFrame;
}

- (void)renderWithAttribute {
}

- (NSSize)sizeThatFits:(NSSize)limitedSize {
    limitedSize.height = PVDetailNumberInputHorizontalHeight;
    return limitedSize;
}

- (void)_handleClick {
    NSNumber *imageViewOid_num = self.attribute.value;
    if (imageViewOid_num == nil) {
        AlertError(PVInspectErr_Inner, self.window);
        NSAssert(NO, @"");
        return;
    }
    
    unsigned long imageViewOid = [imageViewOid_num unsignedLongValue];

    PVDetailDashboardViewController *dashController = self.dashboardViewController;
    if (!dashController.isStaticMode) {
        AlertErrorText(NSLocalizedString(@"The feature is not available in current mode.", nil), NSLocalizedString(@"You must connect PickView with target iOS app before using this feature.", nil), self.window);
        return;
    }

    if (!InspectingApp) {
        AlertError(PVInspectErr_NoConnect, self.window);
        return;
    }
    
    @weakify(self);
    [[InspectingApp fetchImageWithImageViewOid:imageViewOid] subscribeNext:^(NSData *imageData) {
        @strongify(self);
        if (!imageData) {
            AlertErrorText(NSLocalizedString(@"Operation failed. The image property value of selected UIImageView is nil.", nil), @"", self.window);
            return;
        }
        
        NSString *fileName = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]];
        NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"PickView_UIImageView_%@.png", fileName]];
        NSError *writeError;
        BOOL writeSucc = [imageData writeToFile:filePath options:0 error:&writeError];
        if (!writeSucc) {
            NSAssert(NO, @"");
            AlertError(writeError, self.window);
            return;
        }
        [[NSWorkspace sharedWorkspace] openFile:filePath withApplication:@"preview"];
        
        // 记录临时文件地址以在 PickView 退出时清理
        if (![PVDetailHelper sharedInstance].tempImageFiles) {
            [PVDetailHelper sharedInstance].tempImageFiles = [NSMutableArray array];
        }
        [[PVDetailHelper sharedInstance].tempImageFiles addObject:filePath];
        
    } error:^(NSError * _Nullable error) {
        @strongify(self);
        AlertError(error, self.window);
    }];
}

@end

//
//  PVDetailTipsView.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailBaseView.h"
#import "PVAppInfo.h"

@interface PVDetailTipsView : PVDetailBaseView

@property(nonatomic, weak) id bindingObject;

@property(nonatomic, copy) NSString *title;

/// 请外部不要直接修改 button 的 text 等属性，而是要通过下面的 buttonText 和 buttonImage 来设置
@property(nonatomic, strong, readonly) NSButton *button;

/// buttonText 和 buttonImage 只有一个会生效，请勿同时设置
@property(nonatomic, copy) NSString *buttonText;
@property(nonatomic, strong) NSImage *buttonImage;

@property(nonatomic, strong) NSImage *image;

- (void)setImageByDeviceType:(PVAppInfoDevice)type;

@property(nonatomic, weak) id target;

@property(nonatomic, assign) SEL clickAction;
@property(nonatomic, copy) void (^didClick)(PVDetailTipsView *tipsView);

-(void)setInternalInsetsRight:(CGFloat)value;

@end

@interface PVDetailYellowTipsView : PVDetailTipsView

- (void)startAnimation;
- (void)endAnimation;

@end


@interface PVDetailRedTipsView : PVDetailTipsView

- (void)startAnimation;
- (void)endAnimation;

@end

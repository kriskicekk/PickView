//
//  PVDetailHelper.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import <Cocoa/Cocoa.h>
#import "PVInspectionDefines.h"

#define InspectingApp [PVDetailAppsManager sharedInstance].inspectingApp
#define TutorialMng [PVDetailTutorialManager sharedInstance]
#define CurrentTime [[NSDate date] timeIntervalSince1970]
#define CurrentKeyWindow [NSApplication sharedApplication].keyWindow

#define NSImageMake(imageName) [NSImage imageNamed:imageName]
#define NSFontMake(fontSize) [NSFont systemFontOfSize:fontSize]

#define DashboardCardValueColor PVColorMake(223, 223, 223)
#define DashboardCardControlBackgroundColor PVColorMake(40, 40, 40)
#define DashboardCardControlBorderColor PVColorMake(87, 87, 87)

#define SeparatorLightModeColor PVColorMake(215, 215, 215)
#define SeparatorDarkModeColor PVColorMake(67, 67, 69)

#define NSSizeMax NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX)

#define NSColorBlack PVColorMake(13, 20, 30)
#define NSColorWhite PVColorMake(250, 251, 252)
#define NSColorGray0 PVColorMake(33, 40, 50)
#define NSColorGray1 PVColorMake(53, 60, 70)
#define NSColorGray9 PVColorMake(216, 220, 228)

extern const CGFloat HierarchyMinWidth;

extern const CGFloat MeasureViewWidth;

extern const CGFloat DashboardViewWidth;
extern const CGFloat DashboardAttrItemHorInterspace;
extern const CGFloat DashboardAttrItemVerInterspace;
extern const CGFloat DashboardHorInset;
extern const CGFloat DashboardCardControlCornerRadius;
extern const CGFloat DashboardSectionMarginTop;
extern const CGFloat DashboardCardCornerRadius;
extern const CGFloat DashboardSearchCardInset;

extern const CGFloat ConsoleInsetLeft;
extern const CGFloat ConsoleInsetRight;

extern const CGFloat ZoomSliderMaxValue;

typedef struct {
    CGFloat left, right;
} HorizontalMargins;

CG_INLINE HorizontalMargins HorizontalMarginsMake(CGFloat left, CGFloat right) {
    HorizontalMargins margins = {left, right};
    return margins;
}

#define AlertError(targetError, targetWindow) if (targetError.code != PVInspectErrCode_Discard) {[[NSAlert alertWithError:targetError] beginSheetModalForWindow:targetWindow completionHandler:nil];}

#define AlertErrorText(errorTitle, errorDetail, targetWindow) AlertError(PVInspectErrorMake(errorTitle, errorDetail), targetWindow)

#define IsEnglish [PVDetailHelper isEnglish]

@class PVAppInfo;

@interface PVDetailHelper : NSObject

+ (instancetype)sharedInstance;

+ (NSFont *)italicFontOfSize:(CGFloat)fontSize;

+ (NSString *)pickviewReadableVersion;

+ (void)openPickViewWebsiteWithPath:(NSString *)path;

+ (void)openPickViewOfficialWebsite;

+ (void)openCustomConfigWebsite;

+ (BOOL)isEnglish;

+ (BOOL)appInfoLooksLikeMacTarget:(PVAppInfo *)appInfo;

/// macOS 10.14 及以后返回用户的系统主题色，旧版本系统返回蓝色
+ (NSColor *)accentColor;

+ (NSArray<NSString *> *)bestMatchesInCandidates:(NSArray<NSString *> *)candidates input:(NSString *)input maxResultsCount:(NSUInteger)maxResultsCount;

/// 使用 UIImageView 的 “使用预览打开该图片” 功能时会创建临时图片文件，它们的路径会保存在这里，PickView 退出时应当删除这些临时文件
/// 创建图片的相关逻辑见 PVDetailDashboardAttributeOpenImageView.m
@property(nonatomic, strong) NSMutableArray<NSString *> *tempImageFiles;

/// macOS 10.14 及之后返回系统的 [NSTextView scrollableTextView]。10.13 由该方法自己实现。
/// 当使用自己实现的版本时（即 10.13 系统），需要业务自己负责 textView（即  scrollableTextView.documentVie）的布局
+ (NSScrollView *)scrollableTextView;

+ (BOOL)validateFrame:(CGRect)frame;

@end

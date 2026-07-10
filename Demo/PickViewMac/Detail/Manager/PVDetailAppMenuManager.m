//
//  PVDetailAppMenuManager.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailAnalytics.h"

#import "PVDetailAppMenuManager.h"
#import "PVDetailNavigationManager.h"
#import "PVDetailLaunchWindowController.h"
#import "PVDetailLaunchViewController.h"
#import "PVDetailPreviewController.h"
#import "PVDetailStaticWindowController.h"
#import "PVDetailStaticViewController.h"
#import "PVDetailPreferenceManager.h"
#import "PVDetailStaticHierarchyDataSource.h"
#import "PVDetailWindowController.h"
#include <mach-o/dyld.h>

static NSUInteger const kTag_About = 11;
static NSUInteger const kTag_Preferences = 12;
static NSUInteger const kTag_CheckUpdates = 13;

static NSUInteger const kTag_Reload = 21;
static NSUInteger const kTag_Dimension = 22;
static NSUInteger const kTag_ZoomIn = 23;
static NSUInteger const kTag_ZoomOut = 24;
static NSUInteger const kTag_DecreaseInterspace = 25;
static NSUInteger const kTag_IncreaseInterspace = 26;
static NSUInteger const kTag_Expansion = 27;
static NSUInteger const kTag_Filter = 28;
static NSUInteger const kTag_OpenInNewWindow = 31;
static NSUInteger const kTag_Export = 32;

static NSUInteger const kTag_CocoaPods = 51;
static NSUInteger const kTag_ShowWebsite = 52;
static NSUInteger const kTag_ShowConfig = 53;
static NSUInteger const kTag_ShowPickViewiOS = 54;

static NSUInteger const kTag_GitHub = 57;
static NSUInteger const kTag_PVClientGitHub = 58;
static NSUInteger const kTag_PickViewServerGitHub = 59;

static NSUInteger const kTag_ReportIssues = 60;
static NSUInteger const kTag_PVClientGitHubIssues = 62;
static NSUInteger const kTag_PickViewServerGitHubIssues = 63;
static NSUInteger const kTag_Weibo = 64;

static NSUInteger const kTag_CopyPod = 66;
static NSUInteger const kTag_CopySPM = 67;
static NSUInteger const kTag_MoreIntegrationGuide = 68;
static NSUInteger const kTag_Jobs = 69;
static NSUInteger const kTag_DocumentCollection = 70;
static NSUInteger const kTag_CustomInformation = 71;
static NSUInteger const kTag_Acknowledgements = 72;

@interface PVDetailAppMenuManager ()

@property(nonatomic, copy) NSDictionary<NSNumber *, NSString *> *delegatingTagToSelMap;

@end

@implementation PVDetailAppMenuManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static PVDetailAppMenuManager *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self sharedInstance];
}

- (void)setup {
    self.delegatingTagToSelMap = @{
                                   @(kTag_Reload):NSStringFromSelector(@selector(appMenuManagerDidSelectReload)),
                                   @(kTag_Dimension):NSStringFromSelector(@selector(appMenuManagerDidSelectDimension)),
                                   @(kTag_ZoomIn):NSStringFromSelector(@selector(appMenuManagerDidSelectZoomIn)),
                                   @(kTag_ZoomOut):NSStringFromSelector(@selector(appMenuManagerDidSelectZoomOut)),
                                   @(kTag_DecreaseInterspace):NSStringFromSelector(@selector(appMenuManagerDidSelectDecreaseInterspace)),
                                   @(kTag_IncreaseInterspace):NSStringFromSelector(@selector(appMenuManagerDidSelectIncreaseInterspace)),
                                   @(kTag_Expansion):NSStringFromSelector(@selector(appMenuManagerDidSelectExpansionIndex:)),
                                   @(kTag_Export):NSStringFromSelector(@selector(appMenuManagerDidSelectExport)),
                                   @(kTag_OpenInNewWindow):NSStringFromSelector(@selector(appMenuManagerDidSelectOpenInNewWindow)),
                                   @(kTag_Filter):NSStringFromSelector(@selector(appMenuManagerDidSelectFilter)),
    };
    
    NSMenu *menu = [NSApp mainMenu];
    
    // PickView
    NSMenu *menu_pickview = [menu itemAtIndex:0].submenu;
    menu_pickview.autoenablesItems = NO;
    menu_pickview.delegate = self;
    
    NSMenuItem *menuItem_about = [menu_pickview itemWithTag:kTag_About];
    menuItem_about.target = self;
    menuItem_about.action = @selector(_handleAbout);
    
    // PickView - 偏好设置
    NSMenuItem *menuItem_preferences = [menu_pickview itemWithTag:kTag_Preferences];
    menuItem_preferences.target = self;
    menuItem_preferences.action = @selector(_handlePreferences);
    
    NSMenuItem *menuItem_checkUpdates = [menu_pickview itemWithTag:kTag_CheckUpdates];
    menuItem_checkUpdates.target = self;
    menuItem_checkUpdates.action = @selector(_handleCheckUpdates);
    
    // 文件
    NSMenu *menu_file = [menu itemAtIndex:1].submenu;
    menu_file.autoenablesItems = NO;
    menu_file.delegate = self;
    
    // 视图
    NSMenu *menu_view = [menu itemAtIndex:3].submenu;
    menu_view.autoenablesItems = NO;
    menu_view.delegate = self;
    
    // 帮助
    NSMenu *menu_help = [menu itemAtIndex:5].submenu;
    menu_help.autoenablesItems = YES;
    menu_help.delegate = self;
    
    // 帮助 - CocoaPods
    NSMenuItem *menuItem_cocoaPods = [menu_help itemWithTag:kTag_CocoaPods];
    menuItem_cocoaPods.target = self;
    menuItem_cocoaPods.action = @selector(_handleShowCocoaPods);
    
    // 帮助 - 官方网站
    NSMenuItem *menuItem_showWebsite = [menu_help itemWithTag:kTag_ShowWebsite];
    menuItem_showWebsite.target = self;
    menuItem_showWebsite.action = @selector(_handleShowWebsite);
    
    // 帮助 - 创建配置文件
    NSMenuItem *menuItem_showConfig = [menu_help itemWithTag:kTag_ShowConfig];
    menuItem_showConfig.target = self;
    menuItem_showConfig.action = @selector(_handleShowConfig);
    
    // 帮助 - 在 iOS 上使用 PickView
    NSMenuItem *menuItem_showPickViewiOS = [menu_help itemWithTag:kTag_ShowPickViewiOS];
    menuItem_showPickViewiOS.target = self;
    menuItem_showPickViewiOS.action = @selector(_handleShowPickViewiOS);
    
    NSMenu *sourceCodeMenu = [menu_help itemWithTag:kTag_GitHub].submenu;
    {
        NSMenuItem *item = [sourceCodeMenu itemWithTag:kTag_PVClientGitHub];
        item.target = self;
        item.action = @selector(_handleShowPVClientGithub);
    }
    
    {
        NSMenuItem *item = [sourceCodeMenu itemWithTag:kTag_PickViewServerGitHub];
        item.target = self;
        item.action = @selector(_handleShowPickViewServerGithub);
    }
    
    NSMenu *issuesMenu = [menu_help itemWithTag:kTag_ReportIssues].submenu;
    {
        NSMenuItem *item = [issuesMenu itemWithTag:kTag_PVClientGitHubIssues];
        item.target = self;
        item.action = @selector(_handleClientIssues);
    }
    {
        NSMenuItem *item = [issuesMenu itemWithTag:kTag_PickViewServerGitHubIssues];
        item.target = self;
        item.action = @selector(_handleServerIssues);
    }
    {
        NSMenuItem *item = [issuesMenu itemWithTag:kTag_Weibo];
        item.target = self;
        item.action = @selector(_handleWeibo);
    }
    
    {
        NSMenuItem *item = [menu_help itemWithTag:kTag_CopyPod];
        item.target = self;
        item.action = @selector(_handleCopyPod);
    }
    {
        NSMenuItem *item = [menu_help itemWithTag:kTag_CopySPM];
        item.target = self;
        item.action = @selector(_handleCopySPM);
    }
    {
        NSMenuItem *item = [menu_help itemWithTag:kTag_MoreIntegrationGuide];
        item.target = self;
        item.action = @selector(_handleOpenMoreIntegrationGuide);
    }
    {
        NSMenuItem *item = [menu_help itemWithTag:kTag_Jobs];
        item.target = self;
        item.action = @selector(_handleJobs);
    }
    {
        NSMenuItem *item = [menu_help itemWithTag:kTag_DocumentCollection];
        item.target = self;
        item.action = @selector(_handleDocumentCollection);
    }
    {
        NSMenuItem *item = [menu_help itemWithTag:kTag_CustomInformation];
        item.target = self;
        item.action = @selector(_handleCustomInformation);
    }
    {
        NSMenuItem *item = [menu_help itemWithTag:kTag_Acknowledgements];
        item.target = self;
        item.action = @selector(_handleAcknowledgements);
    }
    
    NSArray *itemArray = [menu_file.itemArray arrayByAddingObjectsFromArray:menu_view.itemArray];
    [itemArray enumerateObjectsUsingBlock:^(NSMenuItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *selString = self.delegatingTagToSelMap[@(obj.tag)];
        if (selString) {
            if (obj.hasSubmenu) {
                if (obj.tag == kTag_Expansion) {
                    // 视图 - 深度
                    [obj.submenu.itemArray enumerateObjectsUsingBlock:^(NSMenuItem * _Nonnull expansionSubItem, NSUInteger idx, BOOL * _Nonnull stop) {
                        expansionSubItem.target = self;
                        expansionSubItem.representedObject = @(idx);
                        expansionSubItem.action = @selector(_handleExpansion:);
                    }];
                }
            } else {
                obj.target = self;
                obj.action = @selector(_handleDelegateItem:);
            }
        }
    }];
}

- (void)menuNeedsUpdate:(NSMenu *)menu {
    PVDetailWindowController *wc = [PVDetailNavigationManager sharedInstance].currentKeyWindowController;

    [menu.itemArray enumerateObjectsUsingBlock:^(NSMenuItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *selString = self.delegatingTagToSelMap[@(obj.tag)];
        if (selString) {
            SEL delegateSel = NSSelectorFromString(selString);
            obj.enabled = [wc respondsToSelector:delegateSel];
        } else {
            obj.enabled = YES;
        }
    }];
}

- (void)_handlePreferences {
    [[PVDetailNavigationManager sharedInstance] showPreference];
}

- (void)_handleDelegateItem:(NSMenuItem *)item {
    NSString *selString = self.delegatingTagToSelMap[@(item.tag)];
    SEL sel = NSSelectorFromString(selString);
    if (!sel) {
        NSAssert(NO, @"");
        return;
    }
    PVDetailWindowController *wc = [PVDetailNavigationManager sharedInstance].currentKeyWindowController;
    if (![wc respondsToSelector:sel]) {
        NSAssert(NO, @"");
        return;
    }
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[wc methodSignatureForSelector:sel]];
    [invocation setTarget:wc];
    [invocation setSelector:sel];
    [invocation invoke];
}

- (void)_handleExpansion:(NSMenuItem *)item {
    NSNumber *idxNum = item.representedObject;
    if (idxNum == nil) {
        NSAssert(NO, @"");
        return;
    }
    NSUInteger index = idxNum.unsignedIntegerValue;
    
    PVDetailWindowController *wc = [PVDetailNavigationManager sharedInstance].currentKeyWindowController;
    if (![wc respondsToSelector:@selector(appMenuManagerDidSelectExpansionIndex:)]) {
        NSAssert(NO, @"");
        return;
    }
    [wc appMenuManagerDidSelectExpansionIndex:index];
    
    [PVDetailAnalytics trackEvent:@"Hierarchy Expansion" withProperties:@{@"level":[NSString stringWithFormat:@"%@", idxNum]}];
}

- (void)_handleShowConfig {
    [PVDetailHelper openPickViewWebsiteWithPath:@"faq/config-file/"];
}

- (void)_handleShowPickViewiOS {
    [PVDetailHelper openPickViewWebsiteWithPath:@"faq/pickview-ios/"];
}

- (void)_handleShowPVClientGithub {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/hughkli/PickView"]];
}

- (void)_handleShowPickViewServerGithub {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/QMUI/PickViewServer"]];
}

- (void)_handleClientIssues {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/hughkli/PickView/issues"]];
}

- (void)_handleServerIssues {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/QMUI/PickViewServer/issues"]];
}

- (void)_handleWeibo {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://weibo.com/234885306"]];
}

- (void)_handleShowWebsite {
    [PVDetailHelper openPickViewOfficialWebsite];
}

- (void)_handleCopyPod {
    NSString *stringToCopy = @"pod 'PickViewServer', :configurations => ['Debug']";
    
    NSPasteboard *paste = [NSPasteboard generalPasteboard];
    [paste clearContents];
    [paste writeObjects:@[stringToCopy]];
}

- (void)_handleCopySPM {
    NSString *stringToCopy = @"https://github.com/QMUI/PickViewServer/";
    
    NSPasteboard *paste = [NSPasteboard generalPasteboard];
    [paste clearContents];
    [paste writeObjects:@[stringToCopy]];
}

- (void)_handleOpenMoreIntegrationGuide {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/QMUI/PickViewServer/blob/master/README.md"]];
}

- (void)_handleJobs {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://bytedance.feishu.cn/docx/SAcgdoQuAouyXAxAqy8cmrT2n4b"]];
}

- (void)_handleCheckUpdates {
    return;
}

- (void)_handleShowCocoaPods {
    [PVDetailHelper openPickViewWebsiteWithPath:@"faq/integration-guide/"];
}

- (void)_handleAbout {
    [[PVDetailNavigationManager sharedInstance] showAbout];
}

- (void)_handleDocumentCollection {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://bytedance.larkoffice.com/docx/Yvv1d57XQoe5l0xZ0ZRc0ILfnWb"]];
}

- (void)_handleCustomInformation {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://bytedance.larkoffice.com/docx/TRridRXeUoErMTxs94bcnGchnlb"]];
}

- (void)_handleAcknowledgements {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://qxh1ndiez2w.feishu.cn/docx/YIFjdE4gIolp3hxn1tGckiBxnWf"]];
}

@end

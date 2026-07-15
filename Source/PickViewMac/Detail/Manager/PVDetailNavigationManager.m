//
//  PVDetailNavigationManager.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailNavigationManager.h"
#import "PVDetailLaunchWindowController.h"
#import "PVDetailStaticWindowController.h"
#import "PVDetailPreferenceWindowController.h"
#import "PVDetailStaticViewController.h"
#import "PVDetailPreviewController.h"
#import "PVDetailPreviewController.h"
#import "PVDetailAppsManager.h"
#import "PVHierarchyFile.h"
#import "PVDetailReadWindowController.h"
#import "PVDetailConsoleViewController.h"
#import "PVDetailPreferenceManager.h"
#import "PVDetailAboutWindowController.h"
#import "PVDetailJSONAttributeWindowController.h"
#import "PVDetailJSONAttributeViewController.h"

@interface PVDetailNavigationManager ()

@property(nonatomic, strong) PVDetailPreferenceWindowController *preferenceWindowController;
@property(nonatomic, strong) PVDetailJSONAttributeWindowController *jsonWindowController;
@property(nonatomic, strong) PVDetailAboutWindowController *aboutWindowController;

@end

@implementation PVDetailNavigationManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static PVDetailNavigationManager *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self sharedInstance];
}

- (void)showLaunch {
    _launchWindowController = [[PVDetailLaunchWindowController alloc] init];
    [self.launchWindowController showWindow:self];
}

- (void)showStaticWorkspace {
    if (!self.staticWindowController) {
        _staticWindowController = [[PVDetailStaticWindowController alloc] init];
        self.staticWindowController.window.delegate = self;
    }
    [self.staticWindowController showWindow:self];
}

- (void)closeLaunch {
    [self.launchWindowController close];
    _launchWindowController = nil;
}

- (void)showPreference {
    if (!self.preferenceWindowController) {
        self.preferenceWindowController = [PVDetailPreferenceWindowController new];
        self.preferenceWindowController.window.delegate = self;
    }
    [self.preferenceWindowController showWindow:self];
}

- (void)showAbout {
    if (!self.aboutWindowController) {
        _aboutWindowController = [[PVDetailAboutWindowController alloc] init];
        self.aboutWindowController.window.delegate = self;
    }
    [self.aboutWindowController showWindow:self];
}

- (PVDetailWindowController *)currentKeyWindowController {
    NSWindow *keyWindow = [NSApplication sharedApplication].keyWindow;
    if ([keyWindow.windowController isKindOfClass:[PVDetailWindowController class]]) {
        return keyWindow.windowController;
    }
    return nil;
}

- (BOOL)showReaderWithFilePath:(NSString *)filePath error:(NSError **)error {
    NSData *data = [NSData dataWithContentsOfFile:filePath options:0 error:error];
    if (!data) {
        return NO;
    }
    
    id dataObj = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSObject class] fromData:data error:error];
    if (!dataObj) {
        // 比如拖了一个 pdf 格式的文件进来就会走到这里
        if (error) {
            *error = [NSError errorWithDomain:PVInspectErrorDomain code:PVInspectErrCode_UnsupportedFileType userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"Failed to open the document.", nil), NSLocalizedRecoverySuggestionErrorKey:NSLocalizedString(@"The file type is not supported.", nil)}];
        }
        return NO;
    }
    
    NSError *verifyError = [PVHierarchyFile verifyHierarchyFile:dataObj];
    if (verifyError) {
        // 有问题，无法打开
        if (error) {
            *error = verifyError;
        }
        return NO;
    }
    
    // 文件校验无误
    NSString *title = [[NSFileManager defaultManager] displayNameAtPath:filePath];
    [self showReaderWithHierarchyFile:dataObj title:title];
    return YES;
}

- (void)showReaderWithHierarchyFile:(PVHierarchyFile *)file title:(NSString *)title {
    PVDetailReadWindowController *wc = [[PVDetailReadWindowController alloc] initWithFile:file];
    wc.window.title = title ? : @"";
    wc.window.delegate = self;
    [wc showWindow:self];
    
    if (!self.readWindowControllers) {
        self.readWindowControllers = [NSMutableArray array];
    }
    [self.readWindowControllers addObject:wc];
}


- (void)showJsonWindow:(NSString *)json {
    if (!self.jsonWindowController) {
        self.jsonWindowController = [PVDetailJSONAttributeWindowController new];
        self.jsonWindowController.window.delegate = self;
    }
    [((PVDetailJSONAttributeViewController *)self.jsonWindowController.contentViewController) renderWithJSON:json];
    [self.jsonWindowController showWindow:self];
}

#pragma mark - <NSWindowDelegate>


/**
 staticWindowController 关闭时不要直接释放，因为点击某些窗口的“连接已断开” tips 可能需要唤起 static 窗口来切换 App
 */
- (void)windowWillClose:(NSNotification *)notification {
    NSWindow *closingWindow = notification.object;
    
    if (closingWindow == self.preferenceWindowController.window) {
        _preferenceWindowController = nil;
        
    } else if (closingWindow == self.preferenceWindowController.window) {
        self.preferenceWindowController = nil;
        
    } else if (closingWindow == self.staticWindowController.window) {
        [closingWindow saveFrameUsingName:PVDetailWindowSizeName_Static];
        
    } else if (closingWindow == self.aboutWindowController.window) {
        self.aboutWindowController = nil;
        
    } else {
        PVDetailReadWindowController *wc = [self.readWindowControllers pv_inspect_firstFiltered:^BOOL(PVDetailReadWindowController *obj) {
            return obj.window == closingWindow;
        }];
        [self.readWindowControllers removeObject:wc];
    }
}

@end

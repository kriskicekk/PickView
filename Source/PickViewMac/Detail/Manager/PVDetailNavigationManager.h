//
//  PVDetailNavigationManager.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import <Foundation/Foundation.h>

@class PVDetailLaunchWindowController, PVDetailStaticWindowController, PVDetailDynamicWindowController, PVDetailWindowController, PVDetailReadWindowController, PVHierarchyInfo, PVHierarchyFile;

@interface PVDetailNavigationManager : NSObject <NSWindowDelegate>

+ (instancetype)sharedInstance;

- (void)showLaunch;

- (void)closeLaunch;

- (void)showStaticWorkspace;

- (void)showPreference;

- (void)showAbout;

- (void)showJsonWindow:(NSString *)json;

- (BOOL)showReaderWithFilePath:(NSString *)filePath error:(NSError **)error;
- (void)showReaderWithHierarchyFile:(PVHierarchyFile *)file title:(NSString *)title;

@property(nonatomic, strong, readonly) PVDetailLaunchWindowController *launchWindowController;
@property(nonatomic, strong, readonly) PVDetailStaticWindowController *staticWindowController;
@property(nonatomic, strong) NSMutableArray<PVDetailReadWindowController *> *readWindowControllers;

- (PVDetailWindowController *)currentKeyWindowController;

@property(nonatomic, assign) CGFloat windowTitleBarHeight;

@end

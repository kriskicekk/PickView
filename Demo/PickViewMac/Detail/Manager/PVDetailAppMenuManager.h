//
//  PVDetailAppMenuManager.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import <Foundation/Foundation.h>

@class PVDetailAppMenuManager, PVDetailWindowController;

@protocol PVDetailAppMenuManagerDelegate <NSObject>

@optional

- (void)appMenuManagerDidSelectReload;
- (void)appMenuManagerDidSelectDimension;
- (void)appMenuManagerDidSelectZoomIn;
- (void)appMenuManagerDidSelectZoomOut;
- (void)appMenuManagerDidSelectDecreaseInterspace;
- (void)appMenuManagerDidSelectIncreaseInterspace;
- (void)appMenuManagerDidSelectExpansionIndex:(NSUInteger)index;
- (void)appMenuManagerDidSelectFilter;

- (void)appMenuManagerDidSelectExport;
- (void)appMenuManagerDidSelectOpenInNewWindow;

@end

@interface PVDetailAppMenuManager : NSObject <NSMenuDelegate>

+ (instancetype)sharedInstance;

- (void)setup;

@end

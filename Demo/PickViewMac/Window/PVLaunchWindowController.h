//
//  PVLaunchWindowController.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import <Cocoa/Cocoa.h>

@class PVClientSession;

NS_ASSUME_NONNULL_BEGIN

@interface PVLaunchWindowController : NSWindowController

@property (nonatomic, copy, nullable) void (^selectionHandler)(NSInteger row);

- (void)reloadWithSessions:(NSArray<PVClientSession *> *)sessions
             previewImages:(NSDictionary<NSString *, NSImage *> *)previewImages;

@end

NS_ASSUME_NONNULL_END

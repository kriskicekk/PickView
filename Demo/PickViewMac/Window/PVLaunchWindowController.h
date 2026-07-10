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
@property (nonatomic, copy, nullable) void (^LANSelectionHandler)(NSInteger row);

- (void)reloadWithPreviewSessions:(NSArray<PVClientSession *> *)previewSessions
                       LANSessions:(NSArray<PVClientSession *> *)LANSessions
                     previewImages:(NSDictionary<NSString *, NSImage *> *)previewImages
    connectedLANEndpointIdentifier:(nullable NSString *)connectedLANEndpointIdentifier;

@end

NS_ASSUME_NONNULL_END

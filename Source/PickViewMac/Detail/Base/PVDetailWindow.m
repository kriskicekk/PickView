//
//  PVDetailWindow.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailWindow.h"
#import "PVDetailNavigationManager.h"
#import "PVDetailPanelContentView.h"

@implementation PVDetailWindow

+ (instancetype)panelWindowWithWidth:(CGFloat)width height:(CGFloat)height contentView:(PVDetailPanelContentView *)contentView {
    PVDetailWindow *window = [[PVDetailWindow alloc] initWithContentRect:NSMakeRect(0, 0, width, height) styleMask:NSWindowStyleMaskTitled backing:NSBackingStoreBuffered defer:YES];
    window.contentView = contentView;
    return window;
}

- (instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSWindowStyleMask)style backing:(NSBackingStoreType)backingStoreType defer:(BOOL)flag {
    if (self = [super initWithContentRect:contentRect styleMask:style backing:backingStoreType defer:flag]) {
         [self registerForDraggedTypes:@[NSPasteboardTypeFileURL]];
    }
    return self;
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    return NSDragOperationCopy;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    NSString *path = [NSURL URLFromPasteboard:[sender draggingPasteboard]].path;
    NSError *error;
    BOOL isSucc = [[PVDetailNavigationManager sharedInstance] showReaderWithFilePath:path error:&error];
    if (!isSucc) {
        if (error) {
            AlertError(error, self);
        }
    }
    return isSucc;
}

@end

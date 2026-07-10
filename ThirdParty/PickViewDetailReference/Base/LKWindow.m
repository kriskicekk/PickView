//
//  LKWindow.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "LKWindow.h"
#import "LKNavigationManager.h"
#import "LKPanelContentView.h"

@implementation LKWindow

+ (instancetype)panelWindowWithWidth:(CGFloat)width height:(CGFloat)height contentView:(LKPanelContentView *)contentView {
    LKWindow *window = [[LKWindow alloc] initWithContentRect:NSMakeRect(0, 0, width, height) styleMask:NSWindowStyleMaskTitled backing:NSBackingStoreBuffered defer:YES];
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
    BOOL isSucc = [[LKNavigationManager sharedInstance] showReaderWithFilePath:path error:&error];
    if (!isSucc) {
        if (error) {
            AlertError(error, self);
        }
    }
    return isSucc;
}

@end

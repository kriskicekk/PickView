//
//  PVDetailPreviewStageView.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailBaseView.h"

@class PVDetailPreviewStageView;

@protocol PVDetailPreviewStageViewDelegate <NSObject>

- (void)previewStageView:(PVDetailPreviewStageView *)view mouseMoved:(NSEvent *)event;
- (void)didResetCursorRectsInPreviewStageView:(PVDetailPreviewStageView *)view;

@end

@interface PVDetailPreviewStageView : PVDetailBaseView

@property(nonatomic, weak) id<PVDetailPreviewStageViewDelegate> delegate;

@end

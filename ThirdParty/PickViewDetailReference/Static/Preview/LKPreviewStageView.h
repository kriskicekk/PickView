//
//  LKPreviewStageView.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "LKBaseView.h"

@class LKPreviewStageView;

@protocol LKPreviewStageViewDelegate <NSObject>

- (void)previewStageView:(LKPreviewStageView *)view mouseMoved:(NSEvent *)event;
- (void)didResetCursorRectsInPreviewStageView:(LKPreviewStageView *)view;

@end

@interface LKPreviewStageView : LKBaseView

@property(nonatomic, weak) id<LKPreviewStageViewDelegate> delegate;

@end

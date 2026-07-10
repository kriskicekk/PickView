//
//  LKPreviewPanGestureRecognizer.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSUInteger, PreviewPanGesturePurpose) {
    PreviewPanGesturePurposeRotate,
    PreviewPanGesturePurposeTranslate
};

@interface LKPreviewPanGestureRecognizer : NSPanGestureRecognizer

/**
 默认为 PreviewPanGesturePurposeRotate
 */
@property(nonatomic, assign) PreviewPanGesturePurpose purpose;

@property(nonatomic, assign) CGPoint initialRotation;
@property(nonatomic, assign) NSPoint initialTranslation;

@end

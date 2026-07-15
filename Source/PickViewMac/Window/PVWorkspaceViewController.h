//
//  PVWorkspaceViewController.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import <Cocoa/Cocoa.h>

@class PVPreviewSceneView;

NS_ASSUME_NONNULL_BEGIN

@interface PVWorkspaceViewController : NSViewController

@property (nonatomic, strong, readonly) NSTableView *windowTableView;
@property (nonatomic, strong, readonly) NSOutlineView *hierarchyOutlineView;
@property (nonatomic, strong, readonly) PVPreviewSceneView *previewSceneView;
@property (nonatomic, strong, readonly) NSTextField *detailPreviewLabel;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, NSTextField *> *inspectorValueLabels;

- (void)setWindowListHidden:(BOOL)hidden;

@end

NS_ASSUME_NONNULL_END

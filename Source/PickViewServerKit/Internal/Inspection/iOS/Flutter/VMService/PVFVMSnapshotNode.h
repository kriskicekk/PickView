#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PVFVMSnapshotNode : NSObject

@property(nonatomic, copy) NSString *objectID;
@property(nonatomic, copy) NSString *flutterType;
@property(nonatomic, copy) NSString *kind;
@property(nonatomic, copy) NSString *renderObjectType;
@property(nonatomic, copy) NSString *paintRole;
@property(nonatomic, copy) NSString *renderStrategy;
@property(nonatomic) BOOL captureEligible;
@property(nonatomic, copy) NSString *nodeDescription;
@property(nonatomic, copy, nullable) NSString *textPreview;
@property(nonatomic) CGSize logicalSize;
@property(nonatomic) CGPoint localOffset;
@property(nonatomic) UIEdgeInsets paintInsets;
@property(nonatomic) BOOL hasLogicalSize;
@property(nonatomic) BOOL hasLocalOffset;
@property(nonatomic) NSInteger depth;
@property(nonatomic, weak, nullable) PVFVMSnapshotNode *parent;
@property(nonatomic) NSMutableArray<PVFVMSnapshotNode *> *children;
@property(nonatomic, nullable) UIImage *image;
@property(nonatomic, nullable) NSData *pngData;
@property(nonatomic, copy) NSString *screenshotStatus;
@property(nonatomic, copy, nullable) NSString *screenshotFile;
@property(nonatomic, nullable) NSDictionary *nativeDecoration;
@property(nonatomic, nullable) NSDictionary *sourceJSON;
// Flutter wrappers that are useful in an inspector but do not need their own
// row in the visual hierarchy.
@property(nonatomic) NSMutableArray<NSDictionary *> *childrenLayouts;
@property(nonatomic) NSMutableArray<NSDictionary *> *layoutModifiers;
@property(nonatomic) NSMutableArray<NSDictionary *> *interactions;
@property(nonatomic) NSMutableArray<NSDictionary *> *semantics;
@property(nonatomic) NSMutableArray<NSString *> *capabilities;

- (NSArray<PVFVMSnapshotNode *> *)flattenedNodes;
- (NSDictionary *)manifestDictionaryWithAbsoluteOrigin:(CGPoint)absoluteOrigin;

@end

NS_ASSUME_NONNULL_END

#import <UIKit/UIKit.h>

@class PVFVMFlutterTarget;
@class PVFVMServiceClient;

NS_ASSUME_NONNULL_BEGIN

typedef void (^PVFVMInspectorConnectionCompletion)(NSError *_Nullable error);
typedef void (^PVFVMInspectorPayloadCompletion)(
    id _Nullable payload, NSDictionary *_Nullable jsonRPCResponse,
    NSError *_Nullable error);
typedef void (^PVFVMInspectorScreenshotCompletion)(
    UIImage *_Nullable image, NSData *_Nullable pngData,
    NSError *_Nullable error);

@interface PVFVMEngineInspectorSession : NSObject

@property(nonatomic, readonly) PVFVMFlutterTarget *target;
@property(nonatomic, readonly, nullable) PVFVMServiceClient *serviceClient;
@property(nonatomic, readonly, nullable) NSURL *vmServiceURL;
@property(nonatomic, readonly, nullable) NSString *isolateID;
@property(nonatomic, readonly) NSString *objectGroup;
@property(nonatomic, readonly, nullable) NSDictionary *vmResponse;
@property(nonatomic, readonly, getter=isConnected) BOOL connected;

- (instancetype)initWithTarget:(PVFVMFlutterTarget *)target
    NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

- (void)connectWithTimeout:(NSTimeInterval)timeout
                completion:(PVFVMInspectorConnectionCompletion)completion;

/// Invalidates Inspector object IDs owned by this session's objectGroup.
- (void)close;

- (void)fetchRootWidgetTreeSummaryWithCompletion:
    (PVFVMInspectorPayloadCompletion)completion;
- (void)fetchRootWidgetTreeFullWithCompletion:
    (PVFVMInspectorPayloadCompletion)completion;
- (void)fetchLayoutExplorerForObjectID:(NSString *)objectID
                          subtreeDepth:(NSInteger)subtreeDepth
                            completion:(PVFVMInspectorPayloadCompletion)completion;
- (void)fetchPropertiesForObjectID:(NSString *)objectID
                        completion:(PVFVMInspectorPayloadCompletion)completion;
- (void)screenshotObjectID:(NSString *)objectID
               logicalSize:(CGSize)logicalSize
                    margin:(CGFloat)margin
             maxPixelRatio:(CGFloat)maxPixelRatio
                completion:(PVFVMInspectorScreenshotCompletion)completion;

@end

NS_ASSUME_NONNULL_END

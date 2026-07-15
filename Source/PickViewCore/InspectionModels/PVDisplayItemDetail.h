//
//  PVDisplayItemDetail.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#ifndef PVDisplayItemDetail_h
#define PVDisplayItemDetail_h

#import "PVInspectionDefines.h"
#import "PVFlutterInspectionModel.h"

#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>

@class PVAttributesGroup;
@class PVDisplayItem;
@class PVFlutterNodeDetail;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PVDisplayItemDetailFailureCode) {
    PVDisplayItemDetailFailureCodeNone = 0,
    /// The object existed in the hierarchy snapshot but disappeared before its
    /// detail request was handled.
    PVDisplayItemDetailFailureCodeStaleObject = -1,
};

@interface PVDisplayItemDetail : NSObject <NSSecureCoding, NSCopying>

@property (nonatomic, copy) NSString *displayItemID;
@property (nonatomic, copy, nullable) NSData *soloImageData;
@property (nonatomic, copy, nullable) NSData *groupImageData;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, assign) CGRect bounds;
@property (nonatomic, assign, getter=isHidden) BOOL hidden;
@property (nonatomic, assign) CGFloat alpha;

@property (nonatomic, assign) unsigned long displayItemOid;
@property (nonatomic, strong, nullable) PVImage *groupScreenshot;
@property (nonatomic, strong, nullable) PVImage *soloScreenshot;
@property (nonatomic, strong, nullable) NSValue *frameValue;
@property (nonatomic, strong, nullable) NSValue *boundsValue;
@property (nonatomic, strong, nullable) NSNumber *hiddenValue;
@property (nonatomic, strong, nullable) NSNumber *alphaValue;
@property (nonatomic, copy, nullable) NSString *customDisplayTitle;
@property (nonatomic, copy, nullable) NSString *danceUISource;
@property (nonatomic, copy) NSArray<PVAttributesGroup *> *attributesGroupList;
@property (nonatomic, copy) NSArray<PVAttributesGroup *> *customAttrGroupList;
@property (nonatomic, copy, nullable) NSArray<PVDisplayItem *> *subitems;
@property (nonatomic, assign) PVDisplayItemDetailFailureCode failureCode;
@property (nonatomic, assign) PVDisplayItemContentKind contentKind;
@property (nonatomic, strong, nullable) PVFlutterNodeDetail *flutterDetail;

@end

NS_ASSUME_NONNULL_END

#endif /* PVDisplayItemDetail_h */

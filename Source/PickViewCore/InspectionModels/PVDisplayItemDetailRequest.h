//
//  PVDisplayItemDetailRequest.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#ifndef PVDisplayItemDetailRequest_h
#define PVDisplayItemDetailRequest_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PVDisplayItemDetailRequest : NSObject <NSSecureCoding, NSCopying>

@property (nonatomic, copy) NSArray<NSString *> *displayItemIDs;
@property (nonatomic, assign) BOOL needsSoloImage;
@property (nonatomic, assign) BOOL needsGroupImage;
@property (nonatomic, assign) BOOL lowImageQuality;

@end

NS_ASSUME_NONNULL_END

#endif /* PVDisplayItemDetailRequest_h */

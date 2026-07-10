//
//  PVAutoLayoutConstraint.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVInspectionDefines.h"

@class PVObject;

typedef NS_ENUM(NSInteger, PVConstraintItemType) {
    PVConstraintItemTypeUnknown,
    PVConstraintItemTypeNil,
    PVConstraintItemTypeView,
    PVConstraintItemTypeSelf,
    PVConstraintItemTypeSuper,
    PVConstraintItemTypeLayoutGuide
};

@interface PVAutoLayoutConstraint : NSObject <NSSecureCoding>

@property(nonatomic, assign) BOOL effective;
@property(nonatomic, assign) BOOL active;
@property(nonatomic, assign) BOOL shouldBeArchived;
@property(nonatomic, strong) PVObject *firstItem;
@property(nonatomic, assign) PVConstraintItemType firstItemType;
/// iOS 里的 NSLayoutAttribute，注意 iOS 和 macOS 虽然都有 NSLayoutAttribute 但是 value 非常不同，因此这里使用 NSInteger 避免混淆
@property(nonatomic, assign) NSInteger firstAttribute;
@property(nonatomic, assign) NSLayoutRelation relation;
@property(nonatomic, strong) PVObject *secondItem;
@property(nonatomic, assign) PVConstraintItemType secondItemType;
/// iOS 里的 NSLayoutAttribute，注意 iOS 和 macOS 虽然都有 NSLayoutAttribute 但是 value 非常不同，因此这里使用 NSInteger 避免混淆
@property(nonatomic, assign) NSInteger secondAttribute;
@property(nonatomic, assign) CGFloat multiplier;
@property(nonatomic, assign) CGFloat constant;
@property(nonatomic, assign) CGFloat priority;
@property(nonatomic, copy) NSString *identifier;

@end

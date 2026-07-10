//
//  PVCustomAttrSetterManager.h
//  PickViewServer
//
//  Created by kris cheng on 2026/7/9.
//

#import <Foundation/Foundation.h>
#import <TargetConditionals.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#define PVCustomSetterColor UIColor
#define PVCustomSetterInsets UIEdgeInsets
#else
#import <AppKit/AppKit.h>
#define PVCustomSetterColor NSColor
#define PVCustomSetterInsets NSEdgeInsets
#endif

typedef void(^PVStringSetter)(NSString *);
typedef void(^PVNumberSetter)(NSNumber *);
typedef void(^PVBoolSetter)(BOOL);
typedef void(^PVColorSetter)(PVCustomSetterColor *);
typedef void(^PVEnumSetter)(NSString *);
typedef void(^PVRectSetter)(CGRect);
typedef void(^PVSizeSetter)(CGSize);
typedef void(^PVPointSetter)(CGPoint);
typedef void(^PVInsetsSetter)(PVCustomSetterInsets);

@interface PVCustomAttrSetterManager : NSObject

+ (instancetype)sharedInstance;

- (void)removeAll;

- (void)saveStringSetter:(PVStringSetter)setter uniqueID:(NSString *)uniqueID;
- (PVStringSetter)getStringSetterWithID:(NSString *)uniqueID;

- (void)saveNumberSetter:(PVNumberSetter)setter uniqueID:(NSString *)uniqueID;
- (PVNumberSetter)getNumberSetterWithID:(NSString *)uniqueID;

- (void)saveBoolSetter:(PVBoolSetter)setter uniqueID:(NSString *)uniqueID;
- (PVBoolSetter)getBoolSetterWithID:(NSString *)uniqueID;

- (void)saveColorSetter:(PVColorSetter)setter uniqueID:(NSString *)uniqueID;
- (PVColorSetter)getColorSetterWithID:(NSString *)uniqueID;

- (void)saveEnumSetter:(PVEnumSetter)setter uniqueID:(NSString *)uniqueID;
- (PVEnumSetter)getEnumSetterWithID:(NSString *)uniqueID;

- (void)saveRectSetter:(PVRectSetter)setter uniqueID:(NSString *)uniqueID;
- (PVRectSetter)getRectSetterWithID:(NSString *)uniqueID;

- (void)saveSizeSetter:(PVSizeSetter)setter uniqueID:(NSString *)uniqueID;
- (PVSizeSetter)getSizeSetterWithID:(NSString *)uniqueID;

- (void)savePointSetter:(PVPointSetter)setter uniqueID:(NSString *)uniqueID;
- (PVPointSetter)getPointSetterWithID:(NSString *)uniqueID;

- (void)saveInsetsSetter:(PVInsetsSetter)setter uniqueID:(NSString *)uniqueID;
- (PVInsetsSetter)getInsetsSetterWithID:(NSString *)uniqueID;

@end

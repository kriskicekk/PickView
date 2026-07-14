//
//  PVFlutterInspectionModel.h
//  PickViewCore
//

#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PVDisplayItemContentKind) {
    PVDisplayItemContentKindNative = 0,
    PVDisplayItemContentKindFlutter = 1,
};

typedef NS_ENUM(NSUInteger, PVFlutterLoadState) {
    PVFlutterLoadStateNone = 0,
    PVFlutterLoadStateLoading,
    PVFlutterLoadStateLoaded,
    PVFlutterLoadStateFailed,
    PVFlutterLoadStateDisconnected,
};

typedef NS_ENUM(NSUInteger, PVFlutterDetailValueKind) {
    PVFlutterDetailValueKindText = 0,
    PVFlutterDetailValueKindNumber,
    PVFlutterDetailValueKindBoolean,
    PVFlutterDetailValueKindColorARGB,
    PVFlutterDetailValueKindRect,
    PVFlutterDetailValueKindSize,
    PVFlutterDetailValueKindJSON,
};

@interface PVFlutterNodeReference : NSObject <NSSecureCoding, NSCopying>
@property(nonatomic, copy) NSString *recordIdentifier;
@property(nonatomic, copy) NSString *engineIdentifier;
@property(nonatomic, copy) NSString *isolateID;
@property(nonatomic, copy) NSString *objectGroup;
@property(nonatomic, copy) NSString *objectID;
@end

@interface PVFlutterDetailField : NSObject <NSSecureCoding, NSCopying>
@property(nonatomic, copy) NSString *identifier;
@property(nonatomic, copy) NSString *title;
@property(nonatomic) PVFlutterDetailValueKind valueKind;
@property(nonatomic, copy, nullable) NSString *textValue;
@property(nonatomic, strong, nullable) NSNumber *numberValue;
@property(nonatomic) CGRect rectValue;
@property(nonatomic) CGSize sizeValue;
@end

@interface PVFlutterDetailSection : NSObject <NSSecureCoding, NSCopying>
@property(nonatomic, copy) NSString *identifier;
@property(nonatomic, copy) NSString *title;
@property(nonatomic) BOOL initiallyExpanded;
@property(nonatomic, copy) NSArray<PVFlutterDetailField *> *fields;
@end

@interface PVFlutterLayoutGroup : NSObject <NSSecureCoding, NSCopying>
@property(nonatomic, copy) NSString *objectID;
@property(nonatomic, copy) NSString *widgetType;
@property(nonatomic, copy) NSString *renderObjectType;
@property(nonatomic, copy) NSArray<NSString *> *managedNodeIDs;
@property(nonatomic, copy) NSArray<PVFlutterDetailField *> *fields;
@property(nonatomic, copy, nullable) NSString *rawJSON;
@end

@interface PVFlutterNodeDetail : NSObject <NSSecureCoding, NSCopying>
@property(nonatomic, strong) PVFlutterNodeReference *reference;
@property(nonatomic, copy) NSString *widgetType;
@property(nonatomic, copy) NSString *elementType;
@property(nonatomic, copy) NSString *renderObjectType;
@property(nonatomic, copy) NSArray<NSString *> *capabilities;
@property(nonatomic, copy) NSArray<PVFlutterDetailSection *> *sections;
@property(nonatomic, copy) NSArray<PVFlutterLayoutGroup *> *layoutGroups;
@property(nonatomic, copy, nullable) NSString *rawJSON;
@end

NS_ASSUME_NONNULL_END

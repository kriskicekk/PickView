//
//  PVCustomAttrGroupsMaker.h
//  PickViewServer
//
//  Created by kris cheng on 2026/7/9.
//

#import <Foundation/Foundation.h>
#import <TargetConditionals.h>

#if TARGET_OS_IPHONE
#import <QuartzCore/QuartzCore.h>

@class PVAttributesGroup;

@interface PVCustomAttrGroupsMaker : NSObject

- (instancetype)initWithLayer:(CALayer *)layer;

- (void)execute;

- (NSArray<PVAttributesGroup *> *)getGroups;
- (NSString *)getCustomDisplayTitle;
- (NSString *)getDanceUISource;

+ (NSArray<PVAttributesGroup *> *)makeGroupsFromRawProperties:(NSArray *)rawProperties saveCustomSetter:(BOOL)saveCustomSetter;

@end

#endif

//
//  PVMacAttrGroupsMaker.h
//  PickViewServer
//
//  Created by kris cheng on 2026/7/10.
//

#import <Foundation/Foundation.h>

@class NSView;
@class NSWindow;
@class PVAttributesGroup;

NS_ASSUME_NONNULL_BEGIN

@interface PVMacAttrGroupsMaker : NSObject

+ (NSArray<PVAttributesGroup *> *)attrGroupsForView:(NSView *)view;
+ (NSArray<PVAttributesGroup *> *)attrGroupsForWindow:(NSWindow *)window;

@end

NS_ASSUME_NONNULL_END

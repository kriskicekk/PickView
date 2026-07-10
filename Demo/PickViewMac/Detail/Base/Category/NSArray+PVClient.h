//
//  NSArray+PVClient.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>

@interface NSArray<__covariant ValueType> (PVClient)

- (NSArray<ValueType> *)lk_visibleViews;

@end

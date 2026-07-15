//
//  NSPointerArray+PVClient.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import <Foundation/Foundation.h>

@interface NSPointerArray (PVClient)

- (NSUInteger)lk_indexOfPointer:(void *)pointer;

- (BOOL)lk_containsPointer:(void *)pointer;

@end

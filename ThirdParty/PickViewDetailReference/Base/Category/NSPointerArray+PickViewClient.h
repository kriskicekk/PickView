//
//  NSPointerArray+PickViewClient.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import <Foundation/Foundation.h>

@interface NSPointerArray (PickViewClient)

- (NSUInteger)lk_indexOfPointer:(void *)pointer;

- (BOOL)lk_containsPointer:(void *)pointer;

@end

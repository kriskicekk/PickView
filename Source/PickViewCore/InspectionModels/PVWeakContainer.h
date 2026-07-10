//
//  PVWeakContainer.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import <Foundation/Foundation.h>

@interface PVWeakContainer : NSObject

+ (instancetype)containerWithObject:(id)object;

@property (nonatomic, weak) id object;

@end


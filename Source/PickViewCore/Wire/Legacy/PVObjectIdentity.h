//
//  PVObjectIdentity.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#ifndef PVObjectIdentity_h
#define PVObjectIdentity_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PVObjectIdentity : NSObject <NSSecureCoding, NSCopying>

@property (nonatomic, copy) NSString *objectID;
@property (nonatomic, copy) NSString *memoryAddress;
@property (nonatomic, copy) NSString *className;
@property (nonatomic, copy) NSArray<NSString *> *classChain;

@end

NS_ASSUME_NONNULL_END

#endif /* PVObjectIdentity_h */

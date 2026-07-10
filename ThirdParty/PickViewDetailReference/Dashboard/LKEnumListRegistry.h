//
//  LKEnumListRegistry.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import <Foundation/Foundation.h>

@interface LKEnumListRegistryKeyValueItem : NSObject

@property(nonatomic, copy) NSString *desc;
@property(nonatomic, assign) long value;
@property(nonatomic, assign) NSInteger availableOSVersion;

@end

@interface LKEnumListRegistry : NSObject

+ (instancetype)sharedInstance;

- (NSArray<LKEnumListRegistryKeyValueItem *> *)itemsForEnumName:(NSString *)enumName;

- (NSString *)descForEnumName:(NSString *)enumName value:(long)value;

@end

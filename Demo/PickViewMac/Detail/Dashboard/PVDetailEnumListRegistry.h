//
//  PVDetailEnumListRegistry.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import <Foundation/Foundation.h>

@interface PVDetailEnumListRegistryKeyValueItem : NSObject

@property(nonatomic, copy) NSString *desc;
@property(nonatomic, assign) long value;
@property(nonatomic, assign) NSInteger availableOSVersion;

@end

@interface PVDetailEnumListRegistry : NSObject

+ (instancetype)sharedInstance;

- (NSArray<PVDetailEnumListRegistryKeyValueItem *> *)itemsForEnumName:(NSString *)enumName;

- (NSString *)descForEnumName:(NSString *)enumName value:(long)value;

@end

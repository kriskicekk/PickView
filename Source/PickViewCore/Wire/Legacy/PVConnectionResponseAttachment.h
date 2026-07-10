//
//  PVConnectionResponseAttachment.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import <Foundation/Foundation.h>
#import "PVConnectionAttachment.h"

@interface PVConnectionResponseAttachment : PVConnectionAttachment

+ (instancetype)attachmentWithError:(NSError *)error;

@property(nonatomic, assign) int pickviewServerVersion;

@property(nonatomic, strong) NSError *error;

/// 如果为 YES，则表示 app 正处于后台模式，默认为 NO
@property(nonatomic, assign) BOOL appIsInBackground;

/**
 dataTotalCount 为 0 时表示仅有这一个 response，默认为 0
 dataTotalCount 大于 0 时表示可能有多个 response，当所有 response 的 currentDataCount 的总和大于 dataTotalCount 即表示所有 response 已接收完毕
 */
@property(nonatomic, assign) NSUInteger dataTotalCount;
@property(nonatomic, assign) NSUInteger currentDataCount;

@end


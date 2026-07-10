//
//  NSString+Score.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import <Foundation/Foundation.h>

enum{
    NSStringScoreOptionNone                         = 1 << 0,
    NSStringScoreOptionFavorSmallerWords            = 1 << 1,
    NSStringScoreOptionReducedLongStringPenalty     = 1 << 2
};

typedef NSUInteger NSStringScoreOption;

@interface NSString (Score)

- (CGFloat) scoreAgainst:(NSString *)otherString;
- (CGFloat) scoreAgainst:(NSString *)otherString fuzziness:(NSNumber *)fuzziness;
- (CGFloat) scoreAgainst:(NSString *)otherString fuzziness:(NSNumber *)fuzziness options:(NSStringScoreOption)options;

- (CGFloat) scoreAgainst:(NSString *)anotherString fuzziness:(NSNumber *)fuzziness options:(NSStringScoreOption)options
     invalidCharacterSet:(NSCharacterSet *)invalidCharacterSet decomposedString:(NSString *)string;

- (NSString *)decomposedStringWithInvalidCharacterSet:(NSCharacterSet *)invalidCharacterSet;
- (NSCharacterSet *)invalidCharacterSet;

@end

//
//  PVDetailJSONAttributeContentView.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import <Foundation/Foundation.h>

@interface PVDetailJSONAttributeContentView : PVDetailBaseView

- (instancetype)initWithBigFont:(BOOL)bigFont;

- (void)renderWithJSON:(NSString *)json;

- (CGFloat)queryContentHeight;

@property (nonatomic, copy) void (^didReloadData)(void);

@end

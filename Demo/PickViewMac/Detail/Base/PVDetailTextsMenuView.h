//
//  PVDetailTextsMenuView.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailBaseView.h"

typedef NS_ENUM(NSInteger, PVDetailTextsMenuViewType) {
    PVDetailTextsMenuViewTypeJustified, // 左侧文字左对齐，右侧文字右对齐
    PVDetailTextsMenuViewTypeCenter   // 居中显示
};

@interface PVDetailTextsMenuView : PVDetailBaseView

/// 默认为 {0, 3, 0, 3}
@property(nonatomic, assign) NSEdgeInsets insets;

@property(nonatomic, assign) PVDetailTextsMenuViewType type;

@property(nonatomic, copy) NSArray<PVStringTwoTuple *> *texts;

@property(nonatomic, strong) NSFont *font;

/// 默认为 2
@property(nonatomic, assign) CGFloat verSpace;
/// 默认为 10
@property(nonatomic, assign) CGFloat horSpace;

/// 在某一行的右侧加一个按钮，业务自己负责这个 button 的点击事件之类的
- (void)addButton:(NSButton *)button atIndex:(NSUInteger)idx;

@end

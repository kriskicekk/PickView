//
//  PVDetailInputSearchSuggestionsContentView.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailInputSearchSuggestionsContentView.h"
#import "PVDetailInputSearchSuggestionsRowView.h"
#import "PVDetailInputSearchSuggestionItem.h"

static CGFloat const kInputSearchSuggestionsItemViewHeight = 28;

@interface PVDetailInputSearchSuggestionsContentView () <NSTableViewDelegate, NSTableViewDataSource>

@property(nonatomic, strong) PVDetailVisualEffectView *backgroundEffectView;

@end

@implementation PVDetailInputSearchSuggestionsContentView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        self.layer.cornerRadius = 4;
        
        self.backgroundEffectView = [PVDetailVisualEffectView new];
        self.backgroundEffectView.blendingMode = NSVisualEffectBlendingModeBehindWindow;
        self.backgroundEffectView.state = NSVisualEffectStateActive;
        [self addSubview:self.backgroundEffectView];
        
        _tableView = [[NSTableView alloc] init];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.wantsLayer = YES;
        self.tableView.headerView = nil;
//        self.tableView.selectionHighlightStyle = NSTableViewSelectionHighlightStyleNone;
//        self.tableView.focusRingType = NSFocusRingTypeNone;
        self.tableView.intercellSpacing = NSMakeSize(0, 0);
        NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:@"column"];
        column.editable = NO;
        [self.tableView addTableColumn:column];
        [self addSubview:self.tableView];
        
        @weakify(self);
        [RACObserve(self, items) subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            [self.tableView reloadData];
        }];
    }
    return self;
}

- (void)layout {
    [super layout];
    $(self.backgroundEffectView, self.tableView).fullFrame;
}

- (PVDetailInputSearchSuggestionItem *)currentSelectedItem {
    NSInteger selectedRow = self.tableView.selectedRow;
    return [self.items pv_inspect_safeObjectAtIndex:selectedRow];
}

- (NSSize)bestSize {
    PVDetailInputSearchSuggestionsRowView *rowView = [self pv_inspect_getBindObjectForKey:@"calculatingRowView"];
    if (!rowView) {
        rowView = [PVDetailInputSearchSuggestionsRowView new];
        [self pv_inspect_bindObject:rowView forKey:@"calculatingRowView"];
    }
    CGFloat width = [self.items pv_inspect_reduceCGFloat:^CGFloat(CGFloat accumulator, NSUInteger idx, PVDetailInputSearchSuggestionItem *obj) {
        rowView.imageView.image = obj.image;
        rowView.titleLabel.stringValue = obj.text;
        return MAX(rowView.bestWidth, accumulator);
    } initialAccumlator:0];
    
    CGFloat height = kInputSearchSuggestionsItemViewHeight * self.items.count;
    return NSMakeSize(width, height);
}

#pragma mark - Table View

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.items.count;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return kInputSearchSuggestionsItemViewHeight;
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    PVDetailInputSearchSuggestionItem *item = [self.items pv_inspect_safeObjectAtIndex:row];
    if (!item) {
        return [PVDetailInputSearchSuggestionsRowView new];
    }
    PVDetailInputSearchSuggestionsRowView *view = (PVDetailInputSearchSuggestionsRowView *)[tableView makeViewWithIdentifier:@"cell" owner:self];
    if (!view) {
        view = [PVDetailInputSearchSuggestionsRowView new];
        view.identifier = @"cell";
    }
    view.titleLabel.stringValue = item.text;
    view.imageView.image = item.image;
    [view setNeedsLayout:YES];
    return view;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return nil;
}

@end

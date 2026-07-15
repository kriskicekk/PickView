//
//  PVDetailJSONAttributeContentView.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailJSONAttributeContentView.h"
#import "PVDetailJSONAttributeItem.h"
#import "PVDetailTableView.h"
#import "PVDetailOutlineRowView.h"
#import "PVDetailTableRowView.h"

@interface PVDetailJSONAttributeContentRowView : PVDetailOutlineRowView

@end

@implementation PVDetailJSONAttributeContentRowView

+ (CGFloat)insetLeft {
    return 0;
}

@end

@interface PVDetailJSONAttributeContentView () <PVDetailTableViewDelegate, PVDetailTableViewDataSource>

@property(nonatomic, assign) BOOL useBigFont;

@property(nonatomic, strong) NSArray<PVDetailJSONAttributeItem *> *rootItems;
@property(nonatomic, strong) NSMutableArray<PVDetailJSONAttributeItem *> *flatItems;

@property(nonatomic, strong) PVDetailTableView *tableView;

@property(nonatomic, assign) CGFloat rowHeight;

@end

@implementation PVDetailJSONAttributeContentView


- (instancetype)initWithBigFont:(BOOL)bigFont {
    if (self = [super initWithFrame:NSZeroRect]) {
        self.tableView = [PVDetailTableView new];
        self.tableView.drawsBackground = NO;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.adjustsSelectionAutomatically = NO;
        self.tableView.adjustsHoverAutomatically = NO;
        self.tableView.automaticallyAdjustsContentInsets = NO;
        if (bigFont) {
            self.tableView.contentInsets = NSEdgeInsetsMake(5, 0, 5, 0);
            self.rowHeight = 25;
        } else {
            self.tableView.contentInsets = NSEdgeInsetsMake(0, 0, 0, 0);
            self.rowHeight = 20;
        }
        [self addSubview:self.tableView];
    }
    return self;
}

- (void)layout {
    [super layout];
    $(self.tableView).fullFrame;
}

- (void)renderWithJSON:(NSString *)json {
    [self buildModel:json];
    [self render];
}

- (void)buildModel:(NSString *)json {
    self.rootItems = nil;
    
    if (!json) {
        return;
    }
    
    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSArray *array = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    if (error) {
        NSLog(@"转换失败: %@", error);
        NSAssert(NO, @"");
        return;
    }
    if (![array isKindOfClass:[NSArray class]]) {
        return;
    }
    self.rootItems = [self createItemsFromArray:array];
}

- (NSArray<PVDetailJSONAttributeItem *> *)createItemsFromArray:(NSArray *)rawArray {
    if (![rawArray isKindOfClass:[NSArray class]]) {
        return nil;
    }
    NSMutableArray *resultArray = [NSMutableArray array];
    
    [rawArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull dict, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![dict isKindOfClass:[NSDictionary class]]) {
            return;
        }
        NSString *title = dict[@"title"];
        NSString *desc = dict[@"desc"];
        NSArray *details = dict[@"details"];
        
        PVDetailJSONAttributeItem *item = [PVDetailJSONAttributeItem new];
        item.titleText = title;
        item.desc = desc;
        item.expanded = YES;
        item.subItems = [self createItemsFromArray:details];
        
        [resultArray addObject:item];
    }];
    
    return resultArray;
}

- (void)render {
    self.flatItems = [NSMutableArray array];
    [self.rootItems enumerateObjectsUsingBlock:^(PVDetailJSONAttributeItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.flatItems addObjectsFromArray:[obj flatItems]];
    }];
    
    [self.tableView reloadData];
}

#pragma mark - PVDetailTableView

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    NSInteger count = self.flatItems.count;
    return count;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return self.rowHeight;
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    PVDetailJSONAttributeItem *item = [self.flatItems pv_inspect_safeObjectAtIndex:row];
    if (!item) {
        return [PVDetailTableBlankRowView new];
    }
    
    PVDetailJSONAttributeContentRowView *view = (PVDetailJSONAttributeContentRowView *)[tableView makeViewWithIdentifier:@"myView" owner:self];
    if (!view) {
        view = [[PVDetailJSONAttributeContentRowView alloc] initWithCompactUI:YES];
        view.titleLabel.textColor = [NSColor secondaryLabelColor];
        if (self.useBigFont) {
            view.titleLabel.font = [NSFont monospacedDigitSystemFontOfSize:14 weight:NSFontWeightRegular];
            view.subtitleLabel.font = [NSFont monospacedDigitSystemFontOfSize:14 weight:NSFontWeightRegular];
        } else {
            view.titleLabel.font = [NSFont monospacedDigitSystemFontOfSize:12 weight:NSFontWeightRegular];
            view.subtitleLabel.font = [NSFont monospacedDigitSystemFontOfSize:12 weight:NSFontWeightRegular];
        }
        
        view.titleLabel.selectable = YES;
        view.subtitleLabel.textColor = [NSColor labelColor];
        view.subtitleLabel.selectable = YES;
        view.disclosureButton.target = self;
        view.disclosureButton.action = @selector(handleExpand:);
        view.identifier = @"myView";
    }
    view.titleLabel.stringValue = item.titleText;
    if (item.desc) {
        view.subtitleLabel.stringValue = item.desc;
    } else {
        view.subtitleLabel.stringValue = @"";
    }
    view.disclosureButton.tag = row;
    view.indentLevel = item.indentation;
    if (item.subItems.count > 0) {
        if (item.expanded) {
            view.status = PVDetailOutlineRowViewStatusExpanded;
        } else {
            view.status = PVDetailOutlineRowViewStatusCollapsed;
        }
    } else {
        view.status = PVDetailOutlineRowViewStatusNotExpandable;
    }
    [view setNeedsLayout:YES];
    return view;
}

- (void)handleExpand:(NSButton *)button {
    NSUInteger row = button.tag;
    PVDetailJSONAttributeItem *item = [self.flatItems pv_inspect_safeObjectAtIndex:row];
    if (!item) {
        return;
    }
    item.expanded = !item.expanded;
    [self render];
    
    if (self.didReloadData) {
        self.didReloadData();
    }
}

- (CGFloat)queryContentHeight {
    NSInteger count = self.flatItems.count;
    return count * self.rowHeight;
}

@end

//
//  PVDetailOutlineView.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailOutlineView.h"
#import "PVDetailTableView.h"
#import "PVDetailOutlineItem.h"
#import "PVDetailOutlineRowView.h"

@interface PVDetailOutlineView () <PVDetailTableViewDelegate, PVDetailTableViewDataSource>

@property(nonatomic, copy, readwrite) NSArray<PVDetailOutlineItem *> *displayingItems;
@property(nonatomic, assign) Class rowViewClass;

@end

@implementation PVDetailOutlineView

- (instancetype)initWithRowViewClass:(Class)aClass {
    if (self = [super initWithFrame:NSZeroRect]) {
        _itemHeight = 24;
        
        self.rowViewClass = aClass;
        NSAssert([aClass isSubclassOfClass:[PVDetailOutlineRowView class]], @"");
        
        self.displayingItems = [NSArray array];
        
        _tableView = [PVDetailTableView new];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.adjustsSelectionAutomatically = NO;
        [self addSubview:self.tableView];
    }
    return self;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    return [self initWithRowViewClass:[PVDetailOutlineRowView class]];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    return [self initWithRowViewClass:[PVDetailOutlineRowView class]];
}

- (void)layout {
    [super layout];
    $(self.tableView).fullFrame;
}

- (void)setItems:(NSArray<PVDetailOutlineItem *> *)items {
    _items = items.copy;
    [self _updateDisplayingItems];
}

#pragma mark - PVDetailTableView

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.displayingItems.count;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return self.itemHeight;
}

- (PVDetailOutlineRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    PVDetailOutlineItem *item = [self.displayingItems pv_inspect_safeObjectAtIndex:row];
    if (!item) {
        return [self.rowViewClass new];
    }
    
    PVDetailOutlineRowView *view = (PVDetailOutlineRowView *)[tableView makeViewWithIdentifier:@"cell" owner:self];
    if (!view) {
        view = [self.rowViewClass new];
        view.identifier = @"cell";
    }
    view.disclosureButton.tag = row;
    view.disclosureButton.target = self;
    view.disclosureButton.action = @selector(_handleDisclosureButton:);
    
    if (item.status == PVDetailOutlineItemStatusNotExpandable) {
        view.status = PVDetailOutlineRowViewStatusNotExpandable;
    } else if (item.status == PVDetailOutlineItemStatusExpanded) {
        view.status = PVDetailOutlineRowViewStatusExpanded;
    } else {
        view.status = PVDetailOutlineRowViewStatusCollapsed;
    }
    
    view.indentLevel = item.indentation;
    view.titleLabel.stringValue = item.titleText;
    view.image = item.image;
    
    if ([self.delegate respondsToSelector:@selector(outlineView:configureRowView:withItem:)]) {
        [self.delegate outlineView:self configureRowView:view withItem:item];
    }
    
    [view setNeedsLayout:YES];
    
    return view;
}

#pragma mark - Event Handler

- (void)_handleDisclosureButton:(NSButton *)button {
    NSInteger row = button.tag;
    PVDetailOutlineItem *item = [self.displayingItems pv_inspect_safeObjectAtIndex:row];
    if (!item || item.status == PVDetailOutlineItemStatusNotExpandable) {
        return;
    }
    if (item.status == PVDetailOutlineItemStatusExpanded) {
        item.status = PVDetailOutlineItemStatusCollapsed;
    } else {
        item.status = PVDetailOutlineItemStatusExpanded;
    }
    [self _updateDisplayingItems];
}

#pragma mark - Others

- (void)_updateDisplayingItems {
    self.displayingItems = [PVDetailOutlineItem flatItemsFromRootItems:self.items];
    [self.tableView reloadData];
}

@end

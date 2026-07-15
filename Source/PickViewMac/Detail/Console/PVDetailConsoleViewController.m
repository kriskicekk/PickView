//
//  PVDetailConsoleViewController.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailConsoleViewController.h"
#import "PVDetailConsoleDataSource.h"
#import "PVDetailConsoleDataSourceRowItem.h"
#import "PVDetailTableView.h"
#import "PVDetailConsoleSubmitRowView.h"
#import "PVDetailConsoleReturnRowView.h"
#import "PVDetailConsoleInputRowView.h"
#import "PVDetailTableRowView.h"
#import "PVObject.h"

@interface PVDetailConsoleViewController () <PVDetailTableViewDelegate, PVDetailTableViewDataSource>

@property(nonatomic, strong) PVDetailConsoleDataSource *dataSource;
@property(nonatomic, strong) PVDetailTableView *tableView;
@property(nonatomic, strong) NSButton *clearButton;

@property(nonatomic, strong) PVDetailConsoleInputRowView *inputRowView;
@property(nonatomic, strong) CALayer *topBorderLayer;

@end

@implementation PVDetailConsoleViewController

- (instancetype)initWithHierarchyDataSource:(PVDetailHierarchyDataSource *)dataSource {
    self.dataSource = [[PVDetailConsoleDataSource alloc] initWithHierarchyDataSource:dataSource];

    if (self = [self initWithContainerView:nil]) {
        @weakify(self);
        [RACObserve(self.dataSource, rowItems) subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            [self.tableView reloadData];
            [self.tableView layoutSubtreeIfNeeded];
            
            if (self.dataSource.rowItems.count) {
                [self.tableView scrollRowToVisible:(self.dataSource.rowItems.count - 1)];
            }
            [self.inputRowView makeTextFieldAsFirstResponder];
        }];
    }
    return self;
}

- (NSView *)makeContainerView {
    PVDetailBaseView *containerView = [PVDetailBaseView new];
    containerView.backgroundColorName = @"ConsoleBackgroundColor";
    
    self.inputRowView = [[PVDetailConsoleInputRowView alloc] initWithDataSource:self.dataSource];
    
    self.tableView = [PVDetailTableView new];
    self.tableView.drawsBackground = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.canScrollHorizontally = NO;
    self.tableView.adjustsSelectionAutomatically = NO;
    self.tableView.adjustsHoverAutomatically = NO;
    self.tableView.automaticallyAdjustsContentInsets = NO;
    self.tableView.contentInsets = NSEdgeInsetsMake(5, 0, 5, 0);
    [containerView addSubview:self.tableView];
    
    NSImage *clearButtonImage = NSImageMake(@"icon_delete");
    clearButtonImage.template = YES;
    self.clearButton = [NSButton new];
    self.clearButton.image = clearButtonImage;
    self.clearButton.bezelStyle = NSBezelStyleRoundRect;
    self.clearButton.bordered = NO;
    self.clearButton.target = self;
    self.clearButton.action = @selector(_handleClearButton);
    [containerView addSubview:self.clearButton];
    
    self.topBorderLayer = [CALayer layer];
    [self.topBorderLayer pv_inspect_removeImplicitAnimations];
    [containerView.layer addSublayer:self.topBorderLayer];
    @weakify(self);
    containerView.didChangeAppearanceBlock = ^(PVDetailBaseView *view, BOOL isDarkMode) {
        @strongify(self);
        if (isDarkMode) {
            self.topBorderLayer.backgroundColor = [NSColor colorWithWhite:1 alpha:.12].CGColor;
        } else {
            self.topBorderLayer.backgroundColor = [NSColor colorWithWhite:0 alpha:.15].CGColor;
        }
    };

    return containerView;
}

- (void)viewDidAppear {
    [super viewDidAppear];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView scrollRowToVisible:(self.dataSource.rowItems.count - 1)];
        [self.inputRowView makeTextFieldAsFirstResponder];
    });
}

- (void)viewDidLayout {
    [super viewDidLayout];
    $(self.topBorderLayer).fullWidth.height(1).y(0);
    
    $(self.tableView).fullFrame;
    $(self.clearButton).sizeToFit.right(20).bottom(8);
    
    CGFloat prevWidth = [self pv_inspect_getBindDoubleForKey:@"prevWidth"];
    if (prevWidth != self.view.$width) {
        [self pv_inspect_bindDouble:self.view.$width forKey:@"prevWidth"];
        [self.tableView reloadData];
    }
}

- (void)_handleClearButton {
    [self.dataSource clearHistoryContents];
}

- (void)setIsControllerShowing:(BOOL)isControllerShowing {
    self.dataSource.isShowingConsole = isControllerShowing;
}

- (BOOL)isControllerShowing {
    return self.dataSource.isShowingConsole;
}

- (void)submitWithObj:(PVObject *)obj text:(NSString *)text {
    [[self.dataSource submitWithObj:obj text:text] subscribeNext:^(id  _Nullable x) {
    } error:^(NSError * _Nullable error) {
        NSLog(@"Submit error: %@", error);
    }];
}

#pragma mark - PVDetailTableView

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    NSInteger count = self.dataSource.rowItems.count;
    return count;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    PVDetailConsoleDataSourceRowItem *item = [self.dataSource.rowItems pv_inspect_safeObjectAtIndex:row];
    if (!item) {
        return 0;
    }
    if (item.type == PVDetailConsoleDataSourceRowItemTypeInput) {
        return 20;
    }
    
    if (item.type == PVDetailConsoleDataSourceRowItemTypeSubmit) {
        return 20;
    }
    
    if (item.type == PVDetailConsoleDataSourceRowItemTypeReturn) {
        PVDetailConsoleReturnRowView *calculatingView = [self pv_inspect_getBindObjectForKey:@"calculatingReturnRowView"];
        if (!calculatingView) {
            calculatingView = [PVDetailConsoleReturnRowView new];
            [self pv_inspect_bindObject:calculatingView forKey:@"calculatingReturnRowView"];
        }
        calculatingView.titleLabel.stringValue = item.normalText;
        CGFloat height = [calculatingView heightForWidth:self.tableView.$width];
        return height;
    }
    return 0;
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    PVDetailConsoleDataSourceRowItem *item = [self.dataSource.rowItems pv_inspect_safeObjectAtIndex:row];
    if (!item) {
        return [PVDetailTableBlankRowView new];
    }
    
    if (item.type == PVDetailConsoleDataSourceRowItemTypeInput) {
        return self.inputRowView;
    }
    
    if (item.type == PVDetailConsoleDataSourceRowItemTypeSubmit) {
        PVDetailConsoleSubmitRowView *view = (PVDetailConsoleSubmitRowView *)[tableView makeViewWithIdentifier:@"submit" owner:self];
        if (!view) {
            view = [PVDetailConsoleSubmitRowView new];
            view.identifier = @"submit";
        }
        view.titleLabel.stringValue = item.highlightText;
        view.subtitleLabel.stringValue = item.normalText;
        [view setNeedsLayout:YES];
        return view;
    }
    
    if (item.type == PVDetailConsoleDataSourceRowItemTypeReturn) {
        PVDetailConsoleReturnRowView *view = (PVDetailConsoleReturnRowView *)[tableView makeViewWithIdentifier:@"return" owner:self];
        if (!view) {
            view = [PVDetailConsoleReturnRowView new];
            view.identifier = @"return";
        }
        view.titleLabel.stringValue = item.normalText;
        [view setNeedsLayout:YES];
        return view;
    }
    
    return [PVDetailTableBlankRowView new];
}

- (void)tableViewDidClickBlankArea:(PVDetailTableView *)tableView {
    [self.inputRowView makeTextFieldAsFirstResponder];
}

@end

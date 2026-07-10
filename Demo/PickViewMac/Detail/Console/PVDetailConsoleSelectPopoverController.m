//
//  PVDetailConsoleSelectPopoverController.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailConsoleSelectPopoverController.h"
#import "PVDetailConsoleDataSource.h"
#import "PVDetailConsoleSelectPopoverItemControl.h"
#import "PVDetailImageTextView.h"
#import "PVObject.h"
#import "PVDetailPreferenceManager.h"

@interface PVDetailConsoleSelectPopoverController ()

@property(nonatomic, strong) PVDetailConsoleDataSource *dataSource;

@property(nonatomic, strong) PVDetailImageTextView *historyTitleView;
@property(nonatomic, copy) NSArray<PVDetailConsoleSelectPopoverItemControl *> *historyControls;
@property(nonatomic, copy) NSArray<PVDetailConsoleSelectPopoverItemControl *> *highlightControls;
@property(nonatomic, strong) PVDetailImageTextView *highlightTitleView;
@property(nonatomic, strong) NSButton *toggleButton;
@property(nonatomic, strong) CALayer *sepLayer;

@end

@implementation PVDetailConsoleSelectPopoverController {
    NSEdgeInsets _insets;
    CGFloat _titleMarginTop;
    CGFloat _itemControlMarginTop;
    CGFloat _toggleButtonMarginTop;
}

- (instancetype)initWithDataSource:(PVDetailConsoleDataSource *)dataSource {
    if (self = [self initWithContainerView:nil]) {
        self.dataSource = dataSource;
        _insets = NSEdgeInsetsMake(8, 12, 8, 12);
        _titleMarginTop = 16;
        _itemControlMarginTop = 5;
        _toggleButtonMarginTop = 22;
    }
    return self;
}

- (NSView *)makeContainerView {
    PVDetailBaseView *view = [PVDetailBaseView new];
    
    self.historyTitleView = [PVDetailImageTextView new];
    self.historyTitleView.imageMargins = HorizontalMarginsMake(0, 5);
    self.historyTitleView.imageView.image = NSImageMake(@"console_history");
    self.historyTitleView.label.stringValue = NSLocalizedString(@"Objects returned recently in console", nil);
    [view addSubview:self.historyTitleView];
    
    self.highlightTitleView = [PVDetailImageTextView new];
    self.highlightTitleView.imageMargins = HorizontalMarginsMake(0, 5);
    self.highlightTitleView.imageView.image = NSImageMake(@"icon_cursor");
    self.highlightTitleView.label.stringValue = NSLocalizedString(@"Objects highlighted in hierarchy panel", nil);
    [view addSubview:self.highlightTitleView];
    
    self.historyControls = [NSArray array];
    self.highlightControls = [NSArray array];
    
    self.toggleButton = [NSButton new];
    [self.toggleButton setButtonType:NSButtonTypeSwitch];
    self.toggleButton.title = NSLocalizedString(@"Automatically make highlighted view in hierarchy panel as console target", nil);
    self.toggleButton.font = NSFontMake(12);
    self.toggleButton.target = self;
    self.toggleButton.action = @selector(_handleToggleSyncButton);
    [view addSubview:self.toggleButton];
    
    RAC(self.toggleButton, state) = [RACObserve([PVDetailPreferenceManager mainManager], syncConsoleTarget) map:^id _Nullable(NSNumber *value) {
        BOOL shouldChecked = value.boolValue;
        if (shouldChecked) {
            return @(NSControlStateValueOn);
        } else {
            return @(NSControlStateValueOff);
        }
    }];
    
    @weakify(self);
    view.didChangeAppearanceBlock = ^(PVDetailBaseView *view, BOOL isDarkMode) {
        @strongify(self);
        if (isDarkMode) {
            self.sepLayer.backgroundColor = [NSColor colorWithWhite:1 alpha:.2].CGColor;
        } else {
            self.sepLayer.backgroundColor = [NSColor colorWithWhite:0 alpha:.12].CGColor; 
        }
    };
    self.sepLayer = [CALayer layer];
    [self.sepLayer pv_inspect_removeImplicitAnimations];
    [view.layer addSublayer:self.sepLayer];
    
    return view;
}

- (void)viewDidLayout {
    [super viewDidLayout];
    
    __block CGFloat y = _insets.top;
    
    if (self.historyTitleView.isVisible) {
        $(self.historyTitleView).sizeToFit.x(_insets.left).y(y);
        y = self.historyTitleView.$maxY;
    }
    [self.historyControls enumerateObjectsUsingBlock:^(PVDetailConsoleSelectPopoverItemControl * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        $(obj).x(self->_insets.left).toRight(self->_insets.right).heightToFit.y(y + self->_itemControlMarginTop);
        y = obj.$maxY;
    }];
    if (self.highlightTitleView.isVisible) {
        if (self.historyTitleView.isVisible) {
            y += _titleMarginTop;
        }
        $(self.highlightTitleView).sizeToFit.x(_insets.left).y(y);
        y = self.highlightTitleView.$maxY;
    }
    [self.highlightControls enumerateObjectsUsingBlock:^(PVDetailConsoleSelectPopoverItemControl * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        $(obj).x(self->_insets.left).toRight(self->_insets.right).heightToFit.y(y + self->_itemControlMarginTop);
        y = obj.$maxY;
    }];
    
    $(self.toggleButton).x(_insets.left).toRight(_insets.right).y(y + _toggleButtonMarginTop).height([self.toggleButton sizeThatFits:NSSizeMax].height + 2);
    $(self.sepLayer).x(_insets.left).toRight(_insets.right).height(1).y(self.toggleButton.$y - 7);
}

- (CGFloat)bestHeight {
    __block CGFloat height = _insets.top + _insets.bottom;
    if (self.historyTitleView.isVisible) {
        height += [self.historyTitleView sizeThatFits:NSSizeMax].height;
    }
    if (self.highlightTitleView.isVisible) {
        height += [self.highlightTitleView sizeThatFits:NSSizeMax].height;
        
        if (self.historyTitleView.isVisible) {
            height += _titleMarginTop;
        }
    }
    [[self.historyControls arrayByAddingObjectsFromArray:self.highlightControls] enumerateObjectsUsingBlock:^(PVDetailConsoleSelectPopoverItemControl * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        height += [obj sizeThatFits:NSSizeMax].height + self->_itemControlMarginTop;
    }];
    
    height += [self.toggleButton sizeThatFits:NSSizeMax].height + _toggleButtonMarginTop;
    return height;
}

- (void)reRender {
    if (self.dataSource.recentObjects.count == 0) {
        self.historyControls = [self.historyControls pv_inspect_resizeWithCount:1 add:^PVDetailConsoleSelectPopoverItemControl *(NSUInteger idx) {
            PVDetailConsoleSelectPopoverItemControl *control = [PVDetailConsoleSelectPopoverItemControl new];
            [control addTarget:self clickAction:@selector(_handleControl:)];
            [self.view addSubview:control];
            return control;
            
        } remove:^(NSUInteger idx, PVDetailConsoleSelectPopoverItemControl *control) {
            [control removeFromSuperview];
            
        } doNext:^(NSUInteger idx, PVDetailConsoleSelectPopoverItemControl *control) {
            control.title = NSLocalizedString(@"No object was returned yet", nil);
            control.isChecked = NO;
            control.representedObject = nil;
        }];
    } else {
        self.historyControls = [self.historyControls pv_inspect_resizeWithCount:self.dataSource.recentObjects.count add:^PVDetailConsoleSelectPopoverItemControl *(NSUInteger idx) {
            PVDetailConsoleSelectPopoverItemControl *control = [PVDetailConsoleSelectPopoverItemControl new];
            [control addTarget:self clickAction:@selector(_handleControl:)];
            [self.view addSubview:control];
            return control;
            
        } remove:^(NSUInteger idx, PVDetailConsoleSelectPopoverItemControl *control) {
            [control removeFromSuperview];
            
        } doNext:^(NSUInteger idx, PVDetailConsoleSelectPopoverItemControl *control) {
            RACTwoTuple *tuple = self.dataSource.recentObjects[idx];
            PVObject *targetObject = tuple.first;
            control.title = [NSString stringWithFormat:@"<%@: %@>", targetObject.lk_simpleDemangledClassName, targetObject.memoryAddress];
            control.subtitle = tuple.second;
            control.isChecked = (self.dataSource.currentObject.oid == targetObject.oid);
            control.representedObject = targetObject;
        }];
    }
    
    self.highlightTitleView.hidden = (self.dataSource.selectedObjects.count == 0);
    self.highlightControls = [self.highlightControls pv_inspect_resizeWithCount:self.dataSource.selectedObjects.count add:^PVDetailConsoleSelectPopoverItemControl *(NSUInteger idx) {
        PVDetailConsoleSelectPopoverItemControl *control = [PVDetailConsoleSelectPopoverItemControl new];
        [control addTarget:self clickAction:@selector(_handleControl:)];
        [self.view addSubview:control];
        return control;
        
    } remove:^(NSUInteger idx, PVDetailConsoleSelectPopoverItemControl *control) {
        [control removeFromSuperview];
        
    } doNext:^(NSUInteger idx, PVDetailConsoleSelectPopoverItemControl *control) {
        PVObject *targetObject = self.dataSource.selectedObjects[idx];
        control.title = [NSString stringWithFormat:@"<%@: %@>", targetObject.lk_simpleDemangledClassName, targetObject.memoryAddress];
        control.isChecked = (self.dataSource.currentObject.oid == targetObject.oid);
        control.representedObject = targetObject;
    }];
    
    [self.view setNeedsLayout:YES];
}

- (void)_handleControl:(PVDetailConsoleSelectPopoverItemControl *)control {
    PVObject *obj = control.representedObject;
    if (!obj) {
        return;
    }
    @weakify(self);
    [[self.dataSource makeObjectAsCurrent:obj] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        if (obj.oid != self.dataSource.selectedObjects.lastObject.oid) {
            [PVDetailPreferenceManager mainManager].syncConsoleTarget = NO;
        }
        if (self.needClose) {
            self.needClose();
        }

    } error:^(NSError * _Nullable error) {
        if (self.needShowError) {
            self.needShowError(PVInspectErr_NoConnect);
        }
    }];
}

- (void)_handleToggleSyncButton {
    PVDetailPreferenceManager *mng = [PVDetailPreferenceManager mainManager];
    mng.syncConsoleTarget = !mng.syncConsoleTarget;
    if (mng.syncConsoleTarget) {
        @weakify(self);
        [[self.dataSource makeObjectAsCurrent:self.dataSource.selectedObjects.lastObject] subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            [self reRender];
        }];
    }
}

@end

//
//  PVDetailHierarchyHandlersPopoverController.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailHierarchyHandlersPopoverController.h"
#import "PVDetailHierarchyHandlersPopoverItemView.h"
#import "PVEventHandler.h"
#import "PVDisplayItem.h"

@interface PVDetailHierarchyHandlersPopoverController ()

@property(nonatomic, strong) NSScrollView *scrollView;
@property(nonatomic, copy) NSArray<PVDetailHierarchyHandlersPopoverItemView *> *itemViews;

@end

@implementation PVDetailHierarchyHandlersPopoverController {
    CGFloat _verInset;
}

- (instancetype)initWithDisplayItem:(PVDisplayItem *)displayItem editable:(BOOL)editable {
    if (self = [self initWithContainerView:nil]) {
        _verInset = 0;
        self.scrollView.documentView = [PVDetailBaseView new];
        
        self.itemViews = [displayItem.eventHandlers pv_inspect_map:^id(NSUInteger idx, PVEventHandler *handler) {
            PVDetailHierarchyHandlersPopoverItemView *view = [[PVDetailHierarchyHandlersPopoverItemView alloc] initWithEventHandler:handler editable:editable];
            [self.scrollView.documentView addSubview:view];
            view.needTopBorder = (idx > 0);
            view.hidden = NO;
            return view;
        }];
    }
    return self;
}

- (NSView *)makeContainerView {
    self.scrollView = [NSScrollView new];
    self.scrollView.drawsBackground = NO;
    return self.scrollView;
}

- (void)viewDidLayout {
    [super viewDidLayout];
    
    $(self.scrollView.documentView).fullWidth.y(0);
    
    __block CGFloat maxY = 0;
    NSArray<PVDetailHierarchyHandlersPopoverItemView *> *visibleViews = self.itemViews.lk_visibleViews;
    [visibleViews enumerateObjectsUsingBlock:^(PVDetailHierarchyHandlersPopoverItemView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        PVDetailHierarchyHandlersPopoverItemView *prevView = (idx > 0 ? self.itemViews[idx - 1] : nil);
        CGFloat y = prevView ? prevView.$maxY : self->_verInset;
        $(view).fullWidth.heightToFit.y(y);
        
        if (idx == visibleViews.count - 1) {
            maxY = view.$maxY;
        }
    }];
    $(self.scrollView.documentView).height(maxY);
}

- (NSSize)neededSize {
    __block NSSize resultSize = NSMakeSize(0, _verInset * 2);
    [self.itemViews enumerateObjectsUsingBlock:^(PVDetailHierarchyHandlersPopoverItemView * _Nonnull itemView, NSUInteger idx, BOOL * _Nonnull stop) {
        if (itemView.hidden) {
            return;
        }
        NSSize itemSize = [itemView sizeThatFits:NSSizeMax];
        resultSize.width = MAX(resultSize.width, itemSize.width);
        resultSize.height += itemSize.height;
    }];
    return resultSize;
}

@end

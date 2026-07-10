//
//  PVDetailDashboardAttributeConstraintsView.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailDashboardAttributeConstraintsView.h"
#import "PVObject.h"
#import "PVDetailDashboardAttributeConstraintsItemControl.h"
#import "PVAutoLayoutConstraint.h"
#import "PVDetailConstraintPopoverController.h"
#import "PVDetailDashboardViewController.h"
#import "PVDetailHierarchyDataSource.h"
#import "PVDisplayItem.h"

@interface PVDetailDashboardAttributeConstraintsView ()

@property(nonatomic, strong) NSMutableArray<PVDetailDashboardAttributeConstraintsItemControl *> *textControls;

@end

@implementation PVDetailDashboardAttributeConstraintsView {
    CGFloat _verInterSpace;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        _verInterSpace = 8;
        
        self.textControls = [NSMutableArray array];
    }
    return self;
}

- (void)renderWithAttribute {
    [super renderWithAttribute];
    
    NSArray<PVAutoLayoutConstraint *> *rawData = self.attribute.value;
    NSArray<PVAutoLayoutConstraint *> *sortedRawData = [self _sortedRawDataFromData:rawData];
    
    [self.textControls pv_inspect_dequeueWithCount:sortedRawData.count add:^PVDetailDashboardAttributeConstraintsItemControl *(NSUInteger idx) {
        PVDetailDashboardAttributeConstraintsItemControl *control = [PVDetailDashboardAttributeConstraintsItemControl new];
        [control addTarget:self clickAction:@selector(_handleClickItem:)];
        [self addSubview:control];
        return control;
        
    } notDequeued:^(NSUInteger idx, PVDetailDashboardAttributeConstraintsItemControl *control) {
        control.hidden = YES;
        
    } doNext:^(NSUInteger idx, PVDetailDashboardAttributeConstraintsItemControl *control) {
        control.hidden = NO;
        control.constraint = sortedRawData[idx];
        [control setNeedsLayout:YES];
    }];
    [self setNeedsLayout:YES];
}

- (void)layout {
    [super layout];
    
    __block CGFloat y = 0;
    [self.textControls enumerateObjectsUsingBlock:^(PVDetailTextControl * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.hidden) {
            return;
        }
        $(obj).fullFrame.heightToFit.y(y);
        y = obj.$maxY + self->_verInterSpace;
    }];
}

- (NSSize)sizeThatFits:(NSSize)limitedSize {
    NSArray<PVDetailTextControl *> *visibleControls = [self.textControls pv_inspect_filter:^BOOL(PVDetailTextControl *obj) {
        return !obj.hidden;
    }];
    limitedSize.height = [visibleControls pv_inspect_reduceCGFloat:^CGFloat(CGFloat accumulator, NSUInteger idx, PVDetailTextControl *obj) {
        CGFloat labelHeight = [obj sizeThatFits:limitedSize].height;
        accumulator += labelHeight;
        if (idx) {
            accumulator += self->_verInterSpace;
        }
        return accumulator;
    } initialAccumlator:0];
    return limitedSize;
}

- (NSArray<PVAutoLayoutConstraint *> *)_sortedRawDataFromData:(NSArray<PVAutoLayoutConstraint *> *)rawData {
    return [rawData sortedArrayUsingComparator:^NSComparisonResult(PVAutoLayoutConstraint *obj1, PVAutoLayoutConstraint *obj2) {
        if (obj1.effective != obj2.effective) {
            if (obj1.effective) {
                return NSOrderedAscending;
            } else {
                return NSOrderedDescending;
            }
        }
        
        if (obj1.firstItemType > obj2.firstItemType) {
            return NSOrderedDescending;
        } else if (obj1.firstItemType < obj2.firstItemType) {
            return NSOrderedAscending;
        }
        
        if (obj1.firstAttribute > obj2.firstAttribute) {
            return NSOrderedDescending;
        } else if (obj1.firstAttribute < obj2.firstAttribute) {
            return NSOrderedAscending;
        }
        
        return NSOrderedSame;
    }];
}

- (void)_handleClickItem:(PVDetailDashboardAttributeConstraintsItemControl *)control {
    PVAutoLayoutConstraint *constraint = control.constraint;
    PVDetailConstraintPopoverController *vc = [[PVDetailConstraintPopoverController alloc] initWithConstraint:constraint];
    
    NSPopover *popover = [[NSPopover alloc] init];
    popover.animates = NO;
    popover.behavior = NSPopoverBehaviorTransient;
    popover.contentSize = [vc contentSize];
    popover.contentViewController = vc;
    @weakify(popover);
    vc.requestJumpingToObject = ^(PVObject *pickviewObj) {
        @strongify(popover);
        [popover close];
        
        PVDetailHierarchyDataSource *dataSource = [self.dashboardViewController currentDataSource];
        PVDisplayItem *item = [dataSource displayItemWithOid:pickviewObj.oid];
        // 注意这里要先 expand 然后再 select 以使得可以滚动到目标位置
        if (!item.displayingInHierarchy) {
            [dataSource expandToShowItem:item];
        }
        dataSource.selectedItem = item;
    };
    [popover showRelativeToRect:NSMakeRect(0, 0, control.bounds.size.width, control.bounds.size.height) ofView:control preferredEdge:NSRectEdgeMaxX];
}

@end

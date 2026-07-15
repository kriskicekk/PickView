//
//  PVDetailDashboardSearchPropView.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailDashboardSearchPropView.h"
#import "PVDashboardBlueprint.h"
#import "PVAttribute.h"
#import "PVDetailPreferenceManager.h"
#import "PVDetailEnumListRegistry.h"

@interface PVDetailDashboardSearchPropView ()

@property(nonatomic, strong) PVDetailLabel *titleLabel;
@property(nonatomic, strong) PVDetailLabel *contentLabel;
@property(nonatomic, strong) PVDetailTextControl *revealControl;

@property(nonatomic, strong) PVAttribute *attribute;

@end

@implementation PVDetailDashboardSearchPropView {
    CGFloat _contentLabelY;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        _contentLabelY = 21;
        
        self.titleLabel = [PVDetailLabel new];
        self.titleLabel.font = NSFontMake(12);
        self.titleLabel.textColor = [NSColor secondaryLabelColor];
        [self addSubview:self.titleLabel];
    
        self.contentLabel = [PVDetailLabel new];
        self.contentLabel.font = NSFontMake(15);
        [self addSubview:self.contentLabel];
        
        self.revealControl = [PVDetailTextControl new];
        [self.revealControl addTarget:self clickAction:@selector(_handleRevealButton)];
        self.revealControl.adjustAlphaWhenClick = YES;
        [self addSubview:self.revealControl];
        
        [self updateColors];
    }
    return self;
}

- (void)layout {
    [super layout];
    
    CGFloat width = self.$width - DashboardSearchCardInset * 2;
    
    $(self.titleLabel).x(DashboardSearchCardInset).width(width).heightToFit.y(5);
    $(self.contentLabel).x(DashboardSearchCardInset).width(width).heightToFit.y(_contentLabelY);
    $(self.revealControl).sizeToFit.x(DashboardSearchCardInset).bottom(DashboardSearchCardInset);
}

- (NSSize)sizeThatFits:(NSSize)limitedSize {
    CGFloat width = limitedSize.width - DashboardSearchCardInset * 2;
    CGFloat height = _contentLabelY;
    height += [self.contentLabel heightForWidth:width] + DashboardSearchCardInset + 25;
    limitedSize.height = height;
    return limitedSize;
}

- (void)updateColors {
    [super updateColors];
    self.contentLabel.textColor = self.isDarkMode ? PVColorMake(250, 251, 252) : PVColorMake(56, 57, 58);
    
    NSString *text = NSLocalizedString(@"Reveal in panel…", nil);
    self.revealControl.label.attributedStringValue = $(text).textColor(self.isDarkMode ? @"245, 166, 30" : @"229, 135, 67").font(@11).addImage(@"icon_arrowRight_orange", 0, 2, 0).attrString;
}

- (void)renderWithAttribute:(PVAttribute *)attribute {
    self.attribute = attribute;
    self.titleLabel.stringValue = attribute.displayTitle ? : [PVDashboardBlueprint fullTitleWithAttrID:attribute.identifier];
    self.contentLabel.stringValue = [self _stringValueFromAttribute:attribute];
    [self setNeedsLayout:YES];
}

- (void)_handleRevealButton {
    if ([self.delegate respondsToSelector:@selector(dashboardSearchPropView:didClickRevealAttribute:)]) {
        [self.delegate dashboardSearchPropView:self didClickRevealAttribute:self.attribute];
    }
}

- (NSString *)_stringValueFromAttribute:(PVAttribute *)attribute {
    switch (attribute.attrType) {
        case PVAttrTypeNone:
        case PVAttrTypeVoid:
        case PVAttrTypeCustomObj:
            NSAssert(NO, @"");
            return @"";
            
        case PVAttrTypeChar:
        case PVAttrTypeInt:
        case PVAttrTypeShort:
        case PVAttrTypeLong:
        case PVAttrTypeLongLong:
        case PVAttrTypeUnsignedChar:
        case PVAttrTypeUnsignedInt:
        case PVAttrTypeUnsignedShort:
        case PVAttrTypeUnsignedLong:
        case PVAttrTypeUnsignedLongLong:
        case PVAttrTypeFloat:
        case PVAttrTypeDouble:
        case PVAttrTypeSel:
        case PVAttrTypeClass:
        case PVAttrTypeCGVector:
        case PVAttrTypeCGAffineTransform:
        case PVAttrTypeUIOffset:
            return [attribute.value description];
            
        case PVAttrTypeBOOL: {
            BOOL boolValue = [(NSNumber *)attribute.value boolValue];
            return boolValue ? @"YES" : @"NO";
        }
            
        case PVAttrTypeCGPoint:
            return [NSString pv_inspect_stringFromPoint:[(NSValue *)attribute.value pointValue]];
        case PVAttrTypeCGSize:
            return [NSString pv_inspect_stringFromSize:[(NSValue *)attribute.value sizeValue]];
        case PVAttrTypeCGRect:
            return [NSString pv_inspect_stringFromRect:[(NSValue *)attribute.value rectValue]];
        case PVAttrTypeUIEdgeInsets:
            return [NSString pv_inspect_stringFromInset:[(NSValue *)attribute.value edgeInsetsValue]];
            
        case PVAttrTypeNSString:
        case PVAttrTypeEnumString:
            return attribute.value;
            
        case PVAttrTypeEnumInt:
        case PVAttrTypeEnumLong: {
            NSInteger enumValue = [attribute.value integerValue];
            NSString *enumListName = [PVDashboardBlueprint enumListNameWithAttrID:attribute.identifier];
            NSString *enumString = [[PVDetailEnumListRegistry sharedInstance] descForEnumName:enumListName value:enumValue];
            return enumString;
        }

        case PVAttrTypeUIColor: {
            NSColor *color = [NSColor lk_colorFromRGBAComponents:attribute.value];
            if (color) {
                return [PVDetailPreferenceManager mainManager].rgbaFormat ? color.rgbaString : color.hexString;
            } else {
                return @"nil";
            }
        }
        case PVAttrTypeShadow:
        case PVAttrTypeJson:
            return @"……";
    }
    
    NSAssert(NO, @"");
    return @"";
}

@end

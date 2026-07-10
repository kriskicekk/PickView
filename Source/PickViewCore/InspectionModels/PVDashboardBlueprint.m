//
//  PVDashboardBlueprint.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDashboardBlueprint.h"

@implementation PVDashboardBlueprint

+ (NSArray<PVAttrGroupIdentifier> *)groupIDs {
    static NSArray<PVAttrGroupIdentifier> *array;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        array = @[
            PVAttrGroup_Class,
            PVAttrGroup_Relation,
            PVAttrGroup_Layout,
            PVAttrGroup_AutoLayout,
            PVAttrGroup_ViewLayer,
            PVAttrGroup_UIStackView,
            PVAttrGroup_UIVisualEffectView,
            PVAttrGroup_UIImageView,
            PVAttrGroup_UILabel,
            PVAttrGroup_UIControl,
            PVAttrGroup_UIButton,
            PVAttrGroup_UIScrollView,
            PVAttrGroup_UITableView,
            PVAttrGroup_UITextView,
            PVAttrGroup_UITextField
        ];
    });
    return array;
}

+ (NSArray<PVAttrSectionIdentifier> *)sectionIDsForGroupID:(PVAttrGroupIdentifier)groupID {
    static NSDictionary<PVAttrGroupIdentifier, NSArray<PVAttrSectionIdentifier> *> *dict;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        dict = @{
            PVAttrGroup_Class: @[PVAttrSec_Class_Class],
            
            PVAttrGroup_Relation: @[PVAttrSec_Relation_Relation],
            
            PVAttrGroup_Layout: @[PVAttrSec_Layout_Frame,
                                      PVAttrSec_Layout_Bounds,
                                      PVAttrSec_Layout_SafeArea,
                                      PVAttrSec_Layout_Position,
                                      PVAttrSec_Layout_AnchorPoint],
            
            PVAttrGroup_AutoLayout: @[PVAttrSec_AutoLayout_Constraints,
                                          PVAttrSec_AutoLayout_IntrinsicSize,
                                          PVAttrSec_AutoLayout_Hugging,
                                          PVAttrSec_AutoLayout_Resistance],
            
            PVAttrGroup_ViewLayer: @[
                PVAttrSec_ViewLayer_Visibility,
                PVAttrSec_ViewLayer_InterationAndMasks,
                PVAttrSec_ViewLayer_BgColor,
                PVAttrSec_ViewLayer_Border,
                PVAttrSec_ViewLayer_Corner,
                PVAttrSec_ViewLayer_Shadow,
                PVAttrSec_ViewLayer_ContentMode,
                PVAttrSec_ViewLayer_TintColor,
                PVAttrSec_ViewLayer_Tag
            ],
            
            PVAttrGroup_UIStackView: @[
                PVAttrSec_UIStackView_Axis,
                PVAttrSec_UIStackView_Distribution,
                PVAttrSec_UIStackView_Alignment,
                PVAttrSec_UIStackView_Spacing
            ],
            
            PVAttrGroup_UIVisualEffectView: @[
                PVAttrSec_UIVisualEffectView_Style,
                PVAttrSec_UIVisualEffectView_QMUIForegroundColor
            ],
            
            PVAttrGroup_UIImageView: @[PVAttrSec_UIImageView_Name,
                                           PVAttrSec_UIImageView_Open],
            
            PVAttrGroup_UILabel: @[
                PVAttrSec_UILabel_Text,
                PVAttrSec_UILabel_Font,
                PVAttrSec_UILabel_NumberOfLines,
                PVAttrSec_UILabel_TextColor,
                PVAttrSec_UILabel_BreakMode,
                PVAttrSec_UILabel_Alignment,
                PVAttrSec_UILabel_CanAdjustFont],
            
            PVAttrGroup_UIControl: @[PVAttrSec_UIControl_EnabledSelected,
                                         PVAttrSec_UIControl_QMUIOutsideEdge,
                                         PVAttrSec_UIControl_VerAlignment,
                                         PVAttrSec_UIControl_HorAlignment],
            
            PVAttrGroup_UIButton: @[PVAttrSec_UIButton_ContentInsets,
                                        PVAttrSec_UIButton_TitleInsets,
                                        PVAttrSec_UIButton_ImageInsets],
            
            PVAttrGroup_UIScrollView: @[PVAttrSec_UIScrollView_ContentInset,
                                            PVAttrSec_UIScrollView_AdjustedInset,
                                            PVAttrSec_UIScrollView_QMUIInitialInset,
                                            PVAttrSec_UIScrollView_IndicatorInset,
                                            PVAttrSec_UIScrollView_Offset,
                                            PVAttrSec_UIScrollView_ContentSize,
                                            PVAttrSec_UIScrollView_Behavior,
                                            PVAttrSec_UIScrollView_ShowsIndicator,
                                            PVAttrSec_UIScrollView_Bounce,
                                            PVAttrSec_UIScrollView_ScrollPaging,
                                            PVAttrSec_UIScrollView_ContentTouches,
                                            PVAttrSec_UIScrollView_Zoom],
            
            PVAttrGroup_UITableView: @[PVAttrSec_UITableView_Style,
                                           PVAttrSec_UITableView_SectionsNumber,
                                           PVAttrSec_UITableView_RowsNumber,
                                           PVAttrSec_UITableView_SeparatorStyle,
                                           PVAttrSec_UITableView_SeparatorColor,
                                           PVAttrSec_UITableView_SeparatorInset],
            
            PVAttrGroup_UITextView: @[PVAttrSec_UITextView_Basic,
                                          PVAttrSec_UITextView_Text,
                                          PVAttrSec_UITextView_Font,
                                          PVAttrSec_UITextView_TextColor,
                                          PVAttrSec_UITextView_Alignment,
                                          PVAttrSec_UITextView_ContainerInset],
            
            PVAttrGroup_UITextField: @[PVAttrSec_UITextField_Text,
                                           PVAttrSec_UITextField_Placeholder,
                                           PVAttrSec_UITextField_Font,
                                           PVAttrSec_UITextField_TextColor,
                                           PVAttrSec_UITextField_Alignment,
                                           PVAttrSec_UITextField_Clears,
                                           PVAttrSec_UITextField_CanAdjustFont,
                                           PVAttrSec_UITextField_ClearButtonMode],
            
        };
    });
    return dict[groupID];
}

+ (NSArray<PVAttrIdentifier> *)attrIDsForSectionID:(PVAttrSectionIdentifier)sectionID {
    static NSDictionary<PVAttrSectionIdentifier, NSArray<PVAttrIdentifier> *> *dict;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        dict = @{
            PVAttrSec_Class_Class: @[PVAttr_Class_Class_Class],
            
            PVAttrSec_Relation_Relation: @[PVAttr_Relation_Relation_Relation],
            
            PVAttrSec_Layout_Frame: @[PVAttr_Layout_Frame_Frame],
            PVAttrSec_Layout_Bounds: @[PVAttr_Layout_Bounds_Bounds],
            PVAttrSec_Layout_SafeArea: @[PVAttr_Layout_SafeArea_SafeArea],
            PVAttrSec_Layout_Position: @[PVAttr_Layout_Position_Position],
            PVAttrSec_Layout_AnchorPoint: @[PVAttr_Layout_AnchorPoint_AnchorPoint],
            
            PVAttrSec_AutoLayout_Hugging: @[PVAttr_AutoLayout_Hugging_Hor,
                                                PVAttr_AutoLayout_Hugging_Ver],
            PVAttrSec_AutoLayout_Resistance: @[PVAttr_AutoLayout_Resistance_Hor,
                                                   PVAttr_AutoLayout_Resistance_Ver],
            PVAttrSec_AutoLayout_Constraints: @[PVAttr_AutoLayout_Constraints_Constraints],
            PVAttrSec_AutoLayout_IntrinsicSize: @[PVAttr_AutoLayout_IntrinsicSize_Size],
            
            PVAttrSec_ViewLayer_Visibility: @[PVAttr_ViewLayer_Visibility_Hidden,
                                                  PVAttr_ViewLayer_Visibility_Opacity],
            
            PVAttrSec_ViewLayer_InterationAndMasks: @[PVAttr_ViewLayer_InterationAndMasks_Interaction,
                                                          PVAttr_ViewLayer_InterationAndMasks_MasksToBounds],
            
            PVAttrSec_ViewLayer_Corner: @[PVAttr_ViewLayer_Corner_Radius],
            
            PVAttrSec_ViewLayer_BgColor: @[PVAttr_ViewLayer_BgColor_BgColor],
            
            PVAttrSec_ViewLayer_Border: @[PVAttr_ViewLayer_Border_Color,
                                              PVAttr_ViewLayer_Border_Width],
            
            PVAttrSec_ViewLayer_Shadow: @[PVAttr_ViewLayer_Shadow_Color,
                                              PVAttr_ViewLayer_Shadow_Opacity,
                                              PVAttr_ViewLayer_Shadow_Radius,
                                              PVAttr_ViewLayer_Shadow_OffsetW,
                                              PVAttr_ViewLayer_Shadow_OffsetH],
            
            PVAttrSec_ViewLayer_ContentMode: @[PVAttr_ViewLayer_ContentMode_Mode],
            
            PVAttrSec_ViewLayer_TintColor: @[PVAttr_ViewLayer_TintColor_Color,
                                                 PVAttr_ViewLayer_TintColor_Mode],
            
            PVAttrSec_ViewLayer_Tag: @[PVAttr_ViewLayer_Tag_Tag],
            
            PVAttrSec_UIStackView_Axis: @[PVAttr_UIStackView_Axis_Axis],
            
            PVAttrSec_UIStackView_Distribution: @[PVAttr_UIStackView_Distribution_Distribution],
            
            PVAttrSec_UIStackView_Alignment: @[PVAttr_UIStackView_Alignment_Alignment],
            
            PVAttrSec_UIStackView_Spacing: @[PVAttr_UIStackView_Spacing_Spacing],
            
            PVAttrSec_UIVisualEffectView_Style: @[PVAttr_UIVisualEffectView_Style_Style],
            
            PVAttrSec_UIVisualEffectView_QMUIForegroundColor: @[PVAttr_UIVisualEffectView_QMUIForegroundColor_Color],
            
            PVAttrSec_UIImageView_Name: @[PVAttr_UIImageView_Name_Name],
            
            PVAttrSec_UIImageView_Open: @[PVAttr_UIImageView_Open_Open],
            
            PVAttrSec_UILabel_Font: @[PVAttr_UILabel_Font_Name,
                                          PVAttr_UILabel_Font_Size],
            
            PVAttrSec_UILabel_NumberOfLines: @[PVAttr_UILabel_NumberOfLines_NumberOfLines],
            
            PVAttrSec_UILabel_Text: @[PVAttr_UILabel_Text_Text],
            
            PVAttrSec_UILabel_TextColor: @[PVAttr_UILabel_TextColor_Color],
            
            PVAttrSec_UILabel_BreakMode: @[PVAttr_UILabel_BreakMode_Mode],
            
            PVAttrSec_UILabel_Alignment: @[PVAttr_UILabel_Alignment_Alignment],
            
            PVAttrSec_UILabel_CanAdjustFont: @[PVAttr_UILabel_CanAdjustFont_CanAdjustFont],
            
            PVAttrSec_UIControl_EnabledSelected: @[PVAttr_UIControl_EnabledSelected_Enabled,
                                                       PVAttr_UIControl_EnabledSelected_Selected],
            
            PVAttrSec_UIControl_QMUIOutsideEdge: @[PVAttr_UIControl_QMUIOutsideEdge_Edge],
            
            PVAttrSec_UIControl_VerAlignment: @[PVAttr_UIControl_VerAlignment_Alignment],
            
            PVAttrSec_UIControl_HorAlignment: @[PVAttr_UIControl_HorAlignment_Alignment],
            
            PVAttrSec_UIButton_ContentInsets: @[PVAttr_UIButton_ContentInsets_Insets],
            
            PVAttrSec_UIButton_TitleInsets: @[PVAttr_UIButton_TitleInsets_Insets],
            
            PVAttrSec_UIButton_ImageInsets: @[PVAttr_UIButton_ImageInsets_Insets],
            
            PVAttrSec_UIScrollView_ContentInset: @[PVAttr_UIScrollView_ContentInset_Inset],
            
            PVAttrSec_UIScrollView_AdjustedInset: @[PVAttr_UIScrollView_AdjustedInset_Inset],
            
            PVAttrSec_UIScrollView_QMUIInitialInset: @[PVAttr_UIScrollView_QMUIInitialInset_Inset],
            
            PVAttrSec_UIScrollView_IndicatorInset: @[PVAttr_UIScrollView_IndicatorInset_Inset],
            
            PVAttrSec_UIScrollView_Offset: @[PVAttr_UIScrollView_Offset_Offset],
            
            PVAttrSec_UIScrollView_ContentSize: @[PVAttr_UIScrollView_ContentSize_Size],
            
            PVAttrSec_UIScrollView_Behavior: @[PVAttr_UIScrollView_Behavior_Behavior],
            
            PVAttrSec_UIScrollView_ShowsIndicator: @[PVAttr_UIScrollView_ShowsIndicator_Hor,
                                                         PVAttr_UIScrollView_ShowsIndicator_Ver],
            
            PVAttrSec_UIScrollView_Bounce: @[PVAttr_UIScrollView_Bounce_Hor,
                                                 PVAttr_UIScrollView_Bounce_Ver],
            
            PVAttrSec_UIScrollView_ScrollPaging: @[PVAttr_UIScrollView_ScrollPaging_ScrollEnabled,
                                                       PVAttr_UIScrollView_ScrollPaging_PagingEnabled],
            
            PVAttrSec_UIScrollView_ContentTouches: @[PVAttr_UIScrollView_ContentTouches_Delay,
                                                         PVAttr_UIScrollView_ContentTouches_CanCancel],
            
            PVAttrSec_UIScrollView_Zoom: @[PVAttr_UIScrollView_Zoom_Bounce,
                                               PVAttr_UIScrollView_Zoom_Scale,
                                               PVAttr_UIScrollView_Zoom_MinScale,
                                               PVAttr_UIScrollView_Zoom_MaxScale],
            
            PVAttrSec_UITableView_Style: @[PVAttr_UITableView_Style_Style],
            
            PVAttrSec_UITableView_SectionsNumber: @[PVAttr_UITableView_SectionsNumber_Number],
            
            PVAttrSec_UITableView_RowsNumber: @[PVAttr_UITableView_RowsNumber_Number],
            
            PVAttrSec_UITableView_SeparatorInset: @[PVAttr_UITableView_SeparatorInset_Inset],
            
            PVAttrSec_UITableView_SeparatorColor: @[PVAttr_UITableView_SeparatorColor_Color],
            
            PVAttrSec_UITableView_SeparatorStyle: @[PVAttr_UITableView_SeparatorStyle_Style],
            
            PVAttrSec_UITextView_Basic: @[PVAttr_UITextView_Basic_Editable,
                                              PVAttr_UITextView_Basic_Selectable],
            
            PVAttrSec_UITextView_Text: @[PVAttr_UITextView_Text_Text],
            
            PVAttrSec_UITextView_Font: @[PVAttr_UITextView_Font_Name,
                                             PVAttr_UITextView_Font_Size],
            
            PVAttrSec_UITextView_TextColor: @[PVAttr_UITextView_TextColor_Color],
            
            PVAttrSec_UITextView_Alignment: @[PVAttr_UITextView_Alignment_Alignment],
            
            PVAttrSec_UITextView_ContainerInset: @[PVAttr_UITextView_ContainerInset_Inset],
            
            PVAttrSec_UITextField_Text: @[PVAttr_UITextField_Text_Text],
            
            PVAttrSec_UITextField_Placeholder: @[PVAttr_UITextField_Placeholder_Placeholder],
            
            PVAttrSec_UITextField_Font: @[PVAttr_UITextField_Font_Name,
                                              PVAttr_UITextField_Font_Size],
            
            PVAttrSec_UITextField_TextColor: @[PVAttr_UITextField_TextColor_Color],
            
            PVAttrSec_UITextField_Alignment: @[PVAttr_UITextField_Alignment_Alignment],
            
            PVAttrSec_UITextField_Clears: @[PVAttr_UITextField_Clears_ClearsOnBeginEditing,
                                                PVAttr_UITextField_Clears_ClearsOnInsertion],
            
            PVAttrSec_UITextField_CanAdjustFont: @[PVAttr_UITextField_CanAdjustFont_CanAdjustFont,
                                                       PVAttr_UITextField_CanAdjustFont_MinSize],
            
            PVAttrSec_UITextField_ClearButtonMode: @[PVAttr_UITextField_ClearButtonMode_Mode]
        };
    });
    return dict[sectionID];
}

+ (void)getHostGroupID:(inout PVAttrGroupIdentifier *)groupID_inout sectionID:(inout PVAttrSectionIdentifier *)sectionID_inout fromAttrID:(PVAttrIdentifier)targetAttrID {
    __block PVAttrGroupIdentifier targetGroupID = nil;
    __block PVAttrSectionIdentifier targetSecID = nil;
    [[self groupIDs] enumerateObjectsUsingBlock:^(PVAttrGroupIdentifier _Nonnull groupID, NSUInteger idx, BOOL * _Nonnull stop0) {
        [[self sectionIDsForGroupID:groupID] enumerateObjectsUsingBlock:^(PVAttrSectionIdentifier _Nonnull secID, NSUInteger idx, BOOL * _Nonnull stop1) {
            [[self attrIDsForSectionID:secID] enumerateObjectsUsingBlock:^(PVAttrIdentifier _Nonnull attrID, NSUInteger idx, BOOL * _Nonnull stop2) {
                if ([attrID isEqualToString:targetAttrID]) {
                    targetGroupID = groupID;
                    targetSecID = secID;
                    *stop0 = YES;
                    *stop1 = YES;
                    *stop2 = YES;
                }
            }];
        }];
    }];
    
    if (groupID_inout && targetGroupID) {
        *groupID_inout = targetGroupID;
    }
    if (sectionID_inout && targetSecID) {
        *sectionID_inout = targetSecID;
    }
}

+ (NSString *)groupTitleWithGroupID:(PVAttrGroupIdentifier)groupID {
    static dispatch_once_t onceToken;
    static NSDictionary *rawInfo = nil;
    dispatch_once(&onceToken,^{
        rawInfo = @{
            PVAttrGroup_Class: @"Class",
            PVAttrGroup_Relation: @"Relation",
            PVAttrGroup_Layout: @"Layout",
            PVAttrGroup_AutoLayout: @"AutoLayout",
            PVAttrGroup_ViewLayer: @"CALayer / UIView",
            PVAttrGroup_UIImageView: @"UIImageView",
            PVAttrGroup_UILabel: @"UILabel",
            PVAttrGroup_UIControl: @"UIControl",
            PVAttrGroup_UIButton: @"UIButton",
            PVAttrGroup_UIScrollView: @"UIScrollView",
            PVAttrGroup_UITableView: @"UITableView",
            PVAttrGroup_UITextView: @"UITextView",
            PVAttrGroup_UITextField: @"UITextField",
            PVAttrGroup_UIVisualEffectView: @"UIVisualEffectView",
            PVAttrGroup_UIStackView: @"UIStackView"
        };
    });
    NSString *title = rawInfo[groupID];
    NSAssert(title.length, @"");
    return title;
}

+ (NSString *)sectionTitleWithSectionID:(PVAttrSectionIdentifier)secID {
    static dispatch_once_t onceToken;
    static NSDictionary *rawInfo = nil;
    dispatch_once(&onceToken,^{
        rawInfo = @{
            PVAttrSec_Layout_Frame: @"Frame",
            PVAttrSec_Layout_Bounds: @"Bounds",
            PVAttrSec_Layout_SafeArea: @"SafeArea",
            PVAttrSec_Layout_Position: @"Position",
            PVAttrSec_Layout_AnchorPoint: @"AnchorPoint",
            PVAttrSec_AutoLayout_Hugging: @"HuggingPriority",
            PVAttrSec_AutoLayout_Resistance: @"ResistancePriority",
            PVAttrSec_AutoLayout_IntrinsicSize: @"IntrinsicSize",
            PVAttrSec_ViewLayer_Corner: @"CornerRadius",
            PVAttrSec_ViewLayer_BgColor: @"BackgroundColor",
            PVAttrSec_ViewLayer_Border: @"Border",
            PVAttrSec_ViewLayer_Shadow: @"Shadow",
            PVAttrSec_ViewLayer_ContentMode: @"ContentMode",
            PVAttrSec_ViewLayer_TintColor: @"TintColor",
            PVAttrSec_ViewLayer_Tag: @"Tag",
            PVAttrSec_UIStackView_Axis: @"Axis",
            PVAttrSec_UIStackView_Distribution: @"Distribution",
            PVAttrSec_UIStackView_Alignment: @"Alignment",
            PVAttrSec_UIVisualEffectView_Style: @"Style",
            PVAttrSec_UIVisualEffectView_QMUIForegroundColor: @"ForegroundColor",
            PVAttrSec_UIImageView_Name: @"ImageName",
            PVAttrSec_UILabel_TextColor: @"TextColor",
            PVAttrSec_UITextView_TextColor: @"TextColor",
            PVAttrSec_UITextField_TextColor: @"TextColor",
            PVAttrSec_UILabel_BreakMode: @"LineBreakMode",
            PVAttrSec_UILabel_NumberOfLines: @"NumberOfLines",
            PVAttrSec_UILabel_Text: @"Text",
            PVAttrSec_UITextView_Text: @"Text",
            PVAttrSec_UITextField_Text: @"Text",
            PVAttrSec_UITextField_Placeholder: @"Placeholder",
            PVAttrSec_UILabel_Alignment: @"TextAlignment",
            PVAttrSec_UITextView_Alignment: @"TextAlignment",
            PVAttrSec_UITextField_Alignment: @"TextAlignment",
            PVAttrSec_UIControl_HorAlignment: @"HorizontalAlignment",
            PVAttrSec_UIControl_VerAlignment: @"VerticalAlignment",
            PVAttrSec_UIControl_QMUIOutsideEdge: @"QMUI_outsideEdge",
            PVAttrSec_UIButton_ContentInsets: @"ContentInsets",
            PVAttrSec_UIButton_TitleInsets: @"TitleInsets",
            PVAttrSec_UIButton_ImageInsets: @"ImageInsets",
            PVAttrSec_UIScrollView_QMUIInitialInset: @"QMUI_initialContentInset",
            PVAttrSec_UIScrollView_ContentInset: @"ContentInset",
            PVAttrSec_UIScrollView_AdjustedInset: @"AdjustedContentInset",
            PVAttrSec_UIScrollView_IndicatorInset: @"ScrollIndicatorInsets",
            PVAttrSec_UIScrollView_Offset: @"ContentOffset",
            PVAttrSec_UIScrollView_ContentSize: @"ContentSize",
            PVAttrSec_UIScrollView_Behavior: @"InsetAdjustmentBehavior",
            PVAttrSec_UIScrollView_ShowsIndicator: @"ShowsScrollIndicator",
            PVAttrSec_UIScrollView_Bounce: @"AlwaysBounce",
            PVAttrSec_UIScrollView_Zoom: @"Zoom",
            PVAttrSec_UITableView_Style: @"Style",
            PVAttrSec_UITableView_SectionsNumber: @"NumberOfSections",
            PVAttrSec_UITableView_RowsNumber: @"NumberOfRows",
            PVAttrSec_UITableView_SeparatorColor: @"SeparatorColor",
            PVAttrSec_UITableView_SeparatorInset: @"SeparatorInset",
            PVAttrSec_UITableView_SeparatorStyle: @"SeparatorStyle",
            PVAttrSec_UILabel_Font: @"Font",
            PVAttrSec_UITextField_Font: @"Font",
            PVAttrSec_UITextView_Font: @"Font",
            PVAttrSec_UITextView_ContainerInset: @"ContainerInset",
            PVAttrSec_UITextField_ClearButtonMode: @"ClearButtonMode",
        };
    });
    return rawInfo[secID];
}

/**
 className: 必填项，标识该属性是哪一个类拥有的
 
 fullTitle: 完整的名字，将作为搜索的 keywords，也会展示在搜索结果中，如果为 nil 则不会被搜索到
 
 briefTitle：简略的名字，仅 checkbox 和那种自带标题的 input 才需要这个属性，如果需要该属性但该属性又为空，则会读取 fullTitle
 
 setterString：用户试图修改属性值时会用到，若该字段为空字符串（即 @“”）则该属性不可修改，若该字段为 nil 则会在 fullTitle 的基础上自动生成（自动改首字母大小写、加前缀后缀，比如 alpha 会被转换为 setAlpha:）
 
 getterString：必填项，业务中读取属性值时会用到。如果该字段为 nil ，则会在 fullTitle 的基础上自动生成（自动把 fullTitle 的第一个字母改成小写，比如 Alpha 会被转换为 alpha）。如果该字段为空字符串（比如 image_open_open）则属性值会被固定为 nil，attrType 会被指为 PVAttrTypeCustomObj
 
 typeIfObj：当某个 PVAttribute 确定是 NSObject 类型时，该方法返回它具体是什么对象，比如 UIColor、NSString
 
 enumList：如果某个 attribute 是 enum，则这里标识了相应的 enum 的名称（如 "NSTextAlignment"），业务可通过这个名称进而查询可用的枚举值列表
 
 patch：如果为 YES，则用户修改了该 Attribute 的值后，PickView 会重新拉取和更新相关图层的位置、截图等信息，如果为 nil 则默认是 NO
 
 hideIfNil：如果为 YES，则当获取的 value 为 nil 时，PickView 不会传输该 attr。如果为 NO，则即使 value 为 nil 也会传输（比如 label 的 text 属性，即使它是 nil 我们也要显示，所以它的 hideIfNil 应该为 NO）。如果该字段为 nil 则默认是 NO
 
 osVersion: 该属性需要的最低的 iOS 版本，比如 safeAreaInsets 从 iOS 11.0 开始出现，则该属性应该为 @11，如果为 nil 则表示不限制 iOS 版本
 
 */
+ (NSDictionary<NSString *, id> *)_infoForAttrID:(PVAttrIdentifier)attrID {
    static NSDictionary<PVAttrIdentifier, NSDictionary<NSString *, id> *> *dict;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        dict = @{
            PVAttr_Class_Class_Class: @{
                @"className": @"CALayer",
                @"getterString": @"pv_lks_relatedClassChainList",
                @"setterString": @"",
                @"typeIfObj": @(PVAttrTypeCustomObj)
            },
            
            PVAttr_Relation_Relation_Relation: @{
                @"className": @"CALayer",
                @"getterString": @"pv_lks_selfRelation",
                @"setterString": @"",
                @"typeIfObj": @(PVAttrTypeCustomObj),
                @"hideIfNil": @(YES)
            },
            
            PVAttr_Layout_Frame_Frame: @{
                @"className": @"CALayer",
                @"fullTitle": @"Frame",
                @"patch": @(YES)
            },
            PVAttr_Layout_Bounds_Bounds: @{
                @"className": @"CALayer",
                @"fullTitle": @"Bounds",
                @"patch": @(YES)
            },
            PVAttr_Layout_SafeArea_SafeArea: @{
                @"className": @"UIView",
                @"fullTitle": @"SafeAreaInsets",
                @"setterString": @"",
                @"osVersion": @(11)
            },
            PVAttr_Layout_Position_Position: @{
                @"className": @"CALayer",
                @"fullTitle": @"Position",
                @"patch": @(YES)
            },
            PVAttr_Layout_AnchorPoint_AnchorPoint: @{
                @"className": @"CALayer",
                @"fullTitle": @"AnchorPoint",
                @"patch": @(YES)
            },
            
            PVAttr_AutoLayout_Hugging_Hor: @{
                @"className": @"UIView",
                @"fullTitle": @"ContentHuggingPriority(Horizontal)",
                @"getterString": @"pv_lks_horizontalContentHuggingPriority",
                @"setterString": @"setLks_horizontalContentHuggingPriority:",
                @"briefTitle": @"H",
                @"patch": @(YES)
            },
            PVAttr_AutoLayout_Hugging_Ver: @{
                @"className": @"UIView",
                @"fullTitle": @"ContentHuggingPriority(Vertical)",
                @"getterString": @"pv_lks_verticalContentHuggingPriority",
                @"setterString": @"setLks_verticalContentHuggingPriority:",
                @"briefTitle": @"V",
                @"patch": @(YES)
            },
            PVAttr_AutoLayout_Resistance_Hor: @{
                @"className": @"UIView",
                @"fullTitle": @"ContentCompressionResistancePriority(Horizontal)",
                @"getterString": @"pv_lks_horizontalContentCompressionResistancePriority",
                @"setterString": @"setLks_horizontalContentCompressionResistancePriority:",
                @"briefTitle": @"H",
                @"patch": @(YES)
            },
            PVAttr_AutoLayout_Resistance_Ver: @{
                @"className": @"UIView",
                @"fullTitle": @"ContentCompressionResistancePriority(Vertical)",
                @"getterString": @"pv_lks_verticalContentCompressionResistancePriority",
                @"setterString": @"setLks_verticalContentCompressionResistancePriority:",
                @"briefTitle": @"V",
                @"patch": @(YES)
            },
            PVAttr_AutoLayout_Constraints_Constraints: @{
                @"className": @"UIView",
                @"getterString": @"pv_lks_constraints",
                @"setterString": @"",
                @"typeIfObj": @(PVAttrTypeCustomObj),
                @"hideIfNil": @(YES)
            },
            PVAttr_AutoLayout_IntrinsicSize_Size: @{
                @"className": @"UIView",
                @"fullTitle": @"IntrinsicContentSize",
                @"setterString": @""
            },
            
            PVAttr_ViewLayer_Visibility_Hidden: @{
                @"className": @"CALayer",
                @"fullTitle": @"Hidden",
                @"getterString": @"isHidden",
                @"patch": @(YES)
            },
            PVAttr_ViewLayer_Visibility_Opacity: @{
                @"className": @"CALayer",
                @"fullTitle": @"Opacity / Alpha",
                @"setterString": @"setOpacity:",
                @"getterString": @"opacity",
                @"patch": @(YES)
            },
            PVAttr_ViewLayer_InterationAndMasks_Interaction: @{
                @"className": @"UIView",
                @"fullTitle": @"UserInteractionEnabled",
                @"getterString": @"isUserInteractionEnabled",
                @"patch": @(NO)
            },
            PVAttr_ViewLayer_InterationAndMasks_MasksToBounds: @{
                @"className": @"CALayer",
                @"fullTitle": @"MasksToBounds / ClipsToBounds",
                @"briefTitle": @"MasksToBounds",
                @"setterString": @"setMasksToBounds:",
                @"getterString": @"masksToBounds",
                @"patch": @(YES)
            },
            PVAttr_ViewLayer_Corner_Radius: @{
                @"className": @"CALayer",
                @"fullTitle": @"CornerRadius",
                @"briefTitle": @"",
                @"patch": @(YES)
            },
            PVAttr_ViewLayer_BgColor_BgColor: @{
                @"className": @"CALayer",
                @"fullTitle": @"BackgroundColor",
                @"setterString": @"setLks_backgroundColor:",
                @"getterString": @"pv_lks_backgroundColor",
                @"typeIfObj": @(PVAttrTypeUIColor),
                @"patch": @(YES)
            },
            PVAttr_ViewLayer_Border_Color: @{
                @"className": @"CALayer",
                @"fullTitle": @"BorderColor",
                @"setterString": @"setLks_borderColor:",
                @"getterString": @"pv_lks_borderColor",
                @"typeIfObj": @(PVAttrTypeUIColor),
                @"patch": @(YES)
            },
            PVAttr_ViewLayer_Border_Width: @{
                @"className": @"CALayer",
                @"fullTitle": @"BorderWidth",
                @"patch": @(YES)
            },
            PVAttr_ViewLayer_Shadow_Color: @{
                @"className": @"CALayer",
                @"fullTitle": @"ShadowColor",
                @"setterString": @"setLks_shadowColor:",
                @"getterString": @"pv_lks_shadowColor",
                @"typeIfObj": @(PVAttrTypeUIColor),
                @"patch": @(YES)
            },
            PVAttr_ViewLayer_Shadow_Opacity: @{
                @"className": @"CALayer",
                @"fullTitle": @"ShadowOpacity",
                @"briefTitle": @"Opacity",
                @"patch": @(YES)
            },
            PVAttr_ViewLayer_Shadow_Radius: @{
                @"className": @"CALayer",
                @"fullTitle": @"ShadowRadius",
                @"briefTitle": @"Radius",
                @"patch": @(YES)
            },
            PVAttr_ViewLayer_Shadow_OffsetW: @{
                @"className": @"CALayer",
                @"fullTitle": @"ShadowOffsetWidth",
                @"briefTitle": @"OffsetW",
                @"setterString": @"setLks_shadowOffsetWidth:",
                @"getterString": @"pv_lks_shadowOffsetWidth",
                @"patch": @(YES)
            },
            PVAttr_ViewLayer_Shadow_OffsetH: @{
                @"className": @"CALayer",
                @"fullTitle": @"ShadowOffsetHeight",
                @"briefTitle": @"OffsetH",
                @"setterString": @"setLks_shadowOffsetHeight:",
                @"getterString": @"pv_lks_shadowOffsetHeight",
                @"patch": @(YES)
            },
            PVAttr_ViewLayer_ContentMode_Mode: @{
                @"className": @"UIView",
                @"fullTitle": @"ContentMode",
                @"enumList": @"UIViewContentMode",
                @"patch": @(YES)
            },
            PVAttr_ViewLayer_TintColor_Color: @{
                @"className": @"UIView",
                @"fullTitle": @"TintColor",
                @"typeIfObj": @(PVAttrTypeUIColor),
                @"patch": @(YES)
            },
            PVAttr_ViewLayer_TintColor_Mode: @{
                @"className": @"UIView",
                @"fullTitle": @"TintAdjustmentMode",
                @"enumList": @"UIViewTintAdjustmentMode",
                @"patch": @(YES)
            },
            PVAttr_ViewLayer_Tag_Tag: @{
                @"className": @"UIView",
                @"fullTitle": @"Tag",
                @"briefTitle": @"",
                @"patch": @(NO)
            },
            
            PVAttr_UIStackView_Axis_Axis: @{
                @"className": @"UIStackView",
                @"fullTitle": @"Axis",
                @"enumList": @"UILayoutConstraintAxis",
                @"patch": @(YES)
            },
            
            PVAttr_UIStackView_Distribution_Distribution: @{
                @"className": @"UIStackView",
                @"fullTitle": @"Distribution",
                @"enumList": @"UIStackViewDistribution",
                @"patch": @(YES)
            },
            
            PVAttr_UIStackView_Alignment_Alignment: @{
                @"className": @"UIStackView",
                @"fullTitle": @"Alignment",
                @"enumList": @"UIStackViewAlignment",
                @"patch": @(YES)
            },
            
            PVAttr_UIStackView_Spacing_Spacing: @{
                @"className": @"UIStackView",
                @"fullTitle": @"Spacing",
                @"patch": @(YES)
            },
            
            PVAttr_UIVisualEffectView_Style_Style: @{
                @"className": @"UIVisualEffectView",
                @"setterString": @"setLks_blurEffectStyleNumber:",
                @"getterString": @"pv_lks_blurEffectStyleNumber",
                @"enumList": @"UIBlurEffectStyle",
                @"typeIfObj": @(PVAttrTypeCustomObj),
                @"patch": @(YES),
                @"hideIfNil": @(YES)
            },
            
            PVAttr_UIVisualEffectView_QMUIForegroundColor_Color: @{
                @"className": @"QMUIVisualEffectView",
                @"fullTitle": @"ForegroundColor",
                @"typeIfObj": @(PVAttrTypeUIColor),
                @"patch": @(YES),
            },
            
            PVAttr_UIImageView_Name_Name: @{
                @"className": @"UIImageView",
                @"fullTitle": @"ImageName",
                @"setterString": @"",
                @"getterString": @"pv_lks_imageSourceName",
                @"typeIfObj": @(PVAttrTypeNSString),
                @"hideIfNil": @(YES)
            },
            PVAttr_UIImageView_Open_Open: @{
                @"className": @"UIImageView",
                @"setterString": @"",
                @"getterString": @"pv_lks_imageViewOidIfHasImage",
                @"typeIfObj": @(PVAttrTypeCustomObj),
                @"hideIfNil": @(YES)
            },
            
            PVAttr_UILabel_Text_Text: @{
                @"className": @"UILabel",
                @"fullTitle": @"Text",
                @"typeIfObj": @(PVAttrTypeNSString),
                @"patch": @(YES)
            },
            PVAttr_UILabel_NumberOfLines_NumberOfLines: @{
                @"className": @"UILabel",
                @"fullTitle": @"NumberOfLines",
                @"briefTitle": @"",
                @"patch": @(YES)
            },
            PVAttr_UILabel_Font_Size: @{
                @"className": @"UILabel",
                @"fullTitle": @"FontSize",
                @"briefTitle": @"FontSize",
                @"setterString": @"setLks_fontSize:",
                @"getterString": @"pv_lks_fontSize",
                @"patch": @(YES)
            },
            PVAttr_UILabel_Font_Name: @{
                @"className": @"UILabel",
                @"fullTitle": @"FontName",
                @"setterString": @"",
                @"getterString": @"pv_lks_fontName",
                @"typeIfObj": @(PVAttrTypeNSString),
                @"patch": @(NO)
            },
            PVAttr_UILabel_TextColor_Color: @{
                @"className": @"UILabel",
                @"fullTitle": @"TextColor",
                @"typeIfObj": @(PVAttrTypeUIColor),
                @"patch": @(YES)
            },
            PVAttr_UILabel_Alignment_Alignment: @{
                @"className": @"UILabel",
                @"fullTitle": @"TextAlignment",
                @"enumList": @"NSTextAlignment",
                @"patch": @(YES)
            },
            PVAttr_UILabel_BreakMode_Mode: @{
                @"className": @"UILabel",
                @"fullTitle": @"LineBreakMode",
                @"enumList": @"NSLineBreakMode",
                @"patch": @(YES)
            },
            PVAttr_UILabel_CanAdjustFont_CanAdjustFont: @{
                @"className": @"UILabel",
                @"fullTitle": @"AdjustsFontSizeToFitWidth",
                @"patch": @(YES)
            },
            
            PVAttr_UIControl_EnabledSelected_Enabled: @{
                @"className": @"UIControl",
                @"fullTitle": @"Enabled",
                @"getterString": @"isEnabled",
                @"patch": @(NO)
            },
            PVAttr_UIControl_EnabledSelected_Selected: @{
                @"className": @"UIControl",
                @"fullTitle": @"Selected",
                @"getterString": @"isSelected",
                @"patch": @(YES)
            },
            PVAttr_UIControl_VerAlignment_Alignment: @{
                @"className": @"UIControl",
                @"fullTitle": @"ContentVerticalAlignment",
                @"enumList": @"UIControlContentVerticalAlignment",
                @"patch": @(YES)
            },
            PVAttr_UIControl_HorAlignment_Alignment: @{
                @"className": @"UIControl",
                @"fullTitle": @"ContentHorizontalAlignment",
                @"enumList": @"UIControlContentHorizontalAlignment",
                @"patch": @(YES)
            },
            PVAttr_UIControl_QMUIOutsideEdge_Edge: @{
                @"className": @"UIControl",
                @"fullTitle": @"qmui_outsideEdge"
            },
            
            PVAttr_UIButton_ContentInsets_Insets: @{
                @"className": @"UIButton",
                @"fullTitle": @"ContentEdgeInsets",
                @"patch": @(YES)
            },
            PVAttr_UIButton_TitleInsets_Insets: @{
                @"className": @"UIButton",
                @"fullTitle": @"TitleEdgeInsets",
                @"patch": @(YES)
            },
            PVAttr_UIButton_ImageInsets_Insets: @{
                @"className": @"UIButton",
                @"fullTitle": @"ImageEdgeInsets",
                @"patch": @(YES)
            },
            
            PVAttr_UIScrollView_Offset_Offset: @{
                @"className": @"UIScrollView",
                @"fullTitle": @"ContentOffset",
                @"patch": @(YES)
            },
            PVAttr_UIScrollView_ContentSize_Size: @{
                @"className": @"UIScrollView",
                @"fullTitle": @"ContentSize",
                @"patch": @(YES)
            },
            PVAttr_UIScrollView_ContentInset_Inset: @{
                @"className": @"UIScrollView",
                @"fullTitle": @"ContentInset",
                @"patch": @(YES)
            },
            PVAttr_UIScrollView_QMUIInitialInset_Inset: @{
                @"className": @"UIScrollView",
                @"fullTitle": @"qmui_initialContentInset",
                @"patch": @(YES)
            },
            PVAttr_UIScrollView_AdjustedInset_Inset: @{
                @"className": @"UIScrollView",
                @"fullTitle": @"AdjustedContentInset",
                @"setterString": @"",
                @"osVersion": @(11)
            },
            PVAttr_UIScrollView_Behavior_Behavior: @{
                @"className": @"UIScrollView",
                @"fullTitle": @"ContentInsetAdjustmentBehavior",
                @"enumList": @"UIScrollViewContentInsetAdjustmentBehavior",
                @"patch": @(YES),
                @"osVersion": @(11)
            },
            PVAttr_UIScrollView_IndicatorInset_Inset: @{
                @"className": @"UIScrollView",
                @"fullTitle": @"ScrollIndicatorInsets",
                @"patch": @(NO)
            },
            PVAttr_UIScrollView_ScrollPaging_ScrollEnabled: @{
                @"className": @"UIScrollView",
                @"fullTitle": @"ScrollEnabled",
                @"getterString": @"isScrollEnabled",
                @"patch": @(NO)
            },
            PVAttr_UIScrollView_ScrollPaging_PagingEnabled: @{
                @"className": @"UIScrollView",
                @"fullTitle": @"PagingEnabled",
                @"getterString": @"isPagingEnabled",
                @"patch": @(NO)
            },
            PVAttr_UIScrollView_Bounce_Ver: @{
                @"className": @"UIScrollView",
                @"fullTitle": @"AlwaysBounceVertical",
                @"briefTitle": @"Vertical",
                @"patch": @(NO)
            },
            PVAttr_UIScrollView_Bounce_Hor: @{
                @"className": @"UIScrollView",
                @"fullTitle": @"AlwaysBounceHorizontal",
                @"briefTitle": @"Horizontal",
                @"patch": @(NO)
            },
            PVAttr_UIScrollView_ShowsIndicator_Hor: @{
                @"className": @"UIScrollView",
                @"fullTitle": @"ShowsHorizontalScrollIndicator",
                @"briefTitle": @"Horizontal",
                @"patch": @(NO)
            },
            PVAttr_UIScrollView_ShowsIndicator_Ver: @{
                @"className": @"UIScrollView",
                @"fullTitle": @"ShowsVerticalScrollIndicator",
                @"briefTitle": @"Vertical",
                @"patch": @(NO)
            },
            PVAttr_UIScrollView_ContentTouches_Delay: @{
                @"className": @"UIScrollView",
                @"fullTitle": @"DelaysContentTouches",
                @"patch": @(NO)
            },
            PVAttr_UIScrollView_ContentTouches_CanCancel: @{
                @"className": @"UIScrollView",
                @"fullTitle": @"CanCancelContentTouches",
                @"patch": @(NO)
            },
            PVAttr_UIScrollView_Zoom_MinScale: @{
                @"className": @"UIScrollView",
                @"fullTitle": @"MinimumZoomScale",
                @"briefTitle": @"MinScale",
                @"patch": @(NO)
            },
            PVAttr_UIScrollView_Zoom_MaxScale: @{
                @"className": @"UIScrollView",
                @"fullTitle": @"MaximumZoomScale",
                @"briefTitle": @"MaxScale",
                @"patch": @(NO)
            },
            PVAttr_UIScrollView_Zoom_Scale: @{
                @"className": @"UIScrollView",
                @"fullTitle": @"ZoomScale",
                @"briefTitle": @"Scale",
                @"patch": @(YES)
            },
            PVAttr_UIScrollView_Zoom_Bounce: @{
                @"className": @"UIScrollView",
                @"fullTitle": @"BouncesZoom",
                @"patch": @(NO)
            },
            
            PVAttr_UITableView_Style_Style: @{
                @"className": @"UITableView",
                @"fullTitle": @"Style",
                @"setterString": @"",
                @"enumList": @"UITableViewStyle",
                @"patch": @(YES)
            },
            PVAttr_UITableView_SectionsNumber_Number: @{
                @"className": @"UITableView",
                @"fullTitle": @"NumberOfSections",
                @"setterString": @"",
                @"patch": @(YES)
            },
            PVAttr_UITableView_RowsNumber_Number: @{
                @"className": @"UITableView",
                @"setterString": @"",
                @"getterString": @"pv_lks_numberOfRows",
                @"typeIfObj": @(PVAttrTypeCustomObj)
            },
            PVAttr_UITableView_SeparatorInset_Inset: @{
                @"className": @"UITableView",
                @"fullTitle": @"SeparatorInset",
                @"patch": @(NO)
            },
            PVAttr_UITableView_SeparatorColor_Color: @{
                @"className": @"UITableView",
                @"fullTitle": @"SeparatorColor",
                @"typeIfObj": @(PVAttrTypeUIColor),
                @"patch": @(YES)
            },
            PVAttr_UITableView_SeparatorStyle_Style: @{
                @"className": @"UITableView",
                @"fullTitle": @"SeparatorStyle",
                @"enumList": @"UITableViewCellSeparatorStyle",
                @"patch": @(YES)
            },
            
            PVAttr_UITextView_Text_Text: @{
                @"className": @"UITextView",
                @"fullTitle": @"Text",
                @"typeIfObj": @(PVAttrTypeNSString),
                @"patch": @(YES)
            },
            PVAttr_UITextView_Font_Name: @{
                @"className": @"UITextView",
                @"fullTitle": @"FontName",
                @"setterString": @"",
                @"getterString": @"pv_lks_fontName",
                @"typeIfObj": @(PVAttrTypeNSString),
                @"patch": @(NO)
            },
            PVAttr_UITextView_Font_Size: @{
                @"className": @"UITextView",
                @"fullTitle": @"FontSize",
                @"setterString": @"setLks_fontSize:",
                @"getterString": @"pv_lks_fontSize",
                @"patch": @(YES)
            },
            PVAttr_UITextView_Basic_Editable: @{
                @"className": @"UITextView",
                @"fullTitle": @"Editable",
                @"getterString": @"isEditable",
                @"patch": @(NO)
            },
            PVAttr_UITextView_Basic_Selectable: @{
                @"className": @"UITextView",
                @"fullTitle": @"Selectable",
                @"getterString": @"isSelectable",
                @"patch": @(NO)
            },
            PVAttr_UITextView_TextColor_Color: @{
                @"className": @"UITextView",
                @"fullTitle": @"TextColor",
                @"typeIfObj": @(PVAttrTypeUIColor),
                @"patch": @(YES)
            },
            PVAttr_UITextView_Alignment_Alignment: @{
                @"className": @"UITextView",
                @"fullTitle": @"TextAlignment",
                @"enumList": @"NSTextAlignment",
                @"patch": @(YES)
            },
            PVAttr_UITextView_ContainerInset_Inset: @{
                @"className": @"UITextView",
                @"fullTitle": @"TextContainerInset",
                @"patch": @(YES)
            },
            
            PVAttr_UITextField_Font_Name: @{
                @"className": @"UITextField",
                @"fullTitle": @"FontName",
                @"setterString": @"",
                @"getterString": @"pv_lks_fontName",
                @"typeIfObj": @(PVAttrTypeNSString),
                @"patch": @(NO)
            },
            PVAttr_UITextField_Font_Size: @{
                @"className": @"UITextField",
                @"fullTitle": @"FontSize",
                @"setterString": @"setLks_fontSize:",
                @"getterString": @"pv_lks_fontSize",
                @"patch": @(YES)
            },
            PVAttr_UITextField_TextColor_Color: @{
                @"className": @"UITextField",
                @"fullTitle": @"TextColor",
                @"typeIfObj": @(PVAttrTypeUIColor),
                @"patch": @(YES)
            },
            PVAttr_UITextField_Alignment_Alignment: @{
                @"className": @"UITextField",
                @"fullTitle": @"TextAlignment",
                @"enumList": @"NSTextAlignment",
                @"patch": @(YES)
            },
            PVAttr_UITextField_Text_Text: @{
                @"className": @"UITextField",
                @"fullTitle": @"Text",
                @"typeIfObj": @(PVAttrTypeNSString),
                @"patch": @(YES)
            },
            PVAttr_UITextField_Placeholder_Placeholder: @{
                @"className": @"UITextField",
                @"fullTitle": @"Placeholder",
                @"typeIfObj": @(PVAttrTypeNSString),
                @"patch": @(YES)
            },
            PVAttr_UITextField_Clears_ClearsOnBeginEditing: @{
                @"className": @"UITextField",
                @"fullTitle": @"ClearsOnBeginEditing",
                @"patch": @(NO)
            },
            PVAttr_UITextField_Clears_ClearsOnInsertion: @{
                @"className": @"UITextField",
                @"fullTitle": @"ClearsOnInsertion",
                @"patch": @(NO)
            },
            PVAttr_UITextField_CanAdjustFont_CanAdjustFont: @{
                @"className": @"UITextField",
                @"fullTitle": @"AdjustsFontSizeToFitWidth",
                @"patch": @(YES)
            },
            PVAttr_UITextField_CanAdjustFont_MinSize: @{
                @"className": @"UITextField",
                @"fullTitle": @"MinimumFontSize",
                @"patch": @(YES)
            },
            PVAttr_UITextField_ClearButtonMode_Mode: @{
                @"className": @"UITextField",
                @"fullTitle": @"ClearButtonMode",
                @"enumList": @"UITextFieldViewMode",
                @"patch": @(NO)
            },
        };
    });
    
    NSDictionary<NSString *, id> *targetInfo = dict[attrID];
    return targetInfo;
}

+ (PVAttrType)objectAttrTypeWithAttrID:(PVAttrIdentifier)attrID {
    NSDictionary<NSString *, id> *attrInfo = [self _infoForAttrID:attrID];
    NSNumber *typeIfObj = attrInfo[@"typeIfObj"];
    return [typeIfObj integerValue];
}

+ (NSString *)classNameWithAttrID:(PVAttrIdentifier)attrID {
    NSDictionary<NSString *, id> *attrInfo = [self _infoForAttrID:attrID];
    NSString *className = attrInfo[@"className"];
    
    NSAssert(className.length > 0, @"");
    
    return className;
}

+ (BOOL)isUIViewPropertyWithAttrID:(PVAttrIdentifier)attrID {
    NSString *className = [self classNameWithAttrID:attrID];
    
    if ([className isEqualToString:@"CALayer"]) {
        return NO;
    }
    return YES;
}

+ (NSString *)enumListNameWithAttrID:(PVAttrIdentifier)attrID {
    NSDictionary<NSString *, id> *attrInfo = [self _infoForAttrID:attrID];
    NSString *name = attrInfo[@"enumList"];
    return name;
}

+ (BOOL)needPatchAfterModificationWithAttrID:(PVAttrIdentifier)attrID {
    NSDictionary<NSString *, id> *attrInfo = [self _infoForAttrID:attrID];
    NSNumber *needPatch = attrInfo[@"patch"];
    return [needPatch boolValue];
}

+ (NSString *)fullTitleWithAttrID:(PVAttrIdentifier)attrID {
    NSDictionary<NSString *, id> *attrInfo = [self _infoForAttrID:attrID];
    NSString *fullTitle = attrInfo[@"fullTitle"];
    return fullTitle;
}

+ (NSString *)briefTitleWithAttrID:(PVAttrIdentifier)attrID {
    NSDictionary<NSString *, id> *attrInfo = [self _infoForAttrID:attrID];
    NSString *briefTitle = attrInfo[@"briefTitle"];
    if (!briefTitle) {
        briefTitle = attrInfo[@"fullTitle"];
    }
    return briefTitle;
}

+ (SEL)getterWithAttrID:(PVAttrIdentifier)attrID {
    NSDictionary<NSString *, id> *attrInfo = [self _infoForAttrID:attrID];
    NSString *getterString = attrInfo[@"getterString"];
    if (getterString && getterString.length == 0) {
        // 空字符串，比如 image_open_open
        return nil;
    }
    if (!getterString) {
        NSString *fullTitle = attrInfo[@"fullTitle"];
        NSAssert(fullTitle.length > 0, @"");
        
        getterString = [NSString stringWithFormat:@"%@%@", [fullTitle substringToIndex:1].lowercaseString, [fullTitle substringFromIndex:1]].copy;
    }
    return NSSelectorFromString(getterString);
}

+ (SEL)setterWithAttrID:(PVAttrIdentifier)attrID {
    NSDictionary<NSString *, id> *attrInfo = [self _infoForAttrID:attrID];
    NSString *setterString = attrInfo[@"setterString"];
    if ([setterString isEqualToString:@""]) {
        // 该属性不可在 PickView 客户端中被修改
        return nil;
    }
    if (!setterString) {
        NSString *fullTitle = attrInfo[@"fullTitle"];
        NSAssert(fullTitle.length > 0, @"");
        
        setterString = [NSString stringWithFormat:@"set%@%@:", [fullTitle substringToIndex:1].uppercaseString, [fullTitle substringFromIndex:1]];
    }
    return NSSelectorFromString(setterString);
}

+ (BOOL)hideIfNilWithAttrID:(PVAttrIdentifier)attrID {
    NSDictionary<NSString *, id> *attrInfo = [self _infoForAttrID:attrID];
    NSNumber *boolValue = attrInfo[@"hideIfNil"];
    return boolValue.boolValue;
}

+ (NSInteger)minAvailableOSVersionWithAttrID:(PVAttrIdentifier)attrID {
    NSDictionary<NSString *, id> *attrInfo = [self _infoForAttrID:attrID];
    NSNumber *minVerNum = attrInfo[@"osVersion"];
    NSInteger minVer = [minVerNum integerValue];
    return minVer;
}

@end


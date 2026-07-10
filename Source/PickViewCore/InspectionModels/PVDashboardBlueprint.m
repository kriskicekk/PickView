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
#if TARGET_OS_IPHONE
            PVAttrGroup_UIStackView,
            PVAttrGroup_UIVisualEffectView,
            PVAttrGroup_UIImageView,
            PVAttrGroup_UILabel,
            PVAttrGroup_UIControl,
            PVAttrGroup_UIButton,
            PVAttrGroup_UIScrollView,
            PVAttrGroup_UITableView,
            PVAttrGroup_UITextView,
            PVAttrGroup_UITextField,
            PVAttrGroup_UIWindowScene,
            PVAttrGroup_UITraitCollection,
#endif
#if TARGET_OS_OSX
            PVAttrGroup_NSImageView,
            PVAttrGroup_NSControl,
            PVAttrGroup_NSButton,
            PVAttrGroup_NSScrollView,
            PVAttrGroup_NSTableView,
            PVAttrGroup_NSTextView,
            PVAttrGroup_NSTextField,
            PVAttrGroup_NSVisualEffectView,
            PVAttrGroup_NSStackView,
            PVAttrGroup_NSWindow,
#endif
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
                PVAttrSec_ViewLayer_Tag,
#if TARGET_OS_IPHONE
                PVAttrSec_ViewLayer_ContentMode,
                PVAttrSec_ViewLayer_TintColor,
#endif
            ],
            
#if TARGET_OS_IPHONE
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
            PVAttrGroup_UIWindowScene: @[
                PVAttrSec_UIWindowScene_State,
                PVAttrSec_UIWindowScene_Title,
                PVAttrSec_UIWindowScene_Orientation,
                PVAttrSec_UIWindowScene_Windows,
                PVAttrSec_UIWindowScene_Screen,
                PVAttrSec_UIWindowScene_StatusBar,
                PVAttrSec_UIWindowScene_Traits,
                PVAttrSec_UIWindowScene_Session,
            ],
            PVAttrGroup_UITraitCollection: @[
                PVAttrSec_UITraitCollection_Appearance,
                PVAttrSec_UITraitCollection_SizeClass,
                PVAttrSec_UITraitCollection_Display,
                PVAttrSec_UITraitCollection_Device,
                PVAttrSec_UITraitCollection_Layout,
                PVAttrSec_UITraitCollection_Content,
            ],
#endif
#if TARGET_OS_OSX
            PVAttrGroup_NSImageView: @[
                PVAttrSec_NSImageView_Name,
                PVAttrSec_NSImageView_Open,
                PVAttrSec_NSImageView_Scaling,
                PVAttrSec_NSImageView_Behavior,
                PVAttrSec_NSImageView_ContentTintColor,
            ],

            PVAttrGroup_NSControl: @[
                PVAttrSec_NSControl_State,
                PVAttrSec_NSControl_ControlSize,
                PVAttrSec_NSControl_Font,
                PVAttrSec_NSControl_Alignment,
                PVAttrSec_NSControl_Misc,
                PVAttrSec_NSControl_StringValue,
                PVAttrSec_NSControl_Value,
            ],

            PVAttrGroup_NSButton: @[
                PVAttrSec_NSButton_ButtonType,
                PVAttrSec_NSButton_BezelStyle,
                PVAttrSec_NSButton_Title,
                PVAttrSec_NSButton_Bordered,
                PVAttrSec_NSButton_BezelColor,
                PVAttrSec_NSButton_Misc,
            ],

            PVAttrGroup_NSScrollView: @[
                PVAttrSec_NSScrollView_ContentOffset,
                PVAttrSec_NSScrollView_ContentSize,
                PVAttrSec_NSScrollView_ContentInset,
                PVAttrSec_NSScrollView_BorderType,
                PVAttrSec_NSScrollView_Scroller,
                PVAttrSec_NSScrollView_Ruler,
                PVAttrSec_NSScrollView_LineScroll,
                PVAttrSec_NSScrollView_PageScroll,
                PVAttrSec_NSScrollView_ScrollElasiticity,
                PVAttrSec_NSScrollView_Misc,
                PVAttrSec_NSScrollView_Magnification,
            ],

            PVAttrGroup_NSTableView: @[
                PVAttrSec_NSTableView_RowHeight,
                PVAttrSec_NSTableView_AutomaticRowHeights,
                PVAttrSec_NSTableView_IntercellSpacing,
                PVAttrSec_NSTableView_Style,
                PVAttrSec_NSTableView_ColumnAutoresizingStyle,
                PVAttrSec_NSTableView_GridStyleMask,
                PVAttrSec_NSTableView_SelectionHighlightStyle,
                PVAttrSec_NSTableView_GridColor,
                PVAttrSec_NSTableView_RowSizeStyle,
                PVAttrSec_NSTableView_NumberOfRows,
                PVAttrSec_NSTableView_NumberOfColumns,
                PVAttrSec_NSTableView_UseAlternatingRowBackgroundColors,
                PVAttrSec_NSTableView_AllowsColumnReordering,
                PVAttrSec_NSTableView_AllowsColumnResizing,
                PVAttrSec_NSTableView_AllowsMultipleSelection,
                PVAttrSec_NSTableView_AllowsEmptySelection,
                PVAttrSec_NSTableView_AllowsColumnSelection,
                PVAttrSec_NSTableView_AllowsTypeSelect,
                PVAttrSec_NSTableView_DraggingDestinationFeedbackStyle,
                PVAttrSec_NSTableView_Autosave,
                PVAttrSec_NSTableView_FloatsGroupRows,
                PVAttrSec_NSTableView_RowActionsVisible,
                PVAttrSec_NSTableView_UsesStaticContents,
                PVAttrSec_NSTableView_UserInterfaceLayoutDirection,
                PVAttrSec_NSTableView_VerticalMotionCanBeginDrag,
            ],

            PVAttrGroup_NSTextView: @[
                PVAttrSec_NSTextView_Font,
                PVAttrSec_NSTextView_Basic,
                PVAttrSec_NSTextView_String,
                PVAttrSec_NSTextView_TextColor,
                PVAttrSec_NSTextView_Alignment,
                PVAttrSec_NSTextView_ContainerInset,
                PVAttrSec_NSTextView_BaseWritingDirection,
                PVAttrSec_NSTextView_Size,
                PVAttrSec_NSTextView_Resizable,
            ],

            PVAttrGroup_NSTextField: @[
                PVAttrSec_NSTextField_BezelStyle,
                PVAttrSec_NSTextField_LineBreakStrategy,
                PVAttrSec_NSTextField_Bordered,
                PVAttrSec_NSTextField_TextColor,
                PVAttrSec_NSTextField_Placeholder,
                PVAttrSec_NSTextField_PreferredMaxLayoutWidth,
            ],


            PVAttrGroup_NSVisualEffectView: @[
                PVAttrSec_NSVisualEffectView_Material,
                PVAttrSec_NSVisualEffectView_InteriorBackgroundStyle,
                PVAttrSec_NSVisualEffectView_BlendingMode,
                PVAttrSec_NSVisualEffectView_State,
                PVAttrSec_NSVisualEffectView_Emphasized,
            ],

            PVAttrGroup_NSStackView: @[
                PVAttrSec_NSStackView_Orientation,
                PVAttrSec_NSStackView_EdgeInsets,
                PVAttrSec_NSStackView_DetachesHiddenViews,
                PVAttrSec_NSStackView_Distribution,
                PVAttrSec_NSStackView_Alignment,
                PVAttrSec_NSStackView_Spacing,
            ],

            PVAttrGroup_NSWindow: @[
                PVAttrSec_NSWindow_Title,
                PVAttrSec_NSWindow_Subtitle,
                PVAttrSec_NSWindow_State,
                PVAttrSec_NSWindow_Style,
                PVAttrSec_NSWindow_CollectionBehavior,
                PVAttrSec_NSWindow_Appearance,
                PVAttrSec_NSWindow_TitleVisibility,
                PVAttrSec_NSWindow_ToolbarStyle,
                PVAttrSec_NSWindow_TitlebarSeparatorStyle,
                PVAttrSec_NSWindow_Behavior,
                PVAttrSec_NSWindow_AnimationBehavior,
                PVAttrSec_NSWindow_Level,
                PVAttrSec_NSWindow_TabbingMode,
                PVAttrSec_NSWindow_Size,
                PVAttrSec_NSWindow_Info,
            ],
#endif
            
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
            
            PVAttrSec_ViewLayer_InterationAndMasks:@[
#if TARGET_OS_IPHONE
            PVAttr_ViewLayer_InterationAndMasks_Interaction,
#endif
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
#if TARGET_OS_IPHONE
            
            PVAttrSec_ViewLayer_ContentMode: @[PVAttr_ViewLayer_ContentMode_Mode],
            
            PVAttrSec_ViewLayer_TintColor: @[PVAttr_ViewLayer_TintColor_Color,
                                                 PVAttr_ViewLayer_TintColor_Mode],
#endif
            
            PVAttrSec_ViewLayer_Tag: @[PVAttr_ViewLayer_Tag_Tag],
#if TARGET_OS_IPHONE
            
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
            
            PVAttrSec_UITextField_ClearButtonMode: @[PVAttr_UITextField_ClearButtonMode_Mode],
            PVAttrSec_UIWindowScene_State: @[
                PVAttr_UIWindowScene_State_ActivationState,
            ],
            PVAttrSec_UIWindowScene_Title: @[
                PVAttr_UIWindowScene_Title_Title,
            ],
            PVAttrSec_UIWindowScene_Orientation: @[
                PVAttr_UIWindowScene_Orientation_InterfaceOrientation,
            ],
            PVAttrSec_UIWindowScene_Windows: @[
                PVAttr_UIWindowScene_Windows_WindowCount,
                PVAttr_UIWindowScene_Windows_KeyWindowClassName,
            ],
            PVAttrSec_UIWindowScene_Screen: @[
                PVAttr_UIWindowScene_Screen_ScreenBounds,
                PVAttr_UIWindowScene_Screen_ScreenScale,
            ],
            PVAttrSec_UIWindowScene_StatusBar: @[
                PVAttr_UIWindowScene_StatusBar_StatusBarHidden,
                PVAttr_UIWindowScene_StatusBar_StatusBarStyle,
                PVAttr_UIWindowScene_StatusBar_StatusBarFrame,
            ],
            PVAttrSec_UIWindowScene_Traits: @[
                PVAttr_UIWindowScene_Traits_UserInterfaceStyle,
                PVAttr_UIWindowScene_Traits_HorizontalSizeClass,
                PVAttr_UIWindowScene_Traits_VerticalSizeClass,
                PVAttr_UIWindowScene_Traits_UserInterfaceLevel,
                PVAttr_UIWindowScene_Traits_ActiveAppearance,
                PVAttr_UIWindowScene_Traits_AccessibilityContrast,
                PVAttr_UIWindowScene_Traits_LegibilityWeight,
                PVAttr_UIWindowScene_Traits_DisplayScale,
                PVAttr_UIWindowScene_Traits_DisplayGamut,
                PVAttr_UIWindowScene_Traits_UserInterfaceIdiom,
                PVAttr_UIWindowScene_Traits_LayoutDirection,
                PVAttr_UIWindowScene_Traits_PreferredContentSizeCategory,
                PVAttr_UIWindowScene_Traits_SceneCaptureState,
                PVAttr_UIWindowScene_Traits_ImageDynamicRange,
                PVAttr_UIWindowScene_Traits_TypesettingLanguage,
            ],
            PVAttrSec_UIWindowScene_Session: @[
                PVAttr_UIWindowScene_Session_PersistentIdentifier,
                PVAttr_UIWindowScene_Session_SessionRole,
            ],
            // UITraitCollection
            PVAttrSec_UITraitCollection_Appearance: @[
                PVAttr_UITraitCollection_Appearance_UserInterfaceStyle,
                PVAttr_UITraitCollection_Appearance_UserInterfaceLevel,
                PVAttr_UITraitCollection_Appearance_ActiveAppearance,
                PVAttr_UITraitCollection_Appearance_AccessibilityContrast,
                PVAttr_UITraitCollection_Appearance_LegibilityWeight,
            ],
            PVAttrSec_UITraitCollection_SizeClass: @[
                PVAttr_UITraitCollection_SizeClass_HorizontalSizeClass,
                PVAttr_UITraitCollection_SizeClass_VerticalSizeClass,
            ],
            PVAttrSec_UITraitCollection_Display: @[
                PVAttr_UITraitCollection_Display_DisplayScale,
                PVAttr_UITraitCollection_Display_DisplayGamut,
                PVAttr_UITraitCollection_Display_ImageDynamicRange,
            ],
            PVAttrSec_UITraitCollection_Device: @[
                PVAttr_UITraitCollection_Device_UserInterfaceIdiom,
                PVAttr_UITraitCollection_Device_ForceTouchCapability,
            ],
            PVAttrSec_UITraitCollection_Layout: @[
                PVAttr_UITraitCollection_Layout_LayoutDirection,
            ],
            PVAttrSec_UITraitCollection_Content: @[
                PVAttr_UITraitCollection_Content_PreferredContentSizeCategory,
                PVAttr_UITraitCollection_Content_TypesettingLanguage,
            ],
#endif
#if TARGET_OS_OSX
            PVAttrSec_NSImageView_Name:@[
                PVAttr_NSImageView_Name_Name
            ],
            PVAttrSec_NSImageView_Open:@[
                PVAttr_NSImageView_Open_Open
            ],
            PVAttrSec_NSImageView_Scaling: @[
                PVAttr_NSImageView_Scaling_ImageScaling,
                PVAttr_NSImageView_Scaling_ImageAlignment,
                PVAttr_NSImageView_Scaling_ImageFrameStyle,
            ],
            PVAttrSec_NSImageView_Behavior: @[
                PVAttr_NSImageView_Behavior_Animates,
                PVAttr_NSImageView_Behavior_Editable,
            ],
            PVAttrSec_NSImageView_ContentTintColor: @[
                PVAttr_NSImageView_ContentTintColor_ContentTintColor,
            ],
            PVAttrSec_NSControl_State: @[
                PVAttr_NSControl_State_Enabled,
                PVAttr_NSControl_State_Highlighted,
                PVAttr_NSControl_State_Continuous,
            ],
            PVAttrSec_NSControl_ControlSize: @[
                PVAttr_NSControl_ControlSize_Size
            ],
            PVAttrSec_NSControl_Font: @[
                PVAttr_NSControl_Font_Name,
                PVAttr_NSControl_Font_Size
            ],
            PVAttrSec_NSControl_Alignment: @[
                PVAttr_NSControl_Alignment_Alignment
            ],
            PVAttrSec_NSControl_Misc: @[
                PVAttr_NSControl_Misc_WritingDirection,
                PVAttr_NSControl_Misc_IgnoresMultiClick,
                PVAttr_NSControl_Misc_UsesSingleLineMode,
                PVAttr_NSControl_Misc_AllowsExpansionToolTips,
            ],
            PVAttrSec_NSControl_StringValue: @[
                PVAttr_NSControl_Value_StringValue,
            ],
            PVAttrSec_NSControl_Value: @[
                PVAttr_NSControl_Value_IntValue,
                PVAttr_NSControl_Value_IntegerValue,
                PVAttr_NSControl_Value_FloatValue,
                PVAttr_NSControl_Value_DoubleValue,
            ],

            PVAttrSec_NSButton_ButtonType: @[
                PVAttr_NSButton_ButtonType_ButtonType
            ],
            PVAttrSec_NSButton_Title: @[
                PVAttr_NSButton_Title_Title,
                PVAttr_NSButton_Title_AlernateTitle,
            ],
            PVAttrSec_NSButton_BezelStyle: @[PVAttr_NSButton_BezelStyle_BezelStyle],
            PVAttrSec_NSButton_Bordered: @[
                PVAttr_NSButton_Bordered_Bordered,
                PVAttr_NSButton_Transparent_Transparent,
                PVAttr_NSButton_Misc_ShowsBorderOnlyWhileMouseInside,
                PVAttr_NSButton_Misc_SpringLoaded,
                PVAttr_NSButton_Misc_HasDestructiveAction,
            ],
            PVAttrSec_NSButton_BezelColor: @[
                PVAttr_NSButton_BezelColor_BezelColor,
                PVAttr_NSButton_ContentTintColor_ContentTintColor,
            ],
            PVAttrSec_NSButton_Misc: @[
                PVAttr_NSButton_Misc_MaxAcceleratorLevel,
            ],



            PVAttrSec_NSScrollView_ContentOffset: @[
                PVAttr_NSScrollView_ContentOffset_Offset
            ],
            PVAttrSec_NSScrollView_ContentSize: @[
                PVAttr_NSScrollView_ContentSize_Size
            ],
            PVAttrSec_NSScrollView_ContentInset: @[
                PVAttr_NSScrollView_ContentInset_ContentInset,
                PVAttr_NSScrollView_ContentInset_AutomaticallyAdjustsContentInsets
            ],
            PVAttrSec_NSScrollView_BorderType: @[
                PVAttr_NSScrollView_BorderType_BorderType
            ],
            PVAttrSec_NSScrollView_Scroller: @[
                PVAttr_NSScrollView_Scroller_Horizontal,
                PVAttr_NSScrollView_Scroller_Vertical,
                PVAttr_NSScrollView_Scroller_AutohidesScrollers,
                PVAttr_NSScrollView_Scroller_ScrollerStyle,
                PVAttr_NSScrollView_Scroller_ScrollerKnobStyle,
                PVAttr_NSScrollView_Scroller_ScrollerInsets,
            ],
            PVAttrSec_NSScrollView_Ruler: @[
                PVAttr_NSScrollView_Ruler_Horizontal,
                PVAttr_NSScrollView_Ruler_Vertical,
                PVAttr_NSScrollView_Ruler_Visible,
            ],
            PVAttrSec_NSScrollView_LineScroll: @[
                PVAttr_NSScrollView_LineScroll_Horizontal,
                PVAttr_NSScrollView_LineScroll_Vertical,
                PVAttr_NSScrollView_LineScroll_LineScroll,
            ],
            PVAttrSec_NSScrollView_PageScroll: @[
                PVAttr_NSScrollView_PageScroll_Horizontal,
                PVAttr_NSScrollView_PageScroll_Vertical,
                PVAttr_NSScrollView_PageScroll_PageScroll,
            ],
            PVAttrSec_NSScrollView_ScrollElasiticity: @[
                PVAttr_NSScrollView_ScrollElasiticity_Horizontal,
                PVAttr_NSScrollView_ScrollElasiticity_Vertical,
            ],
            PVAttrSec_NSScrollView_Misc: @[
                PVAttr_NSScrollView_Misc_ScrollsDynamically,
                PVAttr_NSScrollView_Misc_UsesPredominantAxisScrolling,
            ],
            PVAttrSec_NSScrollView_Magnification: @[
                PVAttr_NSScrollView_Magnification_AllowsMagnification,
                PVAttr_NSScrollView_Magnification_Magnification,
                PVAttr_NSScrollView_Magnification_Max,
                PVAttr_NSScrollView_Magnification_Min,
            ],

            PVAttrSec_NSTableView_RowHeight: @[
                PVAttr_NSTableView_RowHeight_RowHeight,
            ],
            PVAttrSec_NSTableView_AutomaticRowHeights: @[
                PVAttr_NSTableView_AutomaticRowHeights_AutomaticRowHeights,
            ],
            PVAttrSec_NSTableView_IntercellSpacing: @[
                PVAttr_NSTableView_IntercellSpacing_IntercellSpacing
            ],
            PVAttrSec_NSTableView_Style: @[
                PVAttr_NSTableView_Style_Style
            ],
            PVAttrSec_NSTableView_ColumnAutoresizingStyle: @[
                PVAttr_NSTableView_ColumnAutoresizingStyle_ColumnAutoresizingStyle
            ],
            PVAttrSec_NSTableView_GridStyleMask: @[
                PVAttr_NSTableView_GridStyleMask_GridStyleMask
            ],
            PVAttrSec_NSTableView_SelectionHighlightStyle: @[
                PVAttr_NSTableView_SelectionHighlightStyle_SelectionHighlightStyle
            ],
            PVAttrSec_NSTableView_GridColor: @[
                PVAttr_NSTableView_GridColor_GridColor
            ],
            PVAttrSec_NSTableView_RowSizeStyle: @[
                PVAttr_NSTableView_RowSizeStyle_RowSizeStyle
            ],
            PVAttrSec_NSTableView_NumberOfRows: @[
                PVAttr_NSTableView_NumberOfRows_NumberOfRows
            ],
            PVAttrSec_NSTableView_NumberOfColumns: @[
                PVAttr_NSTableView_NumberOfColumns_NumberOfColumns
            ],
            PVAttrSec_NSTableView_UseAlternatingRowBackgroundColors: @[
                PVAttr_NSTableView_UseAlternatingRowBackgroundColors_UseAlternatingRowBackgroundColors
            ],
            PVAttrSec_NSTableView_AllowsColumnReordering: @[
                PVAttr_NSTableView_AllowsColumnReordering_AllowsColumnReordering
            ],
            PVAttrSec_NSTableView_AllowsColumnResizing: @[
                PVAttr_NSTableView_AllowsColumnResizing_AllowsColumnResizing
            ],
            PVAttrSec_NSTableView_AllowsMultipleSelection: @[
                PVAttr_NSTableView_AllowsMultipleSelection_AllowsMultipleSelection
            ],
            PVAttrSec_NSTableView_AllowsEmptySelection: @[
                PVAttr_NSTableView_AllowsEmptySelection_AllowsEmptySelection
            ],
            PVAttrSec_NSTableView_AllowsColumnSelection: @[
                PVAttr_NSTableView_AllowsColumnSelection_AllowsColumnSelection
            ],
            PVAttrSec_NSTableView_AllowsTypeSelect: @[
                PVAttr_NSTableView_AllowsTypeSelect_AllowsTypeSelect
            ],
            PVAttrSec_NSTableView_DraggingDestinationFeedbackStyle: @[
                PVAttr_NSTableView_DraggingDestinationFeedbackStyle_DraggingDestinationFeedbackStyle
            ],
            PVAttrSec_NSTableView_Autosave: @[
                PVAttr_NSTableView_AutosaveName_AutosaveName,
                PVAttr_NSTableView_AutosaveTableColumns_AutosaveTableColumns
            ],
            PVAttrSec_NSTableView_FloatsGroupRows: @[
                PVAttr_NSTableView_FloatsGroupRows_FloatsGroupRows
            ],
            PVAttrSec_NSTableView_RowActionsVisible: @[
                PVAttr_NSTableView_RowActionsVisible_RowActionsVisible
            ],
            PVAttrSec_NSTableView_UsesStaticContents: @[
                PVAttr_NSTableView_UsesStaticContents_UsesStaticContents
            ],
            PVAttrSec_NSTableView_UserInterfaceLayoutDirection: @[
                PVAttr_NSTableView_UserInterfaceLayoutDirection_UserInterfaceLayoutDirection
            ],
            PVAttrSec_NSTableView_VerticalMotionCanBeginDrag: @[
                PVAttr_NSTableView_VerticalMotionCanBeginDrag_VerticalMotionCanBeginDrag
            ],



            PVAttrSec_NSTextView_Font: @[
                PVAttr_NSTextView_Font_Name,
                PVAttr_NSTextView_Font_Size
            ],
            PVAttrSec_NSTextView_Basic: @[
                PVAttr_NSTextView_Basic_Editable,
                PVAttr_NSTextView_Basic_Selectable,
                PVAttr_NSTextView_Basic_RichText,
                PVAttr_NSTextView_Basic_FieldEditor,
                PVAttr_NSTextView_Basic_ImportsGraphics,
            ],
            PVAttrSec_NSTextView_String: @[
                PVAttr_NSTextView_String_String
            ],
            PVAttrSec_NSTextView_TextColor: @[
                PVAttr_NSTextView_TextColor_Color
            ],
            PVAttrSec_NSTextView_Alignment: @[
                PVAttr_NSTextView_Alignment_Alignment
            ],
            PVAttrSec_NSTextView_ContainerInset: @[
                PVAttr_NSTextView_ContainerInset_Inset
            ],
            PVAttrSec_NSTextView_BaseWritingDirection: @[
                PVAttr_NSTextView_BaseWritingDirection_BaseWritingDirection
            ],
            PVAttrSec_NSTextView_Size: @[
                PVAttr_NSTextView_MaxSize_MaxSize,
                PVAttr_NSTextView_MinSize_MinSize,
            ],
            PVAttrSec_NSTextView_Resizable: @[
                PVAttr_NSTextView_Resizable_Horizontal,
                PVAttr_NSTextView_Resizable_Vertical,
            ],

            PVAttrSec_NSTextField_BezelStyle: @[
                PVAttr_NSTextField_BezelStyle_BezelStyle
            ],
            PVAttrSec_NSTextField_Bordered: @[
                PVAttr_NSTextField_Bordered_Bordered,
                PVAttr_NSTextField_Bezeled_Bezeled,
                PVAttr_NSTextField_Editable_Editable,
                PVAttr_NSTextField_Selectable_Selectable,
                PVAttr_NSTextField_DrawsBackground_DrawsBackground,
                PVAttr_NSTextField_AllowsDefaultTighteningForTruncation_AllowsDefaultTighteningForTruncation,
                PVAttr_NSTextField_AllowsEditingTextAttributes_AllowsEditingTextAttributes,
                PVAttr_NSTextField_ImportsGraphics_ImportsGraphics,
            ],
            PVAttrSec_NSTextField_TextColor: @[
                PVAttr_NSTextField_TextColor_Color,
                PVAttr_NSTextField_BackgroundColor_Color,
            ],
            PVAttrSec_NSTextField_Placeholder: @[
                PVAttr_NSTextField_Placeholder_Placeholder
            ],
            PVAttrSec_NSTextField_LineBreakStrategy: @[
                PVAttr_NSTextField_LineBreakStrategy_LineBreakStrategy,
            ],
            PVAttrSec_NSTextField_PreferredMaxLayoutWidth: @[
                PVAttr_NSTextField_PreferredMaxLayoutWidth_PreferredMaxLayoutWidth,
                PVAttr_NSTextField_MaximumNumberOfLines_MaximumNumberOfLines,
            ],




            PVAttrSec_NSVisualEffectView_Material: @[
                PVAttr_NSVisualEffectView_Material_Material
            ],
            PVAttrSec_NSVisualEffectView_InteriorBackgroundStyle: @[
                PVAttr_NSVisualEffectView_InteriorBackgroundStyle_InteriorBackgroundStyle
            ],
            PVAttrSec_NSVisualEffectView_BlendingMode: @[
                PVAttr_NSVisualEffectView_BlendingMode_BlendingMode
            ],
            PVAttrSec_NSVisualEffectView_State: @[
                PVAttr_NSVisualEffectView_State_State
            ],
            PVAttrSec_NSVisualEffectView_Emphasized: @[
                PVAttr_NSVisualEffectView_Emphasized_Emphasized
            ],



            PVAttrSec_NSStackView_Orientation:@[
                PVAttr_NSStackView_Orientation_Orientation
            ],
            PVAttrSec_NSStackView_EdgeInsets:@[
                PVAttr_NSStackView_EdgeInsets_EdgeInsets
            ],
            PVAttrSec_NSStackView_DetachesHiddenViews:@[
                PVAttr_NSStackView_DetachesHiddenViews_DetachesHiddenViews
            ],
            PVAttrSec_NSStackView_Distribution:@[
                PVAttr_NSStackView_Distribution_Distribution
            ],
            PVAttrSec_NSStackView_Alignment:@[
                PVAttr_NSStackView_Alignment_Alignment
            ],
            PVAttrSec_NSStackView_Spacing:@[
                PVAttr_NSStackView_Spacing_Spacing
            ],

            PVAttrSec_NSWindow_Title: @[
                PVAttr_NSWindow_Title_Title,
            ],
            PVAttrSec_NSWindow_Subtitle: @[
                PVAttr_NSWindow_Title_Subtitle,
            ],
            PVAttrSec_NSWindow_State: @[
                PVAttr_NSWindow_State_KeyWindow,
                PVAttr_NSWindow_State_MainWindow,
                PVAttr_NSWindow_State_Visible,
                PVAttr_NSWindow_State_CanBecomeKeyWindow,
                PVAttr_NSWindow_State_CanBecomeMainWindow,
            ],
            PVAttrSec_NSWindow_Style: @[
                PVAttr_NSWindow_Style_Titled,
                PVAttr_NSWindow_Style_Closable,
                PVAttr_NSWindow_Style_Miniaturizable,
                PVAttr_NSWindow_Style_Resizable,
                PVAttr_NSWindow_Style_UnifiedTitleAndToolbar,
                PVAttr_NSWindow_Style_FullScreen,
                PVAttr_NSWindow_Style_FullSizeContentView,
                PVAttr_NSWindow_Style_UtilityWindow,
                PVAttr_NSWindow_Style_DocModalWindow,
                PVAttr_NSWindow_Style_NonactivatingPanel,
                PVAttr_NSWindow_Style_HUDWindow,
            ],
            PVAttrSec_NSWindow_CollectionBehavior: @[
                PVAttr_NSWindow_CollectionBehavior_CanJoinAllSpaces,
                PVAttr_NSWindow_CollectionBehavior_MoveToActiveSpace,
                PVAttr_NSWindow_CollectionBehavior_ParticipatesInCycle,
                PVAttr_NSWindow_CollectionBehavior_IgnoresCycle,
                PVAttr_NSWindow_CollectionBehavior_FullScreenPrimary,
                PVAttr_NSWindow_CollectionBehavior_FullScreenAuxiliary,
                PVAttr_NSWindow_CollectionBehavior_FullScreenNone,
                PVAttr_NSWindow_CollectionBehavior_FullScreenAllowsTiling,
                PVAttr_NSWindow_CollectionBehavior_FullScreenDisallowsTiling,
            ],
            PVAttrSec_NSWindow_Appearance: @[
                PVAttr_NSWindow_Appearance_TitlebarAppearsTransparent,
                PVAttr_NSWindow_Appearance_BackgroundColor,
                PVAttr_NSWindow_Appearance_AlphaValue,
                PVAttr_NSWindow_Appearance_Opaque,
                PVAttr_NSWindow_Appearance_HasShadow,
            ],
            PVAttrSec_NSWindow_TitleVisibility: @[
                PVAttr_NSWindow_Appearance_TitleVisibility,
            ],
            PVAttrSec_NSWindow_ToolbarStyle: @[
                PVAttr_NSWindow_Appearance_ToolbarStyle,
            ],
            PVAttrSec_NSWindow_TitlebarSeparatorStyle: @[
                PVAttr_NSWindow_Appearance_TitlebarSeparatorStyle,
            ],
            PVAttrSec_NSWindow_Behavior: @[
                PVAttr_NSWindow_Behavior_Movable,
                PVAttr_NSWindow_Behavior_MovableByWindowBackground,
                PVAttr_NSWindow_Behavior_HidesOnDeactivate,
            ],
            PVAttrSec_NSWindow_AnimationBehavior: @[
                PVAttr_NSWindow_Behavior_AnimationBehavior,
            ],
            PVAttrSec_NSWindow_Level: @[
                PVAttr_NSWindow_Behavior_Level,
            ],
            PVAttrSec_NSWindow_TabbingMode: @[
                PVAttr_NSWindow_Behavior_TabbingMode,
            ],
            PVAttrSec_NSWindow_Size: @[
                PVAttr_NSWindow_Size_MinSize,
                PVAttr_NSWindow_Size_MaxSize,
            ],
            PVAttrSec_NSWindow_Info: @[
                PVAttr_NSWindow_Info_WindowNumber,
                PVAttr_NSWindow_Info_BackingScaleFactor,
            ],

#endif
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
#if TARGET_OS_IPHONE
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
            PVAttrGroup_UIStackView: @"UIStackView",
            PVAttrGroup_UIWindowScene: @"UIWindowScene",
            PVAttrGroup_UITraitCollection: @"UITraitCollection",
#else
            PVAttrGroup_ViewLayer: @"CALayer / NSView",
            PVAttrGroup_NSImageView:        @"NSImageView",
            PVAttrGroup_NSControl:          @"NSControl",
            PVAttrGroup_NSButton:           @"NSButton",
            PVAttrGroup_NSScrollView:       @"NSScrollView",
            PVAttrGroup_NSTableView:        @"NSTableView",
            PVAttrGroup_NSTextView:         @"NSTextView",
            PVAttrGroup_NSTextField:        @"NSTextField",
            PVAttrGroup_NSVisualEffectView: @"NSVisualEffectView",
            PVAttrGroup_NSStackView:        @"NSStackView",
            PVAttrGroup_NSWindow:           @"NSWindow",
#endif
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
            PVAttrSec_ViewLayer_Tag: @"Tag",
            PVAttrSec_ViewLayer_ContentMode: @"ContentMode",
            PVAttrSec_ViewLayer_TintColor: @"TintColor",
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
            PVAttrSec_NSImageView_Name: @"ImageName",
            PVAttrSec_NSImageView_Open: @"Open",
            PVAttrSec_NSImageView_Scaling: @"Scaling",
            PVAttrSec_NSImageView_Behavior: @"Behavior",
            PVAttrSec_NSImageView_ContentTintColor: @"ContentTintColor",
            PVAttrSec_NSControl_State: @"State",
            PVAttrSec_NSControl_ControlSize: @"ControlSize",
            PVAttrSec_NSControl_Font: @"Font",
            PVAttrSec_NSControl_Alignment: @"Alignment",
            PVAttrSec_NSControl_Misc: @"Misc",
            PVAttrSec_NSControl_StringValue: @"StringValue",
            PVAttrSec_NSControl_Value: @"Value",
            PVAttrSec_NSButton_ButtonType: @"ButtonType",
            PVAttrSec_NSButton_Title: @"Title",
            PVAttrSec_NSButton_BezelStyle: @"BezelStyle",
            PVAttrSec_NSButton_BezelColor: @"Colors",
            PVAttrSec_NSButton_Misc: @"Misc",
            PVAttrSec_NSScrollView_ContentOffset: @"ContentOffset",
            PVAttrSec_NSScrollView_ContentSize: @"ContentSize",
            PVAttrSec_NSScrollView_ContentInset: @"ContentInset",
            PVAttrSec_NSScrollView_BorderType: @"BorderType",
            PVAttrSec_NSScrollView_Scroller: @"Scroller",
            PVAttrSec_NSScrollView_Ruler: @"Ruler",
            PVAttrSec_NSScrollView_LineScroll: @"LineScroll",
            PVAttrSec_NSScrollView_PageScroll: @"PageScroll",
            PVAttrSec_NSScrollView_ScrollElasiticity: @"ScrollElasiticity",
            PVAttrSec_NSScrollView_Misc: @"Misc",
            PVAttrSec_NSScrollView_Magnification: @"Magnification",
            PVAttrSec_NSTableView_RowHeight: @"RowHeight",
            PVAttrSec_NSTableView_AutomaticRowHeights: @"AutomaticRowHeights",
            PVAttrSec_NSTableView_IntercellSpacing: @"IntercellSpacing",
            PVAttrSec_NSTableView_Style: @"Style",
            PVAttrSec_NSTableView_ColumnAutoresizingStyle: @"ColumnAutoresizingStyle",
            PVAttrSec_NSTableView_GridStyleMask: @"GridStyleMask",
            PVAttrSec_NSTableView_SelectionHighlightStyle: @"SelectionHighlightStyle",
            PVAttrSec_NSTableView_GridColor: @"GridColor",
            PVAttrSec_NSTableView_RowSizeStyle: @"RowSizeStyle",
            PVAttrSec_NSTableView_NumberOfRows: @"NumberOfRows",
            PVAttrSec_NSTableView_NumberOfColumns: @"NumberOfColumns",
            PVAttrSec_NSTableView_UseAlternatingRowBackgroundColors: @"UseAlternatingRowBackgroundColors",
            PVAttrSec_NSTableView_AllowsColumnReordering: @"AllowsColumnReordering",
            PVAttrSec_NSTableView_AllowsColumnResizing: @"AllowsColumnResizing",
            PVAttrSec_NSTableView_AllowsMultipleSelection: @"AllowsMultipleSelection",
            PVAttrSec_NSTableView_AllowsEmptySelection: @"AllowsEmptySelection",
            PVAttrSec_NSTableView_AllowsColumnSelection: @"AllowsColumnSelection",
            PVAttrSec_NSTableView_AllowsTypeSelect: @"AllowsTypeSelect",
            PVAttrSec_NSTableView_DraggingDestinationFeedbackStyle: @"DraggingDestinationFeedbackStyle",
            PVAttrSec_NSTableView_Autosave: @"Autosave",
            PVAttrSec_NSTableView_FloatsGroupRows: @"FloatsGroupRows",
            PVAttrSec_NSTableView_RowActionsVisible: @"RowActionsVisible",
            PVAttrSec_NSTableView_UsesStaticContents: @"UsesStaticContents",
            PVAttrSec_NSTableView_UserInterfaceLayoutDirection: @"UserInterfaceLayoutDirection",
            PVAttrSec_NSTableView_VerticalMotionCanBeginDrag: @"VerticalMotionCanBeginDrag",
            PVAttrSec_NSTextView_Font: @"Font",
            PVAttrSec_NSTextView_Basic: @"Basic",
            PVAttrSec_NSTextView_String: @"String",
            PVAttrSec_NSTextView_TextColor: @"TextColor",
            PVAttrSec_NSTextView_Alignment: @"Alignment",
            PVAttrSec_NSTextView_ContainerInset: @"ContainerInset",
            PVAttrSec_NSTextView_BaseWritingDirection: @"BaseWritingDirection",
            PVAttrSec_NSTextView_Size: @"Size",
            PVAttrSec_NSTextView_Resizable: @"Resizable",
            PVAttrSec_NSTextField_BezelStyle: @"BezelStyle",
            PVAttrSec_NSTextField_LineBreakStrategy: @"LineBreakStrategy",
            PVAttrSec_NSTextField_TextColor: @"Colors",
            PVAttrSec_NSTextField_Placeholder: @"Placeholder",
            PVAttrSec_NSTextField_PreferredMaxLayoutWidth: @"Layout",
            PVAttrSec_NSVisualEffectView_Material: @"Material",
            PVAttrSec_NSVisualEffectView_InteriorBackgroundStyle: @"InteriorBackgroundStyle",
            PVAttrSec_NSVisualEffectView_BlendingMode: @"BlendingMode",
            PVAttrSec_NSVisualEffectView_State: @"State",
            PVAttrSec_NSVisualEffectView_Emphasized: @"Emphasized",
            PVAttrSec_NSStackView_Orientation: @"Orientation",
            PVAttrSec_NSStackView_EdgeInsets: @"EdgeInsets",
            PVAttrSec_NSStackView_DetachesHiddenViews: @"DetachesHiddenViews",
            PVAttrSec_NSStackView_Distribution: @"Distribution",
            PVAttrSec_NSStackView_Alignment: @"Alignment",
            PVAttrSec_NSStackView_Spacing: @"Spacing",
            PVAttrSec_NSWindow_Title: @"Title",
            PVAttrSec_NSWindow_Subtitle: @"Subtitle",
            PVAttrSec_NSWindow_State: @"State",
            PVAttrSec_NSWindow_Style: @"StyleMask",
            PVAttrSec_NSWindow_CollectionBehavior: @"CollectionBehavior",
            PVAttrSec_NSWindow_Appearance: @"Appearance",
            PVAttrSec_NSWindow_TitleVisibility: @"TitleVisibility",
            PVAttrSec_NSWindow_ToolbarStyle: @"ToolbarStyle",
            PVAttrSec_NSWindow_TitlebarSeparatorStyle: @"TitlebarSeparatorStyle",
            PVAttrSec_NSWindow_Behavior: @"Behavior",
            PVAttrSec_NSWindow_AnimationBehavior: @"AnimationBehavior",
            PVAttrSec_NSWindow_Level: @"Level",
            PVAttrSec_NSWindow_TabbingMode: @"TabbingMode",
            PVAttrSec_NSWindow_Size: @"Size",
            PVAttrSec_NSWindow_Info: @"Info",
            // UIWindowScene
            PVAttrSec_UIWindowScene_State: @"State",
            PVAttrSec_UIWindowScene_Title: @"Title",
            PVAttrSec_UIWindowScene_Orientation: @"Orientation",
            PVAttrSec_UIWindowScene_Windows: @"Windows",
            PVAttrSec_UIWindowScene_Screen: @"Screen",
            PVAttrSec_UIWindowScene_StatusBar: @"StatusBar",
            PVAttrSec_UIWindowScene_Traits: @"Traits",
            PVAttrSec_UIWindowScene_Session: @"Session",
            // UITraitCollection
            PVAttrSec_UITraitCollection_Appearance: @"Appearance",
            PVAttrSec_UITraitCollection_SizeClass: @"SizeClass",
            PVAttrSec_UITraitCollection_Display: @"Display",
            PVAttrSec_UITraitCollection_Device: @"Device",
            PVAttrSec_UITraitCollection_Layout: @"Layout",
            PVAttrSec_UITraitCollection_Content: @"Content",
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
 
 patch：如果为 YES，则用户修改了该 Attribute 的值后，PV 会重新拉取和更新相关图层的位置、截图等信息，如果为 nil 则默认是 NO
 
 hideIfNil：如果为 YES，则当获取的 value 为 nil 时，PV 不会传输该 attr。如果为 NO，则即使 value 为 nil 也会传输（比如 label 的 text 属性，即使它是 nil 我们也要显示，所以它的 hideIfNil 应该为 NO）。如果该字段为 nil 则默认是 NO
 
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
#if TARGET_OS_IPHONE
            PVAttr_Layout_SafeArea_SafeArea: @{
                @"className": @"UIView",
                @"fullTitle": @"SafeAreaInsets",
                @"setterString": @"",
                @"osVersion": @(11)
            },
#elif TARGET_OS_OSX
            PVAttr_Layout_SafeArea_SafeArea: @{
                @"className": @"NSView",
                @"fullTitle": @"SafeAreaInsets",
                @"setterString": @"",
                @"osVersion": @(11)
            },
#endif
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
#if TARGET_OS_IPHONE
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
#elif TARGET_OS_OSX
            PVAttr_AutoLayout_Hugging_Hor: @{
                @"className": @"NSView",
                @"fullTitle": @"ContentHuggingPriority(Horizontal)",
                @"getterString": @"pv_lks_horizontalContentHuggingPriority",
                @"setterString": @"setLks_horizontalContentHuggingPriority:",
                @"briefTitle": @"H",
                @"patch": @(YES)
            },
            PVAttr_AutoLayout_Hugging_Ver: @{
                @"className": @"NSView",
                @"fullTitle": @"ContentHuggingPriority(Vertical)",
                @"getterString": @"pv_lks_verticalContentHuggingPriority",
                @"setterString": @"setLks_verticalContentHuggingPriority:",
                @"briefTitle": @"V",
                @"patch": @(YES)
            },
            PVAttr_AutoLayout_Resistance_Hor: @{
                @"className": @"NSView",
                @"fullTitle": @"ContentCompressionResistancePriority(Horizontal)",
                @"getterString": @"pv_lks_horizontalContentCompressionResistancePriority",
                @"setterString": @"setLks_horizontalContentCompressionResistancePriority:",
                @"briefTitle": @"H",
                @"patch": @(YES)
            },
            PVAttr_AutoLayout_Resistance_Ver: @{
                @"className": @"NSView",
                @"fullTitle": @"ContentCompressionResistancePriority(Vertical)",
                @"getterString": @"pv_lks_verticalContentCompressionResistancePriority",
                @"setterString": @"setLks_verticalContentCompressionResistancePriority:",
                @"briefTitle": @"V",
                @"patch": @(YES)
            },
            PVAttr_AutoLayout_Constraints_Constraints: @{
                @"className": @"NSView",
                @"getterString": @"pv_lks_constraints",
                @"setterString": @"",
                @"typeIfObj": @(PVAttrTypeCustomObj),
                @"hideIfNil": @(YES)
            },
            PVAttr_AutoLayout_IntrinsicSize_Size: @{
                @"className": @"NSView",
                @"fullTitle": @"IntrinsicContentSize",
                @"setterString": @""
            },
#endif

            PVAttr_ViewLayer_InterationAndMasks_Interaction: @{
                @"className": @"UIView",
                @"fullTitle": @"UserInteractionEnabled",
                @"getterString": @"isUserInteractionEnabled",
                @"patch": @(NO)
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
#if TARGET_OS_IPHONE
            PVAttr_ViewLayer_Tag_Tag: @{
                @"className": @"UIView",
                @"fullTitle": @"Tag",
                @"briefTitle": @"",
                @"patch": @(NO)
            },
#elif TARGET_OS_OSX
            PVAttr_ViewLayer_Tag_Tag: @{
                @"className": @"NSView",
                @"fullTitle": @"Tag",
                @"briefTitle": @"",
                @"patch": @(NO)
            },
#endif
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
            PVAttr_NSImageView_Name_Name: @{
                @"className": @"NSImageView",
                @"fullTitle": @"ImageName",
                @"setterString": @"",
                @"getterString": @"pv_lks_imageSourceName",
                @"typeIfObj": @(PVAttrTypeNSString),
                @"hideIfNil": @(YES)
            },
            PVAttr_NSImageView_Open_Open: @{
                @"className": @"NSImageView",
                @"setterString": @"",
                @"getterString": @"pv_lks_imageViewOidIfHasImage",
                @"typeIfObj": @(PVAttrTypeCustomObj),
                @"hideIfNil": @(YES)
            },
            PVAttr_NSImageView_Scaling_ImageScaling: @{
                @"className": @"NSImageView",
                @"fullTitle": @"ImageScaling",
                @"enumList": @"NSImageScaling",
                @"patch": @(YES)
            },
            PVAttr_NSImageView_Scaling_ImageAlignment: @{
                @"className": @"NSImageView",
                @"fullTitle": @"ImageAlignment",
                @"enumList": @"NSImageAlignment",
                @"patch": @(YES)
            },
            PVAttr_NSImageView_Scaling_ImageFrameStyle: @{
                @"className": @"NSImageView",
                @"fullTitle": @"ImageFrameStyle",
                @"enumList": @"NSImageFrameStyle",
                @"patch": @(YES)
            },
            PVAttr_NSImageView_Behavior_Animates: @{
                @"className": @"NSImageView",
                @"fullTitle": @"Animates",
                @"patch": @(YES)
            },
            PVAttr_NSImageView_Behavior_Editable: @{
                @"className": @"NSImageView",
                @"fullTitle": @"Editable",
                @"getterString": @"isEditable",
                @"patch": @(YES)
            },
            PVAttr_NSImageView_ContentTintColor_ContentTintColor: @{
                @"className": @"NSImageView",
                @"fullTitle": @"ContentTintColor",
                @"typeIfObj": @(PVAttrTypeUIColor),
                @"patch": @(YES)
            },
            PVAttr_NSControl_State_Enabled: @{
                @"className": @"NSControl",
                @"fullTitle": @"Enabled",
                @"getterString": @"isEnabled",
                @"patch": @(YES)
            },
            PVAttr_NSControl_State_Highlighted: @{
                @"className": @"NSControl",
                @"fullTitle": @"Highlighted",
                @"getterString": @"isHighlighted",
                @"patch": @(YES)
            },
            PVAttr_NSControl_State_Continuous: @{
                @"className": @"NSControl",
                @"fullTitle": @"Continuous",
                @"getterString": @"isContinuous",
                @"patch": @(NO)
            },
            PVAttr_NSControl_ControlSize_Size: @{
                @"className": @"NSControl",
                @"fullTitle": @"ControlSize",
                @"enumList": @"NSControlSize",
                @"patch": @(YES)
            },
            PVAttr_NSControl_Font_Name: @{
                @"className": @"NSControl",
                @"fullTitle": @"FontName",
                @"setterString": @"",
                @"getterString": @"pv_lks_fontName",
                @"typeIfObj": @(PVAttrTypeNSString),
                @"patch": @(NO)
            },
            PVAttr_NSControl_Font_Size: @{
                @"className": @"NSControl",
                @"fullTitle": @"FontSize",
                @"setterString": @"setLks_fontSize:",
                @"getterString": @"pv_lks_fontSize",
                @"patch": @(YES)
            },
            PVAttr_NSControl_Alignment_Alignment: @{
                @"className": @"NSControl",
                @"fullTitle": @"Alignment",
                @"enumList": @"NSTextAlignment_AppKit",
                @"patch": @(YES)
            },
            PVAttr_NSControl_Misc_WritingDirection: @{
                @"className": @"NSControl",
                @"fullTitle": @"BaseWritingDirection",
                @"enumList": @"NSWritingDirection",
                @"patch": @(NO)
            },
            PVAttr_NSControl_Misc_IgnoresMultiClick: @{
                @"className": @"NSControl",
                @"fullTitle": @"IgnoresMultiClick",
                @"patch": @(NO)
            },
            PVAttr_NSControl_Misc_UsesSingleLineMode: @{
                @"className": @"NSControl",
                @"fullTitle": @"UsesSingleLineMode",
                @"patch": @(NO)
            },
            PVAttr_NSControl_Misc_AllowsExpansionToolTips: @{
                @"className": @"NSControl",
                @"fullTitle": @"AllowsExpansionToolTips",
                @"patch": @(NO)
            },
            PVAttr_NSControl_Value_StringValue: @{
                @"className": @"NSControl",
                @"fullTitle": @"StringValue",
                @"typeIfObj": @(PVAttrTypeNSString),
                @"patch": @(YES)
            },
            PVAttr_NSControl_Value_IntValue: @{
                @"className": @"NSControl",
                @"fullTitle": @"IntValue",
                @"patch": @(YES)
            },
            PVAttr_NSControl_Value_IntegerValue: @{
                @"className": @"NSControl",
                @"fullTitle": @"IntegerValue",
                @"patch": @(YES)
            },
            PVAttr_NSControl_Value_FloatValue: @{
                @"className": @"NSControl",
                @"fullTitle": @"FloatValue",
                @"patch": @(YES)
            },
            PVAttr_NSControl_Value_DoubleValue: @{
                @"className": @"NSControl",
                @"fullTitle": @"DoubleValue",
                @"patch": @(YES)
            },
            PVAttr_NSButton_ButtonType_ButtonType: @{
                @"className": @"NSButton",
                @"fullTitle": @"ButtonType",
                @"getterString": @"pv_lks_buttonType",
                @"enumList": @"NSButtonType",
                @"patch": @(YES)
            },
            PVAttr_NSButton_Title_Title: @{
                @"className": @"NSButton",
                @"fullTitle": @"Title",
                @"typeIfObj": @(PVAttrTypeNSString),
                @"patch": @(YES)
            },
            PVAttr_NSButton_Title_AlernateTitle: @{
                @"className": @"NSButton",
                @"fullTitle": @"AlternateTitle",
                @"typeIfObj": @(PVAttrTypeNSString),
                @"patch": @(YES)
            },
            PVAttr_NSButton_BezelStyle_BezelStyle: @{
                @"className": @"NSButton",
                @"fullTitle": @"BezelStyle",
                @"enumList": @"NSBezelStyle",
                @"patch": @(YES)
            },
            PVAttr_NSButton_Bordered_Bordered: @{
                @"className": @"NSButton",
                @"fullTitle": @"Bordered",
                @"getterString": @"isBordered",
                @"patch": @(YES)
            },
            PVAttr_NSButton_Transparent_Transparent: @{
                @"className": @"NSButton",
                @"fullTitle": @"Transparent",
                @"getterString": @"isTransparent",
                @"patch": @(YES)
            },
            PVAttr_NSButton_BezelColor_BezelColor: @{
                @"className": @"NSButton",
                @"fullTitle": @"BezelColor",
                @"typeIfObj": @(PVAttrTypeUIColor),
                @"patch": @(YES)
            },
            PVAttr_NSButton_ContentTintColor_ContentTintColor: @{
                @"className": @"NSButton",
                @"fullTitle": @"ContentTintColor",
                @"typeIfObj": @(PVAttrTypeUIColor),
                @"patch": @(YES)
            },
            PVAttr_NSButton_Misc_ShowsBorderOnlyWhileMouseInside: @{
                @"className": @"NSButton",
                @"fullTitle": @"ShowsBorderOnlyWhileMouseInside",
                @"patch": @(YES)
            },
            PVAttr_NSButton_Misc_MaxAcceleratorLevel: @{
                @"className": @"NSButton",
                @"fullTitle": @"MaxAcceleratorLevel",
                @"patch": @(YES)
            },
            PVAttr_NSButton_Misc_SpringLoaded: @{
                @"className": @"NSButton",
                @"fullTitle": @"SpringLoaded",
                @"patch": @(YES)
            },
            PVAttr_NSButton_Misc_HasDestructiveAction: @{
                @"className": @"NSButton",
                @"fullTitle": @"HasDestructiveAction",
                @"patch": @(YES)
            },
            PVAttr_NSScrollView_ContentOffset_Offset: @{
                @"className": @"NSScrollView",
                @"fullTitle": @"ContentOffset",
                @"setterString": @"setLks_contentOffset:",
                @"getterString": @"pv_lks_contentOffset",
                @"patch": @(YES)
            },
            PVAttr_NSScrollView_ContentSize_Size: @{
                @"className": @"NSScrollView",
                @"fullTitle": @"ContentSize",
                @"setterString": @"setLks_contentSize:",
                @"getterString": @"pv_lks_contentSize",
                @"patch": @(YES)
            },
            PVAttr_NSScrollView_ContentInset_ContentInset: @{
                @"className": @"NSScrollView",
                @"fullTitle": @"ContentInset",
                @"patch": @(YES)
            },
            PVAttr_NSScrollView_ContentInset_AutomaticallyAdjustsContentInsets: @{
                @"className": @"NSScrollView",
                @"fullTitle": @"AutomaticallyAdjustsContentInsets",
                @"patch": @(YES)
            },
            PVAttr_NSScrollView_BorderType_BorderType: @{
                @"className": @"NSScrollView",
                @"fullTitle": @"BorderType",
                @"enumList": @"NSBorderType",
                @"patch": @(YES)
            },
            PVAttr_NSScrollView_Scroller_Horizontal: @{
                @"className": @"NSScrollView",
                @"fullTitle": @"HasHorizontalScroller",
                @"patch": @(YES)
            },
            PVAttr_NSScrollView_Scroller_Vertical: @{
                @"className": @"NSScrollView",
                @"fullTitle": @"HasVerticalScroller",
                @"patch": @(YES)
            },
            PVAttr_NSScrollView_Scroller_AutohidesScrollers: @{
                @"className": @"NSScrollView",
                @"fullTitle": @"AutohidesScrollers",
                @"patch": @(YES)
            },
            PVAttr_NSScrollView_Scroller_ScrollerStyle: @{
                @"className": @"NSScrollView",
                @"fullTitle": @"ScrollerStyle",
                @"enumList": @"NSScrollerStyle",
                @"patch": @(YES)
            },
            PVAttr_NSScrollView_Scroller_ScrollerKnobStyle: @{
                @"className": @"NSScrollView",
                @"fullTitle": @"ScrollerKnobStyle",
                @"enumList": @"NSScrollerKnobStyle",
                @"patch": @(YES)
            },
            PVAttr_NSScrollView_Scroller_ScrollerInsets: @{
                @"className": @"NSScrollView",
                @"fullTitle": @"ScrollerInsets",
                @"patch": @(YES)
            },
            PVAttr_NSScrollView_Ruler_Horizontal: @{
                @"className": @"NSScrollView",
                @"fullTitle": @"HasHorizontalRuler",
                @"patch": @(YES)
            },
            PVAttr_NSScrollView_Ruler_Vertical: @{
                @"className": @"NSScrollView",
                @"fullTitle": @"HasVerticalRuler",
                @"patch": @(YES)
            },
            PVAttr_NSScrollView_Ruler_Visible: @{
                @"className": @"NSScrollView",
                @"fullTitle": @"RulersVisible",
                @"patch": @(YES)
            },
            PVAttr_NSScrollView_LineScroll_Horizontal: @{
                @"className": @"NSScrollView",
                @"fullTitle": @"HorizontalLineScroll",
                @"patch": @(YES)
            },
            PVAttr_NSScrollView_LineScroll_Vertical: @{
                @"className": @"NSScrollView",
                @"fullTitle": @"VerticalLineScroll",
                @"patch": @(YES)
            },
            PVAttr_NSScrollView_LineScroll_LineScroll: @{
                @"className": @"NSScrollView",
                @"fullTitle": @"LineScroll",
                @"patch": @(YES)
            },
            PVAttr_NSScrollView_PageScroll_Horizontal: @{
                @"className": @"NSScrollView",
                @"fullTitle": @"HorizontalPageScroll",
                @"patch": @(YES)
            },
            PVAttr_NSScrollView_PageScroll_Vertical: @{
                @"className": @"NSScrollView",
                @"fullTitle": @"VerticalPageScroll",
                @"patch": @(YES)
            },
            PVAttr_NSScrollView_PageScroll_PageScroll: @{
                @"className": @"NSScrollView",
                @"fullTitle": @"PageScroll",
                @"patch": @(YES)
            },
            PVAttr_NSScrollView_ScrollElasiticity_Horizontal: @{
                @"className": @"NSScrollView",
                @"fullTitle": @"HorizontalScrollElasticity",
                @"enumList": @"NSScrollElasticity",
                @"patch": @(YES)
            },
            PVAttr_NSScrollView_ScrollElasiticity_Vertical: @{
                @"className": @"NSScrollView",
                @"fullTitle": @"VerticalScrollElasticity",
                @"enumList": @"NSScrollElasticity",
                @"patch": @(YES)
            },
            PVAttr_NSScrollView_Misc_ScrollsDynamically: @{
                @"className": @"NSScrollView",
                @"fullTitle": @"ScrollsDynamically",
                @"patch": @(YES)
            },
            PVAttr_NSScrollView_Misc_UsesPredominantAxisScrolling: @{
                @"className": @"NSScrollView",
                @"fullTitle": @"UsesPredominantAxisScrolling",
                @"patch": @(YES)
            },
            PVAttr_NSScrollView_Magnification_AllowsMagnification: @{
                @"className": @"NSScrollView",
                @"fullTitle": @"AllowsMagnification",
                @"patch": @(YES)
            },
            PVAttr_NSScrollView_Magnification_Magnification: @{
                @"className": @"NSScrollView",
                @"fullTitle": @"Magnification",
                @"patch": @(YES)
            },
            PVAttr_NSScrollView_Magnification_Max: @{
                @"className": @"NSScrollView",
                @"fullTitle": @"MaximunMagnification",
                @"patch": @(YES)
            },
            PVAttr_NSScrollView_Magnification_Min: @{
                @"className": @"NSScrollView",
                @"fullTitle": @"MinimumMagnification",
                @"patch": @(YES)
            },
            PVAttr_NSTableView_AllowsColumnReordering_AllowsColumnReordering: @{
                @"className": @"NSTableView",
                @"fullTitle": @"AllowsColumnReordering",
                @"patch": @(YES)
            },
            PVAttr_NSTableView_AllowsColumnResizing_AllowsColumnResizing: @{
                @"className": @"NSTableView",
                @"fullTitle": @"AllowsColumnResizing",
                @"patch": @(YES)
            },
            PVAttr_NSTableView_ColumnAutoresizingStyle_ColumnAutoresizingStyle: @{
                @"className": @"NSTableView",
                @"fullTitle": @"ColumnAutoresizingStyle",
                @"enumList": @"NSTableViewColumnAutoresizingStyle",
                @"patch": @(YES)
            },
            PVAttr_NSTableView_GridStyleMask_GridStyleMask: @{
                @"className": @"NSTableView",
                @"fullTitle": @"GridStyleMask",
                @"enumList": @"NSTableViewGridLineStyle",
                @"patch": @(YES)
            },
            PVAttr_NSTableView_IntercellSpacing_IntercellSpacing: @{
                @"className": @"NSTableView",
                @"fullTitle": @"IntercellSpacing",
                @"patch": @(YES)
            },
            PVAttr_NSTableView_UseAlternatingRowBackgroundColors_UseAlternatingRowBackgroundColors: @{
                @"className": @"NSTableView",
                @"fullTitle": @"UsesAlternatingRowBackgroundColors",
                @"patch": @(YES)
            },
            PVAttr_NSTableView_GridColor_GridColor: @{
                @"className": @"NSTableView",
                @"fullTitle": @"GridColor",
                @"typeIfObj": @(PVAttrTypeUIColor),
                @"patch": @(YES)
            },
            PVAttr_NSTableView_RowSizeStyle_RowSizeStyle: @{
                @"className": @"NSTableView",
                @"fullTitle": @"RowSizeStyle",
                @"enumList": @"NSTableViewRowSizeStyle",
                @"patch": @(YES)
            },
            PVAttr_NSTableView_RowHeight_RowHeight: @{
                @"className": @"NSTableView",
                @"fullTitle": @"RowHeight",
                @"patch": @(YES)
            },
            PVAttr_NSTableView_NumberOfRows_NumberOfRows: @{
                @"className": @"NSTableView",
                @"fullTitle": @"NumberOfRows",
                @"setterString": @"",
                @"patch": @(YES)
            },
            PVAttr_NSTableView_NumberOfColumns_NumberOfColumns: @{
                @"className": @"NSTableView",
                @"fullTitle": @"NumberOfColumns",
                @"setterString": @"",
                @"patch": @(YES)
            },
            PVAttr_NSTableView_VerticalMotionCanBeginDrag_VerticalMotionCanBeginDrag: @{
                @"className": @"NSTableView",
                @"fullTitle": @"VerticalMotionCanBeginDrag",
                @"patch": @(YES)
            },
            PVAttr_NSTableView_AllowsMultipleSelection_AllowsMultipleSelection: @{
                @"className": @"NSTableView",
                @"fullTitle": @"AllowsMultipleSelection",
                @"patch": @(YES)
            },
            PVAttr_NSTableView_AllowsEmptySelection_AllowsEmptySelection: @{
                @"className": @"NSTableView",
                @"fullTitle": @"AllowsEmptySelection",
                @"patch": @(YES)
            },
            PVAttr_NSTableView_AllowsColumnSelection_AllowsColumnSelection: @{
                @"className": @"NSTableView",
                @"fullTitle": @"AllowsColumnSelection",
                @"patch": @(YES)
            },
            PVAttr_NSTableView_AllowsTypeSelect_AllowsTypeSelect: @{
                @"className": @"NSTableView",
                @"fullTitle": @"AllowsTypeSelect",
                @"patch": @(YES)
            },
            PVAttr_NSTableView_SelectionHighlightStyle_SelectionHighlightStyle: @{
                @"className": @"NSTableView",
                @"fullTitle": @"SelectionHighlightStyle",
                @"enumList": @"NSTableViewSelectionHighlightStyle",
                @"patch": @(YES)
            },
            PVAttr_NSTableView_DraggingDestinationFeedbackStyle_DraggingDestinationFeedbackStyle: @{
                @"className": @"NSTableView",
                @"fullTitle": @"DraggingDestinationFeedbackStyle",
                @"enumList": @"NSTableViewDraggingDestinationFeedbackStyle",
                @"patch": @(YES)
            },
            PVAttr_NSTableView_AutomaticRowHeights_AutomaticRowHeights: @{
                @"className": @"NSTableView",
                @"fullTitle": @"AutomaticRowHeights",
                @"patch": @(YES)
            },
            PVAttr_NSTableView_AutosaveName_AutosaveName: @{
                @"className": @"NSTableView",
                @"fullTitle": @"AutosaveName",
                @"patch": @(YES)
            },
            PVAttr_NSTableView_AutosaveTableColumns_AutosaveTableColumns: @{
                @"className": @"NSTableView",
                @"fullTitle": @"AutosaveTableColumns",
                @"patch": @(YES)
            },
            PVAttr_NSTableView_FloatsGroupRows_FloatsGroupRows: @{
                @"className": @"NSTableView",
                @"fullTitle": @"FloatsGroupRows",
                @"patch": @(YES)
            },
            PVAttr_NSTableView_RowActionsVisible_RowActionsVisible: @{
                @"className": @"NSTableView",
                @"fullTitle": @"RowActionsVisible",
                @"patch": @(YES)
            },
            PVAttr_NSTableView_UsesStaticContents_UsesStaticContents: @{
                @"className": @"NSTableView",
                @"fullTitle": @"UsesStaticContents",
                @"patch": @(YES)
            },
            PVAttr_NSTableView_UserInterfaceLayoutDirection_UserInterfaceLayoutDirection: @{
                @"className": @"NSTableView",
                @"fullTitle": @"UserInterfaceLayoutDirection",
                @"enumList": @"NSUserInterfaceLayoutDirection",
                @"patch": @(YES)
            },
            PVAttr_NSTableView_Style_Style: @{
                @"className": @"NSTableView",
                @"fullTitle": @"Style",
                @"enumList": @"NSTableViewStyle",
                @"patch": @(YES)
            },
            PVAttr_NSTextView_Font_Name: @{
                @"className": @"NSTextView",
                @"fullTitle": @"FontName",
                @"setterString": @"",
                @"getterString": @"pv_lks_fontName",
                @"typeIfObj": @(PVAttrTypeNSString),
                @"patch": @(NO)
            },
            PVAttr_NSTextView_Font_Size: @{
                @"className": @"NSTextView",
                @"fullTitle": @"FontSize",
                @"setterString": @"setLks_fontSize:",
                @"getterString": @"pv_lks_fontSize",
                @"patch": @(YES)
            },
            PVAttr_NSTextView_Basic_Editable: @{
                @"className": @"NSTextView",
                @"fullTitle": @"Editable",
                @"getterString": @"isEditable",
                @"patch": @(NO)
            },
            PVAttr_NSTextView_Basic_Selectable: @{
                @"className": @"NSTextView",
                @"fullTitle": @"Selectable",
                @"getterString": @"isSelectable",
                @"patch": @(NO)
            },
            PVAttr_NSTextView_Basic_RichText: @{
                @"className": @"NSTextView",
                @"fullTitle": @"RichText",
                @"getterString": @"isRichText",
                @"patch": @(NO)
            },
            PVAttr_NSTextView_Basic_FieldEditor: @{
                @"className": @"NSTextView",
                @"fullTitle": @"FieldEditor",
                @"getterString": @"isFieldEditor",
                @"patch": @(NO)
            },
            PVAttr_NSTextView_Basic_ImportsGraphics: @{
                @"className": @"NSTextView",
                @"fullTitle": @"ImportsGraphics",
                @"patch": @(NO)
            },
            PVAttr_NSTextView_String_String: @{
                @"className": @"NSTextView",
                @"fullTitle": @"String",
                @"typeIfObj": @(PVAttrTypeNSString),
                @"patch": @(YES)
            },
            PVAttr_NSTextView_TextColor_Color: @{
                @"className": @"NSTextView",
                @"fullTitle": @"TextColor",
                @"typeIfObj": @(PVAttrTypeUIColor),
                @"patch": @(YES)
            },
            PVAttr_NSTextView_Alignment_Alignment: @{
                @"className": @"NSTextView",
                @"fullTitle": @"Alignment",
                @"enumList": @"NSTextAlignment_AppKit",
                @"patch": @(YES)
            },
            PVAttr_NSTextView_ContainerInset_Inset: @{
                @"className": @"NSTextView",
                @"fullTitle": @"TextContainerInset",
                @"patch": @(YES)
            },
            PVAttr_NSTextView_BaseWritingDirection_BaseWritingDirection: @{
                @"className": @"NSTextView",
                @"fullTitle": @"BaseWritingDirection",
                @"enumList": @"NSWritingDirection",
                @"patch": @(NO)
            },
            PVAttr_NSTextView_MaxSize_MaxSize: @{
                @"className": @"NSTextView",
                @"fullTitle": @"MaxSize",
                @"patch": @(YES)
            },
            PVAttr_NSTextView_MinSize_MinSize: @{
                @"className": @"NSTextView",
                @"fullTitle": @"MinSize",
                @"patch": @(YES)
            },
            PVAttr_NSTextView_Resizable_Horizontal: @{
                @"className": @"NSTextView",
                @"fullTitle": @"HorizontallyResizable",
                @"patch": @(NO)
            },
            PVAttr_NSTextView_Resizable_Vertical: @{
                @"className": @"NSTextView",
                @"fullTitle": @"VerticallyResizable",
                @"patch": @(NO)
            },
            PVAttr_NSTextField_Bordered_Bordered: @{
                @"className": @"NSTextField",
                @"fullTitle": @"Bordered",
                @"getterString": @"isBordered",
                @"patch": @(NO)
            },
            PVAttr_NSTextField_Bezeled_Bezeled: @{
                @"className": @"NSTextField",
                @"fullTitle": @"Bezeled",
                @"getterString": @"isBezeled",
                @"patch": @(NO)
            },
            PVAttr_NSTextField_Editable_Editable: @{
                @"className": @"NSTextField",
                @"fullTitle": @"Editable",
                @"getterString": @"isEditable",
                @"patch": @(NO)
            },
            PVAttr_NSTextField_Selectable_Selectable: @{
                @"className": @"NSTextField",
                @"fullTitle": @"Selectable",
                @"getterString": @"isSelectable",
                @"patch": @(NO)
            },
            PVAttr_NSTextField_DrawsBackground_DrawsBackground: @{
                @"className": @"NSTextField",
                @"fullTitle": @"DrawsBackground",
                @"patch": @(YES)
            },
            PVAttr_NSTextField_BezelStyle_BezelStyle: @{
                @"className": @"NSTextField",
                @"fullTitle": @"BezelStyle",
                @"enumList": @"NSTextFieldBezelStyle",
                @"patch": @(YES)
            },
            PVAttr_NSTextField_PreferredMaxLayoutWidth_PreferredMaxLayoutWidth: @{
                @"className": @"NSTextField",
                @"fullTitle": @"PreferredMaxLayoutWidth",
                @"patch": @(YES)
            },
            PVAttr_NSTextField_MaximumNumberOfLines_MaximumNumberOfLines: @{
                @"className": @"NSTextField",
                @"fullTitle": @"MaximumNumberOfLines",
                @"patch": @(YES)
            },
            PVAttr_NSTextField_AllowsDefaultTighteningForTruncation_AllowsDefaultTighteningForTruncation: @{
                @"className": @"NSTextField",
                @"fullTitle": @"AllowsDefaultTighteningForTruncation",
                @"patch": @(YES)
            },
            PVAttr_NSTextField_LineBreakStrategy_LineBreakStrategy: @{
                @"className": @"NSTextField",
                @"fullTitle": @"LineBreakStrategy",
                @"enumList": @"NSLineBreakStrategy",
                @"patch": @(YES)
            },
            PVAttr_NSTextField_Placeholder_Placeholder: @{
                @"className": @"NSTextField",
                @"fullTitle": @"PlaceholderString",
                @"typeIfObj": @(PVAttrTypeNSString),
                @"patch": @(YES)
            },
            PVAttr_NSTextField_TextColor_Color: @{
                @"className": @"NSTextField",
                @"fullTitle": @"TextColor",
                @"typeIfObj": @(PVAttrTypeUIColor),
                @"patch": @(YES)
            },
            PVAttr_NSTextField_BackgroundColor_Color: @{
                @"className": @"NSTextField",
                @"fullTitle": @"BackgroundColor",
                @"typeIfObj": @(PVAttrTypeUIColor),
                @"patch": @(YES)
            },
            PVAttr_NSTextField_AllowsEditingTextAttributes_AllowsEditingTextAttributes: @{
                @"className": @"NSTextField",
                @"fullTitle": @"AllowsEditingTextAttributes",
                @"patch": @(YES)
            },
            PVAttr_NSTextField_ImportsGraphics_ImportsGraphics: @{
                @"className": @"NSTextField",
                @"fullTitle": @"ImportsGraphics",
                @"patch": @(YES)
            },
            PVAttr_NSVisualEffectView_Material_Material: @{
                @"className": @"NSVisualEffectView",
                @"fullTitle": @"Material",
                @"enumList": @"NSVisualEffectMaterial",
                @"patch": @(YES)
            },
            PVAttr_NSVisualEffectView_InteriorBackgroundStyle_InteriorBackgroundStyle: @{
                @"className": @"NSVisualEffectView",
                @"fullTitle": @"InteriorBackgroundStyle",
                @"enumList": @"NSBackgroundStyle",
                @"patch": @(YES)
            },
            PVAttr_NSVisualEffectView_BlendingMode_BlendingMode: @{
                @"className": @"NSVisualEffectView",
                @"fullTitle": @"BlendingMode",
                @"enumList": @"NSVisualEffectBlendingMode",
                @"patch": @(YES)
            },
            PVAttr_NSVisualEffectView_State_State: @{
                @"className": @"NSVisualEffectView",
                @"fullTitle": @"State",
                @"enumList": @"NSVisualEffectState",
                @"patch": @(YES)
            },
            PVAttr_NSVisualEffectView_Emphasized_Emphasized: @{
                @"className": @"NSVisualEffectView",
                @"fullTitle": @"Emphasized",
                @"getterString": @"isEmphasized",
                @"patch": @(YES)
            },
            PVAttr_NSStackView_Orientation_Orientation: @{
                @"className": @"NSStackView",
                @"fullTitle": @"Orientation",
                @"enumList": @"NSUserInterfaceLayoutOrientation",
                @"patch": @(YES)
            },
            PVAttr_NSStackView_EdgeInsets_EdgeInsets: @{
                @"className": @"NSStackView",
                @"fullTitle": @"EdgeInsets",
                @"patch": @(YES)
            },
            PVAttr_NSStackView_DetachesHiddenViews_DetachesHiddenViews: @{
                @"className": @"NSStackView",
                @"fullTitle": @"DetachesHiddenViews",
                @"patch": @(YES)
            },
            PVAttr_NSStackView_Distribution_Distribution: @{
                @"className": @"NSStackView",
                @"fullTitle": @"Distribution",
                @"enumList": @"NSStackViewDistribution",
                @"patch": @(YES)
            },
            PVAttr_NSStackView_Alignment_Alignment: @{
                @"className": @"NSStackView",
                @"fullTitle": @"Alignment",
                @"enumList": @"NSLayoutAttribute",
                @"patch": @(YES)
            },
            PVAttr_NSStackView_Spacing_Spacing: @{
                @"className": @"NSStackView",
                @"fullTitle": @"Spacing",
                @"patch": @(YES)
            },

            // MARK: - NSWindow
            PVAttr_NSWindow_Title_Title: @{
                @"className": @"NSWindow",
                @"fullTitle": @"Title",
                @"typeIfObj": @(PVAttrTypeNSString),
                @"patch": @(NO)
            },
            PVAttr_NSWindow_Title_Subtitle: @{
                @"className": @"NSWindow",
                @"fullTitle": @"Subtitle",
                @"typeIfObj": @(PVAttrTypeNSString),
                @"patch": @(NO),
                @"osVersion": @(11)
            },
            PVAttr_NSWindow_State_KeyWindow: @{
                @"className": @"NSWindow",
                @"fullTitle": @"KeyWindow",
                @"getterString": @"isKeyWindow",
                @"setterString": @"",
                @"patch": @(NO)
            },
            PVAttr_NSWindow_State_MainWindow: @{
                @"className": @"NSWindow",
                @"fullTitle": @"MainWindow",
                @"getterString": @"isMainWindow",
                @"setterString": @"",
                @"patch": @(NO)
            },
            PVAttr_NSWindow_State_Visible: @{
                @"className": @"NSWindow",
                @"fullTitle": @"Visible",
                @"getterString": @"isVisible",
                @"setterString": @"",
                @"patch": @(NO)
            },
            PVAttr_NSWindow_State_CanBecomeKeyWindow: @{
                @"className": @"NSWindow",
                @"fullTitle": @"CanBecomeKeyWindow",
                @"setterString": @"",
                @"patch": @(NO)
            },
            PVAttr_NSWindow_State_CanBecomeMainWindow: @{
                @"className": @"NSWindow",
                @"fullTitle": @"CanBecomeMainWindow",
                @"setterString": @"",
                @"patch": @(NO)
            },
            PVAttr_NSWindow_Style_Titled: @{
                @"className": @"NSWindow",
                @"fullTitle": @"Titled",
                @"getterString": @"pv_lks_styleMaskTitled",
                @"setterString": @"setLks_styleMaskTitled:",
                @"patch": @(YES)
            },
            PVAttr_NSWindow_Style_Closable: @{
                @"className": @"NSWindow",
                @"fullTitle": @"Closable",
                @"getterString": @"pv_lks_styleMaskClosable",
                @"setterString": @"setLks_styleMaskClosable:",
                @"patch": @(YES)
            },
            PVAttr_NSWindow_Style_Miniaturizable: @{
                @"className": @"NSWindow",
                @"fullTitle": @"Miniaturizable",
                @"getterString": @"pv_lks_styleMaskMiniaturizable",
                @"setterString": @"setLks_styleMaskMiniaturizable:",
                @"patch": @(YES)
            },
            PVAttr_NSWindow_Style_Resizable: @{
                @"className": @"NSWindow",
                @"fullTitle": @"Resizable",
                @"getterString": @"pv_lks_styleMaskResizable",
                @"setterString": @"setLks_styleMaskResizable:",
                @"patch": @(YES)
            },
            PVAttr_NSWindow_Style_UnifiedTitleAndToolbar: @{
                @"className": @"NSWindow",
                @"fullTitle": @"UnifiedTitleAndToolbar",
                @"getterString": @"pv_lks_styleMaskUnifiedTitleAndToolbar",
                @"setterString": @"setLks_styleMaskUnifiedTitleAndToolbar:",
                @"patch": @(YES)
            },
            PVAttr_NSWindow_Style_FullScreen: @{
                @"className": @"NSWindow",
                @"fullTitle": @"FullScreen",
                @"getterString": @"pv_lks_styleMaskFullScreen",
                @"setterString": @"",
                @"patch": @(NO)
            },
            PVAttr_NSWindow_Style_FullSizeContentView: @{
                @"className": @"NSWindow",
                @"fullTitle": @"FullSizeContentView",
                @"getterString": @"pv_lks_styleMaskFullSizeContentView",
                @"setterString": @"setLks_styleMaskFullSizeContentView:",
                @"patch": @(YES)
            },
            PVAttr_NSWindow_Style_UtilityWindow: @{
                @"className": @"NSWindow",
                @"fullTitle": @"UtilityWindow",
                @"getterString": @"pv_lks_styleMaskUtilityWindow",
                @"setterString": @"",
                @"patch": @(NO)
            },
            PVAttr_NSWindow_Style_DocModalWindow: @{
                @"className": @"NSWindow",
                @"fullTitle": @"DocModalWindow",
                @"getterString": @"pv_lks_styleMaskDocModalWindow",
                @"setterString": @"",
                @"patch": @(NO)
            },
            PVAttr_NSWindow_Style_NonactivatingPanel: @{
                @"className": @"NSWindow",
                @"fullTitle": @"NonactivatingPanel",
                @"getterString": @"pv_lks_styleMaskNonactivatingPanel",
                @"setterString": @"",
                @"patch": @(NO)
            },
            PVAttr_NSWindow_Style_HUDWindow: @{
                @"className": @"NSWindow",
                @"fullTitle": @"HUDWindow",
                @"getterString": @"pv_lks_styleMaskHUDWindow",
                @"setterString": @"",
                @"patch": @(NO)
            },
            PVAttr_NSWindow_CollectionBehavior_CanJoinAllSpaces: @{
                @"className": @"NSWindow",
                @"fullTitle": @"CanJoinAllSpaces",
                @"getterString": @"pv_lks_collectionBehaviorCanJoinAllSpaces",
                @"setterString": @"",
                @"patch": @(NO)
            },
            PVAttr_NSWindow_CollectionBehavior_MoveToActiveSpace: @{
                @"className": @"NSWindow",
                @"fullTitle": @"MoveToActiveSpace",
                @"getterString": @"pv_lks_collectionBehaviorMoveToActiveSpace",
                @"setterString": @"",
                @"patch": @(NO)
            },
            PVAttr_NSWindow_CollectionBehavior_ParticipatesInCycle: @{
                @"className": @"NSWindow",
                @"fullTitle": @"ParticipatesInCycle",
                @"getterString": @"pv_lks_collectionBehaviorParticipatesInCycle",
                @"setterString": @"",
                @"patch": @(NO)
            },
            PVAttr_NSWindow_CollectionBehavior_IgnoresCycle: @{
                @"className": @"NSWindow",
                @"fullTitle": @"IgnoresCycle",
                @"getterString": @"pv_lks_collectionBehaviorIgnoresCycle",
                @"setterString": @"",
                @"patch": @(NO)
            },
            PVAttr_NSWindow_CollectionBehavior_FullScreenPrimary: @{
                @"className": @"NSWindow",
                @"fullTitle": @"FullScreenPrimary",
                @"getterString": @"pv_lks_collectionBehaviorFullScreenPrimary",
                @"setterString": @"",
                @"patch": @(NO)
            },
            PVAttr_NSWindow_CollectionBehavior_FullScreenAuxiliary: @{
                @"className": @"NSWindow",
                @"fullTitle": @"FullScreenAuxiliary",
                @"getterString": @"pv_lks_collectionBehaviorFullScreenAuxiliary",
                @"setterString": @"",
                @"patch": @(NO)
            },
            PVAttr_NSWindow_CollectionBehavior_FullScreenNone: @{
                @"className": @"NSWindow",
                @"fullTitle": @"FullScreenNone",
                @"getterString": @"pv_lks_collectionBehaviorFullScreenNone",
                @"setterString": @"",
                @"patch": @(NO)
            },
            PVAttr_NSWindow_CollectionBehavior_FullScreenAllowsTiling: @{
                @"className": @"NSWindow",
                @"fullTitle": @"FullScreenAllowsTiling",
                @"getterString": @"pv_lks_collectionBehaviorFullScreenAllowsTiling",
                @"setterString": @"",
                @"patch": @(NO)
            },
            PVAttr_NSWindow_CollectionBehavior_FullScreenDisallowsTiling: @{
                @"className": @"NSWindow",
                @"fullTitle": @"FullScreenDisallowsTiling",
                @"getterString": @"pv_lks_collectionBehaviorFullScreenDisallowsTiling",
                @"setterString": @"",
                @"patch": @(NO)
            },
            PVAttr_NSWindow_Appearance_TitlebarAppearsTransparent: @{
                @"className": @"NSWindow",
                @"fullTitle": @"TitlebarAppearsTransparent",
                @"patch": @(YES)
            },
            PVAttr_NSWindow_Appearance_TitleVisibility: @{
                @"className": @"NSWindow",
                @"fullTitle": @"TitleVisibility",
                @"enumList": @"NSWindowTitleVisibility",
                @"patch": @(YES)
            },
            PVAttr_NSWindow_Appearance_ToolbarStyle: @{
                @"className": @"NSWindow",
                @"fullTitle": @"ToolbarStyle",
                @"enumList": @"NSWindowToolbarStyle",
                @"patch": @(YES),
                @"osVersion": @(11)
            },
            PVAttr_NSWindow_Appearance_TitlebarSeparatorStyle: @{
                @"className": @"NSWindow",
                @"fullTitle": @"TitlebarSeparatorStyle",
                @"enumList": @"NSTitlebarSeparatorStyle",
                @"patch": @(YES),
                @"osVersion": @(11)
            },
            PVAttr_NSWindow_Appearance_BackgroundColor: @{
                @"className": @"NSWindow",
                @"fullTitle": @"BackgroundColor",
                @"typeIfObj": @(PVAttrTypeUIColor),
                @"patch": @(YES)
            },
            PVAttr_NSWindow_Appearance_AlphaValue: @{
                @"className": @"NSWindow",
                @"fullTitle": @"AlphaValue",
                @"patch": @(YES)
            },
            PVAttr_NSWindow_Appearance_Opaque: @{
                @"className": @"NSWindow",
                @"fullTitle": @"Opaque",
                @"getterString": @"isOpaque",
                @"setterString": @"",
                @"patch": @(NO)
            },
            PVAttr_NSWindow_Appearance_HasShadow: @{
                @"className": @"NSWindow",
                @"fullTitle": @"HasShadow",
                @"patch": @(YES)
            },
            PVAttr_NSWindow_Behavior_Movable: @{
                @"className": @"NSWindow",
                @"fullTitle": @"Movable",
                @"getterString": @"isMovable",
                @"patch": @(NO)
            },
            PVAttr_NSWindow_Behavior_MovableByWindowBackground: @{
                @"className": @"NSWindow",
                @"fullTitle": @"MovableByWindowBackground",
                @"getterString": @"isMovableByWindowBackground",
                @"patch": @(NO)
            },
            PVAttr_NSWindow_Behavior_AnimationBehavior: @{
                @"className": @"NSWindow",
                @"fullTitle": @"AnimationBehavior",
                @"enumList": @"NSWindowAnimationBehavior",
                @"patch": @(NO)
            },
            PVAttr_NSWindow_Behavior_Level: @{
                @"className": @"NSWindow",
                @"fullTitle": @"Level",
                @"enumList": @"NSWindowLevel",
                @"patch": @(YES)
            },
            PVAttr_NSWindow_Behavior_HidesOnDeactivate: @{
                @"className": @"NSWindow",
                @"fullTitle": @"HidesOnDeactivate",
                @"patch": @(YES)
            },
            PVAttr_NSWindow_Behavior_TabbingMode: @{
                @"className": @"NSWindow",
                @"fullTitle": @"TabbingMode",
                @"enumList": @"NSWindowTabbingMode",
                @"patch": @(YES)
            },
            PVAttr_NSWindow_Size_MinSize: @{
                @"className": @"NSWindow",
                @"fullTitle": @"MinSize",
                @"patch": @(YES)
            },
            PVAttr_NSWindow_Size_MaxSize: @{
                @"className": @"NSWindow",
                @"fullTitle": @"MaxSize",
                @"patch": @(YES)
            },
            PVAttr_NSWindow_Info_WindowNumber: @{
                @"className": @"NSWindow",
                @"fullTitle": @"WindowNumber",
                @"setterString": @"",
                @"patch": @(NO)
            },
            PVAttr_NSWindow_Info_BackingScaleFactor: @{
                @"className": @"NSWindow",
                @"fullTitle": @"BackingScaleFactor",
                @"setterString": @"",
                @"patch": @(NO)
            },

            // MARK: - UIWindowScene
            PVAttr_UIWindowScene_State_ActivationState: @{
                @"className": @"UIWindowScene",
                @"fullTitle": @"ActivationState",
                @"getterString": @"activationState",
                @"setterString": @"",
                @"enumList": @"UISceneActivationState",
                @"patch": @(NO)
            },
            PVAttr_UIWindowScene_Title_Title: @{
                @"className": @"UIWindowScene",
                @"fullTitle": @"Title",
                @"patch": @(YES),
                @"typeIfObj": @(PVAttrTypeNSString)
            },
            PVAttr_UIWindowScene_Orientation_InterfaceOrientation: @{
                @"className": @"UIWindowScene",
                @"fullTitle": @"InterfaceOrientation",
                @"setterString": @"",
                @"enumList": @"UIInterfaceOrientation",
                @"patch": @(NO)
            },
            PVAttr_UIWindowScene_Windows_WindowCount: @{
                @"className": @"UIWindowScene",
                @"fullTitle": @"WindowCount",
                @"getterString": @"pv_lks_windowCount",
                @"setterString": @"",
                @"patch": @(NO)
            },
            PVAttr_UIWindowScene_Windows_KeyWindowClassName: @{
                @"className": @"UIWindowScene",
                @"fullTitle": @"KeyWindowClassName",
                @"getterString": @"pv_lks_keyWindowClassName",
                @"setterString": @"",
                @"typeIfObj": @(PVAttrTypeNSString),
                @"patch": @(NO)
            },
            PVAttr_UIWindowScene_Screen_ScreenBounds: @{
                @"className": @"UIWindowScene",
                @"fullTitle": @"ScreenBounds",
                @"getterString": @"pv_lks_screenBounds",
                @"setterString": @"",
                @"patch": @(NO)
            },
            PVAttr_UIWindowScene_Screen_ScreenScale: @{
                @"className": @"UIWindowScene",
                @"fullTitle": @"ScreenScale",
                @"getterString": @"pv_lks_screenScale",
                @"setterString": @"",
                @"patch": @(NO)
            },
            PVAttr_UIWindowScene_StatusBar_StatusBarHidden: @{
                @"className": @"UIWindowScene",
                @"fullTitle": @"StatusBarHidden",
                @"getterString": @"pv_lks_statusBarHidden",
                @"setterString": @"",
                @"patch": @(NO)
            },
            PVAttr_UIWindowScene_StatusBar_StatusBarStyle: @{
                @"className": @"UIWindowScene",
                @"fullTitle": @"StatusBarStyle",
                @"getterString": @"pv_lks_statusBarStyle",
                @"setterString": @"",
                @"enumList": @"UIStatusBarStyle",
                @"patch": @(NO)
            },
            PVAttr_UIWindowScene_StatusBar_StatusBarFrame: @{
                @"className": @"UIWindowScene",
                @"fullTitle": @"StatusBarFrame",
                @"getterString": @"pv_lks_statusBarFrame",
                @"setterString": @"",
                @"patch": @(NO)
            },
            PVAttr_UIWindowScene_Traits_UserInterfaceStyle: @{
                @"className": @"UIWindowScene",
                @"fullTitle": @"UserInterfaceStyle",
                @"getterString": @"pv_lks_userInterfaceStyle",
                @"setterString": @"",
                @"enumList": @"UIUserInterfaceStyle",
                @"patch": @(NO)
            },
            PVAttr_UIWindowScene_Traits_HorizontalSizeClass: @{
                @"className": @"UIWindowScene",
                @"fullTitle": @"HorizontalSizeClass",
                @"getterString": @"pv_lks_horizontalSizeClass",
                @"setterString": @"",
                @"enumList": @"UIUserInterfaceSizeClass",
                @"patch": @(NO)
            },
            PVAttr_UIWindowScene_Traits_VerticalSizeClass: @{
                @"className": @"UIWindowScene",
                @"fullTitle": @"VerticalSizeClass",
                @"getterString": @"pv_lks_verticalSizeClass",
                @"setterString": @"",
                @"enumList": @"UIUserInterfaceSizeClass",
                @"patch": @(NO)
            },
            PVAttr_UIWindowScene_Traits_UserInterfaceLevel: @{
                @"className": @"UIWindowScene",
                @"fullTitle": @"UserInterfaceLevel",
                @"getterString": @"pv_lks_userInterfaceLevel",
                @"setterString": @"",
                @"enumList": @"UIUserInterfaceLevel",
                @"patch": @(NO),
                @"osVersion": @(13)
            },
            PVAttr_UIWindowScene_Traits_ActiveAppearance: @{
                @"className": @"UIWindowScene",
                @"fullTitle": @"ActiveAppearance",
                @"getterString": @"pv_lks_activeAppearance",
                @"setterString": @"",
                @"enumList": @"UIUserInterfaceActiveAppearance",
                @"patch": @(NO),
                @"osVersion": @(14)
            },
            PVAttr_UIWindowScene_Traits_AccessibilityContrast: @{
                @"className": @"UIWindowScene",
                @"fullTitle": @"AccessibilityContrast",
                @"getterString": @"pv_lks_accessibilityContrast",
                @"setterString": @"",
                @"enumList": @"UIAccessibilityContrast",
                @"patch": @(NO),
                @"osVersion": @(13)
            },
            PVAttr_UIWindowScene_Traits_LegibilityWeight: @{
                @"className": @"UIWindowScene",
                @"fullTitle": @"LegibilityWeight",
                @"getterString": @"pv_lks_legibilityWeight",
                @"setterString": @"",
                @"enumList": @"UILegibilityWeight",
                @"patch": @(NO),
                @"osVersion": @(13)
            },
            PVAttr_UIWindowScene_Traits_DisplayScale: @{
                @"className": @"UIWindowScene",
                @"fullTitle": @"DisplayScale",
                @"getterString": @"pv_lks_traitDisplayScale",
                @"setterString": @"",
                @"patch": @(NO),
                @"osVersion": @(13)
            },
            PVAttr_UIWindowScene_Traits_DisplayGamut: @{
                @"className": @"UIWindowScene",
                @"fullTitle": @"DisplayGamut",
                @"getterString": @"pv_lks_displayGamut",
                @"setterString": @"",
                @"enumList": @"UIDisplayGamut",
                @"patch": @(NO),
                @"osVersion": @(13)
            },
            PVAttr_UIWindowScene_Traits_UserInterfaceIdiom: @{
                @"className": @"UIWindowScene",
                @"fullTitle": @"UserInterfaceIdiom",
                @"getterString": @"pv_lks_userInterfaceIdiom",
                @"setterString": @"",
                @"enumList": @"UIUserInterfaceIdiom",
                @"patch": @(NO),
                @"osVersion": @(13)
            },
            PVAttr_UIWindowScene_Traits_LayoutDirection: @{
                @"className": @"UIWindowScene",
                @"fullTitle": @"LayoutDirection",
                @"getterString": @"pv_lks_layoutDirection",
                @"setterString": @"",
                @"enumList": @"UITraitEnvironmentLayoutDirection",
                @"patch": @(NO),
                @"osVersion": @(13)
            },
            PVAttr_UIWindowScene_Traits_PreferredContentSizeCategory: @{
                @"className": @"UIWindowScene",
                @"fullTitle": @"PreferredContentSizeCategory",
                @"getterString": @"pv_lks_preferredContentSizeCategory",
                @"setterString": @"",
                @"typeIfObj": @(PVAttrTypeNSString),
                @"patch": @(NO),
                @"osVersion": @(13)
            },
            PVAttr_UIWindowScene_Traits_SceneCaptureState: @{
                @"className": @"UIWindowScene",
                @"fullTitle": @"SceneCaptureState",
                @"getterString": @"pv_lks_sceneCaptureState",
                @"setterString": @"",
                @"enumList": @"UISceneCaptureState",
                @"patch": @(NO),
                @"osVersion": @(17)
            },
            PVAttr_UIWindowScene_Traits_ImageDynamicRange: @{
                @"className": @"UIWindowScene",
                @"fullTitle": @"ImageDynamicRange",
                @"getterString": @"pv_lks_imageDynamicRange",
                @"setterString": @"",
                @"enumList": @"UIImageDynamicRange",
                @"patch": @(NO),
                @"osVersion": @(17)
            },
            PVAttr_UIWindowScene_Traits_TypesettingLanguage: @{
                @"className": @"UIWindowScene",
                @"fullTitle": @"TypesettingLanguage",
                @"getterString": @"pv_lks_typesettingLanguage",
                @"setterString": @"",
                @"typeIfObj": @(PVAttrTypeNSString),
                @"hideIfNil": @(YES),
                @"patch": @(NO),
                @"osVersion": @(17)
            },
            PVAttr_UIWindowScene_Session_PersistentIdentifier: @{
                @"className": @"UIWindowScene",
                @"fullTitle": @"PersistentIdentifier",
                @"getterString": @"pv_lks_sessionPersistentIdentifier",
                @"setterString": @"",
                @"typeIfObj": @(PVAttrTypeNSString),
                @"patch": @(NO)
            },
            PVAttr_UIWindowScene_Session_SessionRole: @{
                @"className": @"UIWindowScene",
                @"fullTitle": @"SessionRole",
                @"getterString": @"pv_lks_sessionRole",
                @"setterString": @"",
                @"typeIfObj": @(PVAttrTypeNSString),
                @"patch": @(NO)
            },
            // MARK: - UITraitCollection
            PVAttr_UITraitCollection_Appearance_UserInterfaceStyle: @{
                @"className": @"UIView",
                @"fullTitle": @"UserInterfaceStyle",
                @"getterString": @"pv_lks_traitCollection_userInterfaceStyle",
                @"setterString": @"",
                @"enumList": @"UIUserInterfaceStyle",
                @"patch": @(NO),
                @"osVersion": @(12)
            },
            PVAttr_UITraitCollection_Appearance_UserInterfaceLevel: @{
                @"className": @"UIView",
                @"fullTitle": @"UserInterfaceLevel",
                @"getterString": @"pv_lks_traitCollection_userInterfaceLevel",
                @"setterString": @"",
                @"enumList": @"UIUserInterfaceLevel",
                @"patch": @(NO),
                @"osVersion": @(13)
            },
            PVAttr_UITraitCollection_Appearance_ActiveAppearance: @{
                @"className": @"UIView",
                @"fullTitle": @"ActiveAppearance",
                @"getterString": @"pv_lks_traitCollection_activeAppearance",
                @"setterString": @"",
                @"enumList": @"UIUserInterfaceActiveAppearance",
                @"patch": @(NO),
                @"osVersion": @(14)
            },
            PVAttr_UITraitCollection_Appearance_AccessibilityContrast: @{
                @"className": @"UIView",
                @"fullTitle": @"AccessibilityContrast",
                @"getterString": @"pv_lks_traitCollection_accessibilityContrast",
                @"setterString": @"",
                @"enumList": @"UIAccessibilityContrast",
                @"patch": @(NO),
                @"osVersion": @(13)
            },
            PVAttr_UITraitCollection_Appearance_LegibilityWeight: @{
                @"className": @"UIView",
                @"fullTitle": @"LegibilityWeight",
                @"getterString": @"pv_lks_traitCollection_legibilityWeight",
                @"setterString": @"",
                @"enumList": @"UILegibilityWeight",
                @"patch": @(NO),
                @"osVersion": @(13)
            },
            PVAttr_UITraitCollection_SizeClass_HorizontalSizeClass: @{
                @"className": @"UIView",
                @"fullTitle": @"HorizontalSizeClass",
                @"getterString": @"pv_lks_traitCollection_horizontalSizeClass",
                @"setterString": @"",
                @"enumList": @"UIUserInterfaceSizeClass",
                @"patch": @(NO)
            },
            PVAttr_UITraitCollection_SizeClass_VerticalSizeClass: @{
                @"className": @"UIView",
                @"fullTitle": @"VerticalSizeClass",
                @"getterString": @"pv_lks_traitCollection_verticalSizeClass",
                @"setterString": @"",
                @"enumList": @"UIUserInterfaceSizeClass",
                @"patch": @(NO)
            },
            PVAttr_UITraitCollection_Display_DisplayScale: @{
                @"className": @"UIView",
                @"fullTitle": @"DisplayScale",
                @"getterString": @"pv_lks_traitCollection_displayScale",
                @"setterString": @"",
                @"patch": @(NO)
            },
            PVAttr_UITraitCollection_Display_DisplayGamut: @{
                @"className": @"UIView",
                @"fullTitle": @"DisplayGamut",
                @"getterString": @"pv_lks_traitCollection_displayGamut",
                @"setterString": @"",
                @"enumList": @"UIDisplayGamut",
                @"patch": @(NO),
                @"osVersion": @(10)
            },
            PVAttr_UITraitCollection_Display_ImageDynamicRange: @{
                @"className": @"UIView",
                @"fullTitle": @"ImageDynamicRange",
                @"getterString": @"pv_lks_traitCollection_imageDynamicRange",
                @"setterString": @"",
                @"enumList": @"UIImageDynamicRange",
                @"patch": @(NO),
                @"osVersion": @(17)
            },
            PVAttr_UITraitCollection_Device_UserInterfaceIdiom: @{
                @"className": @"UIView",
                @"fullTitle": @"UserInterfaceIdiom",
                @"getterString": @"pv_lks_traitCollection_userInterfaceIdiom",
                @"setterString": @"",
                @"enumList": @"UIUserInterfaceIdiom",
                @"patch": @(NO)
            },
            PVAttr_UITraitCollection_Device_ForceTouchCapability: @{
                @"className": @"UIView",
                @"fullTitle": @"ForceTouchCapability",
                @"getterString": @"pv_lks_traitCollection_forceTouchCapability",
                @"setterString": @"",
                @"enumList": @"UIForceTouchCapability",
                @"patch": @(NO),
                @"osVersion": @(9)
            },
            PVAttr_UITraitCollection_Layout_LayoutDirection: @{
                @"className": @"UIView",
                @"fullTitle": @"LayoutDirection",
                @"getterString": @"pv_lks_traitCollection_layoutDirection",
                @"setterString": @"",
                @"enumList": @"UITraitEnvironmentLayoutDirection",
                @"patch": @(NO),
                @"osVersion": @(10)
            },
            PVAttr_UITraitCollection_Content_PreferredContentSizeCategory: @{
                @"className": @"UIView",
                @"fullTitle": @"PreferredContentSizeCategory",
                @"getterString": @"pv_lks_traitCollection_preferredContentSizeCategory",
                @"setterString": @"",
                @"typeIfObj": @(PVAttrTypeNSString),
                @"patch": @(NO),
                @"osVersion": @(10)
            },
            PVAttr_UITraitCollection_Content_TypesettingLanguage: @{
                @"className": @"UIView",
                @"fullTitle": @"TypesettingLanguage",
                @"getterString": @"pv_lks_traitCollection_typesettingLanguage",
                @"setterString": @"",
                @"typeIfObj": @(PVAttrTypeNSString),
                @"hideIfNil": @(YES),
                @"patch": @(NO),
                @"osVersion": @(17)
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

+ (BOOL)isWindowPropertyWithAttrID:(PVAttrIdentifier)attrID {
    NSString *className = [self classNameWithAttrID:attrID];
    if ([className isEqualToString:@"UIWindowScene"]) {
        return YES;
    }

    if ([className isEqualToString:@"NSWindow"]) {
        return YES;
    }
    return NO;
}

+ (BOOL)isUIViewPropertyWithAttrID:(PVAttrIdentifier)attrID {
    NSString *className = [self classNameWithAttrID:attrID];

    if ([className isEqualToString:@"CALayer"]) {
        return NO;
    }

    if ([className isEqualToString:@"UIWindowScene"]) {
        return NO;
    }

    if ([className isEqualToString:@"NSWindow"]) {
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
        // 该属性不可在 PV 客户端中被修改
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

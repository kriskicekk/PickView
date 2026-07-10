//
//  PVAttrIdentifiers.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVAttrIdentifiers.h"

// value 不能重复（AppDelegate 里的 runTests 有相关 test）
// 如果要去掉某一项可以考虑注释掉而非直接删除，以防止新项和旧项的 value 相同而引发 preference 错乱（这些 value 会被存储到 userDefaults 里）

#pragma mark - Group

PVAttrGroupIdentifier const PVAttrGroup_None = @"n";
PVAttrGroupIdentifier const PVAttrGroup_Class = @"c";
PVAttrGroupIdentifier const PVAttrGroup_Relation = @"r";
PVAttrGroupIdentifier const PVAttrGroup_Layout = @"l";
PVAttrGroupIdentifier const PVAttrGroup_AutoLayout = @"a";
PVAttrGroupIdentifier const PVAttrGroup_ViewLayer = @"vl";
PVAttrGroupIdentifier const PVAttrGroup_UIImageView = @"i";
PVAttrGroupIdentifier const PVAttrGroup_UILabel = @"la";
PVAttrGroupIdentifier const PVAttrGroup_UIControl = @"co";
PVAttrGroupIdentifier const PVAttrGroup_UIButton = @"b";
PVAttrGroupIdentifier const PVAttrGroup_UIScrollView = @"s";
PVAttrGroupIdentifier const PVAttrGroup_UITableView = @"ta";
PVAttrGroupIdentifier const PVAttrGroup_UITextView = @"te";
PVAttrGroupIdentifier const PVAttrGroup_UITextField = @"tf";
PVAttrGroupIdentifier const PVAttrGroup_UIVisualEffectView = @"ve";
PVAttrGroupIdentifier const PVAttrGroup_UIStackView = @"UIStackView";



PVAttrGroupIdentifier const PVAttrGroup_NSImageView = @"NSImageView";
PVAttrGroupIdentifier const PVAttrGroup_NSControl = @"NSControl";
PVAttrGroupIdentifier const PVAttrGroup_NSButton = @"NSButton";
PVAttrGroupIdentifier const PVAttrGroup_NSScrollView = @"NSScrollView";
PVAttrGroupIdentifier const PVAttrGroup_NSTableView = @"NSTableView";
PVAttrGroupIdentifier const PVAttrGroup_NSTextView = @"NSTextView";
PVAttrGroupIdentifier const PVAttrGroup_NSTextField = @"NSTextField";
PVAttrGroupIdentifier const PVAttrGroup_NSVisualEffectView = @"NSVisualEffectView";
PVAttrGroupIdentifier const PVAttrGroup_NSStackView = @"NSStackView";
PVAttrGroupIdentifier const PVAttrGroup_NSWindow = @"NSWindow";


PVAttrGroupIdentifier const PVAttrGroup_UserCustom = @"guc"; // 用户自定义

#pragma mark - Section

PVAttrSectionIdentifier const PVAttrSec_None = @"n";

PVAttrSectionIdentifier const PVAttrSec_UserCustom = @"sec_ctm";

PVAttrSectionIdentifier const PVAttrSec_Class_Class = @"cl_c";

PVAttrSectionIdentifier const PVAttrSec_Relation_Relation = @"r_r";

PVAttrSectionIdentifier const PVAttrSec_Layout_Frame = @"l_f";
PVAttrSectionIdentifier const PVAttrSec_Layout_Bounds = @"l_b";
PVAttrSectionIdentifier const PVAttrSec_Layout_SafeArea = @"l_s";
PVAttrSectionIdentifier const PVAttrSec_Layout_Position = @"l_p";
PVAttrSectionIdentifier const PVAttrSec_Layout_AnchorPoint = @"l_a";

PVAttrSectionIdentifier const PVAttrSec_AutoLayout_Hugging = @"a_h";
PVAttrSectionIdentifier const PVAttrSec_AutoLayout_Resistance = @"a_r";
PVAttrSectionIdentifier const PVAttrSec_AutoLayout_Constraints = @"a_c";
PVAttrSectionIdentifier const PVAttrSec_AutoLayout_IntrinsicSize = @"a_i";

PVAttrSectionIdentifier const PVAttrSec_ViewLayer_Visibility = @"v_v";
PVAttrSectionIdentifier const PVAttrSec_ViewLayer_InterationAndMasks = @"v_i";
PVAttrSectionIdentifier const PVAttrSec_ViewLayer_Corner = @"v_c";
PVAttrSectionIdentifier const PVAttrSec_ViewLayer_BgColor = @"v_b";
PVAttrSectionIdentifier const PVAttrSec_ViewLayer_Border = @"v_bo";
PVAttrSectionIdentifier const PVAttrSec_ViewLayer_Shadow = @"v_s";
PVAttrSectionIdentifier const PVAttrSec_ViewLayer_ContentMode = @"v_co";
PVAttrSectionIdentifier const PVAttrSec_ViewLayer_TintColor = @"v_t";
PVAttrSectionIdentifier const PVAttrSec_ViewLayer_Tag = @"v_ta";

PVAttrSectionIdentifier const PVAttrSec_UIImageView_Name = @"i_n";
PVAttrSectionIdentifier const PVAttrSec_UIImageView_Open = @"i_o";

PVAttrSectionIdentifier const PVAttrSec_UILabel_Text = @"lb_t";
PVAttrSectionIdentifier const PVAttrSec_UILabel_Font = @"lb_f";
PVAttrSectionIdentifier const PVAttrSec_UILabel_NumberOfLines = @"lb_n";
PVAttrSectionIdentifier const PVAttrSec_UILabel_TextColor = @"lb_tc";
PVAttrSectionIdentifier const PVAttrSec_UILabel_BreakMode = @"lb_b";
PVAttrSectionIdentifier const PVAttrSec_UILabel_Alignment = @"lb_a";
PVAttrSectionIdentifier const PVAttrSec_UILabel_CanAdjustFont = @"lb_c";

PVAttrSectionIdentifier const PVAttrSec_UIControl_EnabledSelected = @"c_e";
PVAttrSectionIdentifier const PVAttrSec_UIControl_VerAlignment = @"c_v";
PVAttrSectionIdentifier const PVAttrSec_UIControl_HorAlignment = @"c_h";
PVAttrSectionIdentifier const PVAttrSec_UIControl_QMUIOutsideEdge = @"c_o";

PVAttrSectionIdentifier const PVAttrSec_UIButton_ContentInsets = @"b_c";
PVAttrSectionIdentifier const PVAttrSec_UIButton_TitleInsets = @"b_t";
PVAttrSectionIdentifier const PVAttrSec_UIButton_ImageInsets = @"b_i";

PVAttrSectionIdentifier const PVAttrSec_UIScrollView_ContentInset = @"s_c";
PVAttrSectionIdentifier const PVAttrSec_UIScrollView_AdjustedInset = @"s_a";
PVAttrSectionIdentifier const PVAttrSec_UIScrollView_IndicatorInset = @"s_i";
PVAttrSectionIdentifier const PVAttrSec_UIScrollView_Offset = @"s_o";
PVAttrSectionIdentifier const PVAttrSec_UIScrollView_ContentSize = @"s_cs";
PVAttrSectionIdentifier const PVAttrSec_UIScrollView_Behavior = @"s_b";
PVAttrSectionIdentifier const PVAttrSec_UIScrollView_ShowsIndicator = @"s_si";
PVAttrSectionIdentifier const PVAttrSec_UIScrollView_Bounce = @"s_bo";
PVAttrSectionIdentifier const PVAttrSec_UIScrollView_ScrollPaging = @"s_s";
PVAttrSectionIdentifier const PVAttrSec_UIScrollView_ContentTouches = @"s_ct";
PVAttrSectionIdentifier const PVAttrSec_UIScrollView_Zoom = @"s_z";
PVAttrSectionIdentifier const PVAttrSec_UIScrollView_QMUIInitialInset = @"s_ii";

PVAttrSectionIdentifier const PVAttrSec_UITableView_Style = @"t_s";
PVAttrSectionIdentifier const PVAttrSec_UITableView_SectionsNumber = @"t_sn";
PVAttrSectionIdentifier const PVAttrSec_UITableView_RowsNumber = @"t_r";
PVAttrSectionIdentifier const PVAttrSec_UITableView_SeparatorStyle = @"t_ss";
PVAttrSectionIdentifier const PVAttrSec_UITableView_SeparatorColor = @"t_sc";
PVAttrSectionIdentifier const PVAttrSec_UITableView_SeparatorInset = @"t_si";

PVAttrSectionIdentifier const PVAttrSec_UITextView_Basic = @"tv_b";
PVAttrSectionIdentifier const PVAttrSec_UITextView_Text = @"tv_t";
PVAttrSectionIdentifier const PVAttrSec_UITextView_Font = @"tv_f";
PVAttrSectionIdentifier const PVAttrSec_UITextView_TextColor = @"tv_tc";
PVAttrSectionIdentifier const PVAttrSec_UITextView_Alignment = @"tv_a";
PVAttrSectionIdentifier const PVAttrSec_UITextView_ContainerInset = @"tv_c";

PVAttrSectionIdentifier const PVAttrSec_UITextField_Text = @"tf_t";
PVAttrSectionIdentifier const PVAttrSec_UITextField_Placeholder = @"tf_p";
PVAttrSectionIdentifier const PVAttrSec_UITextField_Font = @"tf_f";
PVAttrSectionIdentifier const PVAttrSec_UITextField_TextColor = @"tf_tc";
PVAttrSectionIdentifier const PVAttrSec_UITextField_Alignment = @"tf_a";
PVAttrSectionIdentifier const PVAttrSec_UITextField_Clears = @"tf_c";
PVAttrSectionIdentifier const PVAttrSec_UITextField_CanAdjustFont = @"tf_ca";
PVAttrSectionIdentifier const PVAttrSec_UITextField_ClearButtonMode = @"tf_cb";

PVAttrSectionIdentifier const PVAttrSec_UIVisualEffectView_Style = @"ve_s";
PVAttrSectionIdentifier const PVAttrSec_UIVisualEffectView_QMUIForegroundColor = @"ve_f";

PVAttrSectionIdentifier const PVAttrSec_UIStackView_Axis = @"usv_axis";
PVAttrSectionIdentifier const PVAttrSec_UIStackView_Distribution = @"usv_dis";
PVAttrSectionIdentifier const PVAttrSec_UIStackView_Alignment = @"usv_align";
PVAttrSectionIdentifier const PVAttrSec_UIStackView_Spacing = @"usv_spa";

PVAttrSectionIdentifier const PVAttrSec_NSImageView_Name = @"NSImageView_Name";
PVAttrSectionIdentifier const PVAttrSec_NSImageView_Open = @"NSImageView_Open";
PVAttrSectionIdentifier const PVAttrSec_NSImageView_Scaling = @"NSImageView_Scaling";
PVAttrSectionIdentifier const PVAttrSec_NSImageView_Behavior = @"NSImageView_Behavior";
PVAttrSectionIdentifier const PVAttrSec_NSImageView_ContentTintColor = @"NSImageView_ContentTintColor";
PVAttrSectionIdentifier const PVAttrSec_NSControl_State = @"NSControl_State";
PVAttrSectionIdentifier const PVAttrSec_NSControl_ControlSize = @"NSControl_ControlSize";
PVAttrSectionIdentifier const PVAttrSec_NSControl_Font = @"NSControl_Font";
PVAttrSectionIdentifier const PVAttrSec_NSControl_Alignment = @"NSControl_Alignment";
PVAttrSectionIdentifier const PVAttrSec_NSControl_Misc = @"NSControl_Misc";
PVAttrSectionIdentifier const PVAttrSec_NSControl_Value = @"NSControl_Value";
PVAttrSectionIdentifier const PVAttrSec_NSControl_StringValue = @"NSControl_StringValue";
PVAttrSectionIdentifier const PVAttrSec_NSButton_ButtonType = @"NSButton_ButtonType";
PVAttrSectionIdentifier const PVAttrSec_NSButton_Title = @"NSButton_Title";
PVAttrSectionIdentifier const PVAttrSec_NSButton_BezelStyle = @"NSButton_BezelStyle";
PVAttrSectionIdentifier const PVAttrSec_NSButton_Bordered = @"NSButton_Bordered";
PVAttrSectionIdentifier const PVAttrSec_NSButton_Transparent = @"NSButton_Transparent";
PVAttrSectionIdentifier const PVAttrSec_NSButton_BezelColor = @"NSButton_BezelColor";
PVAttrSectionIdentifier const PVAttrSec_NSButton_ContentTintColor = @"NSButton_ContentTintColor";
PVAttrSectionIdentifier const PVAttrSec_NSButton_Misc = @"NSButton_Misc";
PVAttrSectionIdentifier const PVAttrSec_NSScrollView_ContentOffset = @"NSScrollView_ContentOffset";
PVAttrSectionIdentifier const PVAttrSec_NSScrollView_ContentSize = @"NSScrollView_ContentSize";
PVAttrSectionIdentifier const PVAttrSec_NSScrollView_ContentInset = @"NSScrollView_ContentInset";
PVAttrSectionIdentifier const PVAttrSec_NSScrollView_BorderType = @"NSScrollView_BorderType";
PVAttrSectionIdentifier const PVAttrSec_NSScrollView_Scroller = @"NSScrollView_Scroller";
PVAttrSectionIdentifier const PVAttrSec_NSScrollView_Ruler = @"NSScrollView_Ruler";
PVAttrSectionIdentifier const PVAttrSec_NSScrollView_LineScroll = @"NSScrollView_LineScroll";
PVAttrSectionIdentifier const PVAttrSec_NSScrollView_PageScroll = @"NSScrollView_PageScroll";
PVAttrSectionIdentifier const PVAttrSec_NSScrollView_ScrollElasiticity = @"NSScrollView_ScrollElasiticity";
PVAttrSectionIdentifier const PVAttrSec_NSScrollView_Misc = @"NSScrollView_Misc";
PVAttrSectionIdentifier const PVAttrSec_NSScrollView_Magnification = @"NSScrollView_Magnification";
PVAttrSectionIdentifier const PVAttrSec_NSTableView_RowHeight = @"NSTableView_RowHeight";
PVAttrSectionIdentifier const PVAttrSec_NSTableView_AutomaticRowHeights = @"NSTableView_AutomaticRowHeights";
PVAttrSectionIdentifier const PVAttrSec_NSTableView_IntercellSpacing = @"NSTableView_IntercellSpacing";
PVAttrSectionIdentifier const PVAttrSec_NSTableView_Style = @"NSTableView_Style";
PVAttrSectionIdentifier const PVAttrSec_NSTableView_ColumnAutoresizingStyle = @"NSTableView_ColumnAutoresizingStyle";
PVAttrSectionIdentifier const PVAttrSec_NSTableView_GridStyleMask = @"NSTableView_GridStyleMask";
PVAttrSectionIdentifier const PVAttrSec_NSTableView_SelectionHighlightStyle = @"NSTableView_SelectionHighlightStyle";
PVAttrSectionIdentifier const PVAttrSec_NSTableView_GridColor = @"NSTableView_GridColor";
PVAttrSectionIdentifier const PVAttrSec_NSTableView_RowSizeStyle = @"NSTableView_RowSizeStyle";
PVAttrSectionIdentifier const PVAttrSec_NSTableView_NumberOfRows = @"NSTableView_NumberOfRows";
PVAttrSectionIdentifier const PVAttrSec_NSTableView_NumberOfColumns = @"NSTableView_NumberOfColumns";
PVAttrSectionIdentifier const PVAttrSec_NSTableView_UseAlternatingRowBackgroundColors = @"NSTableView_UseAlternatingRowBackgroundColors";
PVAttrSectionIdentifier const PVAttrSec_NSTableView_AllowsColumnReordering = @"NSTableView_AllowsColumnReordering";
PVAttrSectionIdentifier const PVAttrSec_NSTableView_AllowsColumnResizing = @"NSTableView_AllowsColumnResizing";
PVAttrSectionIdentifier const PVAttrSec_NSTableView_AllowsMultipleSelection = @"NSTableView_AllowsMultipleSelection";
PVAttrSectionIdentifier const PVAttrSec_NSTableView_AllowsEmptySelection = @"NSTableView_AllowsEmptySelection";
PVAttrSectionIdentifier const PVAttrSec_NSTableView_AllowsColumnSelection = @"NSTableView_AllowsColumnSelection";
PVAttrSectionIdentifier const PVAttrSec_NSTableView_AllowsTypeSelect = @"NSTableView_AllowsTypeSelect";
PVAttrSectionIdentifier const PVAttrSec_NSTableView_DraggingDestinationFeedbackStyle = @"NSTableView_DraggingDestinationFeedbackStyle";
PVAttrSectionIdentifier const PVAttrSec_NSTableView_Autosave = @"NSTableView_Autosave";
PVAttrSectionIdentifier const PVAttrSec_NSTableView_FloatsGroupRows = @"NSTableView_FloatsGroupRows";
PVAttrSectionIdentifier const PVAttrSec_NSTableView_RowActionsVisible = @"NSTableView_RowActionsVisible";
PVAttrSectionIdentifier const PVAttrSec_NSTableView_UsesStaticContents = @"NSTableView_UsesStaticContents";
PVAttrSectionIdentifier const PVAttrSec_NSTableView_UserInterfaceLayoutDirection = @"NSTableView_UserInterfaceLayoutDirection";
PVAttrSectionIdentifier const PVAttrSec_NSTableView_VerticalMotionCanBeginDrag = @"NSTableView_VerticalMotionCanBeginDrag";
PVAttrSectionIdentifier const PVAttrSec_NSTextView_Font = @"NSTextView_Font";
PVAttrSectionIdentifier const PVAttrSec_NSTextView_Basic = @"NSTextView_Basic";
PVAttrSectionIdentifier const PVAttrSec_NSTextView_String = @"NSTextView_String";
PVAttrSectionIdentifier const PVAttrSec_NSTextView_TextColor = @"NSTextView_TextColor";
PVAttrSectionIdentifier const PVAttrSec_NSTextView_Alignment = @"NSTextView_Alignment";
PVAttrSectionIdentifier const PVAttrSec_NSTextView_ContainerInset = @"NSTextView_ContainerInset";
PVAttrSectionIdentifier const PVAttrSec_NSTextView_BaseWritingDirection = @"NSTextView_BaseWritingDirection";
PVAttrSectionIdentifier const PVAttrSec_NSTextView_Size = @"NSTextView_Size";
PVAttrSectionIdentifier const PVAttrSec_NSTextView_Resizable = @"NSTextView_Resizable";
PVAttrSectionIdentifier const PVAttrSec_NSTextField_Bordered = @"NSTextField_Bordered";
PVAttrSectionIdentifier const PVAttrSec_NSTextField_Bezeled = @"NSTextField_Bezeled";
PVAttrSectionIdentifier const PVAttrSec_NSTextField_BezelStyle = @"NSTextField_BezelStyle";
PVAttrSectionIdentifier const PVAttrSec_NSTextField_Editable = @"NSTextField_Editable";
PVAttrSectionIdentifier const PVAttrSec_NSTextField_Selectable = @"NSTextField_Selectable";
PVAttrSectionIdentifier const PVAttrSec_NSTextField_DrawsBackground = @"NSTextField_DrawsBackground";
PVAttrSectionIdentifier const PVAttrSec_NSTextField_PreferredMaxLayoutWidth = @"NSTextField_PreferredMaxLayoutWidth";
PVAttrSectionIdentifier const PVAttrSec_NSTextField_MaximumNumberOfLines = @"NSTextField_MaximumNumberOfLines";
PVAttrSectionIdentifier const PVAttrSec_NSTextField_AllowsDefaultTighteningForTruncation = @"NSTextField_AllowsDefaultTighteningForTruncation";
PVAttrSectionIdentifier const PVAttrSec_NSTextField_LineBreakStrategy = @"NSTextField_LineBreakStrategy";
PVAttrSectionIdentifier const PVAttrSec_NSTextField_Placeholder = @"NSTextField_Placeholder";
PVAttrSectionIdentifier const PVAttrSec_NSTextField_TextColor = @"NSTextField_TextColor";
PVAttrSectionIdentifier const PVAttrSec_NSVisualEffectView_Material = @"NSVisualEffectView_Material";
PVAttrSectionIdentifier const PVAttrSec_NSVisualEffectView_InteriorBackgroundStyle = @"NSVisualEffectView_InteriorBackgroundStyle";
PVAttrSectionIdentifier const PVAttrSec_NSVisualEffectView_BlendingMode = @"NSVisualEffectView_BlendingMode";
PVAttrSectionIdentifier const PVAttrSec_NSVisualEffectView_State = @"NSVisualEffectView_State";
PVAttrSectionIdentifier const PVAttrSec_NSVisualEffectView_Emphasized = @"NSVisualEffectView_Emphasized";
PVAttrSectionIdentifier const PVAttrSec_NSStackView_Orientation = @"NSStackView_Orientation";
PVAttrSectionIdentifier const PVAttrSec_NSStackView_EdgeInsets = @"NSStackView_EdgeInsets";
PVAttrSectionIdentifier const PVAttrSec_NSStackView_DetachesHiddenViews = @"NSStackView_DetachesHiddenViews";
PVAttrSectionIdentifier const PVAttrSec_NSStackView_Distribution = @"NSStackView_Distribution";
PVAttrSectionIdentifier const PVAttrSec_NSStackView_Alignment = @"NSStackView_Alignment";
PVAttrSectionIdentifier const PVAttrSec_NSStackView_Spacing = @"NSStackView_Spacing";

PVAttrSectionIdentifier const PVAttrSec_NSWindow_Title = @"NSWindow_Title";
PVAttrSectionIdentifier const PVAttrSec_NSWindow_Subtitle = @"NSWindow_Subtitle";
PVAttrSectionIdentifier const PVAttrSec_NSWindow_State = @"NSWindow_State";
PVAttrSectionIdentifier const PVAttrSec_NSWindow_Style = @"NSWindow_Style";
PVAttrSectionIdentifier const PVAttrSec_NSWindow_CollectionBehavior = @"NSWindow_CollectionBehavior";
PVAttrSectionIdentifier const PVAttrSec_NSWindow_Appearance = @"NSWindow_Appearance";
PVAttrSectionIdentifier const PVAttrSec_NSWindow_TitleVisibility = @"NSWindow_TitleVisibility";
PVAttrSectionIdentifier const PVAttrSec_NSWindow_ToolbarStyle = @"NSWindow_ToolbarStyle";
PVAttrSectionIdentifier const PVAttrSec_NSWindow_TitlebarSeparatorStyle = @"NSWindow_TitlebarSeparatorStyle";
PVAttrSectionIdentifier const PVAttrSec_NSWindow_Behavior = @"NSWindow_Behavior";
PVAttrSectionIdentifier const PVAttrSec_NSWindow_AnimationBehavior = @"NSWindow_AnimationBehavior";
PVAttrSectionIdentifier const PVAttrSec_NSWindow_Level = @"NSWindow_Level";
PVAttrSectionIdentifier const PVAttrSec_NSWindow_TabbingMode = @"NSWindow_TabbingMode";
PVAttrSectionIdentifier const PVAttrSec_NSWindow_Size = @"NSWindow_Size";
PVAttrSectionIdentifier const PVAttrSec_NSWindow_Info = @"NSWindow_Info";

#pragma mark - Attr

PVAttrIdentifier const PVAttr_None = @"n";
PVAttrIdentifier const PVAttr_UserCustom = @"ctm";

PVAttrIdentifier const PVAttr_Class_Class_Class = @"c_c_c";


PVAttrIdentifier const PVAttr_Relation_Relation_Relation = @"r_r_r";

PVAttrIdentifier const PVAttr_Layout_Frame_Frame = @"l_f_f";
PVAttrIdentifier const PVAttr_Layout_Bounds_Bounds = @"l_b_b";
PVAttrIdentifier const PVAttr_Layout_SafeArea_SafeArea = @"l_s_s";
PVAttrIdentifier const PVAttr_Layout_Position_Position = @"l_p_p";
PVAttrIdentifier const PVAttr_Layout_AnchorPoint_AnchorPoint = @"l_a_a";

PVAttrIdentifier const PVAttr_AutoLayout_Hugging_Hor = @"al_h_h";
PVAttrIdentifier const PVAttr_AutoLayout_Hugging_Ver = @"al_h_v";
PVAttrIdentifier const PVAttr_AutoLayout_Resistance_Hor = @"al_r_h";
PVAttrIdentifier const PVAttr_AutoLayout_Resistance_Ver = @"al_r_v";
PVAttrIdentifier const PVAttr_AutoLayout_Constraints_Constraints = @"al_c_c";
PVAttrIdentifier const PVAttr_AutoLayout_IntrinsicSize_Size = @"cl_i_s";

PVAttrIdentifier const PVAttr_ViewLayer_Visibility_Hidden = @"vl_v_h";
PVAttrIdentifier const PVAttr_ViewLayer_Visibility_Opacity = @"vl_v_o";
PVAttrIdentifier const PVAttr_ViewLayer_InterationAndMasks_Interaction = @"vl_i_i";
PVAttrIdentifier const PVAttr_ViewLayer_InterationAndMasks_MasksToBounds = @"vl_i_m";
PVAttrIdentifier const PVAttr_ViewLayer_Corner_Radius = @"vl_c_r";
PVAttrIdentifier const PVAttr_ViewLayer_BgColor_BgColor = @"vl_b_b";
PVAttrIdentifier const PVAttr_ViewLayer_Border_Color = @"vl_b_c";
PVAttrIdentifier const PVAttr_ViewLayer_Border_Width = @"vl_b_w";
PVAttrIdentifier const PVAttr_ViewLayer_Shadow_Color = @"vl_s_c";
PVAttrIdentifier const PVAttr_ViewLayer_Shadow_Opacity = @"vl_s_o";
PVAttrIdentifier const PVAttr_ViewLayer_Shadow_Radius = @"vl_s_r";
PVAttrIdentifier const PVAttr_ViewLayer_Shadow_OffsetW = @"vl_s_ow";
PVAttrIdentifier const PVAttr_ViewLayer_Shadow_OffsetH = @"vl_s_oh";
PVAttrIdentifier const PVAttr_ViewLayer_ContentMode_Mode = @"vl_c_m";
PVAttrIdentifier const PVAttr_ViewLayer_TintColor_Color = @"vl_t_c";
PVAttrIdentifier const PVAttr_ViewLayer_TintColor_Mode = @"vl_t_m";
PVAttrIdentifier const PVAttr_ViewLayer_Tag_Tag = @"vl_t_t";

PVAttrIdentifier const PVAttr_UIImageView_Name_Name = @"iv_n_n";
PVAttrIdentifier const PVAttr_UIImageView_Open_Open = @"iv_o_o";

PVAttrIdentifier const PVAttr_UILabel_Text_Text = @"lb_t_t";
PVAttrIdentifier const PVAttr_UILabel_Font_Name = @"lb_f_n";
PVAttrIdentifier const PVAttr_UILabel_Font_Size = @"lb_f_s";
PVAttrIdentifier const PVAttr_UILabel_NumberOfLines_NumberOfLines = @"lb_n_n";
PVAttrIdentifier const PVAttr_UILabel_TextColor_Color = @"lb_t_c";
PVAttrIdentifier const PVAttr_UILabel_Alignment_Alignment = @"lb_a_a";
PVAttrIdentifier const PVAttr_UILabel_BreakMode_Mode = @"lb_b_m";
PVAttrIdentifier const PVAttr_UILabel_CanAdjustFont_CanAdjustFont = @"lb_c_c";

PVAttrIdentifier const PVAttr_UIControl_EnabledSelected_Enabled = @"ct_e_e";
PVAttrIdentifier const PVAttr_UIControl_EnabledSelected_Selected = @"ct_e_s";
PVAttrIdentifier const PVAttr_UIControl_VerAlignment_Alignment = @"ct_v_a";
PVAttrIdentifier const PVAttr_UIControl_HorAlignment_Alignment = @"ct_h_a";
PVAttrIdentifier const PVAttr_UIControl_QMUIOutsideEdge_Edge = @"ct_o_e";

PVAttrIdentifier const PVAttr_UIButton_ContentInsets_Insets = @"bt_c_i";
PVAttrIdentifier const PVAttr_UIButton_TitleInsets_Insets = @"bt_t_i";
PVAttrIdentifier const PVAttr_UIButton_ImageInsets_Insets = @"bt_i_i";

PVAttrIdentifier const PVAttr_UIScrollView_Offset_Offset = @"sv_o_o";
PVAttrIdentifier const PVAttr_UIScrollView_ContentSize_Size = @"sv_c_s";
PVAttrIdentifier const PVAttr_UIScrollView_ContentInset_Inset = @"sv_c_i";
PVAttrIdentifier const PVAttr_UIScrollView_AdjustedInset_Inset = @"sv_a_i";
PVAttrIdentifier const PVAttr_UIScrollView_Behavior_Behavior = @"sv_b_b";
PVAttrIdentifier const PVAttr_UIScrollView_IndicatorInset_Inset = @"sv_i_i";
PVAttrIdentifier const PVAttr_UIScrollView_ScrollPaging_ScrollEnabled = @"sv_s_s";
PVAttrIdentifier const PVAttr_UIScrollView_ScrollPaging_PagingEnabled = @"sv_s_p";
PVAttrIdentifier const PVAttr_UIScrollView_Bounce_Ver = @"sv_b_v";
PVAttrIdentifier const PVAttr_UIScrollView_Bounce_Hor = @"sv_b_h";
PVAttrIdentifier const PVAttr_UIScrollView_ShowsIndicator_Hor = @"sv_h_h";
PVAttrIdentifier const PVAttr_UIScrollView_ShowsIndicator_Ver = @"sv_s_v";
PVAttrIdentifier const PVAttr_UIScrollView_ContentTouches_Delay = @"sv_c_d";
PVAttrIdentifier const PVAttr_UIScrollView_ContentTouches_CanCancel = @"sv_c_c";
PVAttrIdentifier const PVAttr_UIScrollView_Zoom_MinScale = @"sv_z_mi";
PVAttrIdentifier const PVAttr_UIScrollView_Zoom_MaxScale = @"sv_z_ma";
PVAttrIdentifier const PVAttr_UIScrollView_Zoom_Scale = @"sv_z_s";
PVAttrIdentifier const PVAttr_UIScrollView_Zoom_Bounce = @"sv_z_b";
PVAttrIdentifier const PVAttr_UIScrollView_QMUIInitialInset_Inset = @"sv_qi_i";

PVAttrIdentifier const PVAttr_UITableView_Style_Style = @"tv_s_s";
PVAttrIdentifier const PVAttr_UITableView_SectionsNumber_Number = @"tv_s_n";
PVAttrIdentifier const PVAttr_UITableView_RowsNumber_Number = @"tv_r_n";
PVAttrIdentifier const PVAttr_UITableView_SeparatorInset_Inset = @"tv_s_i";
PVAttrIdentifier const PVAttr_UITableView_SeparatorColor_Color = @"tv_s_c";
PVAttrIdentifier const PVAttr_UITableView_SeparatorStyle_Style = @"tv_ss_s";

PVAttrIdentifier const PVAttr_UITextView_Font_Name = @"te_f_n";
PVAttrIdentifier const PVAttr_UITextView_Font_Size = @"te_f_s";
PVAttrIdentifier const PVAttr_UITextView_Basic_Editable = @"te_b_e";
PVAttrIdentifier const PVAttr_UITextView_Basic_Selectable = @"te_b_s";
PVAttrIdentifier const PVAttr_UITextView_Text_Text = @"te_t_t";
PVAttrIdentifier const PVAttr_UITextView_TextColor_Color = @"te_t_c";
PVAttrIdentifier const PVAttr_UITextView_Alignment_Alignment = @"te_a_a";
PVAttrIdentifier const PVAttr_UITextView_ContainerInset_Inset = @"te_c_i";

PVAttrIdentifier const PVAttr_UITextField_Text_Text = @"tf_t_t";
PVAttrIdentifier const PVAttr_UITextField_Placeholder_Placeholder = @"tf_p_p";
PVAttrIdentifier const PVAttr_UITextField_Font_Name = @"tf_f_n";
PVAttrIdentifier const PVAttr_UITextField_Font_Size = @"tf_f_s";
PVAttrIdentifier const PVAttr_UITextField_TextColor_Color = @"tf_t_c";
PVAttrIdentifier const PVAttr_UITextField_Alignment_Alignment = @"tf_a_a";
PVAttrIdentifier const PVAttr_UITextField_Clears_ClearsOnBeginEditing = @"tf_c_c";
PVAttrIdentifier const PVAttr_UITextField_Clears_ClearsOnInsertion = @"tf_c_co";
PVAttrIdentifier const PVAttr_UITextField_CanAdjustFont_CanAdjustFont = @"tf_c_ca";
PVAttrIdentifier const PVAttr_UITextField_CanAdjustFont_MinSize = @"tf_c_m";
PVAttrIdentifier const PVAttr_UITextField_ClearButtonMode_Mode = @"tf_cb_m";

PVAttrIdentifier const PVAttr_UIVisualEffectView_Style_Style = @"ve_s_s";
PVAttrIdentifier const PVAttr_UIVisualEffectView_QMUIForegroundColor_Color = @"ve_f_c";

PVAttrIdentifier const PVAttr_UIStackView_Axis_Axis = @"usv_axis_axis";
PVAttrIdentifier const PVAttr_UIStackView_Distribution_Distribution = @"usv_dis_dis";
PVAttrIdentifier const PVAttr_UIStackView_Alignment_Alignment = @"usv_ali_ali";
PVAttrIdentifier const PVAttr_UIStackView_Spacing_Spacing = @"usv_spa_spa";

PVAttrIdentifier const PVAttr_NSImageView_Name_Name = @"NSImageView_Name_Name";
PVAttrIdentifier const PVAttr_NSImageView_Open_Open = @"NSImageView_Open_Open";
PVAttrIdentifier const PVAttr_NSImageView_Scaling_ImageScaling = @"NSImageView_Scaling_ImageScaling";
PVAttrIdentifier const PVAttr_NSImageView_Scaling_ImageAlignment = @"NSImageView_Scaling_ImageAlignment";
PVAttrIdentifier const PVAttr_NSImageView_Scaling_ImageFrameStyle = @"NSImageView_Scaling_ImageFrameStyle";
PVAttrIdentifier const PVAttr_NSImageView_Behavior_Animates = @"NSImageView_Behavior_Animates";
PVAttrIdentifier const PVAttr_NSImageView_Behavior_Editable = @"NSImageView_Behavior_Editable";
PVAttrIdentifier const PVAttr_NSImageView_ContentTintColor_ContentTintColor = @"NSImageView_ContentTintColor_ContentTintColor";
PVAttrIdentifier const PVAttr_NSControl_State_Enabled = @"NSControl_State_Enabled";
PVAttrIdentifier const PVAttr_NSControl_State_Highlighted = @"NSControl_State_Highlighted";
PVAttrIdentifier const PVAttr_NSControl_State_Continuous = @"NSControl_State_Continuous";
PVAttrIdentifier const PVAttr_NSControl_ControlSize_Size = @"NSControl_ControlSize_Size";
PVAttrIdentifier const PVAttr_NSControl_Font_Name = @"NSControl_Font_Name";
PVAttrIdentifier const PVAttr_NSControl_Font_Size = @"NSControl_Font_Size";
PVAttrIdentifier const PVAttr_NSControl_Alignment_Alignment = @"NSControl_Alignment_Alignment";
PVAttrIdentifier const PVAttr_NSControl_Misc_WritingDirection = @"NSControl_Misc_WritingDirection";
PVAttrIdentifier const PVAttr_NSControl_Misc_IgnoresMultiClick = @"NSControl_Misc_IgnoresMultiClick";
PVAttrIdentifier const PVAttr_NSControl_Misc_UsesSingleLineMode = @"NSControl_Misc_UsesSingleLineMode";
PVAttrIdentifier const PVAttr_NSControl_Misc_AllowsExpansionToolTips = @"NSControl_Misc_AllowsExpansionToolTips";
PVAttrIdentifier const PVAttr_NSControl_Value_StringValue = @"NSControl_Value_StringValue";
PVAttrIdentifier const PVAttr_NSControl_Value_IntValue = @"NSControl_Value_IntValue";
PVAttrIdentifier const PVAttr_NSControl_Value_IntegerValue = @"NSControl_Value_IntegerValue";
PVAttrIdentifier const PVAttr_NSControl_Value_FloatValue = @"NSControl_Value_FloatValue";
PVAttrIdentifier const PVAttr_NSControl_Value_DoubleValue = @"NSControl_Value_DoubleValue";
PVAttrIdentifier const PVAttr_NSButton_ButtonType_ButtonType = @"NSButton_ButtonType_ButtonType";
PVAttrIdentifier const PVAttr_NSButton_Title_Title = @"NSButton_Title_Title";
PVAttrIdentifier const PVAttr_NSButton_Title_AlernateTitle = @"NSButton_Title_AlernateTitle";
PVAttrIdentifier const PVAttr_NSButton_BezelStyle_BezelStyle = @"NSButton_BezelStyle_BezelStyle";
PVAttrIdentifier const PVAttr_NSButton_Bordered_Bordered = @"NSButton_Bordered_Bordered";
PVAttrIdentifier const PVAttr_NSButton_Transparent_Transparent = @"NSButton_Transparent_Transparent";
PVAttrIdentifier const PVAttr_NSButton_BezelColor_BezelColor = @"NSButton_BezelColor_BezelColor";
PVAttrIdentifier const PVAttr_NSButton_ContentTintColor_ContentTintColor = @"NSButton_ContentTintColor_ContentTintColor";
PVAttrIdentifier const PVAttr_NSButton_Misc_ShowsBorderOnlyWhileMouseInside = @"NSButton_Misc_ShowsBorderOnlyWhileMouseInside";
PVAttrIdentifier const PVAttr_NSButton_Misc_MaxAcceleratorLevel = @"NSButton_Misc_MaxAcceleratorLevel";
PVAttrIdentifier const PVAttr_NSButton_Misc_SpringLoaded = @"NSButton_Misc_SpringLoaded";
PVAttrIdentifier const PVAttr_NSButton_Misc_HasDestructiveAction = @"NSButton_Misc_HasDestructiveAction";
PVAttrIdentifier const PVAttr_NSScrollView_ContentOffset_Offset = @"NSScrollView_ContentOffset_Offset";
PVAttrIdentifier const PVAttr_NSScrollView_ContentSize_Size = @"NSScrollView_ContentSize_Size";
PVAttrIdentifier const PVAttr_NSScrollView_ContentInset_ContentInset = @"NSScrollView_ContentInset_ContentInset";
PVAttrIdentifier const PVAttr_NSScrollView_ContentInset_AutomaticallyAdjustsContentInsets = @"NSScrollView_ContentInset_AutomaticallyAdjustsContentInsets";
PVAttrIdentifier const PVAttr_NSScrollView_BorderType_BorderType = @"NSScrollView_BorderType_BorderType";
PVAttrIdentifier const PVAttr_NSScrollView_Scroller_Horizontal = @"NSScrollView_Scroller_Horizontal";
PVAttrIdentifier const PVAttr_NSScrollView_Scroller_Vertical = @"NSScrollView_Scroller_Vertical";
PVAttrIdentifier const PVAttr_NSScrollView_Scroller_AutohidesScrollers = @"NSScrollView_Scroller_AutohidesScrollers";
PVAttrIdentifier const PVAttr_NSScrollView_Scroller_ScrollerStyle = @"NSScrollView_Scroller_ScrollerStyle";
PVAttrIdentifier const PVAttr_NSScrollView_Scroller_ScrollerKnobStyle = @"NSScrollView_Scroller_ScrollerKnobStyle";
PVAttrIdentifier const PVAttr_NSScrollView_Scroller_ScrollerInsets = @"NSScrollView_Scroller_ScrollerInsets";
PVAttrIdentifier const PVAttr_NSScrollView_Ruler_Horizontal = @"NSScrollView_Ruler_Horizontal";
PVAttrIdentifier const PVAttr_NSScrollView_Ruler_Vertical = @"NSScrollView_Ruler_Vertical";
PVAttrIdentifier const PVAttr_NSScrollView_Ruler_Visible = @"NSScrollView_Ruler_Visible";
PVAttrIdentifier const PVAttr_NSScrollView_LineScroll_Horizontal = @"NSScrollView_LineScroll_Horizontal";
PVAttrIdentifier const PVAttr_NSScrollView_LineScroll_Vertical = @"NSScrollView_LineScroll_Vertical";
PVAttrIdentifier const PVAttr_NSScrollView_LineScroll_LineScroll = @"NSScrollView_LineScroll_LineScroll";
PVAttrIdentifier const PVAttr_NSScrollView_PageScroll_Horizontal = @"NSScrollView_PageScroll_Horizontal";
PVAttrIdentifier const PVAttr_NSScrollView_PageScroll_Vertical = @"NSScrollView_PageScroll_Vertical";
PVAttrIdentifier const PVAttr_NSScrollView_PageScroll_PageScroll = @"NSScrollView_PageScroll_PageScroll";
PVAttrIdentifier const PVAttr_NSScrollView_ScrollElasiticity_Horizontal = @"NSScrollView_ScrollElasiticity_Horizontal";
PVAttrIdentifier const PVAttr_NSScrollView_ScrollElasiticity_Vertical = @"NSScrollView_ScrollElasiticity_Vertical";
PVAttrIdentifier const PVAttr_NSScrollView_Misc_ScrollsDynamically = @"NSScrollView_Misc_ScrollsDynamically";
PVAttrIdentifier const PVAttr_NSScrollView_Misc_UsesPredominantAxisScrolling = @"NSScrollView_Misc_UsesPredominantAxisScrolling";
PVAttrIdentifier const PVAttr_NSScrollView_Magnification_AllowsMagnification = @"NSScrollView_Magnification_AllowsMagnification";
PVAttrIdentifier const PVAttr_NSScrollView_Magnification_Magnification = @"NSScrollView_Magnification_Magnification";
PVAttrIdentifier const PVAttr_NSScrollView_Magnification_Max = @"NSScrollView_Magnification_Max";
PVAttrIdentifier const PVAttr_NSScrollView_Magnification_Min = @"NSScrollView_Magnification_Min";
PVAttrIdentifier const PVAttr_NSTableView_AllowsColumnReordering_AllowsColumnReordering = @"NSTableView_AllowsColumnReordering_AllowsColumnReordering";
PVAttrIdentifier const PVAttr_NSTableView_AllowsColumnResizing_AllowsColumnResizing = @"NSTableView_AllowsColumnResizing_AllowsColumnResizing";
PVAttrIdentifier const PVAttr_NSTableView_ColumnAutoresizingStyle_ColumnAutoresizingStyle = @"NSTableView_ColumnAutoresizingStyle_ColumnAutoresizingStyle";
PVAttrIdentifier const PVAttr_NSTableView_GridStyleMask_GridStyleMask = @"NSTableView_GridStyleMask_GridStyleMask";
PVAttrIdentifier const PVAttr_NSTableView_IntercellSpacing_IntercellSpacing = @"NSTableView_IntercellSpacing_IntercellSpacing";
PVAttrIdentifier const PVAttr_NSTableView_UseAlternatingRowBackgroundColors_UseAlternatingRowBackgroundColors = @"NSTableView_UseAlternatingRowBackgroundColors_UseAlternatingRowBackgroundColors";
PVAttrIdentifier const PVAttr_NSTableView_GridColor_GridColor = @"NSTableView_GridColor_GridColor";
PVAttrIdentifier const PVAttr_NSTableView_RowSizeStyle_RowSizeStyle = @"NSTableView_RowSizeStyle_RowSizeStyle";
PVAttrIdentifier const PVAttr_NSTableView_RowHeight_RowHeight = @"NSTableView_RowHeight_RowHeight";
PVAttrIdentifier const PVAttr_NSTableView_NumberOfRows_NumberOfRows = @"NSTableView_NumberOfRows_NumberOfRows";
PVAttrIdentifier const PVAttr_NSTableView_NumberOfColumns_NumberOfColumns = @"NSTableView_NumberOfColumns_NumberOfColumns";
PVAttrIdentifier const PVAttr_NSTableView_VerticalMotionCanBeginDrag_VerticalMotionCanBeginDrag = @"NSTableView_VerticalMotionCanBeginDrag_VerticalMotionCanBeginDrag";
PVAttrIdentifier const PVAttr_NSTableView_AllowsMultipleSelection_AllowsMultipleSelection = @"NSTableView_AllowsMultipleSelection_AllowsMultipleSelection";
PVAttrIdentifier const PVAttr_NSTableView_AllowsEmptySelection_AllowsEmptySelection = @"NSTableView_AllowsEmptySelection_AllowsEmptySelection";
PVAttrIdentifier const PVAttr_NSTableView_AllowsColumnSelection_AllowsColumnSelection = @"NSTableView_AllowsColumnSelection_AllowsColumnSelection";
PVAttrIdentifier const PVAttr_NSTableView_AllowsTypeSelect_AllowsTypeSelect = @"NSTableView_AllowsTypeSelect_AllowsTypeSelect";
PVAttrIdentifier const PVAttr_NSTableView_SelectionHighlightStyle_SelectionHighlightStyle = @"NSTableView_SelectionHighlightStyle_SelectionHighlightStyle";
PVAttrIdentifier const PVAttr_NSTableView_DraggingDestinationFeedbackStyle_DraggingDestinationFeedbackStyle = @"NSTableView_DraggingDestinationFeedbackStyle_DraggingDestinationFeedbackStyle";
PVAttrIdentifier const PVAttr_NSTableView_AutomaticRowHeights_AutomaticRowHeights = @"NSTableView_AutomaticRowHeights_AutomaticRowHeights";
PVAttrIdentifier const PVAttr_NSTableView_AutosaveName_AutosaveName = @"NSTableView_AutosaveName_AutosaveName";
PVAttrIdentifier const PVAttr_NSTableView_AutosaveTableColumns_AutosaveTableColumns = @"NSTableView_AutosaveTableColumns_AutosaveTableColumns";
PVAttrIdentifier const PVAttr_NSTableView_FloatsGroupRows_FloatsGroupRows = @"NSTableView_FloatsGroupRows_FloatsGroupRows";
PVAttrIdentifier const PVAttr_NSTableView_RowActionsVisible_RowActionsVisible = @"NSTableView_RowActionsVisible_RowActionsVisible";
PVAttrIdentifier const PVAttr_NSTableView_UsesStaticContents_UsesStaticContents = @"NSTableView_UsesStaticContents_UsesStaticContents";
PVAttrIdentifier const PVAttr_NSTableView_UserInterfaceLayoutDirection_UserInterfaceLayoutDirection = @"NSTableView_UserInterfaceLayoutDirection_UserInterfaceLayoutDirection";
PVAttrIdentifier const PVAttr_NSTableView_Style_Style = @"NSTableView_Style_Style";
PVAttrIdentifier const PVAttr_NSTextView_Font_Name = @"NSTextView_Font_Name";
PVAttrIdentifier const PVAttr_NSTextView_Font_Size = @"NSTextView_Font_Size";
PVAttrIdentifier const PVAttr_NSTextView_Basic_Editable = @"NSTextView_Basic_Editable";
PVAttrIdentifier const PVAttr_NSTextView_Basic_Selectable = @"NSTextView_Basic_Selectable";
PVAttrIdentifier const PVAttr_NSTextView_Basic_RichText = @"NSTextView_Basic_RichText";
PVAttrIdentifier const PVAttr_NSTextView_Basic_FieldEditor = @"NSTextView_Basic_FieldEditor";
PVAttrIdentifier const PVAttr_NSTextView_Basic_ImportsGraphics = @"NSTextView_Basic_ImportsGraphics";
PVAttrIdentifier const PVAttr_NSTextView_String_String = @"NSTextView_String_String";
PVAttrIdentifier const PVAttr_NSTextView_TextColor_Color = @"NSTextView_TextColor_Color";
PVAttrIdentifier const PVAttr_NSTextView_Alignment_Alignment = @"NSTextView_Alignment_Alignment";
PVAttrIdentifier const PVAttr_NSTextView_ContainerInset_Inset = @"NSTextView_ContainerInset_Inset";
PVAttrIdentifier const PVAttr_NSTextView_BaseWritingDirection_BaseWritingDirection = @"NSTextView_BaseWritingDirection_BaseWritingDirection";
PVAttrIdentifier const PVAttr_NSTextView_MaxSize_MaxSize = @"NSTextView_MaxSize_MaxSize";
PVAttrIdentifier const PVAttr_NSTextView_MinSize_MinSize = @"NSTextView_MinSize_MinSize";
PVAttrIdentifier const PVAttr_NSTextView_Resizable_Horizontal = @"NSTextView_Resizable_Horizontal";
PVAttrIdentifier const PVAttr_NSTextView_Resizable_Vertical = @"NSTextView_Resizable_Vertical";
PVAttrIdentifier const PVAttr_NSTextField_Bordered_Bordered = @"NSTextField_Bordered_Bordered";
PVAttrIdentifier const PVAttr_NSTextField_Bezeled_Bezeled = @"NSTextField_Bezeled_Bezeled";
PVAttrIdentifier const PVAttr_NSTextField_Editable_Editable = @"NSTextField_Editable_Editable";
PVAttrIdentifier const PVAttr_NSTextField_Selectable_Selectable = @"NSTextField_Selectable_Selectable";
PVAttrIdentifier const PVAttr_NSTextField_DrawsBackground_DrawsBackground = @"NSTextField_DrawsBackground_DrawsBackground";
PVAttrIdentifier const PVAttr_NSTextField_BezelStyle_BezelStyle = @"NSTextField_BezelStyle_BezelStyle";
PVAttrIdentifier const PVAttr_NSTextField_PreferredMaxLayoutWidth_PreferredMaxLayoutWidth = @"NSTextField_PreferredMaxLayoutWidth_PreferredMaxLayoutWidth";
PVAttrIdentifier const PVAttr_NSTextField_MaximumNumberOfLines_MaximumNumberOfLines = @"NSTextField_MaximumNumberOfLines_MaximumNumberOfLines";
PVAttrIdentifier const PVAttr_NSTextField_AllowsDefaultTighteningForTruncation_AllowsDefaultTighteningForTruncation = @"NSTextField_AllowsDefaultTighteningForTruncation_AllowsDefaultTighteningForTruncation";
PVAttrIdentifier const PVAttr_NSTextField_LineBreakStrategy_LineBreakStrategy = @"NSTextField_LineBreakStrategy_LineBreakStrategy";
PVAttrIdentifier const PVAttr_NSTextField_Placeholder_Placeholder = @"NSTextField_Placeholder_Placeholder";
PVAttrIdentifier const PVAttr_NSTextField_TextColor_Color = @"NSTextField_TextColor_Color";
PVAttrIdentifier const PVAttr_NSTextField_BackgroundColor_Color = @"NSTextField_BackgroundColor_Color";
PVAttrIdentifier const PVAttr_NSTextField_AllowsEditingTextAttributes_AllowsEditingTextAttributes = @"NSTextField_AllowsEditingTextAttributes_AllowsEditingTextAttributes";
PVAttrIdentifier const PVAttr_NSTextField_ImportsGraphics_ImportsGraphics = @"NSTextField_ImportsGraphics_ImportsGraphics";
PVAttrIdentifier const PVAttr_NSVisualEffectView_Material_Material = @"NSVisualEffectView_Material_Material";
PVAttrIdentifier const PVAttr_NSVisualEffectView_InteriorBackgroundStyle_InteriorBackgroundStyle = @"NSVisualEffectView_InteriorBackgroundStyle_InteriorBackgroundStyle";
PVAttrIdentifier const PVAttr_NSVisualEffectView_BlendingMode_BlendingMode = @"NSVisualEffectView_BlendingMode_BlendingMode";
PVAttrIdentifier const PVAttr_NSVisualEffectView_State_State = @"NSVisualEffectView_State_State";
PVAttrIdentifier const PVAttr_NSVisualEffectView_Emphasized_Emphasized = @"NSVisualEffectView_Emphasized_Emphasized";
PVAttrIdentifier const PVAttr_NSStackView_Orientation_Orientation = @"NSStackView_Orientation_Orientation";
PVAttrIdentifier const PVAttr_NSStackView_EdgeInsets_EdgeInsets = @"NSStackView_EdgeInsets_EdgeInsets";
PVAttrIdentifier const PVAttr_NSStackView_DetachesHiddenViews_DetachesHiddenViews = @"NSStackView_DetachesHiddenViews_DetachesHiddenViews";
PVAttrIdentifier const PVAttr_NSStackView_Distribution_Distribution = @"NSStackView_Distribution_Distribution";
PVAttrIdentifier const PVAttr_NSStackView_Alignment_Alignment = @"NSStackView_Alignment_Alignment";
PVAttrIdentifier const PVAttr_NSStackView_Spacing_Spacing = @"NSStackView_Spacing_Spacing";

PVAttrIdentifier const PVAttr_NSWindow_Title_Title = @"NSWindow_Title_Title";
PVAttrIdentifier const PVAttr_NSWindow_Title_Subtitle = @"NSWindow_Title_Subtitle";
PVAttrIdentifier const PVAttr_NSWindow_State_KeyWindow = @"NSWindow_State_KeyWindow";
PVAttrIdentifier const PVAttr_NSWindow_State_MainWindow = @"NSWindow_State_MainWindow";
PVAttrIdentifier const PVAttr_NSWindow_State_Visible = @"NSWindow_State_Visible";
PVAttrIdentifier const PVAttr_NSWindow_State_CanBecomeKeyWindow = @"NSWindow_State_CanBecomeKeyWindow";
PVAttrIdentifier const PVAttr_NSWindow_State_CanBecomeMainWindow = @"NSWindow_State_CanBecomeMainWindow";
PVAttrIdentifier const PVAttr_NSWindow_Style_Titled = @"NSWindow_Style_Titled";
PVAttrIdentifier const PVAttr_NSWindow_Style_Closable = @"NSWindow_Style_Closable";
PVAttrIdentifier const PVAttr_NSWindow_Style_Miniaturizable = @"NSWindow_Style_Miniaturizable";
PVAttrIdentifier const PVAttr_NSWindow_Style_Resizable = @"NSWindow_Style_Resizable";
PVAttrIdentifier const PVAttr_NSWindow_Style_UnifiedTitleAndToolbar = @"NSWindow_Style_UnifiedTitleAndToolbar";
PVAttrIdentifier const PVAttr_NSWindow_Style_FullScreen = @"NSWindow_Style_FullScreen";
PVAttrIdentifier const PVAttr_NSWindow_Style_FullSizeContentView = @"NSWindow_Style_FullSizeContentView";
PVAttrIdentifier const PVAttr_NSWindow_Style_UtilityWindow = @"NSWindow_Style_UtilityWindow";
PVAttrIdentifier const PVAttr_NSWindow_Style_DocModalWindow = @"NSWindow_Style_DocModalWindow";
PVAttrIdentifier const PVAttr_NSWindow_Style_NonactivatingPanel = @"NSWindow_Style_NonactivatingPanel";
PVAttrIdentifier const PVAttr_NSWindow_Style_HUDWindow = @"NSWindow_Style_HUDWindow";
PVAttrIdentifier const PVAttr_NSWindow_CollectionBehavior_CanJoinAllSpaces = @"NSWindow_CollectionBehavior_CanJoinAllSpaces";
PVAttrIdentifier const PVAttr_NSWindow_CollectionBehavior_MoveToActiveSpace = @"NSWindow_CollectionBehavior_MoveToActiveSpace";
PVAttrIdentifier const PVAttr_NSWindow_CollectionBehavior_ParticipatesInCycle = @"NSWindow_CollectionBehavior_ParticipatesInCycle";
PVAttrIdentifier const PVAttr_NSWindow_CollectionBehavior_IgnoresCycle = @"NSWindow_CollectionBehavior_IgnoresCycle";
PVAttrIdentifier const PVAttr_NSWindow_CollectionBehavior_FullScreenPrimary = @"NSWindow_CollectionBehavior_FullScreenPrimary";
PVAttrIdentifier const PVAttr_NSWindow_CollectionBehavior_FullScreenAuxiliary = @"NSWindow_CollectionBehavior_FullScreenAuxiliary";
PVAttrIdentifier const PVAttr_NSWindow_CollectionBehavior_FullScreenNone = @"NSWindow_CollectionBehavior_FullScreenNone";
PVAttrIdentifier const PVAttr_NSWindow_CollectionBehavior_FullScreenAllowsTiling = @"NSWindow_CollectionBehavior_FullScreenAllowsTiling";
PVAttrIdentifier const PVAttr_NSWindow_CollectionBehavior_FullScreenDisallowsTiling = @"NSWindow_CollectionBehavior_FullScreenDisallowsTiling";
PVAttrIdentifier const PVAttr_NSWindow_Appearance_TitlebarAppearsTransparent = @"NSWindow_Appearance_TitlebarAppearsTransparent";
PVAttrIdentifier const PVAttr_NSWindow_Appearance_TitleVisibility = @"NSWindow_Appearance_TitleVisibility";
PVAttrIdentifier const PVAttr_NSWindow_Appearance_ToolbarStyle = @"NSWindow_Appearance_ToolbarStyle";
PVAttrIdentifier const PVAttr_NSWindow_Appearance_TitlebarSeparatorStyle = @"NSWindow_Appearance_TitlebarSeparatorStyle";
PVAttrIdentifier const PVAttr_NSWindow_Appearance_BackgroundColor = @"NSWindow_Appearance_BackgroundColor";
PVAttrIdentifier const PVAttr_NSWindow_Appearance_AlphaValue = @"NSWindow_Appearance_AlphaValue";
PVAttrIdentifier const PVAttr_NSWindow_Appearance_Opaque = @"NSWindow_Appearance_Opaque";
PVAttrIdentifier const PVAttr_NSWindow_Appearance_HasShadow = @"NSWindow_Appearance_HasShadow";
PVAttrIdentifier const PVAttr_NSWindow_Behavior_Movable = @"NSWindow_Behavior_Movable";
PVAttrIdentifier const PVAttr_NSWindow_Behavior_MovableByWindowBackground = @"NSWindow_Behavior_MovableByWindowBackground";
PVAttrIdentifier const PVAttr_NSWindow_Behavior_AnimationBehavior = @"NSWindow_Behavior_AnimationBehavior";
PVAttrIdentifier const PVAttr_NSWindow_Behavior_Level = @"NSWindow_Behavior_Level";
PVAttrIdentifier const PVAttr_NSWindow_Behavior_HidesOnDeactivate = @"NSWindow_Behavior_HidesOnDeactivate";
PVAttrIdentifier const PVAttr_NSWindow_Behavior_TabbingMode = @"NSWindow_Behavior_TabbingMode";
PVAttrIdentifier const PVAttr_NSWindow_Size_MinSize = @"NSWindow_Size_MinSize";
PVAttrIdentifier const PVAttr_NSWindow_Size_MaxSize = @"NSWindow_Size_MaxSize";
PVAttrIdentifier const PVAttr_NSWindow_Info_WindowNumber = @"NSWindow_Info_WindowNumber";
PVAttrIdentifier const PVAttr_NSWindow_Info_BackingScaleFactor = @"NSWindow_Info_BackingScaleFactor";

// UIWindowScene
PVAttrGroupIdentifier const PVAttrGroup_UIWindowScene = @"UIWindowScene";

PVAttrSectionIdentifier const PVAttrSec_UIWindowScene_State = @"UIWindowScene_State";
PVAttrSectionIdentifier const PVAttrSec_UIWindowScene_Title = @"UIWindowScene_Title";
PVAttrSectionIdentifier const PVAttrSec_UIWindowScene_Orientation = @"UIWindowScene_Orientation";
PVAttrSectionIdentifier const PVAttrSec_UIWindowScene_Windows = @"UIWindowScene_Windows";
PVAttrSectionIdentifier const PVAttrSec_UIWindowScene_Screen = @"UIWindowScene_Screen";
PVAttrSectionIdentifier const PVAttrSec_UIWindowScene_StatusBar = @"UIWindowScene_StatusBar";
PVAttrSectionIdentifier const PVAttrSec_UIWindowScene_Traits = @"UIWindowScene_Traits";
PVAttrSectionIdentifier const PVAttrSec_UIWindowScene_Session = @"UIWindowScene_Session";

PVAttrIdentifier const PVAttr_UIWindowScene_State_ActivationState = @"UIWindowScene_State_ActivationState";
PVAttrIdentifier const PVAttr_UIWindowScene_Title_Title = @"UIWindowScene_Title_Title";
PVAttrIdentifier const PVAttr_UIWindowScene_Orientation_InterfaceOrientation = @"UIWindowScene_Orientation_InterfaceOrientation";
PVAttrIdentifier const PVAttr_UIWindowScene_Windows_WindowCount = @"UIWindowScene_Windows_WindowCount";
PVAttrIdentifier const PVAttr_UIWindowScene_Windows_KeyWindowClassName = @"UIWindowScene_Windows_KeyWindowClassName";
PVAttrIdentifier const PVAttr_UIWindowScene_Screen_ScreenBounds = @"UIWindowScene_Screen_ScreenBounds";
PVAttrIdentifier const PVAttr_UIWindowScene_Screen_ScreenScale = @"UIWindowScene_Screen_ScreenScale";
PVAttrIdentifier const PVAttr_UIWindowScene_StatusBar_StatusBarHidden = @"UIWindowScene_StatusBar_StatusBarHidden";
PVAttrIdentifier const PVAttr_UIWindowScene_StatusBar_StatusBarStyle = @"UIWindowScene_StatusBar_StatusBarStyle";
PVAttrIdentifier const PVAttr_UIWindowScene_StatusBar_StatusBarFrame = @"UIWindowScene_StatusBar_StatusBarFrame";
PVAttrIdentifier const PVAttr_UIWindowScene_Traits_UserInterfaceStyle = @"UIWindowScene_Traits_UserInterfaceStyle";
PVAttrIdentifier const PVAttr_UIWindowScene_Traits_HorizontalSizeClass = @"UIWindowScene_Traits_HorizontalSizeClass";
PVAttrIdentifier const PVAttr_UIWindowScene_Traits_VerticalSizeClass = @"UIWindowScene_Traits_VerticalSizeClass";
PVAttrIdentifier const PVAttr_UIWindowScene_Session_PersistentIdentifier = @"UIWindowScene_Session_PersistentIdentifier";
PVAttrIdentifier const PVAttr_UIWindowScene_Session_SessionRole = @"UIWindowScene_Session_SessionRole";

// UIWindowScene additional traits
PVAttrIdentifier const PVAttr_UIWindowScene_Traits_UserInterfaceLevel = @"UIWindowScene_Traits_UserInterfaceLevel";
PVAttrIdentifier const PVAttr_UIWindowScene_Traits_ActiveAppearance = @"UIWindowScene_Traits_ActiveAppearance";
PVAttrIdentifier const PVAttr_UIWindowScene_Traits_AccessibilityContrast = @"UIWindowScene_Traits_AccessibilityContrast";
PVAttrIdentifier const PVAttr_UIWindowScene_Traits_LegibilityWeight = @"UIWindowScene_Traits_LegibilityWeight";
PVAttrIdentifier const PVAttr_UIWindowScene_Traits_DisplayScale = @"UIWindowScene_Traits_DisplayScale";
PVAttrIdentifier const PVAttr_UIWindowScene_Traits_DisplayGamut = @"UIWindowScene_Traits_DisplayGamut";
PVAttrIdentifier const PVAttr_UIWindowScene_Traits_UserInterfaceIdiom = @"UIWindowScene_Traits_UserInterfaceIdiom";
PVAttrIdentifier const PVAttr_UIWindowScene_Traits_LayoutDirection = @"UIWindowScene_Traits_LayoutDirection";
PVAttrIdentifier const PVAttr_UIWindowScene_Traits_PreferredContentSizeCategory = @"UIWindowScene_Traits_PreferredContentSizeCategory";
PVAttrIdentifier const PVAttr_UIWindowScene_Traits_SceneCaptureState = @"UIWindowScene_Traits_SceneCaptureState";
PVAttrIdentifier const PVAttr_UIWindowScene_Traits_ImageDynamicRange = @"UIWindowScene_Traits_ImageDynamicRange";
PVAttrIdentifier const PVAttr_UIWindowScene_Traits_TypesettingLanguage = @"UIWindowScene_Traits_TypesettingLanguage";

// UITraitCollection
PVAttrGroupIdentifier const PVAttrGroup_UITraitCollection = @"UITraitCollection";

PVAttrSectionIdentifier const PVAttrSec_UITraitCollection_Appearance = @"UITraitCollection_Appearance";
PVAttrSectionIdentifier const PVAttrSec_UITraitCollection_SizeClass = @"UITraitCollection_SizeClass";
PVAttrSectionIdentifier const PVAttrSec_UITraitCollection_Display = @"UITraitCollection_Display";
PVAttrSectionIdentifier const PVAttrSec_UITraitCollection_Device = @"UITraitCollection_Device";
PVAttrSectionIdentifier const PVAttrSec_UITraitCollection_Layout = @"UITraitCollection_Layout";
PVAttrSectionIdentifier const PVAttrSec_UITraitCollection_Content = @"UITraitCollection_Content";

PVAttrIdentifier const PVAttr_UITraitCollection_Appearance_UserInterfaceStyle = @"UITraitCollection_Appearance_UserInterfaceStyle";
PVAttrIdentifier const PVAttr_UITraitCollection_Appearance_UserInterfaceLevel = @"UITraitCollection_Appearance_UserInterfaceLevel";
PVAttrIdentifier const PVAttr_UITraitCollection_Appearance_ActiveAppearance = @"UITraitCollection_Appearance_ActiveAppearance";
PVAttrIdentifier const PVAttr_UITraitCollection_Appearance_AccessibilityContrast = @"UITraitCollection_Appearance_AccessibilityContrast";
PVAttrIdentifier const PVAttr_UITraitCollection_Appearance_LegibilityWeight = @"UITraitCollection_Appearance_LegibilityWeight";
PVAttrIdentifier const PVAttr_UITraitCollection_SizeClass_HorizontalSizeClass = @"UITraitCollection_SizeClass_HorizontalSizeClass";
PVAttrIdentifier const PVAttr_UITraitCollection_SizeClass_VerticalSizeClass = @"UITraitCollection_SizeClass_VerticalSizeClass";
PVAttrIdentifier const PVAttr_UITraitCollection_Display_DisplayScale = @"UITraitCollection_Display_DisplayScale";
PVAttrIdentifier const PVAttr_UITraitCollection_Display_DisplayGamut = @"UITraitCollection_Display_DisplayGamut";
PVAttrIdentifier const PVAttr_UITraitCollection_Display_ImageDynamicRange = @"UITraitCollection_Display_ImageDynamicRange";
PVAttrIdentifier const PVAttr_UITraitCollection_Device_UserInterfaceIdiom = @"UITraitCollection_Device_UserInterfaceIdiom";
PVAttrIdentifier const PVAttr_UITraitCollection_Device_ForceTouchCapability = @"UITraitCollection_Device_ForceTouchCapability";
PVAttrIdentifier const PVAttr_UITraitCollection_Layout_LayoutDirection = @"UITraitCollection_Layout_LayoutDirection";
PVAttrIdentifier const PVAttr_UITraitCollection_Content_PreferredContentSizeCategory = @"UITraitCollection_Content_PreferredContentSizeCategory";
PVAttrIdentifier const PVAttr_UITraitCollection_Content_TypesettingLanguage = @"UITraitCollection_Content_TypesettingLanguage";

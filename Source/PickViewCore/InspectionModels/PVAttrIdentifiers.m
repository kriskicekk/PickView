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

PVAttrGroupIdentifier const PVAttrGroup_UserCustom = @"guc"; // user custom

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


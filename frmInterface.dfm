object frm_Interface: Tfrm_Interface
  Left = 447
  Top = 271
  Width = 855
  Height = 670
  Caption = #1055#1088#1086#1075#1088#1072#1084#1084#1072' '#1076#1083#1103' '#1084#1086#1076#1077#1083#1080#1088#1086#1074#1072#1085#1080#1103' '#1087#1086#1083#1077#1090#1085#1086#1075#1086' '#1079#1072#1076#1072#1085#1080#1103
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lbl_H0name: TLabel
    Left = 16
    Top = 88
    Width = 26
    Height = 13
    Caption = 'H0, '#1084
  end
  object lbl_H0value: TLabel
    Left = 152
    Top = 88
    Width = 27
    Height = 13
    Caption = #1079#1085#1072#1095'.'
  end
  object lbl_Gname: TLabel
    Left = 16
    Top = 120
    Width = 25
    Height = 13
    Caption = 'G, '#1082#1075
  end
  object lbl_Gvalue: TLabel
    Left = 152
    Top = 120
    Width = 27
    Height = 13
    Caption = #1079#1085#1072#1095'.'
  end
  object lbl_Tname: TLabel
    Left = 8
    Top = 152
    Width = 37
    Height = 13
    Caption = 'T, '#1075#1088#1072#1076
  end
  object lbl_Tvalue: TLabel
    Left = 152
    Top = 152
    Width = 27
    Height = 13
    Caption = #1079#1085#1072#1095'.'
  end
  object lblV0: TLabel
    Left = 4
    Top = 183
    Width = 41
    Height = 13
    Caption = 'V0, '#1082#1084'/'#1095
  end
  object lblV0value: TLabel
    Left = 152
    Top = 184
    Width = 27
    Height = 13
    Caption = #1079#1085#1072#1095'.'
  end
  object lst_Manevry: TListBox
    Left = 656
    Top = 8
    Width = 177
    Height = 121
    ItemHeight = 13
    PopupMenu = pm_Manevry
    TabOrder = 0
    OnMouseDown = lst_ManevryMouseDown
  end
  object cbb_Manevry: TComboBox
    Left = 432
    Top = 8
    Width = 177
    Height = 21
    Hint = #1042#1099#1073#1077#1088#1080#1090#1077' '#1084#1072#1085#1077#1074#1088
    Style = csDropDownList
    ItemHeight = 13
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
    OnChange = cbb_ManevryChange
  end
  object btn_AddManevr: TButton
    Left = 432
    Top = 168
    Width = 177
    Height = 25
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100'/'#1086#1073#1085#1086#1074#1080#1090#1100' '#1084#1072#1085#1077#1074#1088
    Enabled = False
    TabOrder = 2
    OnClick = btn_AddManevrClick
  end
  object cbb_HelicopterType: TComboBox
    Left = 8
    Top = 56
    Width = 177
    Height = 22
    Hint = #1042#1099#1073#1077#1088#1080#1090#1077' '#1090#1080#1087' '#1074#1077#1088#1090#1086#1083#1077#1090#1072
    Style = csOwnerDrawFixed
    ItemHeight = 16
    ParentShowHint = False
    ShowHint = True
    TabOrder = 3
    OnSelect = cbb_HelicopterTypeSelect
  end
  object btn_ExportFlightTask: TButton
    Left = 656
    Top = 136
    Width = 177
    Height = 25
    Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1087#1086#1083#1077#1090#1085#1086#1077' '#1079#1072#1076#1072#1085#1080#1077
    TabOrder = 4
    OnClick = btn_ExportFlightTaskClick
  end
  object btn_ImportFlightTask: TButton
    Left = 8
    Top = 8
    Width = 177
    Height = 33
    Caption = #1047#1072#1075#1088#1091#1079#1080#1090#1100' '#1087#1086#1083#1077#1090#1085#1086#1077' '#1079#1072#1076#1072#1085#1080#1077
    TabOrder = 5
    OnClick = btn_ImportFlightTaskClick
  end
  object Memo1: TMemo
    Left = 24
    Top = 312
    Width = 617
    Height = 57
    Lines.Strings = (
      'M'
      'e'
      'm'
      'o1')
    TabOrder = 6
    Visible = False
  end
  object trckbr_H0: TTrackBar
    Left = 48
    Top = 88
    Width = 97
    Height = 17
    Position = 5
    TabOrder = 8
    ThumbLength = 10
    TickStyle = tsNone
  end
  object trckbr_G: TTrackBar
    Left = 48
    Top = 120
    Width = 97
    Height = 17
    Position = 5
    TabOrder = 9
    ThumbLength = 10
    TickStyle = tsNone
  end
  object trckbr_T: TTrackBar
    Left = 48
    Top = 152
    Width = 97
    Height = 17
    Position = 5
    TabOrder = 7
    ThumbLength = 10
    TickStyle = tsNone
  end
  object btn_Calcutate: TButton
    Left = 656
    Top = 168
    Width = 177
    Height = 25
    Caption = #1056#1072#1089#1095#1077#1090
    TabOrder = 10
    OnClick = btn_CalcutateClick
  end
  object cht_DiapNXNY: TChart
    Left = 192
    Top = 8
    Width = 209
    Height = 153
    BackWall.Brush.Color = clWhite
    BackWall.Brush.Style = bsClear
    Title.Text.Strings = (
      '')
    BottomAxis.Automatic = False
    BottomAxis.AutomaticMaximum = False
    BottomAxis.AutomaticMinimum = False
    BottomAxis.Maximum = 330.000000000000000000
    BottomAxis.Title.Caption = 'V, '#1082#1084'/'#1095
    LeftAxis.Automatic = False
    LeftAxis.AutomaticMaximum = False
    LeftAxis.AutomaticMinimum = False
    LeftAxis.Maximum = 1004.000000000000000000
    LeftAxis.Minimum = 532.000000000000000000
    Legend.Visible = False
    RightAxis.Visible = False
    TopAxis.Visible = False
    View3D = False
    View3DWalls = False
    TabOrder = 11
    object Series1: TLineSeries
      Marks.ArrowLength = 8
      Marks.Visible = False
      SeriesColor = clRed
      Dark3D = False
      LinePen.Color = clGreen
      LinePen.Width = 2
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      Pointer.Visible = False
      XValues.DateTime = False
      XValues.Name = 'X'
      XValues.Multiplier = 1.000000000000000000
      XValues.Order = loAscending
      YValues.DateTime = False
      YValues.Name = 'Y'
      YValues.Multiplier = 1.000000000000000000
      YValues.Order = loNone
    end
  end
  object cht_traj: TChart
    Left = 8
    Top = 208
    Width = 377
    Height = 377
    BackWall.Brush.Color = clWhite
    BackWall.Brush.Style = bsClear
    Title.AdjustFrame = False
    Title.Text.Strings = (
      '')
    Title.Visible = False
    BottomAxis.Visible = False
    LeftAxis.Visible = False
    Legend.Visible = False
    RightAxis.Visible = False
    TopAxis.Visible = False
    View3D = False
    TabOrder = 12
    object Series2: TPointSeries
      Marks.ArrowLength = 0
      Marks.Visible = False
      SeriesColor = clRed
      Pointer.Brush.Color = 16744448
      Pointer.HorizSize = 3
      Pointer.InflateMargins = True
      Pointer.Pen.Visible = False
      Pointer.Style = psCircle
      Pointer.VertSize = 3
      Pointer.Visible = True
      XValues.DateTime = False
      XValues.Name = 'X'
      XValues.Multiplier = 1.000000000000000000
      XValues.Order = loAscending
      YValues.DateTime = False
      YValues.Name = 'Y'
      YValues.Multiplier = 1.000000000000000000
      YValues.Order = loNone
    end
  end
  object rg_view: TRadioGroup
    Left = 216
    Top = 592
    Width = 225
    Height = 33
    Caption = #1042#1080#1076
    Columns = 3
    ItemIndex = 2
    Items.Strings = (
      #1057#1074#1077#1088#1093#1091
      #1057#1083#1077#1074#1072
      #1048#1079#1086#1084#1077#1090#1088#1080#1103)
    TabOrder = 13
    OnClick = rg_viewClick
  end
  object rg_xarak: TRadioGroup
    Left = 235
    Top = 162
    Width = 129
    Height = 33
    Columns = 3
    ItemIndex = 0
    Items.Strings = (
      'H(V)'
      'ny'
      'nx')
    TabOrder = 14
    OnClick = rg_xarakClick
  end
  object btn_ExportCalculatedTask: TButton
    Left = 656
    Top = 592
    Width = 177
    Height = 33
    Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1088#1077#1079#1091#1083#1100#1090#1072#1090#1099
    TabOrder = 15
    OnClick = btn_ExportCalculatedTaskClick
  end
  object trckbrV0: TTrackBar
    Left = 48
    Top = 184
    Width = 97
    Height = 17
    Position = 5
    TabOrder = 16
    ThumbLength = 10
    TickStyle = tsNone
  end
  object pm_Manevry: TPopupMenu
    AutoPopup = False
    Left = 760
    Top = 64
    object DeleteManevr: TMenuItem
      Caption = #1059#1076#1072#1083#1080#1090#1100' '#1084#1072#1085#1077#1074#1088
      OnClick = DeleteManevrClick
    end
  end
  object dlgOpenFile: TOpenDialog
    Left = 200
    Top = 40
  end
end

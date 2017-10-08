object frm_Plot: Tfrm_Plot
  Left = 176
  Top = 198
  Width = 479
  Height = 346
  Caption = #1043#1088#1072#1092#1080#1082
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Visible = True
  PixelsPerInch = 96
  TextHeight = 13
  object cht_plot: TChart
    Left = 16
    Top = 40
    Width = 433
    Height = 257
    BackWall.Brush.Color = clWhite
    BackWall.Brush.Style = bsClear
    Title.Text.Strings = (
      '')
    Legend.LegendStyle = lsSeries
    Legend.Visible = False
    View3D = False
    View3DWalls = False
    TabOrder = 0
    object Series1: TLineSeries
      Marks.ArrowLength = 8
      Marks.Visible = False
      SeriesColor = clRed
      LinePen.Width = 3
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
  object cbb_parameter: TComboBox
    Left = 16
    Top = 16
    Width = 49
    Height = 21
    ItemHeight = 13
    ItemIndex = 5
    TabOrder = 1
    Text = 'psi'
    OnSelect = cbb_parameterSelect
    Items.Strings = (
      'x'
      'y'
      'z'
      'theta'
      'gamma'
      'psi'
      'V'
      'ny')
  end
end

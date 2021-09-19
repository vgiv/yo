object OptionsForm: TOptionsForm
  Left = 607
  Top = 180
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = #1054#1087#1094#1080#1080
  ClientHeight = 398
  ClientWidth = 371
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  Menu = MainMenu1
  OldCreateOrder = False
  OnKeyPress = FormKeyPress
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 371
    Height = 349
    ActivePage = TabSheet1
    Align = alClient
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = #1025#1092#1080#1082#1072#1094#1080#1103
      object Label1: TLabel
        Left = 8
        Top = 253
        Width = 146
        Height = 13
        Caption = #1050#1086#1083#1080#1095#1077#1089#1090#1074#1086' '#1089#1090#1088#1086#1082' '#1087#1088#1086#1084#1086#1090#1082#1080':'
      end
      object cbCheckYo: TCheckBox
        Left = 8
        Top = 68
        Width = 300
        Height = 21
        Caption = #1055#1088#1086#1074#1077#1088#1103#1090#1100' '#1088#1072#1089#1089#1090#1072#1085#1086#1074#1082#1091' "'#1105'"'
        TabOrder = 3
      end
      object cbNoVarOnly: TCheckBox
        Left = 8
        Top = 24
        Width = 300
        Height = 17
        Caption = #1058#1086#1083#1100#1082#1086' '#1073#1077#1089#1089#1087#1086#1088#1085#1099#1077' '#1079#1072#1084#1077#1085#1099
        TabOrder = 1
        OnClick = cbClick
      end
      object cbVarOnly: TCheckBox
        Left = 8
        Top = 46
        Width = 300
        Height = 17
        Caption = #1058#1086#1083#1100#1082#1086' '#1080#1085#1090#1077#1088#1072#1082#1090#1080#1074#1085#1099#1077' '#1079#1072#1084#1077#1085#1099
        TabOrder = 2
        OnClick = cbClick
      end
      object cbAlwaysAsk: TCheckBox
        Left = 8
        Top = 91
        Width = 300
        Height = 17
        Caption = #1042#1089#1077#1075#1076#1072' '#1087#1086#1076#1090#1074#1077#1088#1078#1076#1072#1090#1100' '#1079#1072#1084#1077#1085#1091
        TabOrder = 4
        OnClick = cbClick
      end
      object cbToConfirmAbbr: TCheckBox
        Left = 8
        Top = 113
        Width = 300
        Height = 17
        Caption = #1042#1089#1077#1075#1076#1072' '#1087#1086#1076#1074#1077#1088#1078#1076#1072#1090#1100' '#1079#1072#1084#1077#1085#1091' '#1076#1083#1103' '#1089#1086#1082#1088#1072#1097#1077#1085#1080#1081
        TabOrder = 5
      end
      object cbToConfirmCap: TCheckBox
        Left = 8
        Top = 135
        Width = 300
        Height = 17
        Caption = #1042#1089#1077#1075#1076#1072' '#1087#1086#1076#1090#1074#1077#1088#1078#1076#1072#1090#1100' '#1079#1072#1084#1077#1085#1091' '#1076#1083#1103' '#1080#1084#1105#1085' '#1089#1086#1073#1089#1090#1074#1077#1085#1085#1099#1093
        TabOrder = 6
      end
      object cbToConfirmEllipsis: TCheckBox
        Left = 8
        Top = 158
        Width = 300
        Height = 17
        Caption = #1042#1089#1077#1075#1076#1072' '#1087#1086#1076#1090#1074#1077#1088#1078#1076#1072#1090#1100' '#1079#1072#1084#1077#1085#1091' '#1076#1083#1103' '#1086#1073#1086#1088#1074#1072#1085#1085#1099#1093' '#1089#1083#1086#1074
        TabOrder = 7
      end
      object cbProposeLast: TCheckBox
        Left = 8
        Top = 180
        Width = 300
        Height = 17
        Caption = #1055#1088#1077#1076#1083#1072#1075#1072#1090#1100' '#1087#1086#1089#1083#1077#1076#1085#1080#1081' '#1074#1072#1088#1080#1072#1085#1090' '#1079#1072#1084#1077#1085#1099
        TabOrder = 8
      end
      object cbRegExprs: TCheckBox
        Left = 8
        Top = 2
        Width = 300
        Height = 17
        Caption = #1048#1089#1087#1086#1083#1100#1079#1086#1074#1072#1085#1080#1077' '#1089#1083#1086#1074#1072#1088#1103' '#1088#1077#1075#1091#1083#1103#1088#1085#1099#1093' '#1074#1099#1088#1072#1078#1077#1085#1080#1081
        TabOrder = 0
      end
      object cbFBFormat: TCheckBox
        Left = 8
        Top = 202
        Width = 300
        Height = 17
        Caption = #1059#1095#1080#1090#1099#1074#1072#1090#1100' '#1092#1086#1088#1084#1072#1090' "FictionBook"'
        TabOrder = 9
      end
      object eLinesBelow: TEdit
        Left = 160
        Top = 249
        Width = 49
        Height = 21
        TabOrder = 11
      end
      object cbFastScroll: TCheckBox
        Left = 8
        Top = 225
        Width = 300
        Height = 17
        Caption = #1041#1099#1089#1090#1088#1072#1103' '#1087#1088#1086#1084#1086#1090#1082#1072
        TabOrder = 10
      end
    end
    object TabSheet2: TTabSheet
      Caption = #1056#1077#1076#1072#1082#1090#1086#1088
      ImageIndex = 1
      object cbMark: TCheckBox
        Left = 8
        Top = 100
        Width = 300
        Height = 17
        Caption = #1055#1086#1084#1077#1095#1072#1090#1100' '#1080#1089#1087#1088#1072#1074#1083#1077#1085#1085#1086#1077
        TabOrder = 4
        OnClick = cbClick
      end
      object cbWordWrap: TCheckBox
        Left = 8
        Top = 78
        Width = 300
        Height = 17
        Caption = #1047#1072#1074#1086#1088#1072#1095#1080#1074#1072#1090#1100' '#1090#1077#1082#1089#1090' ("Word wrap")'
        TabOrder = 3
        OnClick = cbClick
      end
      object cbLastFile: TCheckBox
        Left = 8
        Top = 12
        Width = 300
        Height = 17
        Caption = #1047#1072#1087#1086#1084#1080#1085#1072#1090#1100' '#1087#1086#1089#1083#1077#1076#1085#1080#1081' '#1092#1072#1081#1083
        TabOrder = 0
      end
      object bFont: TButton
        Left = 160
        Top = 293
        Width = 45
        Height = 21
        Caption = #1064#1088#1080#1092#1090
        TabOrder = 8
        OnClick = bFontClick
      end
      object SampleEditor: TRichEdit
        Left = 16
        Top = 135
        Width = 321
        Height = 72
        TabStop = False
        Lines.Strings = (
          #1042' '#1095#1072#1097#1072#1093' '#1102#1075#1072' '#1078#1080#1083' '#1073#1099' '#1094#1080#1090#1088#1091#1089'? '#1044#1072', '#1085#1086' '#1092#1072#1083#1100#1096#1080#1074#1099#1081' '#1101#1082#1079#1077#1084#1087#1083#1103#1088'! '
          'The quick brown fox jumps over the lazy dog.')
        PlainText = True
        ReadOnly = True
        TabOrder = 7
      end
      object bMark: TButton
        Left = 169
        Top = 97
        Width = 45
        Height = 21
        Caption = #1062#1074#1077#1090
        TabOrder = 5
        OnClick = bMarkClick
      end
      object bBackMark: TButton
        Left = 221
        Top = 97
        Width = 45
        Height = 21
        Caption = #1060#1086#1085
        TabOrder = 6
        OnClick = bBackMarkClick
      end
      object cbAutoUnicode: TCheckBox
        Left = 8
        Top = 56
        Width = 300
        Height = 17
        Caption = #1040#1074#1090#1086#1088#1072#1089#1087#1086#1079#1085#1072#1074#1072#1090#1100' '#1092#1086#1088#1084#1072#1090' Unicode'
        TabOrder = 2
      end
      object cbShowToolbar: TCheckBox
        Left = 8
        Top = 214
        Width = 300
        Height = 17
        Caption = #1055#1086#1082#1072#1079#1099#1074#1072#1090#1100' '#1087#1072#1085#1077#1083#1100' '#1080#1085#1089#1090#1088#1091#1084#1077#1085#1090#1086#1074
        TabOrder = 9
      end
      object cbToConfirmClose: TCheckBox
        Left = 8
        Top = 35
        Width = 226
        Height = 17
        Caption = #1053#1077' '#1087#1086#1076#1090#1074#1077#1088#1078#1076#1072#1090#1100' '#1079#1072#1082#1088#1099#1090#1080#1077' '#1087#1088#1086#1075#1088#1072#1084#1084#1099
        TabOrder = 1
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 349
    Width = 371
    Height = 49
    Align = alBottom
    TabOrder = 1
    object bOK: TButton
      Left = 15
      Top = 10
      Width = 75
      Height = 25
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      TabOrder = 0
      OnClick = bOKClick
    end
    object bCancel: TButton
      Left = 281
      Top = 10
      Width = 75
      Height = 25
      Caption = #1054#1090#1084#1077#1085#1080#1090#1100
      TabOrder = 1
      OnClick = bCancelClick
    end
    object bOKSave: TButton
      Left = 120
      Top = 10
      Width = 137
      Height = 25
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100' '#1080' '#1079#1072#1087#1086#1084#1085#1080#1090#1100
      TabOrder = 2
      OnClick = bOKSaveClick
    end
  end
  object FontDialog1: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Options = []
    Left = 324
    Top = 32
  end
  object ColorDialog1: TColorDialog
    Left = 324
    Top = 64
  end
  object MainMenu1: TMainMenu
    Left = 280
    Top = 32
  end
end

object InputForm: TInputForm
  Left = 337
  Top = 266
  Width = 213
  Height = 92
  BorderIcons = []
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShortCut = FormShortCut
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lInput: TLabel
    Left = 18
    Top = 8
    Width = 77
    Height = 13
    Caption = '¬ведите число:'
  end
  object eInput: TEdit
    Left = 101
    Top = 5
    Width = 74
    Height = 21
    TabOrder = 0
    Text = '00000000000'
  end
  object bOK: TButton
    Left = 4
    Top = 32
    Width = 75
    Height = 25
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 1
  end
  object bCancel: TButton
    Left = 121
    Top = 32
    Width = 75
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
end

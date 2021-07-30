object Form1: TForm1
  Left = 315
  Top = 306
  Width = 275
  Height = 70
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object btnClose: TButton
    Left = 184
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Close'
    TabOrder = 0
    OnClick = btnCloseClick
  end
  object btnUnInject: TButton
    Left = 8
    Top = 8
    Width = 75
    Height = 25
    Caption = 'UnInject'
    TabOrder = 1
    OnClick = btnUnInjectClick
  end
  object btnInject: TButton
    Left = 96
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Inject'
    TabOrder = 2
    OnClick = btnInjectClick
  end
end

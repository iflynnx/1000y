object FrmStipulation: TFrmStipulation
  Left = 394
  Top = 211
  BorderStyle = bsNone
  Caption = 'FrmStipulation'
  ClientHeight = 480
  ClientWidth = 640
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object A2ButtonAgree: TA2Button
    Left = 244
    Top = 366
    Width = 61
    Height = 25
    AutoSize = False
    Color = clHighlight
    ParentColor = False
    OnClick = A2ButtonAgreeClick
    ADXForm = A2Form
  end
  object A2ButtonNotAgree: TA2Button
    Left = 346
    Top = 366
    Width = 61
    Height = 25
    AutoSize = False
    Color = clHighlight
    ParentColor = False
    OnClick = A2ButtonNotAgreeClick
    ADXForm = A2Form
  end
  object A2ListBox1: TA2ListBox
    Left = 116
    Top = 119
    Width = 416
    Height = 240
    ADXForm = A2Form
    FontColor = 32767
    FontSelColor = 32767
    ItemHeight = 14
    ItemMerginX = 5
    ItemMerginY = 3
    FontEmphasis = False
    ScrollBarView = True
  end
  object A2Form: TA2Form
    Color = clBlack
    ShowMethod = FSM_NONE
    TransParent = False
    Left = 8
    Top = 8
  end
end

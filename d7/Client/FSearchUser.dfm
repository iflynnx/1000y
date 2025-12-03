object FrmSearchUser: TFrmSearchUser
  Left = 356
  Top = 269
  BorderStyle = bsNone
  Caption = 'FrmSearchUser'
  ClientHeight = 363
  ClientWidth = 460
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object CenterIDLabel: TA2ILabel
    Left = 208
    Top = 200
    Width = 8
    Height = 8
    AutoSize = False
    Color = clTeal
    ParentColor = False
    ADXForm = A2Form
  end
  object SearchIDLabel: TA2ILabel
    Left = 120
    Top = 192
    Width = 48
    Height = 57
    AutoSize = False
    Caption = 'SearchIDLabel'
    Color = clOlive
    ParentColor = False
    Visible = False
    ADXForm = A2Form
  end
  object A2Form: TA2Form
    Color = 31
    ImageFileName = 'South.bmp'
    ShowMethod = FSM_DARKEN
    TransParent = False
  end
end

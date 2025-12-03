object frmMain: TfrmMain
  Left = 191
  Top = 123
  Width = 369
  Height = 408
  Caption = 'Gate Balancing'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object cmdClose: TButton
    Left = 240
    Top = 336
    Width = 113
    Height = 33
    Caption = 'Close'
    TabOrder = 0
    OnClick = cmdCloseClick
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 345
    Height = 265
    Caption = 'Available Gate List'
    TabOrder = 1
    object chkGate1: TCheckBox
      Left = 16
      Top = 24
      Width = 313
      Height = 17
      Caption = 'Not available'
      TabOrder = 0
      OnClick = chkGate1Click
    end
    object chkGate2: TCheckBox
      Left = 16
      Top = 48
      Width = 313
      Height = 17
      Caption = 'Not available'
      TabOrder = 1
      OnClick = chkGate2Click
    end
    object chkGate3: TCheckBox
      Left = 16
      Top = 72
      Width = 313
      Height = 17
      Caption = 'Not available'
      TabOrder = 2
      OnClick = chkGate3Click
    end
    object chkGate4: TCheckBox
      Left = 16
      Top = 96
      Width = 313
      Height = 17
      Caption = 'Not available'
      TabOrder = 3
      OnClick = chkGate4Click
    end
    object chkGate5: TCheckBox
      Left = 16
      Top = 120
      Width = 313
      Height = 17
      Caption = 'Not available'
      TabOrder = 4
      OnClick = chkGate5Click
    end
    object chkGate6: TCheckBox
      Left = 16
      Top = 144
      Width = 313
      Height = 17
      Caption = 'Not available'
      TabOrder = 5
      OnClick = chkGate6Click
    end
    object chkGate7: TCheckBox
      Left = 16
      Top = 168
      Width = 313
      Height = 17
      Caption = 'Not available'
      TabOrder = 6
      OnClick = chkGate7Click
    end
    object chkGate8: TCheckBox
      Left = 16
      Top = 192
      Width = 313
      Height = 17
      Caption = 'Not available'
      TabOrder = 7
      OnClick = chkGate8Click
    end
    object chkGate9: TCheckBox
      Left = 16
      Top = 216
      Width = 313
      Height = 17
      Caption = 'Not available'
      TabOrder = 8
      OnClick = chkGate9Click
    end
    object chkGate10: TCheckBox
      Left = 16
      Top = 240
      Width = 313
      Height = 17
      Caption = 'Not available'
      TabOrder = 9
      OnClick = chkGate10Click
    end
  end
  object lstInfo: TListBox
    Left = 8
    Top = 280
    Width = 345
    Height = 49
    ImeName = 'ÖÐÎÄ(¼òÌå) (MS-IME98)'
    ItemHeight = 13
    TabOrder = 2
  end
  object sckUser: TServerSocket
    Active = False
    Port = 0
    ServerType = stNonBlocking
    OnAccept = sckUserAccept
    OnClientConnect = sckUserClientConnect
    OnClientDisconnect = sckUserClientDisconnect
    OnClientWrite = sckUserClientWrite
    OnClientError = sckUserClientError
    Left = 8
    Top = 280
  end
  object udpGate: TNMUDP
    RemotePort = 0
    LocalPort = 0
    ReportLevel = 1
    OnDataReceived = udpGateDataReceived
    Left = 40
    Top = 280
  end
  object timerDisplay: TTimer
    OnTimer = timerDisplayTimer
    Left = 72
    Top = 280
  end
end

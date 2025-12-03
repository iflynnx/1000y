unit FMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ScktComp, ComCtrls, ExtCtrls, IniFiles, mmSystem, uBuffer, NMUDP,
  uPackets, AnsStringCls, DefType;

type
  TVillageData = record
    Name : String[64];
    X : Integer;
    Y : Integer;
    ServerID : Integer;
  end;
  PTVillageData = ^TVillageData;

  TfrmMain = class(TForm)
    pgMain: TPageControl;
    tsStatus: TTabSheet;
    tsEvent: TTabSheet;
    lstEvent: TListBox;
    tsLog: TTabSheet;
    txtLog: TMemo;
    sckUserAccept: TServerSocket;
    cmdClose: TButton;
    timerDisplay: TTimer;
    StaticText1: TStaticText;
    shpGameConnected: TShape;
    shpDBConnected: TShape;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    StaticText4: TStaticText;
    StaticText5: TStaticText;
    StaticText6: TStaticText;
    lblConnectCount: TStaticText;
    lblPlayCount: TStaticText;
    lblLogCount: TStaticText;
    lblConnectID: TStaticText;
    StaticText11: TStaticText;
    lblElaspedTime: TStaticText;

    // sckGameConnect: TClientSocket;
    sckDBConnect: TClientSocket;
    sckLoginConnect: TClientSocket;
    shpLoginConnected: TShape;
    StaticText7: TStaticText;
    timerProcess: TTimer;
    chkUserAccept: TCheckBox;
    tsBufferStatus: TTabSheet;
    Label1: TLabel;
    lblGameSendBytes: TLabel;
    Label2: TLabel;
    lblGameRecvBytes: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    lblDBSendBytes: TLabel;
    Label8: TLabel;
    lblDBRecvBytes: TLabel;
    Label10: TLabel;
    lblLoginSendBytes: TLabel;
    Label12: TLabel;
    lblLoginRecvBytes: TLabel;
    Label3: TLabel;
    lblGameWBCount: TLabel;
    Label7: TLabel;
    lblDBWBCount: TLabel;
    Label11: TLabel;
    lblLoginWBCount: TLabel;
    shpGameWBSign: TShape;
    Label9: TLabel;
    shpDBWBSign: TShape;
    Label13: TLabel;
    shpLoginWBSign: TShape;
    Label14: TLabel;
    sckGameConnect: TClientSocket;
    timerClose: TTimer;
    udpBalance: TNMUDP;
    cmdReCalc: TButton;
    sckPaidConnect: TClientSocket;
    shpPaidConnected: TShape;
    StaticText8: TStaticText;
    procedure cmdCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure sckUserAcceptAccept(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure sckUserAcceptClientConnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure sckUserAcceptClientDisconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure sckUserAcceptClientError(Sender: TObject;
      Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
      var ErrorCode: Integer);
    procedure sckUserAcceptClientRead(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure sckUserAcceptClientWrite(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure timerDisplayTimer(Sender: TObject);
    procedure sckDBConnectConnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure sckDBConnectDisconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure sckDBConnectError(Sender: TObject;
      Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
      var ErrorCode: Integer);
    procedure sckDBConnectRead(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure sckDBConnectWrite(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure sckLoginConnectConnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure sckLoginConnectDisconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure sckLoginConnectError(Sender: TObject;
      Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
      var ErrorCode: Integer);
    procedure sckLoginConnectRead(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure sckLoginConnectWrite(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure timerProcessTimer(Sender: TObject);
    procedure sckGameConnectConnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure sckGameConnectDisconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure sckGameConnectError(Sender: TObject;
      Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
      var ErrorCode: Integer);
    procedure sckGameConnectRead(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure sckGameConnectWrite(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure timerCloseTimer(Sender: TObject);
    procedure udpBalanceDataReceived(Sender: TComponent;
      NumberBytes: Integer; FromIP: String; Port: Integer);
    procedure cmdReCalcClick(Sender: TObject);
    procedure sckPaidConnectConnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure sckPaidConnectDisconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure sckPaidConnectError(Sender: TObject;
      Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
      var ErrorCode: Integer);
    procedure sckPaidConnectRead(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure sckPaidConnectWrite(Sender: TObject;
      Socket: TCustomWinSocket);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure AddLog (aStr : String);
    procedure AddEvent (aStr : String);

    function UpdateServer (CurTick : Integer) : Boolean;
  end;

var
  frmMain: TfrmMain;

  StartTick, ElaspedSec : Integer;
  BalanceSendTick : Integer;

  RejectCharName : TStringList;

  ServerName : String;
  LimitUserCount : Integer;
  boCheckPaidInfo : Boolean;
  BufferSizeS2S, BufferSizeS2C : Integer;
  UserAcceptInfo, GameConnectInfo, DBConnectInfo, LoginConnectInfo : TConnectInfo;
  BalanceConnectInfo, PaidConnectInfo : TConnectInfo;

  VillageList : TList;

  GameSender, DBSender, LoginSender, PaidSender : TPacketSender;
  GameReceiver, DBReceiver, LoginReceiver, PaidReceiver : TPacketReceiver;

implementation

uses
   uConnector;

{$R *.DFM}

procedure TfrmMain.cmdCloseClick(Sender: TObject);
begin
   if Application.MessageBox ('Do you want to exit program?', 'GATE SERVER', MB_OKCANCEL) <> ID_OK then exit;
    
   if ConnectorList <> nil then begin
   	ConnectorList.Free;
   	ConnectorList := nil;
   end;
   
   Close;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
   i, nCount : Integer;
   iniFile : TIniFile;
   pd : PTVillageData;
begin
   AddLog ('Gate Server Started ' + DateToStr(Date) + ' ' + TimeToStr (Time));

   ElaspedSec := 0;
   StartTick := timeGetTime;

   VillageList := TList.Create;

   RejectCharName := TStringList.Create;
   if FileExists ('.\DONTCHAR.TXT') then begin
      RejectCharName.LoadFromFile ('.\DONTCHAR.TXT');
   end;

   if not FileExists ('.\GATE.INI') then begin
      iniFile := TIniFile.Create ('.\GATE.INI');

      iniFile.WriteString ('GATE_SERVER', 'LOCALIP', '127.0.0.1');
      iniFile.WriteInteger ('GATE_SERVER', 'LOCALPORT', 3054);
      iniFile.WriteString ('GATE_SERVER', 'SERVERNAME', '创造');
      iniFile.WriteInteger ('GATE_SERVER', 'LIMITUSERCOUNT', 0);
      iniFile.WriteString ('GATE_SERVER', 'CHECKPAIDINFO', 'TRUE');
      iniFile.WriteInteger ('GATE_SERVER', 'BUFFERSIZES2S', 16384);
      iniFile.WriteInteger ('GATE_SERVER', 'BUFFERSIZES2C', 8192);

      iniFile.WriteString ('DB_SERVER', 'REMOTEIP', '127.0.0.1');
      iniFile.WriteInteger ('DB_SERVER', 'REMOTEPORT', 3052);

      iniFile.WriteString ('DB_SERVER', 'REMOTEIP', '127.0.0.1');
      iniFile.WriteInteger ('DB_SERVER', 'REMOTEPORT', 3051);

      iniFile.WriteString ('LOGIN_SERVER', 'REMOTEIP', '127.0.0.1');
      iniFile.WriteInteger ('LOGIN_SERVER', 'REMOTEPORT', 3050);

      iniFile.WriteString ('PAID_SERVER', 'REMOTEIP', '127.0.0.1');
      iniFile.WriteInteger ('PAID_SERVER', 'REMOTEPORT', 5999);
      iniFile.WriteInteger ('PAID_SERVER', 'LOCALPORT', 5998);

      iniFile.WriteString ('GATE_SERVER', 'BALANCEIP', '127.0.0.1');
      iniFile.WriteInteger ('GATE_SERVER', 'BALANCEPORT', 3030);

      iniFile.Free;
   end;

   iniFile := TIniFile.Create ('.\GATE.INI');

   UserAcceptInfo.RemoteIP := iniFile.ReadString ('GATE_SERVER', 'LOCALIP', '127.0.0.1');
   UserAcceptInfo.LocalPort := iniFile.ReadInteger ('GATE_SERVER', 'LOCALPORT', 3054);
   ServerName := iniFile.ReadString ('GATE_SERVER', 'SERVERNAME', '创造');
   LimitUserCount := iniFile.ReadInteger ('GATE_SERVER', 'LIMITUSERCOUNT', 0);
   boCheckPaidInfo := true;
   if UpperCase (iniFile.ReadString ('GATE_SERVER', 'CHECKPAIDINFO', 'TRUE')) = 'FALSE' then begin
      boCheckPaidInfo := false;
   end; 
   BufferSizeS2S := iniFile.ReadInteger ('GATE_SERVER', 'BUFFERSIZES2S', 16384);
   BufferSizeS2C := iniFile.ReadInteger ('GATE_SERVER', 'BUFFERSIZES2C', 8192);

   GameConnectInfo.RemoteIP := iniFile.ReadString ('GAME_SERVER', 'REMOTEIP', '127.0.0.1');
   GameConnectInfo.RemotePort := iniFile.ReadInteger ('GAME_SERVER', 'REMOTEPORT', 3052);

   DBConnectInfo.RemoteIP := iniFile.ReadString ('DB_SERVER', 'REMOTEIP', '127.0.0.1');
   DBConnectInfo.RemotePort := iniFile.ReadInteger ('DB_SERVER', 'REMOTEPORT', 3051);

   LoginConnectInfo.RemoteIP := iniFile.ReadString ('LOGIN_SERVER', 'REMOTEIP', '127.0.0.1');
   LoginConnectInfo.RemotePort := iniFile.ReadInteger ('LOGIN_SERVER', 'REMOTEPORT', 3050);

   PaidConnectInfo.RemoteIP := iniFile.ReadString ('PAID_SERVER', 'REMOTEIP', '127.0.0.1');
   PaidConnectInfo.RemotePort := iniFile.ReadInteger ('PAID_SERVER', 'REMOTEPORT', 3049);

   BalanceConnectInfo.RemoteIP := iniFile.ReadString ('GATE_SERVER', 'BALANCEIP', '127.0.0.1');
   BalanceConnectInfo.RemotePort := iniFile.ReadInteger ('GATE_SERVER', 'BALANCEPORT', 3030);

   iniFile.Free;

   iniFile := TIniFile.Create ('.\Village.INI');
   nCount := iniFile.ReadInteger ('VILLAGE', 'COUNT', 1);
   for i := 0 to nCount - 1 do begin
      New (pd);
      pd^.Name := iniFile.ReadString ('VILLAGE', 'NAME' + IntToStr (i), '书生村');
      pd^.X := iniFile.ReadInteger ('VILLAGE', 'X' + IntToStr (i), 513);
      pd^.Y := iniFile.ReadInteger ('VILLAGE', 'Y' + IntToStr (i), 205);
      pd^.ServerID := iniFile.ReadInteger ('VILLAGE', 'ServerID' + IntToStr (i), 0);
      VillageList.Add (pd);
   end;
   iniFile.Free;

   GameSender := nil;
   GameReceiver := nil;
   DBSender := nil;
   DBReceiver := nil;
   LoginSender := nil;
   LoginReceiver := nil;
   PaidSender := nil;
   PaidReceiver := nil;

   ConnectorList := TConnectorList.Create;

   chkUserAccept.Checked := true;

   sckUserAccept.Port := UserAcceptInfo.LocalPort;
   sckUserAccept.Active := true;

   sckGameConnect.Address := GameConnectInfo.RemoteIP;
   sckGameConnect.Port := GameConnectInfo.RemotePort;
   sckGameConnect.Active := true;

   sckDBConnect.Address := DBConnectInfo.RemoteIP;
   sckDBConnect.Port := DBConnectInfo.RemotePort;
   sckDBConnect.Active := true;

   sckLoginConnect.Address := LoginConnectInfo.RemoteIP;
   sckLoginConnect.Port := LoginConnectInfo.RemotePort;
   sckLoginConnect.Active := true;

   sckPaidConnect.Address := PaidConnectInfo.RemoteIP;
   sckPaidConnect.Port := PaidConnectInfo.RemotePort;
   sckPaidConnect.Active := true;

   timerDisplay.Interval := 1000;
   timerDisplay.Enabled := true;

   timerProcess.Interval := 10;
   timerProcess.Enabled := true;

   timerClose.Enabled := false;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
var
   i : Integer;
   pd : PTVillageData;
begin
   for i := 0 to VillageList.Count - 1 do begin
      pd := VillageList.Items [i];
      Dispose (pd);
   end;
   VillageList.Clear;
   VillageList.Free;

   if ConnectorList <> nil then begin
   	ConnectorList.Free;
   	ConnectorList := nil;
   end;

   if sckGameConnect.Socket.Connected = true then begin
      sckGameConnect.Socket.Close;
   end;
   if sckDBConnect.Socket.Connected = true then begin
      sckDBConnect.Socket.Close;
   end;
   if sckLoginConnect.Socket.Connected = true then begin
      sckLoginConnect.Socket.Close;
   end;
   if sckUserAccept.Active = true then begin
      sckUserAccept.Socket.Close;
   end;
   timerDisplay.Enabled := false;
   timerProcess.Enabled := false;

   if GameSender <> nil then begin
      GameSender.Free;
      GameSender := nil;
   end;
   if GameReceiver <> nil then begin
      GameReceiver.Free;
      GameReceiver := nil;
   end;

   if DBSender <> nil then begin
      DBSender.Free;
      DBSender := nil;
   end;
   if DBReceiver <> nil then begin
      DBReceiver.Free;
      DBReceiver := nil;
   end;
   if LoginSender <> nil then begin
      LoginSender.Free;
      LoginSender := nil;
   end;
   if LoginReceiver <> nil then begin
      LoginReceiver.Free;
      LoginReceiver := nil;
   end;

   RejectCharName.Clear;
   RejectCharName.Free;

   AddLog ('Gate Server Exit ' + DateToStr(Date) + ' ' + TimeToStr (Time));
end;

procedure TfrmMain.AddLog (aStr : String);
begin
   if txtLog.Lines.Count >= 30 then begin
      txtLog.Lines.Delete (0);
   end;
   txtLog.Lines.Add (aStr);
end;

procedure TfrmMain.AddEvent (aStr : String);
begin
   if lstEvent.Items.Count >= 30 then begin
      lstEvent.Items.Delete (0);
   end;
   lstEvent.Items.Add (aStr);
   lstEvent.ItemIndex := lstEvent.Items.Count - 1;
end;

function TfrmMain.UpdateServer (CurTick : Integer) : Boolean;
var
   Packet : TPacketData;
begin
   if GameSender <> nil then GameSender.Update;
   if GameReceiver <> nil then begin
      GameReceiver.Update;
      while GameReceiver.Count > 0 do begin
         if GameReceiver.GetPacket (@Packet) = false then break;
         ConnectorList.GameMessageProcess (@Packet);
      end;
   end;

   if DBSender <> nil then DBSender.Update;
   if DBReceiver <> nil then begin
      DBReceiver.Update;
      while DBReceiver.Count > 0 do begin
         if DBReceiver.GetPacket (@Packet) = false then break;
         ConnectorList.DBMessageProcess (@Packet);
      end;
   end;

   if LoginSender <> nil then LoginSender.Update;
   if LoginReceiver <> nil then begin
      LoginReceiver.Update;
      while LoginReceiver.Count > 0 do begin
         if LoginReceiver.GetPacket (@Packet) = false then break;
         ConnectorList.LoginMessageProcess (@Packet);
      end;
   end;

   if PaidSender <> nil then PaidSender.Update;
   if PaidReceiver <> nil then begin
      PaidReceiver.Update;
      while PaidReceiver.Count > 0 do begin
         if PaidReceiver.GetPacket (@Packet) = false then break;
         ConnectorList.PaidMessageProcess (@Packet);
      end;
   end;

   Result := true;
end;

procedure TfrmMain.sckUserAcceptAccept(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   if chkUserAccept.Checked = true then begin
      AddEvent (Socket.RemoteAddress + ' Connected');
      if ConnectorList.CreateConnect (Socket) = true then exit;
   end;
   Socket.Close;
end;

procedure TfrmMain.sckUserAcceptClientConnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   //
end;

procedure TfrmMain.sckUserAcceptClientDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
var
	Name : String;
begin
   Name := ConnectorList.DeleteConnect (Socket);

   AddEvent (Socket.RemoteAddress + ' DisConnected ' + Name);
end;

procedure TfrmMain.sckUserAcceptClientError(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
  var ErrorCode: Integer);
begin
   AddEvent (Socket.RemoteAddress + ' Error');
   ErrorCode := 0;
end;

procedure TfrmMain.sckUserAcceptClientRead(Sender: TObject;
  Socket: TCustomWinSocket);
var
   nRead : Integer;
   buffer : array[0..4096] of byte;
begin
   nRead := Socket.ReceiveBuf (buffer, 4096);
   if nRead > 0 then begin
      ConnectorList.AddReceiveData (Socket, @buffer, nRead);
      exit;
   end;
end;

procedure TfrmMain.sckUserAcceptClientWrite(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   ConnectorList.SetWriteAllow (Socket);
end;

procedure TfrmMain.timerDisplayTimer(Sender: TObject);
var
   CurTick : Integer;
//   wbColor : TColor;
   buffer : array[0..128] of char;
   pBalanceData : PTBalanceData;
begin
   if sckGameConnect.Active = false then begin
      shpGameConnected.Brush.Color := clRed;
      sckGameConnect.Socket.Close;
      sckGameConnect.Active := true;
   end else begin
      shpGameConnected.Brush.Color := clLime;
   end;

   if sckDBConnect.Active = false then begin
      shpDBConnected.Brush.Color := clRed;
      sckDBConnect.Socket.Close;
      sckDBConnect.Active := true;
   end else begin
      shpDBConnected.Brush.Color := clLime;
   end;

   if sckLoginConnect.Active = false then begin
      shpLoginConnected.Brush.Color := clRed;
      sckLoginConnect.Socket.Close;;
      sckLoginConnect.Active := true;
   end else begin
      shpLoginConnected.Brush.Color := clLime;
   end;

   if sckPaidConnect.Active = false then begin
      shpPaidConnected.Brush.Color := clRed;
      sckPaidConnect.Socket.Close;;
      sckPaidConnect.Active := true;
   end else begin
      shpPaidConnected.Brush.Color := clLime;
   end;

   CurTick := timeGetTime;
   if CurTick >= StartTick + 1000 then begin
      ElaspedSec := ElaspedSec + 1;
      StartTick := CurTick;
   end;

   lblElaspedTime.Caption := IntToStr (ElaspedSec);
   lblConnectCount.Caption := IntToStr (ConnectorList.Count);
   lblPlayCount.Caption := IntToStr (ConnectorList.PlayingUserCount);
   lblLogCount.Caption := IntToStr (ConnectorList.LogingUserCount);
   lblConnectID.Caption := IntToStr (ConnectorList.AutoConnectID);

   if GameSender <> nil then begin
      lblGameSendBytes.Caption := IntToStr (GameSender.SendBytesPerSec);
      lblGameWBCount.Caption := IntToStr (GameSender.WouldBlockCount);
      if GameSender.WriteAllow = true then begin
         shpGameWBSign.Brush.Color := clLime;
      end else begin
         shpGameWBSign.Brush.Color := clRed;
      end;
   end;
   if GameReceiver <> nil then begin
      lblGameRecvBytes.Caption := IntToStr (GameReceiver.ReceiveBytesPerSec);
   end;
   if DBSender <> nil then begin
      lblDBSendBytes.Caption := IntToStr (DBSender.SendBytesPerSec);
      lblDBWBCount.Caption := IntToStr (DBSender.WouldBlockCount);
      if DBSender.WriteAllow = true then begin
         shpDBWBSign.Brush.Color := clLime;
      end else begin
         shpDBWBSign.Brush.Color := clRed;
      end;
   end;
   if DBReceiver <> nil then begin
      lblDBRecvBytes.Caption := IntToStr (DBReceiver.ReceiveBytesPerSec);
   end;
   if LoginSender <> nil then begin
      lblLoginSendBytes.Caption := IntToStr (LoginSender.SendBytesPerSec);
      lblLoginWBCount.Caption := IntToStr (LoginSender.WouldBlockCount);
      if LoginSender.WriteAllow = true then begin
         shpLoginWBSign.Brush.Color := clLime;
      end else begin
         shpLoginWBSign.Brush.Color := clRed;
      end;
   end;
   if LoginReceiver <> nil then begin
      lblLoginRecvBytes.Caption := IntToStr (LoginReceiver.ReceiveBytesPerSec);
   end;

   if CurTick >= BalanceSendTick + 3000 then begin
   	udpBalance.RemoteHost := BalanceConnectInfo.RemoteIP;
      udpBalance.RemotePort := BalanceConnectInfo.RemotePort;

      pBalanceData := @buffer;
      pBalanceData^.rMsg := BM_GATEINFO;
      StrPCopy (@pBalanceData^.rIpAddr, UserAcceptInfo.RemoteIP);
      pBalanceData^.rPort := UserAcceptInfo.LocalPort;
      pBalanceData^.rUserCount := ConnectorList.Count;
      udpBalance.SendBuffer (buffer, sizeof (TBalanceData));
   end;

   if ConnectorList.GateUniqueValue = -1 then begin
      if GameSender <> nil then begin
         GameSender.PutPacket (0, GM_UNIQUEVALUE, 0, nil, 0);
      end;
   end;
end;

procedure TfrmMain.sckDBConnectConnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   DBSender := TPacketSender.Create ('DB', BufferSizeS2S, Socket);
   DBReceiver := TPacketReceiver.Create ('DB', BufferSizeS2S);

   AddLog (format ('Connected To DB Server %s', [Socket.RemoteAddress]));
end;

procedure TfrmMain.sckDBConnectDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   if DBSender <> nil then begin
      DBSender.Free;
      DBSender := nil;
   end;
   if DBReceiver <> nil then begin
      DBReceiver.Free;
      DBReceiver := nil;
   end;

   if Socket.Connected = true then begin
      AddLog (format ('Disconnected From DB Server %s', [Socket.RemoteAddress]));
   end;
end;

procedure TfrmMain.sckDBConnectError(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
  var ErrorCode: Integer);
begin
   if (ErrorCode <> 10061) and (ErrorCode <> 10038) then begin
      AddLog (format ('Socket Error At DBServer Connection (%d)', [ErrorCode]));
   end;
   ErrorCode := 0;
end;

procedure TfrmMain.sckDBConnectRead(Sender: TObject;
  Socket: TCustomWinSocket);
var
   nRead : Integer;
   buffer : array[0..4096 - 1] of byte;
begin
   nRead := Socket.ReceiveBuf (buffer, 4096);
   if nRead > 0 then begin
      DBReceiver.PutData (@buffer, nRead);
      exit;
   end;
end;

procedure TfrmMain.sckDBConnectWrite(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   if DBSender <> nil then DBSender.WriteAllow := true;
end;

procedure TfrmMain.sckLoginConnectConnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   LoginSender := TPacketSender.Create ('Login', BufferSizeS2S, Socket);
   LoginReceiver := TPacketReceiver.Create ('Login', BufferSizeS2S);

   AddLog (format ('Connected To Login Server %s', [Socket.RemoteAddress]));
end;

procedure TfrmMain.sckLoginConnectDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   if LoginSender <> nil then begin
      LoginSender.Free;
      LoginSender := nil;
   end;
   if LoginReceiver <> nil then begin
      LoginReceiver.Free;
      LoginReceiver := nil;
   end;
   if Socket.Connected = true then begin
      AddLog (format ('Disconnected From Login Server %s', [Socket.RemoteAddress]));
   end;
end;

procedure TfrmMain.sckLoginConnectError(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
  var ErrorCode: Integer);
begin
   if (ErrorCode <> 10061) and (ErrorCode <> 10038) then begin
      AddLog (format ('Socket Error At LoginServer Connection (%d)', [ErrorCode]));
   end;
   ErrorCode := 0;
end;

procedure TfrmMain.sckLoginConnectRead(Sender: TObject;
  Socket: TCustomWinSocket);
var
   nRead : Integer;
   buffer : array[0..4096 - 1] of byte;
begin
   nRead := Socket.ReceiveBuf (buffer, 4096);
   if nRead > 0 then begin
      LoginReceiver.PutData (@buffer, nRead);
      exit;
   end;
end;

procedure TfrmMain.sckLoginConnectWrite(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   if LoginSender <> nil then LoginSender.WriteAllow := true;
end;

procedure TfrmMain.timerProcessTimer(Sender: TObject);
var
   CurTick : Integer;
begin
   CurTick := timeGetTime;

   ConnectorList.Update (CurTick);
   UpdateServer (CurTick);
end;

procedure TfrmMain.sckGameConnectConnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   GameSender := TPacketSender.Create ('Game', BufferSizeS2S, Socket);
   GameReceiver := TPacketReceiver.Create ('Game', BufferSizeS2S);

   AddLog (format ('Connected To Game Server %s', [Socket.RemoteAddress]));
end;

procedure TfrmMain.sckGameConnectDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   if GameSender <> nil then begin
      GameSender.Free;
      GameSender := nil;
   end;
   if GameReceiver <> nil then begin
      GameReceiver.Free;
      GameReceiver := nil;
   end;
   if Socket.Connected = true then begin
      AddLog (format ('Disconnected From Game Server %s', [Socket.RemoteAddress]));
   end;
   if ConnectorList <> nil then begin
      ConnectorList.GateUniqueValue := -1;
   end;
end;

procedure TfrmMain.sckGameConnectError(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
  var ErrorCode: Integer);
begin
   if (ErrorCode <> 10061) and (ErrorCode <> 10038) then begin
      AddLog (format ('Socket Error At GameServer Connection (%d)', [ErrorCode]));
   end;
   ErrorCode := 0;
end;

procedure TfrmMain.sckGameConnectRead(Sender: TObject;
  Socket: TCustomWinSocket);
var
   nRead : Integer;
   buffer : array[0..4096 - 1] of byte;
begin
   nRead := Socket.ReceiveBuf (buffer, 4096);
   if nRead > 0 then begin
      GameReceiver.PutData (@buffer, nRead);
      exit;
   end;
end;

procedure TfrmMain.sckGameConnectWrite(Sender: TObject;
  Socket: TCustomWinSocket);
begin
	if GameSender <> nil then GameSender.WriteAllow := true;
end;

procedure TfrmMain.timerCloseTimer(Sender: TObject);
begin
	if ConnectorList = nil then begin
   	timerClose.Enabled := false;
   	Close;
      exit;
   end;
end;

procedure TfrmMain.udpBalanceDataReceived(Sender: TComponent;
  NumberBytes: Integer; FromIP: String; Port: Integer);
begin
	//
end;

procedure TfrmMain.cmdReCalcClick(Sender: TObject);
begin
   ConnectorList.ReCalc;
end;

procedure TfrmMain.sckPaidConnectConnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   if PaidSender <> nil then PaidSender.Free;
   if PaidReceiver <> nil then PaidReceiver.Free;

   PaidSender := TPacketSender.Create ('PaidSender', BufferSizeS2S, Socket);
   PaidReceiver := TPacketReceiver.Create ('PaidReceiver', BufferSizeS2S);

   AddLog (format ('Connected To Paid Server %s', [Socket.RemoteAddress]));
end;

procedure TfrmMain.sckPaidConnectDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   if PaidSender <> nil then PaidSender.Free;
   if PaidReceiver <> nil then PaidReceiver.Free;
   PaidSender := nil;
   PaidReceiver := nil;

   if Socket.Connected = true then begin
      AddLog (format ('DisConnected From Paid Server %s', [Socket.RemoteAddress]));
   end;
end;

procedure TfrmMain.sckPaidConnectError(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
  var ErrorCode: Integer);
begin
   ErrorCode := 0;
end;

procedure TfrmMain.sckPaidConnectRead(Sender: TObject;
  Socket: TCustomWinSocket);
var
   nRead : Integer;
   buffer : array [0..4096 - 1] of char;
begin
   if Socket.ReceiveLength > 0 then begin
      nRead := Socket.ReceiveBuf (buffer, 4096);
      if nRead > 0 then begin
         if PaidReceiver <> nil then begin
            PaidReceiver.PutData (@buffer, nRead);
         end;
      end;
   end;
end;

procedure TfrmMain.sckPaidConnectWrite(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   if PaidSender <> nil then PaidSender.WriteAllow := true;
end;

end.

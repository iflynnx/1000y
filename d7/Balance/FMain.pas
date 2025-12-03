unit FMain;

interface

uses
  Windows, mmSystem, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ScktComp, NMUDP, IniFiles, DefType, uUtil, ExtCtrls;

const
  MAX_AVAILABLE_GATE = 10;

type
  TGateInfo = record
    boAvail : Boolean;
    boChecked : Boolean;   
    RemoteIP : String;
    RemotePort : Integer;
    UserCount : Integer;
    ReceiveTick : Integer;
  end;

  TfrmMain = class(TForm)
    sckUser: TServerSocket;
    cmdClose: TButton;
    GroupBox1: TGroupBox;
    chkGate1: TCheckBox;
    chkGate2: TCheckBox;
    chkGate3: TCheckBox;
    chkGate4: TCheckBox;
    chkGate5: TCheckBox;
    udpGate: TNMUDP;
    chkGate6: TCheckBox;
    chkGate7: TCheckBox;
    chkGate8: TCheckBox;
    chkGate9: TCheckBox;
    chkGate10: TCheckBox;
    timerDisplay: TTimer;
    lstInfo: TListBox;
    procedure cmdCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure sckUserAccept(Sender: TObject; Socket: TCustomWinSocket);
    procedure sckUserClientError(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure sckUserClientWrite(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure udpGateDataReceived(Sender: TComponent; NumberBytes: Integer;
      FromIP: String; Port: Integer);
    procedure timerDisplayTimer(Sender: TObject);
    procedure chkGate1Click(Sender: TObject);
    procedure chkGate2Click(Sender: TObject);
    procedure chkGate3Click(Sender: TObject);
    procedure chkGate4Click(Sender: TObject);
    procedure chkGate5Click(Sender: TObject);
    procedure chkGate6Click(Sender: TObject);
    procedure chkGate7Click(Sender: TObject);
    procedure chkGate8Click(Sender: TObject);
    procedure chkGate9Click(Sender: TObject);
    procedure chkGate10Click(Sender: TObject);
    procedure sckUserClientDisconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure sckUserClientConnect(Sender: TObject;
      Socket: TCustomWinSocket);
  private
    { Private declarations }
    procedure DrawStatus (aPos : Integer);
    function isGateChecked (aPos : Integer) : Boolean;
  public
    { Public declarations }

    procedure AddInfo (aStr : String);
  end;

var
  frmMain: TfrmMain;
  TcpLocalPort, UdpLocalPort : Integer;
  TotalConnectionCount : Integer = 0;
  GateInfo : array [0..MAX_AVAILABLE_GATE - 1] of TGateInfo;

implementation

uses
   uPackets;

{$R *.DFM}

procedure TfrmMain.AddInfo (aStr : String);
begin
   if lstInfo.Items.Count >= 10 then begin
      lstInfo.Items.Delete (0);
   end;

   lstInfo.Items.Add (aStr);
   lstInfo.ItemIndex := lstInfo.Items.Count - 1;
end;

procedure TfrmMain.cmdCloseClick(Sender: TObject);
begin
   Close;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
   i : Integer;
   iniFile : TIniFile;
begin
   if not FileExists ('.\BALANCE.INI') then begin
      iniFile := TIniFile.Create ('.\BALANCE.INI');
      iniFile.WriteInteger ('BALANCE', 'TCPLOCALPORT', 3053);
      iniFile.WriteInteger ('BALANCE', 'UDPLOCALPORT', 3030);
      iniFile.Free;
   end;
   iniFile := TIniFile.Create ('.\BALANCE.INI');
   TcpLocalPort := iniFile.ReadInteger ('BALANCE', 'TCPLOCALPORT', 3053);
   UdpLocalPort := iniFile.ReadInteger ('BALANCE', 'UDPLOCALPORT', 3030);
   for i := 0 to MAX_AVAILABLE_GATE - 1 do begin
      GateInfo[i].boAvail := false;
      GateInfo[i].boChecked := true;
      GateInfo[i].RemoteIP := '';
      GateInfo[i].RemotePort := 0;
      GateInfo[i].UserCount := 0;
      GateInfo[i].ReceiveTick := 0;

      DrawStatus (i);
   end;
   iniFile.Free;

   try
      udpGate.LocalPort := UdpLocalPort;

      sckUser.Port := TcpLocalPort;
      sckUser.Active := true;

      timerDisplay.Interval := 1000;
      timerDisplay.Enabled := true;
   except
      Close;
   end;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
   //
end;

procedure TfrmMain.sckUserAccept(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  //
end;

procedure TfrmMain.sckUserClientError(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
  var ErrorCode: Integer);
begin
   ErrorCode := 0;
end;

procedure TfrmMain.sckUserClientWrite(Sender: TObject;
  Socket: TCustomWinSocket);
var
   ComData : TComData;
   sConnectThru : TSConnectThru;
   i, nIndex, MinCount : Integer;
   PacketSender : TPacketSender;
begin
   FillChar (sConnectThru, SizeOf (TSConnectThru), 0);

   nIndex := -1;
   MinCount := 0;
   for i := 0 to MAX_AVAILABLE_GATE - 1 do begin
      if GateInfo[i].boAvail = true then begin
         if nIndex = -1 then begin
            MinCount := GateInfo[i].UserCount + 1;
         end;
         if GateInfo[i].UserCount < MinCount then begin
            nIndex := i;
            MinCount := GateInfo[i].UserCount;
         end;
      end;
   end;

   if (nIndex >= 0) and (isGateChecked (nIndex) = true) then begin
      sConnectThru.rMsg := SM_CONNECTTHRU;
      StrPCopy (@sConnectThru.rIpAddr, GateInfo[nIndex].RemoteIP);
      sConnectThru.rPort := GateInfo[nIndex].RemotePort;
      ComData.Size := SizeOf (TSConnectThru);
      Move (sConnectThru, ComData.Data, ComData.Size);

      PacketSender := TPacketSender.Create ('Sender', 4096, Socket);
      PacketSender.WriteAllow := true;
      PacketSender.PutPacket (0, 0, 0, @ComData, ComData.Size + SizeOf (Word));
      PacketSender.Update;
      PacketSender.Free;
   end;

   // Socket.Close;
end;

procedure TfrmMain.DrawStatus (aPos : Integer);
var
   mCaption : String;
begin
   mCaption := '';
   if GateInfo[aPos].boAvail = true then begin
      mCaption := format ('%s:%d (C:%d)', [GateInfo[aPos].RemoteIP, GateInfo[aPos].RemotePort, GateInfo[aPos].UserCount]);
   end else begin
      mCaption := 'Not available';
   end;

   Case aPos of
      0 : begin
         chkGate1.Enabled := GateInfo[aPos].boAvail;
         if GateInfo[aPos].boChecked = true then begin
            chkGate1.Checked := true;
         end;
         chkGate1.Caption := 'Gate 1 ' + mCaption;
      end;
      1 : begin
         chkGate2.Enabled := GateInfo[aPos].boAvail;
         if GateInfo[aPos].boChecked = true then begin
            chkGate2.Checked := true;
         end;
         chkGate2.Caption := 'Gate 2 ' + mCaption;
      end;
      2 : begin
         chkGate3.Enabled := GateInfo[aPos].boAvail;
         if GateInfo[aPos].boChecked = true then begin
            chkGate3.Checked := true;
         end;
         chkGate3.Caption := 'Gate 3 ' + mCaption;
      end;
      3 : begin
         chkGate4.Enabled := GateInfo[aPos].boAvail;
         if GateInfo[aPos].boChecked = true then begin
            chkGate4.Checked := true;
         end;
         chkGate4.Caption := 'Gate 4 ' + mCaption;
      end;
      4 : begin
         chkGate5.Enabled := GateInfo[aPos].boAvail;
         if GateInfo[aPos].boChecked = true then begin
            chkGate5.Checked := true;
         end;
         chkGate5.Caption := 'Gate 5 ' + mCaption;
      end;
      5 : begin
         chkGate6.Enabled := GateInfo[aPos].boAvail;
         if GateInfo[aPos].boChecked = true then begin
            chkGate6.Checked := true;
         end;
         chkGate6.Caption := 'Gate 6 ' + mCaption;
      end;
      6 : begin
         chkGate7.Enabled := GateInfo[aPos].boAvail;
         if GateInfo[aPos].boChecked = true then begin
            chkGate7.Checked := true;
         end;
         chkGate7.Caption := 'Gate 7 ' + mCaption;
      end;
      7 : begin
         chkGate8.Enabled := GateInfo[aPos].boAvail;
         if GateInfo[aPos].boChecked = true then begin
            chkGate8.Checked := true;
         end;
         chkGate8.Caption := 'Gate 8 ' + mCaption;
      end;
      8 : begin
         chkGate9.Enabled := GateInfo[aPos].boAvail;
         if GateInfo[aPos].boChecked = true then begin
            chkGate9.Checked := true;
         end;
         chkGate9.Caption := 'Gate 9 ' + mCaption;
      end;
      9 : begin
         chkGate10.Enabled := GateInfo[aPos].boAvail;
         if GateInfo[aPos].boChecked = true then begin
            chkGate10.Checked := true;
         end;
         chkGate10.Caption := 'Gate 10 ' + mCaption;
      end;
   end;
end;

function TfrmMain.isGateChecked (aPos : Integer) : Boolean;
begin
   Result := false;

   Case aPos of
      0 : begin Result := chkGate1.Checked; exit; end;
      1 : begin Result := chkGate2.Checked; exit; end;
      2 : begin Result := chkGate3.Checked; exit; end;
      3 : begin Result := chkGate4.Checked; exit; end;
      4 : begin Result := chkGate5.Checked; exit; end;
      5 : begin Result := chkGate6.Checked; exit; end;
      6 : begin Result := chkGate7.Checked; exit; end;
      7 : begin Result := chkGate8.Checked; exit; end;
      8 : begin Result := chkGate9.Checked; exit; end;
      9 : begin Result := chkGate10.Checked; exit; end;
   end;
end;

procedure TfrmMain.udpGateDataReceived(Sender: TComponent;
  NumberBytes: Integer; FromIP: String; Port: Integer);
var
   i, cnt : Integer;
   buffer : array [0..4096 - 1] of char;
   pd : PTBalanceData;
begin
   // if FromIP = '127.0.0.1' then exit;
   if NumberBytes > 0 then begin
      cnt := NumberBytes;
      udpGate.ReadBuffer (buffer, cnt);
      if cnt > 0 then begin
         pd := @buffer;
         Case pd^.rMsg of
            BM_GATEINFO :
               begin
                  if StrPas (@pd^.rIpAddr) <> FromIP then exit;
                   
                  // if cnt <> SizeOf (TBalanceData) then exit;
                  for i := 0 to MAX_AVAILABLE_GATE - 1 do begin
                     if GateInfo[i].boAvail = true then begin
                        if pd^.rIpAddr = GateInfo[i].RemoteIP then begin
                           if pd^.rPort = GateInfo[i].RemotePort then begin
                              GateInfo[i].UserCount := pd^.rUserCount;
                              GateInfo[i].ReceiveTick := timeGetTime;

                              DrawStatus (i);
                              exit;
                           end;
                        end;
                     end;
                  end;

                  for i := 0 to MAX_AVAILABLE_GATE - 1 do begin
                     if GateInfo[i].boAvail = false then begin
                        GateInfo[i].boAvail := true;
                        GateInfo[i].RemoteIP := StrPas (@pd^.rIpAddr);
                        GateInfo[i].RemotePort := pd^.rPort;
                        GateInfo[i].UserCount := pd^.rUserCount;
                        GateInfo[i].ReceiveTick := timeGetTime;

                        DrawStatus (i);
                        exit;
                     end;
                  end;
               end;
         end;
      end;
   end;
end;

procedure TfrmMain.timerDisplayTimer(Sender: TObject);
var
   i, CurTick : Integer;
   Socket : TCustomWinSocket;
begin
   CurTick := timeGetTime;
   for i := 0 to MAX_AVAILABLE_GATE - 1 do begin
      if GateInfo[i].boAvail = true then begin
         if CurTick >= GateInfo[i].ReceiveTick + 5000 then begin
            GateInfo[i].boAvail := false;
            DrawStatus (i);
         end;
      end;
   end;

   {
   for i := 0 to sckUser.Socket.ActiveConnections - 1 do begin
      Socket := sckUser.Socket.Connections [i];
      sckUserClientWrite (Self, Socket);
   end;
   } 
end;

procedure TfrmMain.chkGate1Click(Sender: TObject);
begin
   GateInfo[0].boChecked := chkGate1.Checked;
end;

procedure TfrmMain.chkGate2Click(Sender: TObject);
begin
   GateInfo[1].boChecked := chkGate2.Checked;
end;

procedure TfrmMain.chkGate3Click(Sender: TObject);
begin
   GateInfo[2].boChecked := chkGate3.Checked;
end;

procedure TfrmMain.chkGate4Click(Sender: TObject);
begin
   GateInfo[3].boChecked := chkGate4.Checked;
end;

procedure TfrmMain.chkGate5Click(Sender: TObject);
begin
   GateInfo[4].boChecked := chkGate5.Checked;
end;

procedure TfrmMain.chkGate6Click(Sender: TObject);
begin
   GateInfo[5].boChecked := chkGate6.Checked;
end;

procedure TfrmMain.chkGate7Click(Sender: TObject);
begin
   GateInfo[6].boChecked := chkGate7.Checked;
end;

procedure TfrmMain.chkGate8Click(Sender: TObject);
begin
   GateInfo[7].boChecked := chkGate8.Checked;
end;

procedure TfrmMain.chkGate9Click(Sender: TObject);
begin
   GateInfo[8].boChecked := chkGate9.Checked;
end;

procedure TfrmMain.chkGate10Click(Sender: TObject);
begin
   GateInfo[9].boChecked := chkGate10.Checked;
end;

procedure TfrmMain.sckUserClientDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   AddInfo (Socket.RemoteAddress + ' DisConnected');
end;

procedure TfrmMain.sckUserClientConnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   Inc (TotalConnectionCount);

   AddInfo (Socket.RemoteAddress + ' Connected');
   Caption := 'Balance (' + IntToStr (TotalConnectionCount) + ')';
end;

end.

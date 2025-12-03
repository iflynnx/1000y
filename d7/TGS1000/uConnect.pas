unit uConnect;

interface

uses
   Classes, SysUtils, uGConnect, uDBRecordDef, uBuffer, uAnsTick,
   uKeyClass, DefType, aDefType, BSCommon, uPackets, AnsStringCls;

type
   TBattleConnectState = ( bcs_none, bcs_gotobattle, bcs_inbattle );

   TConnector = class
   private
      GateNo : Integer;
      ConnectID : Integer;

      CharName : String;
      StartTime : String;

      SaveTick : Integer;

      BattleConnectState : TBattleConnectState;
   public
      CharData : TDBRecord;
      NTData : TNoticeData;

      LoginID : String;
      IpAddr : String;
      VerNo : Byte;
      PaidType : TPaidType;
      PaidCode : Byte;

      ReceiveBuffer : TPacketBuffer;
   public
      constructor Create (aGateNo, aConnectID : Integer);
      destructor Destroy; override;

      function StartLayer (aData : PChar) : Boolean;
      procedure EndLayer;
      procedure ReStartLayer;
      
      procedure Update (CurTick : Integer);

      procedure MessageProcess (aComData : PTWordComData);

      procedure AddReceiveData (aData : PChar; aSize : Integer);
      procedure AddSendData (aData : PChar; aSize : Integer);

      property BattleState : TBattleConnectState read BattleConnectState write BattleConnectState;
   end;
   
   TConnectorList = class
   private
      UniqueKey : TIntegerKeyClass;
      NameKey : TStringKeyClass;
      
      DataList : TList;

      SaveBuffer : TPacketBuffer;

      CreateTick : Integer;
      DeleteTick : Integer;
      SaveTick : Integer;

      ConnectorProcessCount : Integer;
      CurProcessPos : Integer;
      
      function GetCount : Integer;
      function GetNameKeyCount : Integer;
      function GetUniqueKeyCount : Integer;
   public
      constructor Create;
      destructor Destroy; override;

      procedure Clear;

      procedure Update (CurTick : Integer);

      procedure CreateConnect (aGateNo : Integer; aPacket : PTPacketData);
      procedure DeleteConnect (aGateNo, aConnectID : Integer);

      procedure ReStartChar (aConnectID : Integer);

      procedure CloseAllConnect;
      procedure CloseConnectByCharName (aName : String);
      procedure CloseConnectByGateNo (aGateNo : Integer);

      procedure AddReceiveData (aGateNo : Integer; aPacket : PTPacketData);
      procedure AddSendData (aPacket : PTPacketData);

      procedure AddSaveData (aData : PChar; aSize : Integer);

      function GetSaveListCount : Integer;

      procedure ProcessNoticeServerMessage (aPacketData : PTPacketData);
      procedure SendConnectInfo (aInfoStr: String);

      property Count : Integer read GetCount;
      property NameKeyCount : Integer read GetNameKeyCount;
      property UniqueKeyCount : Integer read GetUniqueKeyCount;
   end;

var
   ConnectorList : TConnectorList;

implementation

uses
   svMain, FGate, uUser, svClass, FSockets, AUtil32;

constructor TConnector.Create (aGateNo, aConnectID : Integer);
begin
   GateNo := aGateNo;
   ConnectID := aConnectID;

   VerNo := 0;
   PaidType := pt_none;
   PaidCode := 0;
   CharName := '';
   LoginID := '';
   IpAddr := '';

   BattleConnectState := bcs_none;
   
   FillChar (CharData, SizeOf (TDBRecord), 0);

   StartTime := DateToStr (Date) + ' ' + TimeToStr (Time);
   SaveTick := mmAnsTick;

   ReceiveBuffer := TPacketBuffer.Create (BufferSizeS2C);
end;

destructor TConnector.Destroy;
var
   Str : String;
begin
   NTData.rMsg := GNM_OUTUSER;
   FrmSockets.AddDataToNotice (@NTData, SizeOf (TNoticeData));

   frmGate.AddLog ('close ' + CharName);

   if BattleConnectState <> bcs_none then begin
      frmGate.AddSendBattleData (ConnectID, GB_USERDISCONNECT, 0, nil, 0);
   end;
   
   if CharName <> '' then begin
      if BattleConnectState = bcs_none then EndLayer;
      ConnectorList.AddSaveData (@CharData, SizeOf (TDBRecord));
   end;

   Str := StrPas (@CharData.MasterName) + ',' + CharName + ',' + IpAddr + ',' + StartTime + ',' + DateToStr (Date) + ' ' + TimeToStr (Time);  
   ConnectorList.SendConnectInfo (Str);

   ReceiveBuffer.Free;

   inherited Destroy;
end;

function TConnector.StartLayer (aData : PChar) : Boolean;
var
   Str, rdStr : String;
begin
   Result := true;

   Move (aData^, CharData, SizeOf (TDBRecord));
   CharName := StrPas (@CharData.PrimaryKey);
   LoginID := StrPas (@CharData.MasterName);
   Str := StrPas (@CharData.Dummy);

   Str := GetValidStr3 (Str, rdStr, ',');
   IpAddr := rdStr;
   Str := GetValidStr3 (Str, rdStr, ',');
   VerNo := _StrToInt (rdStr);
   Str := GetValidStr3 (Str, rdStr, ',');
   PaidType := TPaidType (_StrToInt (rdStr));
   Str := GetValidStr3 (Str, rdStr, ',');
   PaidCode := _StrToInt (rdStr);

   FillChar (CharData.Dummy, SizeOf (CharData.Dummy), 0);

   if UserList.InitialLayer (CharName, Self) = false then begin
      Result := false;
      exit;
   end;
   UserList.StartChar (CharName);

   FillChar (NTData, SizeOf(TNoticeData), 0);
   NTData.rMsg := GNM_INUSER;
   NTData.rLoginId := LoginID;
   NTData.rCharName := CharName;
   NTData.rIpAddr := IpAddr;
   NTData.rPaidType := TPaidType (PaidType);
   NTData.rCode := PaidCode;

   FrmSockets.AddDataToNotice (@NTData, SizeOf(TNoticeData));
end;

procedure TConnector.EndLayer;
begin
   UserList.FinalLayer (Self);
end;

procedure TConnector.ReStartLayer;
begin
   if UserList.InitialLayer (CharName, Self) = false then begin
      exit;
   end;
   UserList.StartChar (CharName);
   BattleConnectState := bcs_none;
end;

procedure TConnector.Update (CurTick : Integer);
var
   ComData : TWordComData;
   iCnt : Word;
begin
   if frmMain.chkSaveUserData.Checked = true then begin
      if SaveTick + 60 * 10 * 100 < CurTick then begin
         ConnectorList.AddSaveData (@CharData, SizeOf (TDBRecord));
         SaveTick := CurTick;
      end;
   end;

   if BattleConnectState = bcs_gotobattle then begin
      UserList.FinalLayer (Self);

      frmGate.AddSendBattleData (ConnectID, GB_USERCONNECT, 0, @CharData, SizeOf (TDBRecord));

      BattleConnectState := bcs_inbattle;
   end else if BattleConnectState = bcs_inbattle then begin
      if ReceiveBuffer.Count > 0 then begin
         while true do begin
            if ReceiveBuffer.Get (@ComData) = false then break;
            frmGate.AddSendBattleData (ConnectID, GB_GAMEDATA, 0, @ComData, ComData.Size + SizeOf (Word));
         end;
      end;
   end;
end;

procedure TConnector.MessageProcess (aComData : PTWordComData);
begin
end;

procedure TConnector.AddReceiveData (aData : PChar; aSize : Integer);
begin
   if ReceiveBuffer.Put (aData, aSize) = false then begin
      frmMain.WriteLogInfo ('TConnector.AddReceiveData() failed');
   end;
end;

procedure TConnector.AddSendData (aData : PChar; aSize : Integer);
begin
   GateConnectorList.AddSendData (GateNo, ConnectID, aData, aSize);
end;

// TConnectorList
constructor TConnectorList.Create;
begin
   CurProcessPos := 0;
   ConnectorProcessCount := 0;

   CreateTick := 0;
   DeleteTick := 0;
   SaveTick := 0;

   UniqueKey := TIntegerKeyClass.Create;
   NameKey := TStringKeyClass.Create;
   
   DataList := TList.Create;

   SaveBuffer := TPacketBuffer.Create (1024 * 1024 * 4);
end;

destructor TConnectorList.Destroy;
begin
   Clear;
   UniqueKey.Free;
   NameKey.Free;
   DataList.Free;

   SaveBuffer.Free;

   inherited Destroy;
end;

procedure TConnectorList.Clear;
var
   i : Integer;
   Connector : TConnector;
begin
   UniqueKey.Clear;
   NameKey.Clear;

   for i := 0 to DataList.Count - 1 do begin
      Connector := DataList.Items [i];
      Connector.Free;
   end;
   DataList.Clear;

   SaveBuffer.Clear;
end;

procedure TConnectorList.Update (CurTick : Integer);
var
   i, j, StartPos, nCount, nPos : Integer;
   Connector : TConnector;
   CharData : TDBRecord;
begin
   if SaveBuffer.Count > 0 then begin
      if CurTick >= SaveTick + 10 then begin
         if SaveBuffer.View (@CharData) = true then begin
            if frmGate.AddSendDBServerData (DB_UPDATE, @CharData, SizeOf (TDBRecord)) = true then begin
               SaveBuffer.Flush;
            end;
         end;
         SaveTick := CurTick;
      end;
   end;

   ConnectorProcessCount := (DataList.Count * 4 div 100);
   if ConnectorProcessCount = 0 then ConnectorProcessCount := DataList.Count;

   ConnectorProcessCount := ProcessListCount;

   if DataList.Count > 0 then begin
      StartPos := CurProcessPos;
      for i := 0 to ConnectorProcessCount - 1 do begin
         if CurProcessPos >= DataList.Count then CurProcessPos := 0;
         Connector := DataList.Items [CurProcessPos];
         Connector.Update (CurTick);
         Inc (CurProcessPos);
         if CurProcessPos = StartPos then break;
      end;
   end;
end;

function TConnectorList.GetCount : Integer;
begin
   Result := DataList.Count;
end;

function TConnectorList.GetNameKeyCount : Integer;
begin
   Result := NameKey.Count;
end;

function TConnectorList.GetUniqueKeyCount : Integer;
begin
   Result := UniqueKey.Count;
end;

procedure TConnectorList.CreateConnect (aGateNo : Integer; aPacket : PTPacketData);
var
   nPos : Integer;
   Connector : TConnector;
   pcd : PTDBRecord;
   GateNo, ConnectID : Integer;
begin
   GateNo := aGateNo;
   ConnectID := aPacket^.RequestID;
   pcd := @aPacket^.Data;

   if StrPas (@pcd^.PrimaryKey) = '' then begin
      frmMain.WriteLogInfo ('NOName Char found');
      GateConnectorList.AddSendServerData (GateNo, ConnectID, GM_DISCONNECT, nil, 0);
      exit;
   end;

   Connector := NameKey.Select (StrPas (@pcd^.PrimaryKey));
   if Connector <> nil then begin
      GateConnectorList.AddSendServerData (Connector.GateNo, Connector.ConnectID, GM_DISCONNECT, nil, 0);
      GateConnectorList.AddSendServerData (GateNo, ConnectID, GM_DUPLICATE, nil, 0);

      try
         UniqueKey.Delete (Connector.ConnectID);
         NameKey.Delete (Connector.CharName);
         DataList.Remove (Connector);
         Connector.Free;
      except
         frmMain.WriteLogInfo ('TConnectorList.CreateConnect () failed');
      end;
      exit;
   end;

   Connector := TConnector.Create (GateNo, ConnectID);
   if Connector.StartLayer (@aPacket^.Data) = false then begin
      GateConnectorList.AddSendServerData (GateNo, ConnectID, GM_DUPLICATE, nil, 0);
      Connector.Free;
      CloseConnectByCharName (StrPas (@pcd^.PrimaryKey));
      exit;
   end;

   GateConnectorList.AddSendServerData (GateNo, ConnectID, GM_CONNECT, nil, 0);

   UniqueKey.Insert (ConnectID, Connector);
   NameKey.Insert (Connector.CharName, Connector);
   DataList.Add (Connector);
end;

procedure TConnectorList.DeleteConnect (aGateNo, aConnectID : Integer);
var
   nPos : Integer;
   Connector : TConnector;
begin
   Connector := UniqueKey.Select (aConnectID);
   if Connector <> nil then begin
      try
         nPos := DataList.IndexOf (Connector);
         UniqueKey.Delete (Connector.ConnectID);
         NameKey.Delete (Connector.CharName);
         Connector.Free;
         DataList.Delete (nPos);
      except
         frmMain.WriteLogInfo ('TConnectorList.CreateConnect () failed');
      end;
   end;
end;

procedure TConnectorList.ReStartChar (aConnectID : Integer);
var
   Connector : TConnector;
begin
   Connector := UniqueKey.Select (aConnectID);
   if Connector <> nil then begin
      Connector.ReStartLayer;
   end;
end;

procedure TConnectorList.CloseAllConnect;
var
   i : Integer;
   Connector : TConnector;
begin
   for i := 0 to DataList.Count - 1 do begin
      Connector := DataList.Items [i];
      GateConnectorList.AddSendServerData (Connector.GateNo, Connector.ConnectID, GM_DISCONNECT, nil, 0);
   end;
end;

procedure TConnectorList.CloseConnectByCharName (aName : String);
var
   i : Integer;
   Connector : TConnector;
begin
   for i := DataList.Count - 1 downto 0 do begin
      Connector := DataList.Items [i];
      if Connector.CharName = aName then begin
         GateConnectorList.AddSendServerData (Connector.GateNo, Connector.ConnectID, GM_DISCONNECT, nil, 0);
         exit;
      end;
   end;
end;

procedure TConnectorList.CloseConnectByGateNo (aGateNo : Integer);
var
   i : Integer;
   Connector : TConnector;
begin
   for i := DataList.Count - 1 downto 0 do begin
      Connector := DataList.Items [i];
      if Connector.GateNo = aGateNo then begin
         DeleteConnect (aGateNo, Connector.ConnectID);
      end;
   end;
end;

procedure TConnectorList.AddReceiveData (aGateNo : Integer; aPacket : PTPacketData);
var
   ComData : TWordComData;
   Connector : TConnector;
begin
   Connector := UniqueKey.Select (aPacket^.RequestID);
   if Connector <> nil then begin
      if Connector.BattleConnectState = bcs_none then begin
         ComData.Size := aPacket^.PacketSize - (SizeOf (Word) + SizeOf (Integer) + SizeOf (Byte) * 2);
         Move (aPacket^.Data, ComData.Data, ComData.Size);
         Connector.AddReceiveData (@ComData, ComData.Size + SizeOf (Word));
      end else begin
         ComData.Size := aPacket^.PacketSize - (SizeOf (Word) + SizeOf (Integer) + SizeOf (Byte) * 2);
         Move (aPacket^.Data, ComData.Data, ComData.Size);
         frmGate.AddSendBattleData (aPacket^.RequestID, GB_GAMEDATA, 0, @ComData.Data, ComData.Size);
      end;
      exit;
   end;
end;

procedure TConnectorList.AddSendData (aPacket : PTPacketData);
var
   ComData : TWordComData;
   Connector : TConnector;
begin
   Connector := UniqueKey.Select (aPacket^.RequestID);
   if Connector <> nil then begin
      ComData.Size := aPacket^.PacketSize - (SizeOf (Word) + SizeOf (Integer) + SizeOf (Byte) * 2);
      Move (aPacket^.Data, ComData.Data, ComData.Size);
      Connector.AddSendData (@ComData.Data, ComData.Size);
      exit;
   end;
end;

procedure TConnectorList.AddSaveData (aData : PChar; aSize : Integer);
begin
   SaveBuffer.Put (aData, aSize);
end;

function TConnectorList.GetSaveListCount : Integer;
begin
   Result := SaveBuffer.Count;
end;

procedure TConnectorList.ProcessNoticeServerMessage (aPacketData : PTPacketData);
var
   i : integer;
   User: TUser;
   Connector : TConnector;
   pnd : PTNoticeData;
   nd : TNoticeData;
   Str : String;
begin
   if aPacketData^.RequestMsg <> PACKET_NOTICE then exit;
   
   pnd := @aPacketData^.Data;
   case pnd^.rMsg of
      NGM_REQUESTCLOSE :
         begin
            Str := pnd^.rCharName;
            Connector := NameKey.Select (Str);
            if Connector <> nil then begin
               User := UserList.GetUserPointer (Str);
               if User <> nil then begin
                  User.SendClass.SendChatMessage ('因重复连接或连接超时,请重新连线.', SAY_COLOR_SYSTEM);
               end;
               CloseConnectByCharName (Str);
            end;
         end;
      NGM_REQUESTALLUSER :
         begin
            FillChar (nd, SizeOf (TNoticeData), 0);
            nd.rMsg := GNM_ALLCLEAR;
            FrmSockets.AddDataToNotice (@nd, SizeOf (TNoticeData));
            for i := 0 to DataList.Count - 1 do begin
               Connector := DataList.Items [i];
               if Connector.CharName <> '' then begin
                  FrmSockets.AddDataToNotice (@Connector.NTData, SizeOf (TNoticeData));
               end;
            end;
         end;
   end;
end;

procedure TConnectorList.SendConnectInfo (aInfoStr: String);
var
   cnt : integer;
   usd : TStringData;
begin
   usd.rmsg := 1;
   SetWordString (usd.rWordString, aInfoStr + ',');
   cnt := sizeof(usd) - sizeof(TWordString) + sizeofwordstring (usd.rwordstring);

   FrmSockets.UdpConnectAddData (cnt, @usd);
end;

end.
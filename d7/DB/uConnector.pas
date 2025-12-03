unit uConnector;

interface

uses
   Windows, Classes, SysUtils, ScktComp, uBuffer, uRecordDef, uPackets, DefType;

type
   TConnectType = ( ct_gate, ct_gameserver );
   
   TConnector = class
   private
      Socket : TCustomWinSocket;
      boWriteAllow : Boolean;

      ConnectType : TConnectType;

      GateSender : TPacketSender;
      GateReceiver : TPacketReceiver;
   protected
   public
      constructor Create (aSocket :  TCustomWinSocket);
      destructor Destroy; override;

      procedure Update (CurTick : Integer);
      procedure MessageProcess (aPacket : PTPacketData);

      procedure AddReceiveData (aData : PChar; aCount : Integer);
      procedure AddSendData (aID : Integer; aMsg, aRetCode : Byte; aData : PChar; aSize : Integer);

      procedure SetWriteAllow (boFlag : Boolean);
   end;

   TConnectorList = class
   private
      DataList : TList;

      function GetCount : Integer;
   protected
   public
      constructor Create;
      destructor Destroy; override;

      procedure Clear;

      function CreateConnect (aSocket :  TCustomWinSocket) : Boolean;
      function DeleteConnect (aSocket :  TCustomWinSocket) : Boolean;

      procedure Update (CurTick : Integer);
      
      procedure AddReceiveData (aSocket : TCustomWinSocket; aData : PChar; aCount : Integer);

      procedure SetWriteAllow (aSocket : TCustomWinSocket);

      function AddPacketToGameServer (aID : Integer; aMsg, aRetCode : Byte; aData : PChar; aSize : Integer) : Boolean;

      property Count : Integer read GetCount;
   end;

var
   ConnectorList : TConnectorList;

implementation

uses
   FMain, uDBProvider, uRemoteConnector;

// TConnector
constructor TConnector.Create (aSocket : TCustomWinSocket);
begin
   Socket := aSocket;
   boWriteAllow := false;

   ConnectType := ct_gate;

   GateSender := TPacketSender.Create ('Gate', BufferSizeS2S, aSocket);
   GateReceiver := TPacketReceiver.Create ('Gate', BufferSizeS2S);
end;

destructor TConnector.Destroy;
begin
   GateSender.Free;
   GateReceiver.Free;

   inherited Destroy;
end;

procedure TConnector.SetWriteAllow (boFlag : Boolean);
begin
   GateSender.WriteAllow := boFlag;
end;

procedure TConnector.AddReceiveData (aData : PChar; aCount : Integer);
begin
   if aCount > 0 then begin
      GateReceiver.PutData (aData, aCount);
      frmMain.AddEvent (format ('DataReceived (%d bytes %s)', [aCount, Socket.RemoteAddress]));
   end;
end;

procedure TConnector.AddSendData (aID : Integer; aMsg, aRetCode : Byte; aData : PChar; aSize : Integer);
begin
   if aSize < SizeOf (TPacketData) then begin
      GateSender.PutPacket (aID, aMsg, aRetCode, aData, aSize);
      frmMain.AddEvent (format ('DataSend (%d bytes %s)', [aSize, Socket.RemoteAddress]));
   end;
end;


procedure TConnector.Update (CurTick : Integer);
var
   Packet : TPacketData;
begin
   GateReceiver.Update;
   while GateReceiver.Count > 0 do begin
      if GateReceiver.GetPacket (@Packet) = false then break;
      MessageProcess (@Packet);
   end;

   GateSender.Update;
end;

procedure TConnector.MessageProcess (aPacket : PTPacketData);
var
   RecordData : TDBRecord;
   KeyValue, mStr : String;
   nCode : Byte;
begin
   Case aPacket^.RequestMsg of
      DB_INSERT :
         begin
            RecordData.boUsed := 1;
            Move (aPacket^.Data, RecordData.PrimaryKey, SizeOf (TDBRecord) - SizeOf(Byte));
            KeyValue := StrPas (@RecordData.PrimaryKey);

            nCode := DBProvider.Insert (KeyValue, @RecordData);
            if nCode = DB_OK then begin
               frmMain.AddLog (format ('DB_INSERT %s', [KeyValue]));
            end else begin
               frmMain.AddLog (format ('DB_INSERT failed %s', [KeyValue]));
            end;
            AddSendData (aPacket^.RequestID, aPacket^.RequestMsg, nCode, @RecordData.PrimaryKey, SizeOf (RecordData.PrimaryKey));
         end;
      DB_SELECT :
         begin
            Move (aPacket^.Data, RecordData.PrimaryKey, SizeOf (RecordData.PrimaryKey));
            KeyValue := StrPas (@RecordData.PrimaryKey);

            nCode := DBProvider.Select (KeyValue, @RecordData);
            if nCode = DB_OK then begin
               frmMain.AddLog (format ('DB_SELECT %s', [KeyValue]));
               AddSendData (aPacket^.RequestID, aPacket^.RequestMsg, nCode, @RecordData.PrimaryKey, SizeOf (TDBRecord) - SizeOf (Byte));
            end else begin
               frmMain.AddLog (format ('DB_SELECT failed %s', [KeyValue]));
               AddSendData (aPacket^.RequestID, aPacket^.RequestMsg, nCode, @RecordData.PrimaryKey, 0);
            end;
         end;
      DB_UPDATE :
         begin
            RecordData.boUsed := 1;
            Move (aPacket^.Data, RecordData.PrimaryKey, SizeOf (TDBRecord) - SizeOf (Byte));
            KeyValue := StrPas (@RecordData.PrimaryKey);

            nCode := DBProvider.Update (KeyValue, @RecordData);
            if nCode = DB_OK then begin
               mStr := DBProvider.ChangeDataToStr (@RecordData);
               frmMain.AddTodayData (KeyValue, mStr);
               frmMain.AddLog (format ('DB_UPDATE %s', [KeyValue]));
               AddSendData (aPacket^.RequestID, aPacket^.RequestMsg, nCode, @RecordData.PrimaryKey, SizeOf (RecordData.PrimaryKey));
            end else begin
               frmMain.AddLog (format ('DB_UPDATE failed %s', [KeyValue]));
               AddSendData (aPacket^.RequestID, aPacket^.RequestMsg, nCode, @RecordData.PrimaryKey, 0);
            end;
         end;
      DB_LOCK :
         begin
            KeyValue := StrPas (@aPacket^.Data);
            CurrentCharList.Insert (KeyValue, @RecordData);
         end;
      DB_UNLOCK :
         begin
            KeyValue := StrPas (@aPacket^.Data);
            CurrentCharList.Delete (KeyValue);
         end;
      DB_CONNECTTYPE :
         begin
            KeyValue := StrPas (@aPacket^.Data);
            if UpperCase (KeyValue) = 'GATE' then begin
               ConnectType := ct_gate;
            end else if UpperCase (KeyValue) = 'GAMESERVER' then begin
               ConnectType := ct_gameserver;
            end; 
         end;
      DB_ITEMSELECT :
         begin
            KeyValue := StrPas (@aPacket^.Data);
            RemoteConnectorList.AddRequestData (aPacket^.RequestMsg, aPacket^.RequestID, aPacket^.ResultCode, KeyValue);
         end;
      DB_ITEMUPDATE :
         begin

         end;
      Else
         begin
            frmMain.AddLog (format ('%d Packet was received', [aPacket^.RequestMsg]));
         end;
   end;
end;


// TConnectorList
constructor TConnectorList.Create;
begin
   DataList := TList.Create;
end;

destructor TConnectorList.Destroy;
begin
   Clear;
   DataList.Free;

   inherited Destroy;
end;

procedure TConnectorList.Clear;
var
   i : Integer;
   Connector : TConnector;
begin
   for i := 0 to DataList.Count - 1 do begin
      Connector := DataList.Items [i];
      Connector.Free;
   end;
   DataList.Clear;
end;

function TConnectorList.GetCount : Integer;
begin
   Result := DataList.Count;
end;

function TConnectorList.CreateConnect (aSocket : TCustomWinSocket) : Boolean;
var
   Connector : TConnector;
begin
   Result := true;

   try
      Connector := TConnector.Create (aSocket);
      DataList.Add (Connector);
   except
      frmMain.AddEvent ('TConnectorList.CreateConnect failed (' + aSocket.RemoteAddress + ')');
      Result := false;
   end;
end;

function TConnectorList.DeleteConnect (aSocket :  TCustomWinSocket) : Boolean;
var
   i : Integer;
   Connector : TConnector;
begin
   Result := true;

   for i := 0 to DataList.Count - 1 do begin
      Connector := DataList.Items [i];
      if Connector.Socket = aSocket then begin
         DataList.Delete (i);
         exit;
      end;
   end;

   frmMain.AddEvent ('TConnectorList.DeleteConnect failed (' + aSocket.RemoteAddress + ')');
   Result := false;
end;

procedure TConnectorList.AddReceiveData (aSocket :  TCustomWinSocket; aData : PChar; aCount : Integer);
var
   i : Integer;
   Connector : TConnector;
begin
   for i := 0 to DataList.Count - 1 do begin
      Connector := DataList.Items [i];
      if Connector.Socket = aSocket then begin
         Connector.AddReceiveData (aData, aCount);
         exit;
      end;
   end;

   frmMain.AddEvent ('TConnectorList.AddReceiveData failed (' + aSocket.RemoteAddress + ')');
end;

procedure TConnectorList.Update (CurTick : Integer);
var
   i : Integer;
   Connector : TConnector;
begin
   for i := 0 to DataList.Count - 1 do begin
      Connector := DataList.Items [i];
      Connector.Update (CurTick);
   end;
end;

procedure TConnectorList.SetWriteAllow (aSocket : TCustomWinSocket);
var
   i : Integer;
   Connector : TConnector;
begin
   for i := 0 to DataList.Count - 1 do begin
      Connector := DataList.Items [i];
      if Connector.Socket = aSocket then begin
         Connector.SetWriteAllow (true);
         exit;
      end;
   end;
end;

function TConnectorList.AddPacketToGameServer (aID : Integer; aMsg, aRetCode : Byte; aData : PChar; aSize : Integer) : Boolean;
var
   i : Integer;
   Connector : TConnector;
begin
   Result := false;
   for i := 0 to DataList.Count - 1 do begin
      Connector := DataList.Items [i];
      if Connector.ConnectType = ct_gameserver then begin
         Connector.AddSendData (aID, aMsg, aRetCode, aData, aSize);
         Result := true;
         exit;
      end;
   end;
end;

end.

unit uConnector;

interface

uses
   Windows, Classes, SysUtils, ScktComp, uBuffer, deftype, uLGRecordDef, uPackets;

type
   TConnector = class
   private
      Socket : TCustomWinSocket;
      
      GateSender : TPacketSender;
      GateReceiver : TPacketReceiver;
   public
      constructor Create (aSocket : TCustomWinSocket);
      destructor Destroy; override;

      procedure Update (CurTick : Integer);

      PROCEDURE MessageProcess (aPacket : PTPacketData);

      procedure AddReceiveData (aData : PChar; aCount : Integer);
      procedure AddSendData (aID : Integer; aMsg, aRetCode : Byte; aData : PChar; aSize : Integer);

      procedure SetWriteAllow (boFlag : Boolean);
   end;

   TConnectorList = class
   private
      DataList : TList;

      function GetCount : Integer;
   public
      constructor Create;
      destructor Destroy; override;

      procedure Clear;

      procedure Update (CurTick : Integer);

      function CreateConnect (aSocket : TCustomWinSocket) : Boolean;
      function DeleteConnect (aSocket : TCustomWinSocket) : Boolean;

      procedure AddReceiveData (aSocket : TCustomWinSocket; aData : PChar; aCount : Integer);

      procedure SetWriteAllow (aSocket : TCustomWinSocket);

      property Count : Integer read GetCount;
   end;

var
   ConnectorList : TConnectorList;

implementation

uses
   FMain, uDBAdapter;

// TConnector
constructor TConnector.Create (aSocket : TCustomWinSocket);
begin
   Socket := aSocket;
   
   GateSender := TPacketSender.Create ('Gate', 1048576, aSocket);
   GateReceiver := TPacketReceiver.Create ('Gate', 1048576);
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
      frmMain.AddStatus (format ('DataReceived (%d bytes %s)', [aCount, Socket.RemoteAddress]));
   end;
end;

procedure TConnector.AddSendData (aID : Integer; aMsg, aRetCode : Byte; aData : PChar; aSize : Integer);
begin
   if aSize < SizeOf (TPacketData) then begin
      GateSender.PutPacket (aID, aMsg, aRetCode, aData, aSize);
      frmMain.AddStatus (format ('DataSend (%d bytes %s)', [aSize, Socket.RemoteAddress]));
   end;
end;

procedure TConnector.Update (CurTick : Integer);
var
//   i : Integer;
   Packet : TPacketData;
//   buffer : array[0..4096 - 1] of byte;
//   nSend, nSize : Integer;
begin
   GateReceiver.Update;
   while GateReceiver.Count > 0 do begin
      if GateReceiver.GetPacket (@Packet) = false then break;
      MessageProcess (@Packet);
   end;
   GateSender.Update;
end;

PROCEDURE TConnector.MessageProcess (aPacket : PTPacketData);
var
//   Packet : TPacketData;
   RecordData : TLGRecord;
   KeyValue : String;
   nCode : Byte;
begin
   Case aPacket^.RequestMsg of
      LG_INSERT :
         begin
            Move (aPacket^.Data, RecordData.PrimaryKey, SizeOf (TLGRecord));
            KeyValue := StrPas (@RecordData.PrimaryKey);

            if (Pos (';', KeyValue) > 0) or (Pos ('''', KeyValue) > 0) then begin
               nCode := DB_ERR_INVALIDDATA;
               frmMain.AddLog (format ('LG_INSERT failed %s', [KeyValue]));
            end else begin
               nCode := DBAdapter.Insert (KeyValue, @RecordData);
               if nCode = DB_OK then begin
                  frmMain.AddLog (format ('LG_INSERT %s', [KeyValue]));
               end else begin
                  frmMain.AddLog (format ('LG_INSERT failed %s', [KeyValue]));
               end;
            end;
            AddSendData (aPacket^.RequestID, aPacket^.RequestMsg, nCode, @RecordData.PrimaryKey, 0);
         end;
      LG_SELECT :
         begin
            Move (aPacket^.Data, RecordData.PrimaryKey, SizeOf (RecordData.PrimaryKey));
            KeyValue := StrPas (@RecordData.PrimaryKey);

            if (Pos (';', KeyValue) > 0) or (Pos ('''', KeyValue) > 0) then begin
               nCode := DB_ERR_INVALIDDATA;
               frmMain.AddLog (format ('LG_SELECT failed %s', [KeyValue]));
               AddSendData (aPacket^.RequestID, aPacket^.RequestMsg, nCode, @RecordData.PrimaryKey, 0);
            end else begin
               nCode := DBAdapter.Select (KeyValue, @RecordData);
               if nCode = DB_OK then begin
                  frmMain.AddLog (format ('LG_SELECT %s', [KeyValue]));
                  AddSendData (aPacket^.RequestID, aPacket^.RequestMsg, nCode, @RecordData.PrimaryKey, SizeOf (TLGRecord));
               end else begin
                  frmMain.AddLog (format ('LG_SELECT failed %s', [KeyValue]));
                  AddSendData (aPacket^.RequestID, aPacket^.RequestMsg, nCode, @RecordData.PrimaryKey, 0);
               end;
            end;
         end;
      LG_UPDATE :
         begin
            Move (aPacket^.Data, RecordData.PrimaryKey, SizeOf (TLGRecord));
            KeyValue := StrPas (@RecordData.PrimaryKey);

            if (Pos (';', KeyValue) > 0) or (Pos ('''', KeyValue) > 0) then begin
               nCode := DB_ERR_INVALIDDATA;
               frmMain.AddLog (format ('LG_UPDATE failed %s', [KeyValue]));
               AddSendData (aPacket^.RequestID, aPacket^.RequestMsg, nCode, @RecordData.PrimaryKey, 0);
            end else begin
               nCode := DBAdapter.Update (KeyValue, @RecordData);
               if nCode = DB_OK then begin
                  frmMain.AddLog (format ('LG_UPDATE %s', [KeyValue]));
                  AddSendData (aPacket^.RequestID, aPacket^.RequestMsg, nCode, @RecordData.PrimaryKey, SizeOf (TLGRecord));
               end else begin
                  frmMain.AddLog (format ('LG_UPDATE failed %s', [KeyValue]));
                  AddSendData (aPacket^.RequestID, aPacket^.RequestMsg, nCode, @RecordData.PrimaryKey, 0);
               end;
            end;
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
   Result := false;

   Connector := TConnector.Create (aSocket);
   DataList.Add (Connector);

   Result := true;
end;

function TConnectorList.DeleteConnect (aSocket : TCustomWinSocket) : Boolean;
var
   i : Integer;
   Connector : TConnector;
begin
   Result := false;
   for i := 0 to DataList.Count - 1 do begin
      Connector := DataList.Items [i];
      if Connector.Socket = aSocket then begin
         Connector.Free;
         DataList.Delete (i);
         Result := true;
         exit;
      end;
   end;
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

   frmMain.AddLog ('TConnectorList.AddReceiveData failed (' + aSocket.LocalAddress + ')');
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

end.

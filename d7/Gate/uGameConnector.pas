unit uGameConnector;


interface

uses
   Windows, Classes, SysUtils, ScktComp, mmSystem, uPackets;

type
   TGameConnector = class
   private
      UniqueID : Integer;

      FUserCount : Integer;
      
      GameSocket : TClientSocket;
   public
      GameSender : TPacketSender;
      GameReceiver : TPacketReceiver;
   public
      constructor Create (aUniqueID : Integer; aAddress : String; aPort : Integer);
      destructor Destroy; override;

      procedure Connect;
      procedure DisConnect;
      procedure CloseSocket;

      function Connected : Boolean;

      procedure OnConnect(Sender: TObject; Socket: TCustomWinSocket);
      procedure OnDisconnect(Sender: TObject; Socket: TCustomWinSocket);
      procedure OnError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
      procedure OnRead(Sender: TObject; Socket: TCustomWinSocket);
      procedure OnWrite(Sender: TObject; Socket: TCustomWinSocket);

      property UserCount : Integer read FUserCount write FUserCount;
   end;

var
   GameConnectorList : TList;

implementation

uses
   FMain;

// TGameConnector
constructor TGameConnector.Create (aUniqueID : Integer; aAddress : String; aPort : Integer);
begin
   UniqueID := aUniqueID;

   FUserCount := 0;

   GameSocket := TClientSocket.Create (nil);

   GameSocket.OnConnect := OnConnect;
   GameSocket.OnDisConnect := OnDisConnect;
   GameSocket.OnError := OnError;
   GameSocket.OnRead := OnRead;
   GameSocket.OnWrite := OnWrite;

   GameSocket.Address := aAddress;
   GameSocket.Port := aPort;

   GameSender := TPacketSender.Create ('Game' + IntToStr (UniqueID), BufferSizeS2S, GameSocket.Socket);
   GameReceiver := TPacketReceiver.Create ('Game' + IntToStr (UniqueID), BufferSizeS2S);
end;

destructor TGameConnector.Destroy;
begin
   GameSender.Free;
   GameReceiver.Free;
   GameSocket.Free;
   
   inherited Destroy;
end;

procedure TGameConnector.Connect;
begin
   GameSocket.Active := true;
end;

procedure TGameConnector.DisConnect;
begin
   GameSocket.Active := false;
end;

procedure TGameConnector.CloseSocket;
begin
   GameSocket.Socket.Close;
end;

function TGameConnector.Connected : Boolean;
begin
   Result := GameSocket.Active;
end;

procedure TGameConnector.OnConnect(Sender: TObject; Socket: TCustomWinSocket);
begin
   FUserCount := 0;
   frmMain.AddLog (format ('Connected To Game Server %s', [Socket.RemoteAddress]));
end;

procedure TGameConnector.OnDisconnect(Sender: TObject; Socket: TCustomWinSocket);
begin
   if Socket.Connected = true then begin
      FUserCount := 0;
      frmMain.AddLog (format ('Disconnected From Game Server %s', [Socket.RemoteAddress]));
   end;
end;

procedure TGameConnector.OnError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
   if (ErrorCode <> 10061) and (ErrorCode <> 10038)then begin
      frmMain.AddLog (format ('Socket Error At GameServer Connection (%d)', [ErrorCode]));
   end;
   ErrorCode := 0;
end;

procedure TGameConnector.OnRead(Sender: TObject; Socket: TCustomWinSocket);
var
   nRead, nTotalBytes : Integer;
   buffer : array[0..4096 - 1] of byte;
begin
   nTotalBytes := Socket.ReceiveLength;

   while nTotalBytes > 0 do begin
      nRead := nTotalBytes;
      if nRead > 4096 then nRead := 4096;
      nRead := Socket.ReceiveBuf (buffer, nRead);
      if nRead > 0 then begin
         nTotalBytes := nTotalBytes - nRead;
         GameReceiver.PutData (@buffer, nRead);
      end else begin
         break;
      end;
   end;
end;

procedure TGameConnector.OnWrite(Sender: TObject; Socket: TCustomWinSocket);
begin
   GameSender.WriteAllow := true;
end;

end.

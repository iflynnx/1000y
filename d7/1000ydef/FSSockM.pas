unit FSSockM;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ScktComp, WinSock, adeftype, barutil, AnsUnit, AUtil32, StdCtrls, NMUDP;

const
   SERVEREVENT_NONE       = 0;
   SERVEREVENT_CONNECT    = 1;
   SERVEREVENT_DISCONNECT = 2;
   SERVEREVENT_ACCEPT     = 3;

type
   TServerEvent = function  (ConID, EventID: integer; var awstr: WString): Boolean of object;

   TConnect = class
     private
      FConId : integer;
      FAllowClose: Boolean;
      boWriteAllow : Boolean;

      RecieveBuffer: TBufferClass;
      SendBuffer : TBufferClass;
      WouldBlock : array [0..8192] of byte;
      WouldBlockSize: integer;
      cwsocket : TCustomWinSocket;
     public
      constructor Create;
      destructor Destroy; override;
      procedure  Initial (aSocket: TCustomWinSocket);
      procedure  Final;

      function   SendData (cnt: integer; pb: pbyte): integer;
      procedure  RecieveProcess (aSocket: TCustomWinSocket);
      procedure  SendProcess;

      property   ConID : integer read FConId;
      property   AllowClose: Boolean read FAllowClose write FAllowClose;
   end;

   TEventData = record
      ConId : integer;
      EventID : integer;
      bytearr: array [0..64-1] of byte;
   end;
   PTEventData = ^TEventData;

   TErrorData = record
      bytearr: array [0..128-1] of byte;
   end;
   PTErrorData = ^TErrorData;

   TUdpData = record
      ipaddr: array [0..32] of char;
      bytearr: array [0..256-1] of char;
   end;
   PTUdpData = ^TUdpData;

   TFrmSocketM = class(TForm)
      ServerSocket: TServerSocket;
      ListBox1: TListBox;
      BtnSave: TButton;
      BtnClear: TButton;
      LbCount: TLabel;
      procedure FormCreate(Sender: TObject);
      procedure ServerSocketAccept(Sender: TObject; Socket: TCustomWinSocket);
      procedure ServerSocketClientDisconnect(Sender: TObject; Socket: TCustomWinSocket);
      procedure ServerSocketClientError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
      procedure ServerSocketClientRead(Sender: TObject; Socket: TCustomWinSocket);
      procedure ServerSocketClientWrite(Sender: TObject; Socket: TCustomWinSocket);
      procedure FormDestroy(Sender: TObject);
      procedure BtnSaveClick(Sender: TObject);
      procedure BtnClearClick(Sender: TObject);
   private
      DataList : TAnsList;
      FServerEvent : TServerEvent;

      UdpComList : TComDataList;
      ErrorList : TComDataList;
      EventList : TBigComDataList;
      ConIdIndex : TAnsIndexClass;
      ConIdArr : array [0..100000-1] of integer;

      NMUDP0: TNMUDP;

      procedure AddEvent (Conid, EventId: integer; var awstr: WString);
      procedure AddError (str: string);
      function  ListAllocFunction: pointer;
      procedure ListFreeFunction (item: pointer);
      procedure NMUDP0DataReceived(Sender: TComponent; NumberBytes: Integer; FromIP: String; Port : Integer);
      { Private declarations }
   public
      procedure  Update1 (CurTick: integer);
      procedure  ProcessUdp (apu: PTUdpData);
      procedure  AddListBox (str: string);
      function   RecieveData (aConid, cnt: integer; pb: pbyte): integer;
      function   ViewData (aConid, cnt: integer; pb: pbyte): integer;
      function   GetDataSize (aConid: integer): integer;
      function   SendData (aConid, cnt: integer; pb: pbyte): integer;
      function   CloseConnect (aConId: integer): Boolean;
      function   GetIpAddress (aConid: integer; pb: pbyte): Boolean;
      function   AllowSend (aConId: integer): Boolean;
      function   IsConId (aConId: integer): Boolean;
      property   OnServerEvent : TServerEvent read FServerEvent write FServerEvent;
      { Public declarations }
   end;

   procedure DllSSocketSetVisible (aVisible: Boolean);
   function  DllSSocketGetConnections: integer;
   function  DllSSocketUpDate (CurTick: integer): Boolean;
   function  DllSSocketSetPort (aPort: integer): Boolean;
   procedure DllSSocketSetActive (aActive: Boolean);
   procedure DllSSocketSetAllowConnect (aAllowConnect: Boolean);
   procedure DllSSocketSetOnEvent (aServerEvent: TServerEvent);

   function  DllSSocketIsConId (ConId: integer): Boolean;
   function  DllSSocketRecieveData (ConId, cnt: integer; pb: pbyte): integer;
   function  DllSSocketViewData (ConId, cnt: integer; pb: pbyte): integer;
   function  DllSSocketGetDataSize (ConId: integer): integer;
   function  DllSSocketAllowSend (ConId: integer): Boolean;
   function  DllSSocketSendData (ConId, cnt: integer; pb: pbyte): integer;
   function  DllSSocketCloseConnect (ConId: integer): Boolean;
   function  DllSSocketGetIpAddress (ConId: integer; pb: pbyte): Boolean;

   procedure DllSSocketSetMaxUnUsedCount (aCount: Integer);

   procedure DllSUdpSetting (aPort: Integer);

{
   function  DllUdpAlloc (aPort: integer): integer;
   procedure DllUdpFree (aHandle: integer);
   procedure DllUdpAddIp (aHandle: integer; var awip: wstring);

   procedure DllUdpSendData (var wip: wstring; aPort: integer; cnt: integer; pb: pbyte);
   function  DllUdpGetData (aHandle: integer; var awip: wstring; var code: TComData): Boolean;
}
var
  FrmSocketM: TFrmSocketM;

implementation

{$R *.DFM}

var
   boAllowConnect : Boolean = TRUE;
   ProcessCount: integer = 35;
   CurProcess: integer = 0;
   WouldBlockCount: integer = 0;
   ServerSayString : string = '';

   NMUdpForSend : TNMUDP = nil;

   boFormStarted : Boolean = FALSE;

procedure DllUdpSendData (var wip: wstring; aPort: integer; cnt: integer; pb: pbyte);
var
   psd: PTComData;
   buffer : array[0..WSTRINGSIZE-1] of char;
begin
   if NMUdpForSend = nil then exit;
   psd := @Buffer;

   psd^.cnt := cnt;
   move (pb^, psd^.data, cnt);

   NMUdpForSend.ReportLevel := Status_Basic;
   NMUdpForSend.RemoteHost := GetWSString (wip);
   NMUdpForSend.RemotePort := aPort;
   try
      NMUdpForSend.SendBuffer(buffer, cnt+4);
   except
      FrmSocketM.AddError ('Udp Send Except');
   end;
end;

function  DllSSocketGetIpAddress (ConId: integer; pb: pbyte): Boolean;
begin
   Result := FrmSocketM.GetIpAddress (Conid, pb);
end;

procedure DllSSocketSetVisible (aVisible: Boolean);
begin
   FrmSocketM.Visible := aVisible;
end;

function  DllSSocketGetConnections: integer;
begin
   Result := FrmSocketM.ServerSocket.Socket.ActiveConnections;
end;

function  DllSSocketIsConId (ConId: integer): Boolean;
begin
   Result := FrmSocketM.IsConId (Conid);
end;

function  DllSSocketRecieveData (ConId, cnt: integer; pb: pbyte): integer;
begin
   Result := FrmSocketM.RecieveData (Conid, cnt, pb);
end;

function  DllSSocketViewData (ConId, cnt: integer; pb: pbyte): integer;
begin
   Result := FrmSocketM.ViewData (Conid, cnt, pb);
end;

function  DllSSocketGetDataSize (ConId: integer): integer;
begin
   Result := FrmSocketM.GetDataSize (Conid);
end;

function  DllSSocketAllowSend (ConId: integer): Boolean;
begin
   Result := FrmSocketM.AllowSend (Conid);
end;

function  DllSSocketSendData (ConId, cnt: integer; pb: pbyte): integer;
begin
   Result := FrmSocketM.SendData (Conid, cnt, pb);
end;

function  DllSSocketCloseConnect (ConId: integer): Boolean;
begin
   Result := FrmSocketM.CloseConnect (Conid);
end;

function  DllSSocketUpDate (CurTick: integer): Boolean;
begin
   if boFormStarted then FrmSocketM.Update1 (CurTick);
   Result := TRUE;
end;

var
   StartMaxUnUsedCount : integer = -1;
   
   StartPort : integer = -1;
   StartboActive : Boolean = FALSE;
   StartServerEvent : TServerEvent = nil;

   StartUdpPort : integer = 0;

procedure DllSSocketSetMaxUnUsedCount (aCount: Integer);
begin
   if boFormStarted then begin
      FrmSocketM.DataList.MaxUnUsedCount := aCount;
   end else begin
      StartMaxUnUsedCount := aCount;
   end;
end;

procedure DllSUdpSetting (aPort: Integer);
begin
   StartUdpPort := aPort;
end;

function  DllSSocketSetPort (aPort: integer): Boolean;
begin
   if boFormStarted then begin
      Result := FALSE;
      if FrmSocketM.ServerSocket.Active then exit;
      FrmSocketM.ServerSocket.Port := aPort;
      Result := TRUE;
   end else begin
      Result := FALSE;
      if StartboActive then exit;
      StartPort := aPort;
      Result := TRUE;
   end;
end;

procedure DllSSocketSetOnEvent (aServerEvent: TServerEvent);
begin
   if boFormStarted then begin
      FrmSocketM.OnServerEvent := aServerEvent;
   end else begin
      StartServerEvent := aServerEvent;
   end;
end;

procedure DllSSocketSetActive (aActive: Boolean);
begin
   if boFormStarted then begin
      FrmSocketM.ServerSocket.Active := aActive;
   end else begin
      StartboActive := aActive;
   end;
end;

procedure DllSSocketSetAllowConnect (aAllowConnect: Boolean);
begin
   boAllowConnect := aAllowConnect;
end;

//////////////////////////////////
//          Connet
//////////////////////////////////

constructor TConnect.Create;
begin
   boWriteAllow := FALSE;
   FConId    := -1;

   RecieveBuffer := TBufferClass.Create;
   SendBuffer := TBufferClass.Create;
   WouldBlockSize := 0;
end;

destructor  TConnect.Destroy;
begin
   RecieveBuffer.Free;
   SendBuffer.Free;
   inherited destroy;
end;

procedure  TConnect.Initial (aSocket: TCustomWinSocket);
begin
   FAllowClose := FALSE;
   FConId    := aSocket.SocketHandle;

   boWriteAllow := FALSE;
   cwSocket := aSocket;

   RecieveBuffer.Clear;
   SendBuffer.Clear;
   WouldBlockSize := 0;
end;

procedure  TConnect.Final;
begin
   boWriteAllow := FALSE;
   FConId := -1;

   RecieveBuffer.Clear;
   SendBuffer.Clear;
   WouldBlockSize := 0;
end;

procedure   TConnect.RecieveProcess (aSocket: TCustomWinSocket);
var
   cnt : integer;
   buffer : array [0..8192] of byte;
begin
   try
      cnt := cwSocket.ReceiveLength;
      if cnt > 8192 then cnt := 8192;
      cnt := cwSocket.ReceiveBuf (Buffer, cnt);
      if cnt <> SOCKET_ERROR then begin
         Buffer[cnt] := 0;
         RecieveBuffer.Add (cnt, @Buffer);
      end else begin
         FrmSocketM.AddError ('Recieve error');
      end;
   except
      FrmSocketM.AddError ('cwSocket.Recieve Except');
   end;
end;

function    TConnect.SendData (cnt: integer; pb: pbyte): integer;
begin
   if SendBuffer.Add (cnt, pb) then Result := cnt
   else Result := 0;
end;

procedure   TConnect.SendProcess;
   function GetSendData (pb: pbyte): integer;
   begin
      if Wouldblocksize <> 0 then begin
         Result := WouldBlockSize;
         move (Wouldblock, pb^, WouldBlockSize);
         WouldBlocksize :=0;
      end else begin
         Result := SendBuffer.Count;
         if Result = 0 then exit;
         if Result > 8192 then Result := 8192;
         Result := SendBuffer.Get (Result, pb);
      end;
   end;
var
   buf : array [0..8192] of byte;
   n, ret : integer;
begin
   if boWriteAllow = FALSE then exit;
   if AllowClose then exit;

   n := GetSendData (@buf);
   if n = 0 then exit;

   ret := cwSocket.SendBuf (buf, n);
   if ret <> n then begin
      Wouldblocksize := n;
      move (buf, WouldBlock, n);
      boWriteAllow := FALSE;
      FrmSocketM.AddError ('WouldBlock');
   end;
end;

///////////////////////
//
///////////////////////

function  TFrmSocketM.ListAllocFunction: pointer;
begin
   Result := TConnect.Create;
end;

procedure TFrmSocketM.ListFreeFunction (item: pointer);
begin
   TConnect(item).Free;
end;

procedure TFrmSocketM.FormCreate(Sender: TObject);
begin
   ConIdIndex := TAnsIndexClass.Create ('Conid', 4, FALSE);
   FillChar (ConIdArr, sizeof(ConIdArr), 0);

   UdpComList := TComDataList.Create;
   ErrorList := TComDataList.Create;
   EventList := TBigComDataList.Create;
   DataList := TAnsList.Create (5, ListAllocFunction, ListFreeFunction);

   boFormStarted := TRUE;

   if StartPort <> -1 then ServerSocket.Port := StartPort;
   if assigned (StartServerEvent) then OnServerEvent := StartServerEvent;
   if StartboActive then ServerSocket.Active := TRUE;

   if StartMaxUnUsedCount <> -1 then DataList.MaxUnUsedCount := StartMaxUnUsedCount;

   if StartUdpPort <> 0 then begin
      NMUDP0 := TNMUDP.Create (Self);
      NMUDP0.LocalPort := StartUdpPort;
      NMUDP0.RemotePort := StartUdpPort;
      NMUDP0.OnDataReceived := NMUDP0DataReceived;
   end else NMUDP0 := nil;
end;

procedure TFrmSocketM.FormDestroy(Sender: TObject);
begin
   if NMUDP0 <> nil then NMUDP0.Free;

   if ServerSocket.Active then ServerSocket.Active := FALSE;
   boFormStarted := FALSE;

   DataList.Free;
   EventList.Free;
   ErrorList.Free;
   UdpComList.Free;
   ConIdIndex.Free;
end;

procedure TFrmSocketM.ServerSocketAccept(Sender: TObject; Socket: TCustomWinSocket);
var
   n : integer;
   wstr: WString;
   bo : Boolean;
   Connect: TConnect;
begin
   if boAllowConnect = FALSE then begin Socket.Close; exit; end;

   if (Socket.SocketHandle > 0) and (Socket.SocketHandle < 100000) then n := ConIdArr[Socket.SocketHandle]
   else n := ConIdIndex.Select (IntToStr(Socket.SocketHandle));
   if (n <> 0) and (n <> -1) then begin AddError ('Aready Handle:'+IntToStr(Socket.SocketHandle)); Socket.Close; exit;  end;

   SetWSString (wstr, Socket.RemoteAddress);

   bo := TRUE;
   if Assigned (FServerEvent) then bo := FServerEvent (Socket.SocketHandle, SERVEREVENT_ACCEPT, wstr);
   if bo = FALSE then begin Socket.Close; exit; end;        // 立加芭何..

   Connect := DataList.GetUnUsedPointer;
   Connect.Initial (Socket);
   DataList.Add (Connect);

   if (Socket.SocketHandle > 0) and (Socket.SocketHandle < 100000) then ConidArr[Socket.SocketHandle] := Integer (Connect)
   else ConIdIndex.Insert (Integer(Connect), IntToStr(Socket.SocketHandle));

   AddEvent (Connect.ConId, SERVEREVENT_CONNECT, wstr);
end;

procedure TFrmSocketM.ServerSocketClientDisconnect(Sender: TObject; Socket: TCustomWinSocket);
var
   n: integer;
   wstr: WString;
begin
   if (Socket.SocketHandle > 0) and (Socket.SocketHandle < 100000) then n := ConIdArr[Socket.SocketHandle]
   else n := ConIdIndex.Select (IntToStr(Socket.SocketHandle));
   if (n = 0) or (n = -1) then begin AddError ('NotFound Handle: disconnect:'+IntToStr(Socket.SocketHandle)); exit; end;
   TConnect(n).AllowClose := TRUE;
   SetWSString (wstr, Socket.RemoteAddress);
   AddEvent (TConnect(n).ConId, SERVEREVENT_DISCONNECT, wstr);
end;

procedure TFrmSocketM.ServerSocketClientError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
   ErrorCode := 0;
   Socket.Close;
end;

procedure TFrmSocketM.ServerSocketClientRead(Sender: TObject; Socket: TCustomWinSocket);
var n: integer;
begin
   if (Socket.SocketHandle > 0) and (Socket.SocketHandle < 100000) then n := ConIdArr[Socket.SocketHandle]
   else n := ConIdIndex.Select (IntToStr(Socket.SocketHandle));
   if (n = 0) or (n = -1) then begin AddError ('NotFound Handle: Read:'+IntToStr(Socket.SocketHandle)); exit; end;
   TConnect(n).RecieveProcess (Socket);
end;

procedure TFrmSocketM.ServerSocketClientWrite(Sender: TObject; Socket: TCustomWinSocket);
var n: integer;
begin
   if (Socket.SocketHandle > 0) and (Socket.SocketHandle < 100000) then n := ConIdArr[Socket.SocketHandle]
   else n := ConIdIndex.Select (IntToStr(Socket.SocketHandle));
   if (n = 0) or (n = -1) then begin AddError ('NotFound Handle:Write:'+IntToStr(Socket.SocketHandle)); exit; end;
   TConnect(n).boWriteAllow := TRUE;
end;

function   TFrmSocketM.RecieveData (aConid, cnt: integer; pb: pbyte): integer;
var n: integer;
begin
   Result := 0;
   if (aConid > 0) and (aConid < 100000) then n := ConIdArr[aConId]
   else n := ConIdIndex.Select (IntToStr(aConId));
   if (n = 0) or (n = -1) then begin AddError ('NotFound Conid: RecieveData:'+IntToStr(aConid)); exit; end;
   Result := TConnect(n).RecieveBuffer.Get (cnt, pb);
end;

function   TFrmSocketM.ViewData (aConid, cnt: integer; pb: pbyte): integer;
var n: integer;
begin
   Result := 0;
   if (aConid > 0) and (aConid < 100000) then n := ConIdArr[aConId]
   else n := ConIdIndex.Select (IntToStr(aConId));
   if (n = 0) or (n = -1) then begin AddError ('NotFound Conid: ViewData:'+IntToStr(aConid)); exit; end;
   Result := TConnect(n).RecieveBuffer.View (cnt, pb);
end;

function   TFrmSocketM.GetDataSize (aConid: integer): integer;
var n: integer;
begin
   Result := 0;
   if (aConid > 0) and (aConid < 100000) then n := ConIdArr[aConId]
   else n := ConIdIndex.Select (IntToStr(aConId));
   if (n = 0) or (n = -1) then begin AddError ('NotFound Conid: GetDatasize:'+IntToStr(aConid)); exit; end;
   Result := TConnect(n).RecieveBuffer.Count;
end;

function   TFrmSocketM.IsConId (aConId: integer): Boolean;
var n: integer;
begin
   Result := FALSE;
   if (aConid > 0) and (aConid < 100000) then n := ConIdArr[aConId]
   else n := ConIdIndex.Select (IntToStr(aConId));
   if (n = 0) or (n = -1) then begin
      exit;
   end;
   Result := TRUE;
end;

function   TFrmSocketM.AllowSend (aConId: integer): Boolean;
var n: integer;
begin
   Result := FALSE;
   if (aConid > 0) and (aConid < 100000) then n := ConIdArr[aConId]
   else n := ConIdIndex.Select (IntToStr(aConId));
   if (n = 0) or (n = -1) then begin AddError ('NotFound Conid: AllowSend:'+IntToStr(aConid)); exit; end;
   Result := TConnect(n).boWriteAllow;
end;

function   TFrmSocketM.SendData (aConid, cnt: integer; pb: pbyte): integer;
var n: integer;
begin
   Result := 0;
   if (aConid > 0) and (aConid < 100000) then n := ConIdArr[aConId]
   else n := ConIdIndex.Select (IntToStr(aConId));
   if (n = 0) or (n = -1) then begin AddError ('NotFound Conid: SendData:'+IntToStr(aConid)); exit; end;
   Result := TConnect(n).SendData (cnt, pb);
end;

function   TFrmSocketM.GetIpAddress (aConid: integer; pb: pbyte): Boolean;
var
   n: integer;
begin
   pb^ := 0;
   Result := FALSE;
   if (aConid > 0) and (aConid < 100000) then n := ConIdArr[aConId]
   else n := ConIdIndex.Select (IntToStr(aConId));
   if (n = 0) or (n = -1) then begin AddError ('NotFound Conid: GetIpAddress:'+IntToStr(aConid)); exit; end;
   if TConnect(n).AllowClose then exit;
   if TConnect(n).cwSocket <> nil then begin
      StrPCopy (pchar (pb), TConnect(n).cwSocket.RemoteAddress);
      Result := TRUE
   end;
end;

function   TFrmSocketM.CloseConnect (aConId: integer): Boolean;
var
   n: integer;
begin
   Result := FALSE;
   if (aConid > 0) and (aConid < 100000) then n := ConIdArr[aConId]
   else n := ConIdIndex.Select (IntToStr(aConId));
   if (n = 0) or (n = -1) then begin
      AddError ('NotFound Conid: CloseConnect:' + IntToStr(aconid));
      exit;
   end;
   if not TConnect(n).AllowClose then TConnect(n).cwSocket.Close;
   Result := TRUE
end;

procedure TFrmSocketM.AddEvent (Conid, EventId: integer; var awstr: WString);
var ed : TEventData;
begin
   ed.ConId := Conid;
   ed.EventID := EventId;
   GetWSpChar (awstr, @ed.bytearr);
   EventList.AddComData (sizeof(ed), @ed);
end;

procedure  TFrmSocketM.AddError (str: string);
var er : TErrorData;
begin
   StrPCopy (@er.bytearr, str);
   ErrorList.AddComData (sizeof(er), @er);
end;

procedure  TFrmSocketM.AddListBox (str: string);
begin
   if Listbox1.Items.Count >= 10000 then ListBox1.items.delete (0);
   if str = 'WouldBlock' then inc (WouldBlockCount)
   else ListBox1.items.Add (str);
   listbox1.ItemIndex := listbox1.items.count -1;

   FrmSocketM.LbCount.Caption := 'WouldBlock : ' + inttostr (WouldBlockCount);    // 傈价 角菩
end;

procedure TFrmSocketM.BtnSaveClick(Sender: TObject);
begin
   ListBox1.Items.SaveToFile ('DllError.txt');
end;

procedure TFrmSocketM.BtnClearClick(Sender: TObject);
var
   str: string;
begin
   WouldBlockCount := 0;
   ListBox1.Items.Clear;
   str := format ('Clear: %s %s',[DateToStr(Date), TimeToStr(Time)]);
   AddError (str);
end;

procedure TFrmSocketM.NMUDP0DataReceived(Sender: TComponent; NumberBytes: Integer; FromIP: String; Port : Integer);
var
   n : integer;
   ud : TUdpData;
begin
   StrPCopy (ud.ipaddr, FromIp);
   byte (ud.ipaddr[Length(FromIp)]) := 0;

   if NumberBytes < 255 then begin
      NMUDP0.ReadBuffer(ud.bytearr,NumberBytes);
      byte (ud.bytearr[NumberBytes]) := 0;
      UdpComList.AddComData (sizeof(ud), @ud);
   end else begin
      while TRUE do begin
         n := 255;
         if NumberBytes > 255 then begin
            NMUDP0.ReadBuffer(ud.bytearr,n);
            NumberBytes := NumberBytes - n;
         end else begin
            NMUDP0.ReadBuffer(ud.bytearr,NumberBytes);
            break;
         end;
      end;
   end;
end;

procedure  TFrmSocketM.ProcessUdp (apu: PTUdpData);
var
   cmdstr: string;
   Buffer : array [0..256-1] of char;
begin
   cmdstr := StrPas (apu^.bytearr);

   if cmdstr = 'GETCONNECTCOUNT' then begin
      NMUDP0.ReportLevel := Status_Basic;
      NMUDP0.RemoteHost := StrPas (@apu^.ipaddr);
      StrPCopy (Buffer, 'CONNECTCOUNT:'+IntToStr(DataList.Count));
      try
         NMUDP0.SendBuffer(Buffer, StrLen (Buffer));
      finally
      end;
   end;

   if cmdstr = 'GETSERVERSAY' then begin
      NMUDP0.ReportLevel := Status_Basic;
      NMUDP0.RemoteHost := StrPas (@apu^.ipaddr);;
      if Length(ServerSayString) < 200 then StrPCopy (Buffer, 'SERVERSAY:'+ServerSayString)
      else StrPCopy (Buffer, 'SERVERSAY:');
      try
         NMUDP0.SendBuffer(Buffer, StrLen (Buffer));
      finally
      end;
   end;
end;

procedure  TFrmSocketM.Update1 (CurTick: integer);
var
   i : integer;
   sd: TComData;
   Connect : TConnect;
   pe : PTEventData;
   pr : PTErrorData;
   pu : PTUdpData;
   wstr: WString;
begin
   while TRUE do begin
      if not UdpComList.GetComData (sd) then break;
      pu := @sd.data;
      ProcessUdp (pu);
   end;

   while TRUE do begin
      if not EventList.GetComData (sd) then break;
      pe := @sd.data;
      if Assigned (FServerEvent) then begin
         SetWSpChar (wstr, @pe^.bytearr);
         FServerEvent (pe^.Conid, pe^.EventId, wstr);
      end;
   end;

   while TRUE do begin
      if not ErrorList.GetComData (sd) then break;
      pr := @sd.data;
      AddListBox (StrPas (@pr^.bytearr));
   end;


   for i := 0 to ProcessCount -1 do begin
      if CurProcess >= DataList.Count then CurProcess := 0;
      if DataList.Count = 0 then break;
      Connect := DataList[CurProcess];
      if Connect.AllowClose then begin
         if (Connect.Conid > 0) and (Connect.Conid < 100000) then ConIdArr[Connect.Conid] := 0
         else ConIdIndex.Delete (IntToStr(Connect.Conid));
         Connect.Final;
         DataList.Delete (CurProcess);
      end else begin
         Connect.SendProcess;
         inc (CurProcess);
      end;
   end;
end;

{
const
   udpmaxsize = 16384;
type
   TUdpClassData = record
      rip : string[32];
      rwip : wstring;
      rReceiveBuffer : TBigBufferClass;
   end;
   PTUdpClassData = ^TUdpClassData;

   TUdpClass = class
     private
      Udp : TNMUDP;
      IpList : TList;
      procedure UDPDataReceived(Sender: TComponent; NumberBytes: Integer; FromIP: String);
     public
      constructor Create (aPort: integer);
      destructor Destroy; override;
      procedure  AddIp (var awip: wstring);
      function   GetData (var awip : wstring; var code: TComData): Boolean;
   end;

var
   UdpClassList : TList;

//////////////////////////////
//    UdpClass
//////////////////////////////
constructor TUdpClass.Create(aPort: integer);
begin
   IpList := TList.Create;
   Udp := TNMUdp.Create (Application);
   Udp.LocalPort := aPort;
   Udp.OnDataReceived := UDPDataReceived;
end;

destructor TUdpClass.Destroy;
begin
//   Udp.Free;
   IpList.Free;
   inherited destroy;
end;

procedure TUdpClass.UDPDataReceived(Sender: TComponent; NumberBytes: Integer; FromIP: String);
var
   i : integer;
   buffer : array [0..udpmaxsize-1] of char;
begin
   try
      if NumberBytes > udpmaxsize-1 then NumberBytes := udpmaxsize-1;
      Udp.ReadBuffer(buffer,NumberBytes);
      for i := 0 to IpList.Count -1 do begin
         if PTUdpClassData (IpList[i])^.rip = FromIp then begin
            PTUdpClassData (IpList[i])^.rReceiveBuffer.Add (NumberBytes, @Buffer);
            break;
         end;
      end;
   except
      FrmSocketM.AddError ('Udp Recieve Except');
   end;
end;

procedure TUdpClass.AddIp (var awip : wstring);
var ucd : PTUdpClassData;
begin
   new (ucd);
   ucd^.rip := GetWSString (awip);
   MoveWs (awip, ucd^.rwip);
   ucd^.rReceiveBuffer := TBigBufferClass.Create;
   IpList.Add (ucd);
end;

function  TUdpClass.GetData (var awip : wstring; var code: TComData): Boolean;
var
   i, cnt : integer;
   pu : PTUdpClassData;
begin
   Result := FALSE;

   for i := 0 to IpList.Count -1 do begin
      pu := IpList[i];
      if CompareWs (pu^.rwip, awip) = 0 then begin
         if pu^.rReceiveBuffer.Count < 4 then break;
         pu^.rReceiveBuffer.View (4, @cnt);
         if pu^.rReceiveBuffer.Count < cnt + 4 then break;
         code.cnt := cnt;
         pu^.rReceiveBuffer.Get (code.cnt + 4, @code);
         Result := TRUE;
         exit;
      end;
   end;
end;

//////////////////////////////
//    Udp procedure
//////////////////////////////
function  GetUdpClassByHandle (aHandle: integer): TUdpClass;
var i: integer;
begin
   Result := nil;
   for i := 0 to UdpClassList.Count -1 do begin
      if aHandle = Integer (UdpClassList[i]) then begin
         Result := UdpClassList[i];
         exit;
      end;
   end;
end;

procedure DllUdpFree (aHandle: integer);
var i : integer;
begin
   for i := 0 to UdpClassList.Count -1 do begin
      if aHandle = Integer (UdpClassList[i]) then begin
         TUdpClass (UdpClassList[i]).free;
         UdpClassList.Delete (i);
         exit;
      end;
   end;
end;

function  DllUdpAlloc (aPort: integer): integer;
var uc: TUdpClass;
begin
   uc := TUdpClass.Create (aPort);
   UdpClassList.Add (uc);
   Result := Integer (uc);
end;

procedure DllUdpAddIp (aHandle: integer; var awip: wstring);
var uc: TUdpClass;
begin
   uc := GetUdpClassByHandle (aHandle);
   if uc = nil then exit;
   uc.AddIp (awip);
end;

function  DllUdpGetData (aHandle: integer; var awip: wstring; var code: TComData): Boolean;
var i: integer;
begin
   Result := FALSE;
   for i := 0 to UdpClassList.Count -1 do begin
      if aHandle = Integer (UdpClassList[i]) then begin
         Result := TUdpClass (UdpClassList[i]).GetData (awip, code);
         exit;
      end;
   end;
end;

procedure UdpListClear;
var i : integer;
begin
   for i := 0 to UdpClassList.Count -1 do TUdpClass (UdpClassList[i]).Free;
   UdpClassList.Clear;
end;

initialization
begin
   UdpClassList := TList.Create;
   NMUdpForSend := TNMUDP.Create (Application);
end;

finalization
begin
//   NMUdpForSend.Free;
//   UdpListClear;
   UdpClassList.Free;
end;
}
end.

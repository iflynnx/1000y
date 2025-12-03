unit FSUdpM;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ScktComp, WinSock, adeftype, barutil, AnsUnit, AUtil32, StdCtrls, NMUDP, ExtCtrls;

const
   udpmaxsize = 8192;

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
      procedure   UDPDataReceived(Sender: TComponent; NumberBytes: Integer; FromIP: String; FromPort : Integer);
     public
      constructor Create (aPort: integer);
      destructor  Destroy; override;
      procedure   AddIp (var awip: wstring);
      function    GetData (var awip : wstring; var code: TComData): Boolean;
   end;

   TFrmUdpM = class(TForm)
      NMUDPForSend: TNMUDP;
      TimerProcess: TTimer;
      procedure FormCreate(Sender: TObject);
      procedure FormDestroy(Sender: TObject);
      procedure TimerProcessTimer(Sender: TObject);
   private
      UdpClassList : TList;
      UdpDataList : TBigComDataList;
   public
      procedure UdpSendData (var wip: wstring; aPort: integer; cnt: integer; pb: pbyte);

   end;

   function  DllUdpAlloc (aPort: integer): integer;
   procedure DllUdpFree (aHandle: integer);
   procedure DllUdpAddIp (aHandle: integer; var awip: wstring);

   procedure DllUdpSendData (var wip: wstring; aPort: integer; cnt: integer; pb: pbyte);
   function  DllUdpGetData (aHandle: integer; var awip: wstring; var code: TComData): Boolean;

var
  FrmUdpM: TFrmUdpM;

implementation

{$R *.DFM}

//////////////////////////////
//    Udp procedure
//////////////////////////////
function  GetUdpClassByHandle (aHandle: integer): TUdpClass;
var i: integer;
begin
   Result := nil;
   for i := 0 to FrmUdpM.UdpClassList.Count -1 do begin
      if aHandle = Integer (FrmUdpM.UdpClassList[i]) then begin
         Result := FrmUdpM.UdpClassList[i];
         exit;
      end;
   end;
end;

procedure DllUdpFree (aHandle: integer);
var i : integer;
begin
   for i := 0 to FrmUdpM.UdpClassList.Count -1 do begin
      if aHandle = Integer (FrmUdpM.UdpClassList[i]) then begin
         TUdpClass (FrmUdpM.UdpClassList[i]).free;
         FrmUdpM.UdpClassList.Delete (i);
         exit;
      end;
   end;
end;

function  DllUdpAlloc (aPort: integer): integer;
var uc: TUdpClass;
begin
   uc := TUdpClass.Create (aPort);
   FrmUdpM.UdpClassList.Add (uc);
   Result := Integer (uc);
end;

procedure DllUdpAddIp (aHandle: integer; var awip: wstring);
var uc: TUdpClass;
begin
   uc := GetUdpClassByHandle (aHandle);
   if uc = nil then exit;
   uc.AddIp (awip);
end;

procedure DllUdpSendData (var wip: wstring; aPort: integer; cnt: integer; pb: pbyte);
begin
   FrmUdpM.UdpSendData (wip, aPort, cnt, pb);
end;

function  DllUdpGetData (aHandle: integer; var awip: wstring; var code: TComData): Boolean;
var i: integer;
begin
   Result := FALSE;
   for i := 0 to FrmUdpM.UdpClassList.Count -1 do begin
      if aHandle = Integer (FrmUdpM.UdpClassList[i]) then begin
         Result := TUdpClass (FrmUdpM.UdpClassList[i]).GetData (awip, code);
         exit;
      end;
   end;
end;


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
   Udp.Free;
   IpList.Free;
   inherited destroy;
end;

procedure TUdpClass.UDPDataReceived(Sender: TComponent; NumberBytes: Integer; FromIP: String; FromPort : Integer);
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

type
   TUdpData = record
     rip : string [32];
     rport : integer;
     cnt: integer;
     buffer: Array [0..8192] of byte;
   end;
   PTUdpData = ^TUdpData;

procedure TFrmUdpM.UdpSendData (var wip: wstring; aPort: integer; cnt: integer; pb: pbyte);
var
   n : integer;
   ud : TUdpData;
begin
   ud.rip := GetWSString (wip);
   ud.rport := aPort;
   ud.cnt := cnt;
   move (pb^, ud.buffer, cnt);

   n := sizeof(ud) - sizeof(ud.buffer) + ud.cnt;
   UdpDataList.AddComData (n, @ud);
end;

procedure TFrmUdpM.FormCreate(Sender: TObject);
begin
   UdpClassList := TList.Create;
   UdpDataList := TBigComDataList.Create;
end;

procedure TFrmUdpM.FormDestroy(Sender: TObject);
begin
   UdpDataList.Free;
//   for i := 0 to UdpClassList.Count -1 do TUdpClass (UdpClassList[i]).Free;
   UdpClassList.Free;
end;

procedure TFrmUdpM.TimerProcessTimer(Sender: TObject);
var
   pud : PTUdpData;
   sd : TComdata;
   psd: PTComData;
   buffer : array[0..WSTRINGSIZE-1] of char;
begin
   if UdpDataList.GetComData (sd) then begin
      pud := @sd.data;

      psd := @Buffer;

      psd^.cnt := pud^.cnt;
      move (pud^.buffer, psd^.data, pud^.cnt);

      FrmUdpM.NMUdpForSend.ReportLevel := Status_Basic;
      FrmUdpM.NMUdpForSend.RemoteHost := pud^.rip;
      FrmUdpM.NMUdpForSend.RemotePort := pud^.rPort;
      try
         FrmUdpM.NMUdpForSend.SendBuffer(buffer, pud^.cnt+4);
      except
      end;
   end;
end;

end.

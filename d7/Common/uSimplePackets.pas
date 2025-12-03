unit uSimplePackets;

interface

uses
   SysUtils, Classes, ScktComp, mmSystem, uBuffer, aDefType;

const
   PACKET_START      =  42;
   PACKET_END        =  13;

   MAX_PACKET_SIZE   = 4096;

type
   TSimplePacketSender = class
   private
      Name : String;
      Socket : TCustomWinSocket;

      SendBuffer : TBuffer;
      boWriteAllow : Boolean;

      FWouldBlockCount : Integer;

      FSendTick : Integer;
      FSendBytes : Integer;
      FSendBytesPerSec : Integer;

      boBufferFullLog : Boolean;

      function isDataRemained : Boolean;
      procedure SetWriteAllow (boFlag : Boolean);
   public
      constructor Create (aName : String; aSize : Integer; aSocket : TCustomWinSocket);
      destructor Destroy; override;

      procedure Clear;

      procedure Update;

      function PutPacket (aData : PChar; aSize : Integer) : Boolean;

      procedure WriteLog (aStr : String);

      property WriteAllow : Boolean read boWriteAllow write SetWriteAllow;
      property SendBytesPerSec : Integer read FSendBytesPerSec;
      property WouldBlockCount : Integer read FWouldBlockCount;
      property DataRemained : Boolean read isDataRemained;
   end;

   TSimplePacketReceiver = class
   private
      Name : String;

      FReceiveBytes : Integer;
      FReceiveBytesPerSec : Integer;
      FReceiveTick : Integer;

      ReceiveBuffer : TBuffer;

      PacketBuffer : TPacketBuffer;

      boBufferFullLog : Boolean;

      function GetCount : Integer;
   public
      constructor Create (aName : String; aBufferSize : Integer);
      destructor Destroy; override;

      procedure Clear;

      procedure Update;

      function PutData (aData : PChar; aSize : Integer) : Boolean;
      function GetPacket (var aComData : TComData) : Boolean;

      procedure WriteLog (aStr : String);

      property Count : Integer read GetCount;
      property ReceiveBytesPerSec : Integer read FReceiveBytesPerSec;
   end;

implementation

uses
   uCrypt;

// TSimplePacketSender
constructor TSimplePacketSender.Create (aName : String; aSize : Integer; aSocket : TCustomWinSocket);
var
   Size : Integer;
begin
   Name := aName;

   FSendBytes := 0;
   FSendBytesPerSec := 0;
   FSendTick := 0;

   FWouldBlockCount := 0;

   Socket := aSocket;

   boWriteAllow := false;

   Size := aSize;
   if Size <= 0 then Size := 16384;
   SendBuffer := TBuffer.Create (Size);

   boBufferFullLog := false;
end;

destructor TSimplePacketSender.Destroy;
begin
   SendBuffer.Free;
   inherited Destroy;
end;

procedure TSimplePacketSender.Clear;
begin
   SendBuffer.Clear;
end;

function TSimplePacketSender.isDataRemained : Boolean;
begin
   Result := false;
   if SendBuffer.Count > 0 then Result := true;
end;

procedure TSimplePacketSender.SetWriteAllow (boFlag : Boolean);
begin
   boWriteAllow := boFlag;
end;

procedure TSimplePacketSender.Update;
var
   CurTick : Integer;
   nSendSize, nSize, nWrite : Integer;
   buffer : array [0..8192 - 1] of Byte;
begin
   CurTick := timeGetTime;

   if (boWriteAllow = true) and (SendBuffer.Count > 0) then begin
      nSize := SendBuffer.Count;
      // while nSize > 0 do begin
         nSendSize := nSize;
         if nSendSize > 8192 then nSendSize := 8192;
         if SendBuffer.View (@buffer, nSendSize) = false then exit;

         nWrite := Socket.SendBuf (buffer, nSendSize);
         if nWrite < 0 then nWrite := 0;

         if nWrite > 0 then begin
            SendBuffer.Flush (nWrite);
            FSendBytes := FSendBytes + nWrite;
         end;

         if nWrite < nSendSize then begin
            FWouldBlockCount := FWouldBlockCount + 1;
            boWriteAllow := false;
            // break;
         end;
         nSize := nSize - nWrite;
      // end;
   end;

   if CurTick >= FSendTick + 1000 then begin
      FSendBytesPerSec := FSendBytes div 1024;
      FSendBytes := 0;
      FSendTick := CurTick;
   end;
end;

function TSimplePacketSender.PutPacket (aData : PChar; aSize : Integer) : Boolean;
var
   nSize : Word;
   ComData : TComData;
   buffer : array [0..8192 - 1] of Byte;
begin
   Result := false;

   if (aSize < 0) or (aSize > MAX_PACKET_SIZE) then exit;

   ComData.Cnt := aSize;
   if aSize > 0 then begin
      Move (aData^, ComData.Data, aSize);
   end;

   buffer[0] := PACKET_START;
   nSize := EnCryption (@ComData.Data, @buffer[1], ComData.Cnt);
   buffer[nSize + 1] := PACKET_END;
   buffer[nSize + 2] := 0;

   if SendBuffer.Put (@buffer, nSize + 2) = true then begin
      Result := true;
      exit;
   end;

   WriteLog (format ('%sSendBuffer.Put failed BufferSize=%d, InputSize=%d', [Name, SendBuffer.Count, nSize + 2]));
end;

procedure TSimplePacketSender.WriteLog (aStr : String);
var
   Stream : TFileStream;
   FileName : String;
   buffer : array[0..4096 - 1] of byte;
begin
   try
      FileName := '.\Log\' + Name + 'Sender.Log';
      if FileExists (FileName) then begin
         Stream := TFileStream.Create (FileName, fmOpenReadWrite);
      end else begin
         Stream := TFileStream.Create (FileName, fmCreate);
      end;
      StrPCopy (@buffer, '[' + DateToStr (Date) + ' ' + TimeToStr (Time) + ']' + aStr + #13 + #10);
      Stream.Seek (0, soFromEnd);
      Stream.WriteBuffer (buffer, StrLen (@buffer));
      Stream.Free;
   except
   end;
end;

// TSimplePacketReceiver
constructor TSimplePacketReceiver.Create (aName : String; aBufferSize : Integer);
var
   Size : Integer;
begin
   Name := aName;

   FReceiveBytes := 0;
   FReceiveBytesPerSec := 0;
   FReceiveTick := 0;

   Size := aBufferSize;
   if Size <= 0 then Size := 16384;
   ReceiveBuffer := TBuffer.Create (Size);
   PacketBuffer := TPacketBuffer.Create (Size);

   boBufferFullLog := false;
end;

destructor TSimplePacketReceiver.Destroy;
begin
   Clear;
   PacketBuffer.Free;
   ReceiveBuffer.Free;

   inherited Destroy;
end;

procedure TSimplePacketReceiver.Clear;
begin
   PacketBuffer.Clear;
   ReceiveBuffer.Clear;
end;

function TSimplePacketReceiver.GetCount : Integer;
begin
   Result := PacketBuffer.Count;
end;

procedure TSimplePacketReceiver.Update;
var
   i, iBase, iPos, iStartPos, iEndPos, nSize : Integer;
   CurTick : Integer;
   buffer : array [0..8192 - 1] of Byte;
   ComData : TComData;
begin
   CurTick := timeGetTime;
   
   while ReceiveBuffer.Count > 0 do begin
      nSize := ReceiveBuffer.Count;
      if nSize > 8192 then nSize := 8192;

      if ReceiveBuffer.View (@buffer, nSize) = true then begin
         iPos := 0;
         while iPos < nSize do begin
            iStartPos := -1;
            iBase := iPos;
            for i := iBase to nSize - 1 do begin
               Inc (iPos);
               if buffer[i] = PACKET_START then begin
                  iStartPos := i + 1;
                  break;
               end;
            end;
            if iStartPos = -1 then begin
               // WriteLog ('Wrong Packet : StartCode not found');
               ReceiveBuffer.Flush (iPos);
               exit;
            end;

            iEndPos := -1;
            iBase := iPos;
            for i := iBase to nSize - 1 do begin
               Inc (iPos);
               if buffer[i] = PACKET_START then begin
                  // WriteLog ('Wrong Packet : PACKET_START Detected');
                  Dec (iPos);
                  ReceiveBuffer.Flush (iPos);
                  exit;
               end else if buffer[i] = PACKET_END then begin
                  iEndPos := i - 1;
                  break;
               end;
            end;
            if iEndPos = -1 then begin
               iPos := iBase - 1;
               if iPos = 0 then exit;
               break;
            end;

            if iEndPos - iStartPos + 1 > 0 then begin
               ComData.Cnt := DeCryption (@buffer[iStartPos], @ComData.Data, iEndPos - iStartPos + 1);
               if (ComData.Cnt >= 0) and (ComData.Cnt <= SizeOf (TComData)) then begin
                  PacketBuffer.Put (@ComData.Data, ComData.Cnt);
               end;
            end;
         end;
         ReceiveBuffer.Flush (iPos);
      end else begin
         break;
      end;
   end;

   if CurTick >= FReceiveTick + 1000 then begin
      FReceiveBytesPerSec := FReceiveBytes div 1024;
      FReceiveBytes := 0;
      FReceiveTick := CurTick;
   end;
end;

function TSimplePacketReceiver.PutData (aData : PChar; aSize : Integer) : Boolean;
begin
   Result := false;

   FReceiveBytes := FReceiveBytes + aSize;

   if aSize <= 0 then exit;

   if ReceiveBuffer.Put (aData, aSize) = true then begin
      Result := true;
      exit;
   end;

   WriteLog (format ('%sReceiveBuffer.Put failed BufferSize=%d, InputSize=%d', [Name, ReceiveBuffer.Count, aSize]));
end;

function TSimplePacketReceiver.GetPacket (var aComData : TComData) : Boolean;
begin
   Result := PacketBuffer.Get (@aComData.Data);
end;

procedure TSimplePacketReceiver.WriteLog (aStr : String);
var
   Stream : TFileStream;
   FileName : String;
   buffer : array[0..4096 - 1] of byte;
begin
   try
      FileName := '.\Log\' + Name + 'Receiver.Log';
      if FileExists (FileName) then begin
         Stream := TFileStream.Create (FileName, fmOpenReadWrite);
      end else begin
         Stream := TFileStream.Create (FileName, fmCreate);
      end;
      StrPCopy (@buffer, '[' + DateToStr (Date) + ' ' + TimeToStr (Time) + ']' + aStr + #13 + #10);
      Stream.Seek (0, soFromEnd);
      Stream.WriteBuffer (buffer, StrLen (@buffer));
      Stream.Free;
   except
   end;
end;

end.

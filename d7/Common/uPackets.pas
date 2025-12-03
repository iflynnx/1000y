unit uPackets;

interface

uses
   SysUtils, Classes, ScktComp, mmSystem, uBuffer;

const
   MAX_PACKET_SIZE      = 4096;

   PACKET_START         =  $28;
   PACKET_END           =  $29;

type

   TPacketData = record
      PacketSize : Word;
      RequestID : Integer;
      RequestMsg : Byte;
      ResultCode : Byte;
      Data : array[0..MAX_PACKET_SIZE - 1] of byte;
   end;
   PTPacketData = ^TPacketData;

   TPacketSender = class
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

      function PutPacket (aID : Integer; aMsg, aRetCode : Byte; aData : PChar; aSize : Integer) : Boolean;

      procedure WriteLog (aStr : String);

      property WriteAllow : Boolean read boWriteAllow write SetWriteAllow;
      property SendBytesPerSec : Integer read FSendBytesPerSec;
      property WouldBlockCount : Integer read FWouldBlockCount;
      property DataRemained : Boolean read isDataRemained;
   end;

   TPacketReceiver = class
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
      function GetPacket (aPacket : PTPacketData) : Boolean;

      procedure WriteLog (aStr : String);

      property Count : Integer read GetCount;
      property ReceiveBytesPerSec : Integer read FReceiveBytesPerSec;
   end;

implementation

uses
   uCrypt;

// TPacketSender
constructor TPacketSender.Create (aName : String; aSize : Integer; aSocket : TCustomWinSocket);
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

destructor TPacketSender.Destroy;
begin
   SendBuffer.Free;
   inherited Destroy;
end;

procedure TPacketSender.Clear;
begin
   SendBuffer.Clear;
end;

function TPacketSender.isDataRemained : Boolean;
begin
   Result := false;
   if SendBuffer.Count > 0 then Result := true;
end;

procedure TPacketSender.SetWriteAllow (boFlag : Boolean);
begin
   boWriteAllow := boFlag;
end;

procedure TPacketSender.Update;
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

function TPacketSender.PutPacket (aID : Integer; aMsg, aRetCode : Byte; aData : PChar; aSize : Integer) : Boolean;
var
   nSize : Word;
   Packet : TPacketData;
   buffer : array [0..8192 - 1] of Byte;
begin
   Result := false;

   if (aSize < 0) or (aSize > MAX_PACKET_SIZE) then exit;

   Packet.PacketSize := SizeOf (Word) + SizeOf (Integer) + SizeOf (Byte) * 2 + aSize;
   Packet.RequestID := aID;
   Packet.RequestMsg := aMsg;
   Packet.ResultCode := aRetCode;
   if aSize > 0 then begin
      Move (aData^, Packet.Data, aSize);
   end;

   {
   if SendBuffer.Put (@Packet, Packet.PacketSize) = false then begin
      WriteLog (format ('%sSendBuffer.Put failed BufferSize=%d, InputSize=%d', [Name, SendBuffer.Count, Packet.PacketSize]));
   end;
   }
   buffer[0] := PACKET_START;
   nSize := EnCryption (@Packet, @buffer[1], Packet.PacketSize);
   buffer[nSize + 1] := PACKET_END;
   buffer[nSize + 2] := 0;

   if SendBuffer.Put (@buffer, nSize + 2) = true then begin
      Result := true;
      exit;
   end;

   WriteLog (format ('%sSendBuffer.Put failed BufferSize=%d, InputSize=%d', [Name, SendBuffer.Count, nSize + 2]));
end;

procedure TPacketSender.WriteLog (aStr : String);
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

// TPacketReceiver
constructor TPacketReceiver.Create (aName : String; aBufferSize : Integer);
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

destructor TPacketReceiver.Destroy;
begin
   Clear;
   PacketBuffer.Free;
   ReceiveBuffer.Free;

   inherited Destroy;
end;

procedure TPacketReceiver.Clear;
begin
   PacketBuffer.Clear;
   ReceiveBuffer.Clear;
end;

function TPacketReceiver.GetCount : Integer;
begin
   Result := PacketBuffer.Count;
end;

procedure TPacketReceiver.Update;
var
   i, iBase, iPos, iStartPos, iEndPos, nSize : Integer;
   CurTick : Integer;
   buffer : array [0..8192 - 1] of Byte;
   Packet : TPacketData;
begin
   {
   while ReceiveBuffer.Count > 0 do begin
      if ReceiveBuffer.View (@Packet.PacketSize, SizeOf (Word)) = false then break;
      if (Packet.PacketSize <= 0) or (Packet.PacketSize >= SizeOf (TPacketData)) then begin
         ReceiveBuffer.Flush (Packet.PacketSize);
         WriteLog(format ('Wrong Packet Size = %d', [Packet.PacketSize]));
         break;
      end;
      if ReceiveBuffer.View (@Packet, Packet.PacketSize) = false then break;
      PacketBuffer.Put (@Packet, Packet.PacketSize);

      ReceiveBuffer.Flush (Packet.PacketSize);
   end;
   }
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
               DeCryption (@buffer[iStartPos], @Packet, iEndPos - iStartPos + 1);
               if (Packet.PacketSize > 0) and (Packet.PacketSize <= SizeOf (TPacketData)) then begin
                  PacketBuffer.Put (@Packet, Packet.PacketSize);
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

function TPacketReceiver.PutData (aData : PChar; aSize : Integer) : Boolean;
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

function TPacketReceiver.GetPacket (aPacket : PTPacketData) : Boolean;
begin
   Result := PacketBuffer.Get (PChar (aPacket));
end;

procedure TPacketReceiver.WriteLog (aStr : String);
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

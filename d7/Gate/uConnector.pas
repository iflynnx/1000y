unit uConnector;

interface

uses
   Windows, Classes, SysUtils, ScktComp, mmSystem, uBuffer, uLGRecordDef,
   uDBRecordDef, uKeyClass, uPackets, AnsStringCls, DefType, AUtil32;

type
   TClientWindow = ( cw_none, cw_login, cw_createlogin, cw_selectchar, cw_main, cw_agree );
   TGameStatus = ( gs_none, gs_login, gs_agree, gs_selectchar, gs_gotogame, gs_playing, gs_createchar, gs_deletechar, gs_createlogin, gs_changepass );

   TConnectData = record
      SocketInt : Integer;
   end;
   PTConnectData = ^TConnectData;

   TConnector = class
   private
      ConnectID : Integer;

      SocketInt : Integer;
      Socket : TCustomWinSocket;

      PacketSender : TPacketSender;
      PacketReceiver : TPacketReceiver;

      FGameStatus : TGameStatus;
      FClientWindow : TClientWindow;

      FLastMessage : Byte;
      RequestTime : Integer;

      CreateTime : Integer;

      LoginData : TLGRecord;

      VerNo : Byte;
      PaidType : TPaidType;
      Code : Byte;
      LoginID, LoginPW : String;
      PlayChar, UseChar, UseLand : String;
      IpAddr : String;

      // PaidResult : Integer;
      // boTimePay : Boolean;

      procedure ShowWindow (aKey : TClientWindow; boShow : Boolean);
      procedure SendStatusMessage (aKey: Byte; aStr : String);
      function GetCharInfo : String;
   protected
   public
      constructor Create (aSocket : TCustomWinSocket; aConnectID : Integer);
      destructor Destroy; override;

      function Update (CurTick : Integer) : Boolean;
      function MessageProcess (aComData : PTWordComData) : Boolean;

      procedure AddReceiveData (aData : PChar; aCount : Integer);
      procedure AddSendData (aData : PChar; aCount : Integer);
      procedure AddSendDataDirect (aData : PChar; aCount : Integer);
      procedure AddSendDataNoTouch (aData : PChar; aCount : Integer);

      procedure GameMessageProcess (aPacket : PTPacketData);
      procedure DBMessageProcess (aPacket : PTPacketData);
      procedure LoginMessageProcess (aPacket : PTPacketData);
      procedure PaidMessageProcess (aPacket : PTPacketData);

      procedure SetWriteAllow;

      property GameStatus : TGameStatus read FGameStatus;
      property PlayCharName : String read PlayChar;
   end;

   TConnectorList = class
   private
      UniqueID : Integer;
      UniqueValue : Integer;

      FPlayingUserCount : Integer;
      FLogingUserCount : Integer;

      SocketKey, ConnectIDKey : TIntegerKeyClass;
      
      DataList : TList;
      DeleteList : TList;

      CurProcessPos, ProcessCount : Word;

      function GetCount : Integer;
   protected
   public
      constructor Create;
      destructor Destroy; override;

      procedure Clear;

      function Update (CurTick : Integer) : Boolean;

      function CreateConnect (aSocket : TCustomWinSocket) : Boolean;
      function DeleteConnect (aSocket : TCustomWinSocket) : String;

      procedure AddReceiveData (aSocket : TCustomWinSocket; aData : PChar; aCount : Integer);

      procedure GameMessageProcess (aPacket : PTPacketData);
      procedure DBMessageProcess (aPacket : PTPacketData);
      procedure LoginMessageProcess (aPacket : PTPacketData);
      procedure PaidMessageProcess (aPacket : PTPacketData);

      procedure SetWriteAllow (aSocket : TCustomWinSocket);

      procedure ReCalc;

      property Count : Integer read GetCount;

      property PlayingUserCount : Integer read FPlayingUserCount write FPlayingUserCount;
      property LogingUserCount : Integer read FLogingUserCount write FLogingUserCount;
      property AutoConnectID : Integer read UniqueID;
      property GateUniqueValue : Integer read UniqueValue write UniqueValue;
   end;

var
   ConnectorList : TConnectorList;

implementation

uses
   FMain, uUtil, uGramerID;

// TConnector
constructor TConnector.Create (aSocket : TCustomWinSocket; aConnectID : Integer);
begin
   ConnectID := aConnectID;

   SocketInt := Integer (aSocket);
   
   Socket := aSocket;

   PacketSender := TPacketSender.Create ('Sender', 65535, aSocket);
   PacketReceiver := TPacketReceiver.Create ('Receiver', 65535);

   FGameStatus := gs_none;
   FClientWindow := cw_none;

   FLastMessage := 0;
   RequestTime := 0;
   CreateTime := timeGetTime;

   FillChar (LoginData, SizeOf (TLGRecord), 0);

   LoginID := '';
   LoginPW := '';
   PlayChar := '';
   UseChar := '';
   UseLand := '';
   IpAddr := aSocket.RemoteAddress;
   VerNo := 0;
   PaidType := pt_none;
   Code := 0;
end;

destructor TConnector.Destroy;
var
   buffer : array[0..20 - 1] of byte;
begin
   if GameStatus = gs_playing then begin
      FillChar (buffer, SizeOf (buffer), 0);
      StrPCopy (@buffer, PlayChar);
      if GameSender <> nil then begin
         GameSender.PutPacket (ConnectID, GM_DISCONNECT, 0, @buffer, SizeOf (buffer));
      end;
      if DBSender <> nil then begin
         DBSender.PutPacket (ConnectID, DB_UNLOCK, 0, @buffer, SizeOf (buffer));
      end;
   end;

   PacketReceiver.Free;
   PacketSender.Free;

   inherited Destroy;
end;

procedure TConnector.SetWriteAllow;
begin
   PacketSender.WriteAllow := true;
end;

procedure TConnector.AddReceiveData (aData : PChar; aCount : Integer);
begin
   PacketReceiver.PutData (aData, aCount);
end;

procedure TConnector.AddSendData (aData : PChar; aCount : Integer);
var
   ComData : TWordComData;
begin
   ComData.Size := aCount;
   Move (aData^, ComData.Data, aCount);
   PacketSender.PutPacket (0, 0, 0, @ComData, ComData.Size + SizeOf (Word));
end;

procedure TConnector.AddSendDataDirect (aData : PChar; aCount : Integer);
begin
   PacketSender.PutPacket (0, 0, 0, aData, aCount);
end;

procedure TConnector.AddSendDataNoTouch (aData : PChar; aCount : Integer);
begin
   PacketSender.PutPacket (0, 0, 0, aData, aCount);
end;

procedure TConnector.SendStatusMessage (aKey: Byte; aStr : String);
var
   cnt : Integer;
   sMessage : TSMessage;
begin
   sMessage.rmsg := SM_MESSAGE;
   sMessage.rkey := aKey;
   SetWordString (sMessage.rWordString, aStr);
   cnt := Sizeof(sMessage) - Sizeof(TWordString) + sizeofwordstring(sMessage.rWordString);
   
   AddSendData (@sMessage, cnt);
end;

procedure TConnector.ShowWindow (aKey : TClientWindow; boShow : Boolean);
var
   sWindow : TSWindow;
begin
   if boShow = true then begin
      FClientWindow := aKey;
   end;
   sWindow.rmsg := SM_WINDOW;
   sWindow.rwindow := Byte (aKey);
   sWindow.rboShow := boShow;
   AddSendData (@sWindow, sizeof(sWindow));
end;

function TConnector.Update (CurTick : Integer) : Boolean;
var
   PacketData : TPacketData;
   ComData : TWordComData;
   nSize : Integer;
begin
   PacketSender.Update;
   PacketReceiver.Update;
   while PacketReceiver.Count > 0 do begin
      if PacketReceiver.GetPacket (@PacketData) = false then break;
      nSize := PacketData.PacketSize - SizeOf (Word) - SizeOf (Integer) - SizeOf (Byte) - SizeOf (Byte);
      Move (PacketData.Data, ComData, nSize);
      if FGameStatus = gs_playing then begin
         if GameSender <> nil then begin
            GameSender.PutPacket (ConnectID, GM_SENDGAMEDATA, 0, @ComData.Data, ComData.Size);
         end;
      end else begin
         MessageProcess (@ComData);
      end;
   end;

   if (FGameStatus <> gs_none) and (FGameStatus <> gs_playing) then begin
      if RequestTime + 60000 <= CurTick then begin
         RequestTime := 0;
         FGameStatus := gs_none;
         Case FClientWindow of
            cw_login :
               begin
                  SendStatusMessage (MESSAGE_LOGIN, '[TIMEOUT]请重新连接.');
               end;
            cw_selectchar :
               begin
                  SendStatusMessage (MESSAGE_SELCHAR, '[TIMEOUT]请重新连接.');
               end;
            cw_createlogin :
               begin
                  ShowWindow (cw_createlogin, false);
                  ShowWindow (cw_login, true);
                  SendStatusMessage (MESSAGE_LOGIN, '[TIMEOUT]请重新连接.');
               end;
         end;
      end;
   end;

   if FGameStatus <> gs_playing then begin
      if CreateTime + 1000 * 60 * 10 <= CurTick then begin
         ConnectorList.DeleteConnect (Socket);
      end;
   end;

   Result := true;
end;

function TConnector.GetCharInfo : String;
var
   i : Integer;
   str : String;
begin
   str := '';
   for i := 0 to 5 - 1 do begin
{
      if LoginData.CharInfo[i].CharName[0] <> 0 then begin
         str := str + StrPas (@LoginData.CharInfo[i].CharName);
         str := str + ':';
         str := str + StrPas (@LoginData.CharInfo[i].ServerName);
      end;
}
      if LoginData.CharInfo[i].CharName <> '' then begin
         Str := Str + LoginData.CharInfo [i].CharName;
         str := str + ':';
         Str := Str + LoginData.CharInfo [i].ServerName;
      end;

      if i < 5 - 1 then str := str + ',';
      // str := str + ',';
   end;

   Result := str;
end;

procedure TConnector.PaidMessageProcess (aPacket : PTPacketData);
var
   pPaidData : PTPaidData;
begin
   Case aPacket^.RequestMsg of
      PM_CHECKPAID :
         begin
            if aPacket^.ResultCode = 0 then begin
               PaidType := pt_validate;
               FGameStatus := gs_none;
               exit;
            end;

            pPaidData := PTPaidData (@aPacket^.Data);
            if pPaidData^.rLoginId <> LoginID then begin
               SendStatusMessage (MESSAGE_LOGIN, '储值资料错误.');
               FGameStatus := gs_none;
               exit;
            end;
            
            PaidType := pPaidData^.rPaidType;
            Code := pPaidData^.rCode;
            
            Case PaidType of
               pt_invalidate :
                  SendStatusMessage (MESSAGE_SELCHAR, '未储值使用者无法进入游戏.');
               pt_validate :
                  SendStatusMessage (MESSAGE_SELCHAR, '已连接.');
               pt_test :
                  SendStatusMessage (MESSAGE_SELCHAR, '连线为测试账号.');
               pt_timepay :
                  SendStatusMessage (MESSAGE_SELCHAR, '连接为收费账号.');
               Else
                  SendStatusMessage (MESSAGE_SELCHAR, format ('使用期限剩余 %d 天', [pPaidData^.rRemainDay]));
            end;

            FGameStatus := gs_none;
         end;
   end;
end;

procedure TConnector.GameMessageProcess (aPacket : PTPacketData);
var
   iCnt : Integer;
   pDBRecord : PTDBRecord;
   buffer : array [0..20 - 1] of byte;
begin
   Case aPacket^.RequestMsg of
      GM_CONNECT :
         begin
            FGameStatus := gs_playing;
            ShowWindow (cw_selectchar, FALSE);
            ShowWindow (cw_main, TRUE);

            StrPCopy (@buffer, PlayChar);
            if DBSender <> nil then begin
               DBSender.PutPacket (ConnectID, DB_LOCK, 0, @buffer, SizeOf (buffer));
            end;
         end;
      GM_DISCONNECT :
         begin
            frmMain.AddLog ('解除连线 : ' + PlayChar);
            Socket.Close;
         end;
      GM_SENDUSERDATA :
         begin
            pDBRecord := @aPacket^.Data;
            if DBSender <> nil then begin
               DBSender.PutPacket (ConnectID, DB_UPDATE, 0, @aPacket.Data, SizeOf (TDBRecord));
            end;
         end;
      GM_SENDGAMEDATA :
         begin
            iCnt := aPacket^.PacketSize - (SizeOf (Word) + SizeOf (Integer) + SizeOf (Byte) * 2);
            AddSendDataDirect (@aPacket^.Data, iCnt);
         end;
      GM_DUPLICATE :
      	begin
            SendStatusMessage (MESSAGE_SELCHAR, '已解除连线.');
            PlayChar := ''; UseChar := ''; UseLand := '';
            FGameStatus := gs_none;
         end;
      GM_SENDALL :
      	begin
         	if FGameStatus = gs_playing then begin
               iCnt := aPacket^.PacketSize - (SizeOf (Word) + SizeOf (Integer) + SizeOf (Byte) * 2);
               AddSendDataNoTouch (@aPacket^.Data, iCnt);
            end;
         end;
   end;
end;

procedure TConnector.DBMessageProcess (aPacket : PTPacketData);
var
   i, cnt : Integer;
   str : String;
   ws : TWordInfoString;
   pDBRecord : PTDBRecord;
   LGRecord : TLGRecord;
   CurDate, LastDate : TDateTime;
begin
   Case aPacket^.RequestMsg of
      DB_INSERT :
         begin
            if aPacket^.ResultCode = DB_OK then begin
               if FGameStatus = gs_createchar then begin
                  pDBRecord := @aPacket^.Data;

                  Move (LoginData, LGRecord, SizeOf (TLGRecord));
                  for i := 0 to 5 - 1 do begin
//                     if LGRecord.CharInfo[i].CharName[0] = 0 then begin
//                        StrCopy (@LGRecord.CharInfo[i].CharName, @pDBRecord^.PrimaryKey);
//                        StrPCopy (@LGRecord.CharInfo[i].ServerName, ServerName);
                     if LGRecord.CharInfo [i].CharName = '' then begin
                        LGRecord.CharInfo[i].CharName := StrPas (@pDBRecord^.PrimaryKey);
                        LGRecord.CharInfo[i].ServerName := ServerName;
                        break;
                     end;
                  end;
                  ws.rmsg := SM_CHARINFO;
                  str := GetCharInfo;
                  SetWordString (ws.rwordstring, str);
                  cnt := sizeof(ws) - sizeof(TWordString) + SizeofWordString (ws.rWordstring);
                  AddSendData (@ws, cnt);

                  if LoginSender <> nil then begin
                     LoginSender.PutPacket (ConnectID, LG_UPDATE, 0, @LGRecord, SizeOf (TLGRecord));
                  end;
               end;
            end else begin
               Case aPacket^.ResultCode of
                  DB_ERR_DUPLICATE :
                     begin
                        SendStatusMessage (MESSAGE_SELCHAR, '此角色名称已被使用.');
                     end;
                  DB_ERR_NOTENOUGHSPACE :
                     begin
                        SendStatusMessage (MESSAGE_SELCHAR, '角色资料已满,无法再建立.');
                     end;
                  DB_ERR_INVALIDDATA :
                     begin
                        SendStatusMessage (MESSAGE_SELCHAR, '此为不适用的名称.');
                     end;
                  DB_ERR_IO :
                     begin
                        SendStatusMessage (MESSAGE_SELCHAR, '发生I/O错误.');
                     end;
                  Else
                     begin
                        SendStatusMessage (MESSAGE_SELCHAR, 'DB Server 内部错误.');
                     end;
               end;
               FGameStatus := gs_none;
            end;
         end;
      DB_SELECT :
         begin
            if aPacket^.ResultCode = DB_OK then begin
               if FGameStatus = gs_selectchar then begin
                  pDBRecord := @aPacket^.Data;

                  if TestStr (@pDBRecord^.PrimaryKey, 20) = false then begin
                     pDBRecord^.PrimaryKey[0] := 0;
                  end;
                  if TestStr (@pDBRecord^.PrimaryKey, 20) = false then begin
                     pDBRecord^.MasterName[0] := 0;
                  end;

                  if StrPas (@pDBRecord^.PrimaryKey) <> UseChar then begin
                     SendStatusMessage (MESSAGE_SELCHAR, 'DB Server 内部错误.');
                     UseChar := ''; UseLand := '';
                     FGameStatus := gs_none;
                     exit;
                  end;

                  if StrPas (@pDBRecord^.MasterName) <> LoginID then begin
                     SendStatusMessage (MESSAGE_SELCHAR, '不是本人角色.');
                     UseChar := ''; UseLand := '';
                     FGameStatus := gs_none;
                     exit;
                  end;

                  if frmMain.sckGameConnect.Active = false then begin
                     SendStatusMessage (MESSAGE_SELCHAR, '对不起,请稍后再试.');
                     UseChar := ''; UseLand := '';
                     FGameStatus := gs_none;
                     exit;
                  end;

                  PlayChar := UseChar;

                  frmMain.AddLog (format ('角色名称 ： %s', [StrPas (@pDBRecord^.PrimaryKey)]));

                  Str := IpAddr + ',' + IntToStr (VerNo) + ',' + IntToStr (Byte (PaidType)) + ',' + IntToStr (Code);
                  StrPCopy (@pDBRecord^.Dummy, Str);
                  if GameSender <> nil then begin
                     GameSender.PutPacket (ConnectID, GM_CONNECT, 0, @aPacket^.Data, SizeOf (TDBRecord));
                  end;

                  FGameStatus := gs_gotogame;
               end else if FGameStatus = gs_deletechar then begin
                  pDBRecord := @aPacket^.Data;

                  if StrPas (@pDBRecord^.PrimaryKey) <> UseChar then begin
                     SendStatusMessage (MESSAGE_SELCHAR, 'DB Server 内部错误.');
                     UseChar := ''; UseLand := '';
                     FGameStatus := gs_none;
                     exit;
                  end;
                  if StrPas (@pDBRecord^.MasterName) <> LoginID then begin
                     SendStatusMessage (MESSAGE_SELCHAR, '不是本人角色.');
                     UseChar := ''; UseLand := '';
                     FGameStatus := gs_none;
                     exit;
                  end;

                  try
                     CurDate := Date - 7;
                     LastDate := StrToDate (StrPas (@pDBRecord^.LastDate));
                     if LastDate > CurDate then begin
                        SendStatusMessage (MESSAGE_SELCHAR, '七天内使用过的角色无法删除.');
                        FGameStatus := gs_none;
                        exit;
                     end;
                  except
                     SendStatusMessage (MESSAGE_SELCHAR, '七天内使用过的角色无法删除.');
                     FGameStatus := gs_none;
                     exit;
                  end;

                  Move (LoginData, LGRecord, SizeOf (TLGRecord));
                  for i := 0 to 5 - 1 do begin
//                     if StrPas (@LGRecord.CharInfo[i].CharName) = UseChar then begin
//                        if StrPas (@LGRecord.CharInfo[i].ServerName) = UseLand then begin
                     if LGRecord.CharInfo [i].CharName = UseChar then begin
                        if LGRecord.CharInfo [i].ServerName = UseLand then begin
                           FillChar (LGRecord.CharInfo[i], SizeOf (TCharInfo), 0);
                           break;
                        end;
                     end;
                  end;

                  if LoginSender <> nil then begin
                     LoginSender.PutPacket (ConnectID, LG_UPDATE, 0, @LGRecord, SizeOf (TLGRecord));
                  end;
               end;
            end else begin
               Case aPacket^.ResultCode of
                  DB_ERR_NOTFOUND :
                     begin
                        SendStatusMessage (MESSAGE_SELCHAR, '找不到所选择的角色.');
                     end;
                  DB_ERR_INVALIDDATA :
                     begin
                        SendStatusMessage (MESSAGE_SELCHAR, '此为不适用的名称.');
                     end;
                  DB_ERR_IO :
                     begin
                        SendStatusMessage (MESSAGE_SELCHAR, '发生I/O错误.');
                     end;
                  Else
                     begin
                        SendStatusMessage (MESSAGE_SELCHAR, 'DB Server 内部错误.');
                     end;
               end;
               FGameStatus := gs_none;
            end;
         end;
      DB_UPDATE :
         begin
         end;
      Else
         begin
            // frmMain.AddLog (format ('%d Packet was received', [aPacket^.RequestMsg]));
         end;
   end;
end;

procedure TConnector.LoginMessageProcess (aPacket : PTPacketData);
var
   cnt : Integer;
   ws : TWordInfoString;
   str : String;
   PaidPacket : TPacketData;
   pPaidData : PTPaidData;
   PaidData : TPaidData;
begin
   Case aPacket^.RequestMsg of
      LG_INSERT :
         begin
            if aPacket^.ResultCode = DB_OK then begin
               ShowWindow (cw_createlogin, FALSE);
               ShowWindow (cw_login, TRUE);
               SendStatusMessage (MESSAGE_LOGIN, '用此连线名称进行连线.');
            end else begin
               Case aPacket^.ResultCode of
                  DB_ERR_DUPLICATE :
                     begin
                        SendStatusMessage (MESSAGE_CREATELOGIN, '已存在的连线名称.');
                     end;
                  Else
                     begin
                        SendStatusMessage (MESSAGE_CREATELOGIN, 'LOGIN Server 内部错误.');
                     end;
               end;
            end;
            FGameStatus := gs_none;
         end;
      LG_SELECT :
         begin
            if aPacket^.ResultCode = DB_OK then begin
               if FGameStatus = gs_login then begin
                  Move (aPacket^.Data, LoginData, SizeOf (TLGRecord));

{
                  if TestStr (@LoginData.PrimaryKey, 20) = false then begin
                     LoginData.PrimaryKey[0] := 0;
                  end;
                  if TestStr (@LoginData.Password, 20) = false then begin
                     LoginData.Password[0] := 0;
                  end;

                  if StrPas (@LoginData.PrimaryKey) <> LoginID then begin
                     SendStatusMessage (MESSAGE_LOGIN, format ('LOGIN Server 内部错误.', [ServerName]));
                     LoginID := ''; LoginPW := '';
                     FGameStatus := gs_none;
                     exit;
                  end;
                  if StrPas (@LoginData.Password) <> LoginPW then begin
                     SendStatusMessage (MESSAGE_LOGIN, format ('此密码不适用.', [ServerName]));
                     LoginID := ''; LoginPW := '';
                     FGameStatus := gs_none;
                     exit;
                  end;
}

                  if LoginData.PrimaryKey <> LoginID then begin
                     SendStatusMessage (MESSAGE_LOGIN, format ('LOGIN Server 内部错误.', [ServerName]));
                     LoginID := ''; LoginPW := '';
                     FGameStatus := gs_none;
                     exit;
                  end;
                  if LoginData.PassWord <> LoginPW then begin
                     SendStatusMessage (MESSAGE_LOGIN, format ('此密码不适用.', [ServerName]));
                     LoginID := ''; LoginPW := '';
                     FGameStatus := gs_none;
                     exit;
                  end;

                  ShowWindow (cw_login, FALSE);
                  ShowWindow (cw_selectchar, TRUE);

//                  StrPCopy (@LoginData.LastDate, DateToStr (Date));
//                  StrPCopy (@LoginData.IpAddr, IpAddr);
                  LoginData.LastDate := DateToStr (Date);
                  LoginData.IpAddr := IpAddr;

                  if LoginSender <> nil then begin
                     LoginSender.PutPacket (ConnectID, LG_UPDATE, 0, @LoginData, SizeOf (TLGRecord));
                  end;

                  ws.rmsg := SM_CHARINFO;
                  str := GetCharInfo;
                  SetWordString (ws.rwordstring, str);
                  cnt := sizeof(ws) - sizeof(TWordString) + SizeofWordString (ws.rWordstring);
                  AddSendData (@ws, cnt);

                  FGameStatus := gs_none;

                  if PaidSender = nil then begin
                     PaidType := pt_validate;
                     Code := 0;
                  end;

                  FillChar (PaidData, SizeOf (TPaidData), 0);
                  if PaidType = pt_none then begin
                     PaidData.rLoginID := LoginID;
                     PaidData.rIpAddr := IpAddr;
                     PaidData.rMakeDate := LoginData.MakeDate;
                     PaidSender.PutPacket (ConnectID, PM_CHECKPAID, 0, @PaidData, SizeOf (TPaidData));
                     SendStatusMessage (MESSAGE_SELCHAR, '确认储值资料中…');
                  end else if PaidType = pt_timepay then begin
                     FillChar (PaidPacket, SizeOf (TPacketData), 0);
                     PaidPacket.PacketSize := SizeOf (Word) + SizeOf (Integer) + SizeOf (Byte) * 2 + SizeOf (TPaidData);
                     PaidPacket.RequestID := ConnectID;
                     PaidPacket.RequestMsg := PM_CHECKPAID;
                     PaidPacket.ResultCode := 1;

                     pPaidData := PTPaidData (@PaidPacket.Data);
                     pPaidData^.rLoginID := LoginID;
                     pPaidData^.rIpAddr := IpAddr;
                     pPaidData^.rRemainDay := 0;
                     pPaidData^.rPaidType := pt_timepay;
                     pPaidData^.rCode := 0;

                     PaidMessageProcess (@PaidPacket);
                  end else begin
                     PaidType := pt_validate;
                     SendStatusMessage (MESSAGE_SELCHAR, format ('[%s]某腐磐甫 急琶窍技夸.', [ServerName]));
                  end;
               end;
            end else begin
               Case aPacket^.ResultCode of
                  DB_ERR_NOTFOUND :
                     begin
                        SendStatusMessage (MESSAGE_LOGIN, '找不到此连线名称资料.');
                     end;
                  DB_ERR_INVALIDDATA :
                     begin
                        SendStatusMessage (MESSAGE_LOGIN, '连线名称不正确.');
                     end;
                  Else
                     begin
                        SendStatusMessage (MESSAGE_LOGIN, '请重新输入.');
                     end;
               end;
            end;
            FGameStatus := gs_none;
         end;
      LG_UPDATE :
         begin
            if aPacket^.ResultCode = DB_OK then begin
               Move (aPacket^.Data, LoginData, SizeOf (TLGRecord));
               Case FGameStatus of
                  gs_createchar : begin
                     SendStatusMessage (MESSAGE_SELCHAR, '制造了一个角色.');

                     ws.rmsg := SM_CHARINFO;
                     str := GetCharInfo;
                     SetWordString (ws.rwordstring, str);
                     cnt := sizeof(ws) - sizeof(TWordString) + SizeofWordString (ws.rWordstring);
                     AddSendData (@ws, cnt);

                     FGameStatus := gs_none;
                  end;
                  gs_changepass : begin
                     SendStatusMessage (MESSAGE_SELCHAR, '密码变更完成.');
                     FGameStatus := gs_none;
                  end;
                  gs_deletechar : begin
                     SendStatusMessage (MESSAGE_SELCHAR, '角色删除完成.');

                     ws.rmsg := SM_CHARINFO;
                     str := GetCharInfo;
                     SetWordString (ws.rwordstring, str);
                     cnt := sizeof(ws) - sizeof(TWordString) + SizeofWordString (ws.rWordstring);
                     AddSendData (@ws, cnt);

                     FGameStatus := gs_none;
                  end;
               end;
            end else begin
               Case aPacket^.ResultCode of
                  DB_ERR_NOTFOUND :
                     begin
                        SendStatusMessage (MESSAGE_LOGIN, '找不到此连线名称资料.');
                     end;
               end;
               FGameStatus := gs_none;
            end;
         end;
      Else
         begin
            // frmMain.AddLog (format ('%d Packet was received', [aPacket^.RequestMsg]));
         end;
   end;
end;

function TConnector.MessageProcess (aComData : PTWordComData) : Boolean;
var
   i : Integer;
   msg : PByte;
   sKey : TCKey;
//   pcKey : PTCKey;
   pcVer : PTCVer;
//   pcCreateIdPass : PTCCreateIdPass;
   pcCreateIdPass2 : PTCCreateIdPass2;
   pcCreateIdPass3 : PTCCreateIdPass3;
   pcIdPass : PTCIdPass;
   pcCreateChar : PTCCreateChar;
   pcDeleteChar : PTCDeleteChar;
   pcSelectChar : PTCSelectChar;
   pcChangePassword : PTCChangePassword;

   LGRecord : TLGRecord;
   DBRecord : TDBRecord;

   uStr : String;
   boFlag : Boolean;

   nYear, nMonth, nDay : Word;
   uid, upass, uname, unativenumber, umasterkey : String;
   uEmail, uPhone, uParentName, uParentNativeNumber : String;
   ucharname, uvillage, uservername : String;

   pd : PTVillageData;
begin
   Result := true;

   msg := @aComData^.Data;

   case msg^ of
      CM_VERSION :
         begin
            if FGameStatus <> gs_none then exit;

            pcVer := @aComData^.Data;
            if (pcVer^.rNation <> NATION_VERSION) or (pcVer^.rVer < PROGRAM_VERSION) then begin
               sKey.rmsg := SM_CLOSE;
               sKey.rkey := 1;
               AddSendData (@sKey, SizeOf(skey));
            end else begin
               VerNo := pcVer^.rVer;
               FClientWindow := cw_login;
               SendStatusMessage (MESSAGE_LOGIN, '连线成功.');
            end;
         end;
      CM_CHANGEPASSWORD :
         begin
            if (FGameStatus <> gs_none) or (FGameStatus = gs_changepass) then exit;

            Case PaidType of
               pt_none : begin
                  SendStatusMessage (MESSAGE_SELCHAR, '接收玩家情报中,请稍後…');
                  exit;
               end;
               pt_invalidate : begin
                  SendStatusMessage (MESSAGE_SELCHAR, '未储值使用者无法更改设定.');
                  exit;
               end;
            end;
            FGameStatus := gs_changepass;

            pcChangePassword := @aComData^.Data;
            pcChangePassword^.rNewPass [NAME_SIZE - 1] := 0;
            
            upass := Trim (StrPas (@pcChangePassword^.rNewPass));
            if (upass = '') or (Pos (',', upass) > 0) or (Length (upass) > 10) then begin
               FGameStatus := gs_none;
               SendStatusMessage (MESSAGE_SELCHAR, '新密码输入错误.');
               exit;
            end;
            Move (LoginData, LGRecord, SizeOf (TLGRecord));
            LGRecord.Password := uPass;
//            StrPCopy (@LGRecord.Password, upass);

            if LoginSender <> nil then begin
               LoginSender.PutPacket (ConnectID, LG_UPDATE, 0, @LGRecord, SizeOf (TLGRecord));
            end;
         end;
      CM_CREATEIDPASS :
         begin
            exit;
            {
            if (FGameStatus <> gs_none) or (FGameStatus = gs_createlogin) then exit;
            FGameStatus := gs_createlogin;
            }
         end;
      CM_CREATEIDPASS2 :
         begin
            exit;
            {
            if (FGameStatus <> gs_none) or (FGameStatus = gs_createlogin) then exit;

            pcCreateIdPass2 := @aComData^.Data;
            pcCreateIdPass2^.rID [NAME_SIZE - 1] := 0;
            pcCreateIdPass2^.rPass [NAME_SIZE - 1] := 0;
            pcCreateIdPass2^.rName [NAME_SIZE - 1] := 0;
            pcCreateIdPass2^.rNativeNumber [NAME_SIZE - 1] := 0;
            pcCreateIdPass2^.rMasterKey [NAME_SIZE - 1] := 0;

            uid := Trim (StrPas (@pcCreateIdPass2.rID));
            upass := Trim (StrPas (@pcCreateIdPass2.rPass));
            uname := Trim (StrPas (@pcCreateIdPass2.rName));
            unativenumber := Trim (StrPas (@pcCreateIdPass2.rNativeNumber));
            umasterkey := Trim (StrPas (@pcCreateIdPass2.rMasterKey));

            if (uid = '') or (Pos (',', uid) > 0) or (not isFullHangul (uid)) then begin
               SendStatusMessage (MESSAGE_CREATELOGIN, '连线名称输入错误.');
               exit;
            end;
            if (upass = '') or (Pos (',', upass) > 0) then begin
               SendStatusMessage (MESSAGE_CREATELOGIN, '密码输入错误.');
               exit;
            end;
            if (uname = '') or (Pos (',', uname) > 0) or (not isFullHangul (uname)) then begin
               SendStatusMessage (MESSAGE_CREATELOGIN, '本人名称输入错误.');
               exit;
            end;
            if (uNativeNumber = '') or (Pos (',', uNativeNumber) > 0) then begin
               SendStatusMessage (MESSAGE_CREATELOGIN, '出生年月日输入错误.');
               exit;
            end;
            if (uMasterKey = '') or (Pos (',', uMasterKey) > 0) or (not isFullHangul (uMasterKey)) then begin
               SendStatusMessage (MESSAGE_CREATELOGIN, '电话号码输入错误.');
               exit;
            end;

            FGameStatus := gs_createlogin;

            FillChar (LGRecord, SizeOf (TLGRecord), 0);
            StrPCopy (@LGRecord.PrimaryKey, uid);
            StrPCopy (@LGRecord.Password, upass);
            StrPCopy (@LGRecord.UserName, uname);
            StrPCopy (@LGRecord.IpAddr, IpAddr);
            StrPCopy (@LGRecord.MakeDate, DateToStr (Date));
            StrPCopy (@LGRecord.NativeNumber, unativenumber);
            StrPCopy (@LGRecord.MasterKey, umasterkey);

            if LoginSender <> nil then begin
               LoginSender.PutPacket (ConnectID, LG_INSERT, 0, @LGRecord, SizeOf (TLGRecord));
            end;
            }
         end;
      CM_CREATEIDPASS3 :
         begin
            if (FGameStatus <> gs_none) or (FGameStatus = gs_createlogin) then exit;

            pcCreateIdPass3 := @aComData^.Data;
            uId := Trim (pcCreateIdPass3^.rID);
            uPass := Trim (pcCreateIdPass3^.rPass);
            uName := Trim (pcCreateIdPass3^.rName);
            uNativeNumber := Trim (pcCreateIdPass3^.rNativeNumber);
            uMasterKey := Trim (pcCreateIdPass3^.rMasterKey);
            uEmail := Trim (pcCreateIdPass3^.rEmail);
            uPhone := Trim (pcCreateIdPass3^.rPhone);
            uParentName := Trim (pcCreateIdPass3^.rParentName);
            uParentNativeNumber := Trim (pcCreateIdPass3^.rParentNativeNumber);

            if (uId = '') or (Pos (',', uId) > 0) or (not isFullHangul (uId)) then begin
               SendStatusMessage (MESSAGE_CREATELOGIN, '连线名称输入错误.');
               exit;
            end;
            if (uPass = '') or (Pos (',', uPass) > 0) then begin
               SendStatusMessage (MESSAGE_CREATELOGIN, '密码输入错误.');
               exit;
            end;
            if (uName = '') or (Pos (',', uName) > 0) or (not isFullHangul (uName)) then begin
               SendStatusMessage (MESSAGE_CREATELOGIN, '本人名称输入错误.');
               exit;
            end;
            if (uNativeNumber = '') or (Pos (',', uNativeNumber) > 0) then begin
               SendStatusMessage (MESSAGE_CREATELOGIN, '出生年月日输入错误.');
               exit;
            end;
            if (uMasterKey = '') or (Pos (',', uMasterKey) > 0) or (not isFullHangul (uMasterKey)) then begin
               SendStatusMessage (MESSAGE_CREATELOGIN, '密码输入错误.');
               exit;
            end;
            if (uEmail = '') or (Pos (',', uEmail) > 0) or (not isFullHangul (uEmail)) then begin
               SendStatusMessage (MESSAGE_CREATELOGIN, 'e-mail输入错误.');
               exit;
            end;
            if (uPhone = '') or (Pos (',', uPhone) > 0) then begin
               SendStatusMessage (MESSAGE_CREATELOGIN, '电话号码输入错误.');
               exit;
            end;

            if uParentNativeNumber <> '-' then begin
               if (uParentName = '') or (Pos (',', uParentName) > 0) or (not isFullHangul (uParentName)) then begin
                  SendStatusMessage (MESSAGE_CREATELOGIN, '家长名称输入错误.');
                  exit;
               end;
               if (uParentNativeNumber = '') or (Pos (',', uParentNativeNumber) > 0) then begin
                  SendStatusMessage (MESSAGE_CREATELOGIN, '家长的身份证号输入错误.');
                  exit;
               end;
            end;

            FGameStatus := gs_createlogin;

            FillChar (LGRecord, SizeOf (TLGRecord), 0);

            LGRecord.PrimaryKey := uId;
            LGRecord.PassWord := uPass;
            LGRecord.UserName := uName;
            LGRecord.NativeNumber := uNativeNumber;
            LGRecord.MasterKey := uMasterKey;
            LGRecord.Email := uEmail;
            LGRecord.Phone := uPhone;
            LGRecord.ParentName := uParentName;
            LGRecord.ParentNativeNumber := uParentNativeNumber;
            LGRecord.IpAddr := IpAddr;
            LGRecord.MakeDate := DateToStr (Date);

            if LoginSender <> nil then begin
               LoginSender.PutPacket (ConnectID, LG_INSERT, 0, @LGRecord, SizeOf (TLGRecord));
            end;
         end;
      CM_IDPASS :
         begin
            if (FGameStatus <> gs_none) or (FGameStatus = gs_login) then exit;

            if frmMain.sckLoginConnect.Socket.Connected = false then begin
               SendStatusMessage (MESSAGE_LOGIN, '对不起,请稍后再试.');
               exit;
            end;

            FGameStatus := gs_login;

            if boCheckPaidInfo = false then begin
               PaidType := pt_validate;
               Code := 0;
            end;

            pcIdPass := @aComData^.data;
            pcIdPass^.rID [NAME_SIZE - 1] := 0;
            pcIdPass^.rPass [NAME_SIZE - 1] := 0;

            LoginID := Trim (StrPas (@pcIdPass^.rID));
            LoginPW := Trim (StrPas (@pcIdPass^.rPass));

            if (LoginID = '') or (LoginPW = '') then begin
               LoginID := '';
               LoginPW := '';
               FGameStatus := gs_none;
               SendStatusMessage (MESSAGE_LOGIN, '请输入正确的资料.');
               exit;
            end;

            if (LimitUserCount > 0) and (LimitUserCount <= ConnectorList.PlayingUserCount) then begin
               if IpAddr <> '203.227.29.65' then begin
                  if (LoginID <> 'ypinetree') and (LoginID <> 'pinetree') then begin
                     FGameStatus := gs_none;
                     LoginID := '';
                     LoginPW := '';
                     SendStatusMessage (MESSAGE_LOGIN, '上线人数已满,请选择其它服务器.');
                     exit;
                  end;
               end;
            end;

            FillChar (LGRecord, SizeOf (TLGRecord), 0);
//            StrPCopy (@LGRecord.PrimaryKey, LoginID);
            LGRecord.PrimaryKey := LoginID;

            if LoginSender <> nil then begin
               LoginSender.PutPacket (ConnectID, LG_SELECT, 0, @LGRecord.PrimaryKey, SizeOf (LGRecord.PrimaryKey));
            end;
         end;
      CM_IDPASSAZACOM :
         begin
            if (FGameStatus <> gs_none) or (FGameStatus = gs_login) then exit;

            if frmMain.sckLoginConnect.Socket.Connected = false then begin
               SendStatusMessage (MESSAGE_LOGIN, '对不起,请稍后再试.');
               exit;
            end;

            FGameStatus := gs_login;

            PaidType := pt_timepay;

            pcIdPass := @aComData^.data;
            pcIdPass^.rID [NAME_SIZE - 1] := 0;
            pcIdPass^.rPass [NAME_SIZE - 1] := 0;

            LoginID := Trim (StrPas (@pcIdPass^.rID));
            LoginPW := Trim (StrPas (@pcIdPass^.rPass));

            FillChar (LGRecord, SizeOf (TLGRecord), 0);
//            StrPCopy (@LGRecord.PrimaryKey, LoginID);
            LGRecord.PrimaryKey := LoginID;

            if LoginSender <> nil then begin
               LoginSender.PutPacket (ConnectID, LG_SELECT, 0, @LGRecord.PrimaryKey, SizeOf (LGRecord.PrimaryKey));
            end;
         end;
      CM_CREATECHAR :
         begin
            if (FGameStatus <> gs_none) or (FGameStatus = gs_createchar) then exit;

            {
            if (LimitUserCount > 0) and (ServerName = '角氰') then begin
               SendStatusMessage (MESSAGE_SELCHAR, '角氰辑滚俊 歹 捞惑 某腐磐甫 父甸 荐 绝嚼聪促');
               exit;
            end;
            }

            Case PaidType of
               pt_none : begin
                  SendStatusMessage (MESSAGE_SELCHAR, '接收玩家情报中,请稍後…');
                  exit;
               end;
               pt_invalidate : begin
                  SendStatusMessage (MESSAGE_SELCHAR, '未储值使用者无法制造东西.');
                  exit;
               end;
            end;

            FGameStatus := gs_createchar;

            boFlag := false;
            for i := 0 to 5 - 1 do begin
//               if LoginData.CharInfo[i].CharName[0] = 0 then begin
               if LoginData.CharInfo[i].CharName = '' then begin
                  boFlag := true;
                  break;
               end;
            end;
            if boflag = false then begin
               FGameStatus := gs_none;
               SendStatusMessage (MESSAGE_SELCHAR, '无法再建立角色.');
               exit;
            end;

            pcCreateChar := @aComData^.data;
            pcCreateChar^.rChar [NAME_SIZE - 1] := 0;
            pcCreateChar^.rVillage [NAME_SIZE - 1] := 0;
            pcCreateChar^.rServer [NAME_SIZE - 1] := 0;

            ucharname := Trim (StrPas (@pcCreateChar^.rChar));
            uvillage := Trim (StrPas (@pcCreateChar^.rVillage));
            uservername := Trim (StrPas (@pcCreateChar^.rServer));

            for i := 0 to RejectCharName.Count - 1 do begin
               if Pos (RejectCharName.Strings[i], ucharname) > 0 then begin
                  FGameStatus := gs_none;
                  SendStatusMessage (MESSAGE_SELCHAR, '无法使用角色名称.');
                  exit;
               end;
            end;

            if Length (ucharname) > 12 then begin
               FGameStatus := gs_none;
               SendStatusMessage (MESSAGE_SELCHAR, '角色名称最多六个字.');
               exit;
            end;
            if (ucharname [1] >= '0') and (ucharname [1] <= '9') then begin
               FGameStatus := gs_none;
               SendStatusMessage (MESSAGE_SELCHAR, '角色名称的第一个字无法使用数字.');
               exit;
            end;
            if (ucharname [Length (ucharname)] >= '0') and (ucharname [Length (ucharname)] <= '9') then begin
               FGameStatus := gs_none;
               SendStatusMessage (MESSAGE_SELCHAR, '角色名称的最后一个字无法使用数字.');
               exit;
            end;
            if (ucharname = '') or (Pos (',', ucharname) > 0) then begin
               FGameStatus := gs_none;
               SendStatusMessage (MESSAGE_SELCHAR, '无法使用角色名称.');
               exit;
            end;
            if (not isFullHangul (ucharname)) or (not isGrammarID(ucharname)) then begin
               FGameStatus := gs_none;
               SendStatusMessage (MESSAGE_SELCHAR, 'ID无法使用特殊文字.');
               exit;
            end;

            FillChar (DBRecord, SizeOf (TDBRecord), 0);
            DecodeDate (Date, nYear, nMonth, nDay);
            with DBRecord do begin
               StrPCopy (@PrimaryKey, ucharname);
               StrPCopy (@MasterName, LoginData.PrimaryKey);
               // Guild : array [0..20 - 1] of byte;
               StrPCopy (@LastDate, format ('%d-%d-%d', [nYear, nMonth, nDay]));
               StrPCopy (@CreateDate, format ('%d-%d-%d', [nYear, nMonth, nDay]));

               if pcCreateChar^.rSex = 0 then StrPCopy (@Sex, '男')
               else StrPCopy (@Sex, '女');

               ServerID := 0;
               X := 534;
               Y := 574;

               for i := 0 to VillageList.Count - 1 do begin
                  pd := VillageList.Items [i];
                  if pd^.Name = uvillage then begin
                     ServerID := pd^.ServerID;
                     X := pd^.X;
                     Y := pd^.Y;
                     break;
                  end;
               end;

               {
               Light : Integer;
               Dark : Integer;
               Energy : Integer;
               InPower : Integer;
               OutPower : Integer;
               Magic : Integer;
               Life : Integer;

               Talent : integer;
               GoodChar : integer;
               BadChar : integer;

               Adaptive : integer;
               Revival : integer;
               Immunity : integer;
               Virtue : integer;
               }

               CurHeadSeek := 2200;
               CurArmSeek := 2200;
               CurLegSeek := 2200;
               CurHealth := 2200;
               CurSatiety := 2200;
               CurPoisoning := 2200;
               CurEnergy := 600;
               CurInPower := 1100;
               CurOutPower := 1100;
               CurMagic := 600;
               CurLife := 2200;

               {
               BasicMagicArr : array [0..10 - 1] of TBasicMagicData;
               WearItemArr : array [0..8 - 1] of TItemData;
               HaveItemArr : array [0..30 - 1] of TItemData;
               HaveMagicArr : array [0..20 - 1] of TMagicData;
               }
            end;
            if DBSender <> nil then begin
               DBSender.PutPacket (ConnectID, DB_INSERT, 0, @DBRecord, SizeOf (DBRecord));
            end;
         end;
      CM_DELETECHAR:
         begin
            if (FGameStatus <> gs_none) or (FGameStatus = gs_deletechar) then exit;

            Case PaidType of
               pt_none : begin
                  SendStatusMessage (MESSAGE_SELCHAR, '接收玩家情报中,请稍後…');
                  exit;
               end;
               pt_invalidate : begin
                  SendStatusMessage (MESSAGE_SELCHAR, '未储值使用者无法删除.');
                  exit;
               end;
            end;

            FGameStatus := gs_deletechar;

            pcDeleteChar := @aComData^.Data;
            pcDeleteChar^.rChar [NAME_SIZE - 1] := 0;

            uStr := StrPas (@pcDeleteChar^.rChar);
            uStr := GetTokenStr (uStr, UseChar, ':');
            uStr := GetTokenStr (uStr, UseLand, ':');
            UseChar := Trim (UseChar);
            UseLand := Trim (UseLand);
            if UseChar = '' then begin
               FGameStatus := gs_none;
               SendStatusMessage (MESSAGE_SELCHAR, '请选择要删除的角色.');
               exit;
            end;
            if UseLand <> ServerName then begin
               FGameStatus := gs_none;
               SendStatusMessage (MESSAGE_SELCHAR, '不是本服务器的角色.');
               exit;
            end;

            FillChar (DBRecord, SizeOf (TDBRecord), 0);
            StrPCopy (@DBRecord.PrimaryKey, UseChar);

            if DBSender <> nil then begin
               DBSender.PutPacket (ConnectID, DB_SELECT, 0, @DBRecord, SizeOf (DBRecord.PrimaryKey));
            end;
         end;
      CM_SELECTCHAR:
         begin
            if (FGameStatus <> gs_none) or (FGameStatus = gs_selectchar) then exit;
            if frmMain.sckDBConnect.Socket.Connected = false then begin
               SendStatusMessage (MESSAGE_SELCHAR, '对不起,请稍后再试.');
               exit;
            end;

            Case PaidType of
               pt_none : begin
                  SendStatusMessage (MESSAGE_SELCHAR, '接收玩家情报中,请稍後…');
                  exit;
               end;
               pt_invalidate : begin
                  SendStatusMessage (MESSAGE_SELCHAR, '未储值使用者无法连线.');
                  exit;
               end;
            end;

            FGameStatus := gs_selectchar;

            pcSelectChar := @aComData.Data;
            pcSelectChar^.rChar [NAME_SIZE - 1] := 0;

            uStr := StrPas (@pcSelectChar^.rChar);
            uStr := GetTokenStr (uStr, UseChar, ':');
            uStr := GetTokenStr (uStr, UseLand, ':');

            UseChar := Trim (UseChar);
            UseLand := Trim (UseLand);

            if (UseChar = '') or (UseLand = '') then begin
               FGameStatus := gs_none;
               UseChar := '';
               UseLand := '';
               exit;
            end;
            if UseLand <> ServerName then begin
               FGameStatus := gs_none;
               UseChar := '';
               UseLand := '';
               SendStatusMessage (MESSAGE_SELCHAR, '不是本服务器的角色.');
               exit;
            end;

            FillChar (DBRecord, SizeOf (TDBRecord), 0);
            StrPCopy (@DBRecord.PrimaryKey, UseChar);

            SendStatusMessage (MESSAGE_SELCHAR, format ('选择了[%s]角色.', [UseChar]));
            if DBSender <> nil then begin
               DBSender.PutPacket (ConnectID, DB_SELECT, 0, @DBRecord, SizeOf (DBRecord.PrimaryKey));
            end;
         end;
   end;

   FLastMessage := msg^;
   RequestTime := timeGetTime;
end;

// TConnectorList
constructor TConnectorList.Create;
begin
   UniqueID := 0;
   UniqueValue := -1;

   FPlayingUserCount := 0;
   FLogingUserCount := 0;

   SocketKey := TIntegerKeyClass.Create;
   ConnectIDKey := TIntegerKeyClass.Create;

   DataList := TList.Create;
   DeleteList := TList.Create;

   CurProcessPos := 0;
   ProcessCount := 40;
end;

destructor TConnectorList.Destroy;
begin
   Clear;
   SocketKey.Free;
   ConnectIDKey.Free;
   DataList.Free;
   DeleteList.Free;

   inherited Destroy;
end;

procedure TConnectorList.Clear;
var
   i : Integer;
   Connector : TConnector;
   pd : PTConnectData;
begin
   FPlayingUserCount := 0;
   FLogingUserCount := 0;

   SocketKey.Clear;
   ConnectIDKey.Clear;
   
   for i := 0 to DataList.Count - 1 do begin
      Connector := DataList.Items [i];
      Connector.Free;
   end;
   DataList.Clear;

   for i := 0 to DeleteList.Count - 1 do begin
      pd := DeleteList.Items [i];
      Dispose (pd);
   end;
   DeleteList.Clear;
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

   if UniqueValue = -1 then exit;
   
   Connector := TConnector.Create (aSocket, UniqueID + UniqueValue);

   SocketKey.Insert (Connector.SocketInt, Connector);
   ConnectIDKey.Insert (Connector.ConnectID, Connector);
   DataList.Add (Connector);

   Inc (UniqueID, 10);
   Inc (FLogingUserCount);

   Result := true;
end;

function TConnectorList.DeleteConnect (aSocket :  TCustomWinSocket) : String;
var
   pd : PTConnectData;
   Connector : TConnector;
begin
   Result := '';

   Connector := SocketKey.Select (Integer(aSocket));
   if Connector <> nil then begin
      Result := Connector.PlayCharName;
   end;

   New (pd);
   pd^.SocketInt := Integer (aSocket);

   DeleteList.Add (pd);
end;

procedure TConnectorList.AddReceiveData (aSocket : TCustomWinSocket; aData : PChar; aCount : Integer);
var
   Connector : TConnector;
begin
   Connector := SocketKey.Select (Integer(aSocket));
   if Connector <> nil then begin
      Connector.AddReceiveData (aData, aCount);
      exit;
   end;
end;

procedure TConnectorList.GameMessageProcess (aPacket : PTPacketData);
var
	i : Integer;
   Connector : TConnector;
   pDBRecord : PTDBRecord;
begin
   if aPacket^.RequestMsg = GM_SENDALL then begin
   	// Reverse4Bit (PTComData (@aPacket^.Data));
      for i := 0 to DataList.Count - 1 do begin
      	Connector := DataList.Items [i];
         Connector.GameMessageProcess (aPacket);
      end;
      exit;
   end;
   if aPacket^.RequestMsg = GM_UNIQUEVALUE then begin
      UniqueValue := aPacket^.RequestID;
      frmMain.Caption := format ('Gate Server [%d]', [UniqueValue]);
      exit;
   end;
   if aPacket^.RequestMsg = GM_CONNECT then begin
      Inc (FPlayingUserCount);
      Dec (FLogingUserCount);
   end;

   Connector := ConnectIDKey.Select (aPacket^.RequestID);
   if Connector <> nil then begin
      Connector.GameMessageProcess (aPacket);
      exit;
   end;

   if aPacket^.RequestMsg = GM_SENDUSERDATA then begin
      pDBRecord := @aPacket^.Data;
      if DBSender <> nil then begin
         DBSender.PutPacket (0, DB_UPDATE, 0, @aPacket^.Data, SizeOf (TDBRecord));
      end;
      frmMain.AddLog (format ('closing user data (%s)', [StrPas (@pDBRecord^.PrimaryKey)]));
   end else begin
      if GameSender <> nil then begin
         GameSender.PutPacket (aPacket^.RequestID, GM_DISCONNECT, 0, nil, 0);
      end;
      // frmMain.AddLog ('TConnectorList.GameMessageProcess failed');
   end;
end;

procedure TConnectorList.DBMessageProcess (aPacket : PTPacketData);
var
   Connector : TConnector;
   RecordData : TDBRecord;
begin
   if aPacket^.RequestMsg <> DB_UPDATE then begin
      Connector := ConnectIDKey.Select (aPacket^.RequestID);
      if Connector <> nil then begin
         Connector.DBMessageProcess (aPacket);
      end;
      // frmMain.AddLog ('TConnectorList.DBMessageProcess failed');
   end else begin
      Case aPacket^.RequestMsg of
         DB_UPDATE :
            begin
               if aPacket^.ResultCode = DB_OK then begin
                  Move (aPacket^.Data, RecordData.PrimaryKey, SizeOf (RecordData.PrimaryKey));
                  frmMain.AddLog (format ('user data saved [%s]', [StrPas (@RecordData.PrimaryKey)]));
               end else begin
                  Move (aPacket^.Data, RecordData.PrimaryKey, SizeOf (RecordData.PrimaryKey));
                  frmMain.AddLog (format ('user data save failed [%s]', [StrPas (@RecordData.PrimaryKey)]));
               end;
            end;
      end;
   end;
end;

procedure TConnectorList.LoginMessageProcess (aPacket : PTPacketData);
var
   Connector : TConnector;
begin
   Connector := ConnectIDKey.Select (aPacket^.RequestID);
   if Connector <> nil then begin
      Connector.LoginMessageProcess (aPacket);
   end;
   // frmMain.AddLog ('TConnectorList.LoginMessageProcess failed');
end;

procedure TConnectorList.PaidMessageProcess (aPacket : PTPacketData);
var
   Connector : TConnector;
begin
   Connector := ConnectIDKey.Select (aPacket^.RequestID);
   if Connector <> nil then begin
      Connector.PaidMessageProcess (aPacket);
   end;
   // frmMain.AddLog ('TConnectorList.PaidMessageProcess failed');
end;

function TConnectorList.Update (CurTick : Integer) : Boolean;
var
   i, nIndex : Integer;
   Connector : TConnector;
   pd : PTConnectData;
   StartPos : Word;
begin
   if DeleteList.Count > 0 then begin
      for i := 0 to DeleteList.Count - 1 do begin
         pd := DeleteList.Items [i];
         Connector := SocketKey.Select (pd^.SocketInt);
         if Connector <> nil then begin
            if Connector.GameStatus = gs_playing then begin
               Dec (FPlayingUserCount);
            end else begin
               Dec (FLogingUserCount);
            end;
            SocketKey.Delete (Connector.SocketInt);
            ConnectIDKey.Delete (Connector.ConnectID);

            Connector.Free;
            nIndex := DataList.IndexOf (Connector);
            if nIndex <> -1 then DataList.Delete (nIndex);
         end;
         Dispose (pd);
      end;
      DeleteList.Clear;
   end;

   if DataList.Count > 0 then begin
   	ProcessCount := DataList.Count * 4 div 100;
      if ProcessCount < 40 then ProcessCount := 40;
      StartPos := CurProcessPos;
      for i := 0 to ProcessCount - 1 do begin
         if CurProcessPos >= DataList.Count then CurProcessPos := 0;
         Connector := DataList.Items [CurProcessPos];
         Connector.Update (CurTick);
         Inc (CurProcessPos);
         if CurProcessPos >= DataList.Count then CurProcessPos := 0;
         if CurProcessPos = StartPos then break;
      end;
   end;

   Result := true;
end;

procedure TConnectorList.SetWriteAllow (aSocket : TCustomWinSocket);
var
   Connector : TConnector;
begin
   Connector := SocketKey.Select (Integer (aSocket));
   if Connector <> nil then begin
      Connector.SetWriteAllow;
      exit;
   end;
   // frmMain.AddLog ('TConnectorList.SetWriteAllow failed');
end;

procedure TConnectorList.ReCalc;
var
   i : Integer;
   Connector : TConnector;
begin
   FLogingUserCount := 0;
   FPlayingUserCount := 0;
   for i := 0 to DataList.Count - 1 do begin
      Connector := DataList.Items [i];
      if Connector.FGameStatus = gs_playing then begin
         Inc (FPlayingUserCount);
      end else begin
         Inc (FLogingUserCount);
      end;
   end;
end;

end.

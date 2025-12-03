unit uRemoteConnector;

interface

uses
   Windows, Classes, SysUtils, ScktComp, uRecordDef, DefType;

type
   TRemoteType = ( rt_userdata, rt_itemdata );
   
   TRemoteConnector = class
   private
      ConnectID : Integer;
      Socket : TCustomWinSocket;

      RemoteType : TRemoteType;
      
      boWriteAllow : Boolean;

      ReceiveStringList : TStringList;
      SendStringList : TStringList;
   protected
   public
      constructor Create (aSocket :  TCustomWinSocket; aType : TRemoteType; aConnectID : Integer);
      destructor Destroy; override;

      procedure Update (CurTick : Integer);
      procedure MessageProcess (aData : String);
      
      procedure AddReceiveData (aData : String);
      procedure AddSendData (aData : String);

      procedure AddRequestData (aMsgID, aResultCode : Integer; aData : String);

      property WriteAllow : Boolean read boWriteAllow write boWriteAllow;
   end;

   TRemoteConnectorList = class
   private
      UniqueID : Integer;
      DataList : TList;

      function GetCount : Integer;
   protected
   public
      constructor Create;
      destructor Destroy; override;

      procedure Clear;

      function CreateConnect (aSocket :  TCustomWinSocket; aType : TRemoteType) : Boolean;
      function DeleteConnect (aSocket :  TCustomWinSocket) : Boolean;

      procedure Update (CurTick : Integer);
      
      procedure AddReceiveData (aSocket : TCustomWinSocket; aData : String);
      procedure AddRequestData (aMsgID, aConnectID, aResultCode : Integer; aData : String);

      procedure SetWriteAllow (aSocket : TCustomWinSocket);

      property Count : Integer read GetCount;
   end;

var
   RemoteConnectorList : TRemoteConnectorList;

implementation

uses
   FMain, uDBProvider, uUtil, uConnector;

// TRemoteConnector
constructor TRemoteConnector.Create (aSocket : TCustomWinSocket; aType : TRemoteType; aConnectID : Integer);
begin
   Socket := aSocket;
   boWriteAllow := false;

   RemoteType := aType;
   ConnectID := aConnectID;
   
   ReceiveStringList := TStringList.Create;
   SendStringList := TStringList.Create;
end;

destructor TRemoteConnector.Destroy;
begin
   ReceiveStringList.Free;
   SendStringList.Free;

   inherited Destroy;
end;

procedure TRemoteConnector.AddReceiveData (aData : String);
begin
   ReceiveStringList.Add (aData);
end;

procedure TRemoteConnector.AddSendData (aData : String);
begin
   SendStringList.Add (aData);
end;

procedure TRemoteConnector.AddRequestData (aMsgID, aResultCode : Integer; aData : String);
var
   RetStr : String;
begin
   if aResultCode = 0 then begin
      Case aMsgID of
         DB_ITEMSELECT :
            begin
               RetStr := aData;
               Socket.SendText (RetStr);
            end;
         DB_ITEMUPDATE :
            begin
               RetStr := aData;
               if RetStr <> '' then begin
                  Socket.SendText ('Message,' + RetStr);
               end;
            end;
      end;
   end else begin
      RetStr := 'Message,data read failed';
      Socket.SendText (RetStr);
   end;
end;

procedure TRemoteConnector.Update (CurTick : Integer);
var
   cmdStr : String;
begin
   if ReceiveStringList.Count > 0 then begin
      cmdStr := ReceiveStringList.Strings[0];
      MessageProcess (cmdStr);
      ReceiveStringList.Delete (0);
   end;

   if boWriteAllow = true then begin
      if SendStringList.Count > 0 then begin
         cmdStr := SendStringList.Strings[0];
         Socket.SendText (cmdStr);
         SendStringList.Delete (0);
      end;
   end;
end;

procedure TRemoteConnector.MessageProcess (aData : String);
var
   i : Integer;
   rStr, str, rdstr, cmdStr, keyStr, RetStr : String;
   DBRecord : TDBRecord;
   buffer : array [0..2048 - 1] of Char;
   uPrimaryKey, uMasterName, uGuild, uLastDate, uCreateDate, uSex, uServerId, uX, uY : String;
   uLight, uDark, uEnergy, uInPower, uOutPower, uMagic, uLife, uTalent, uGoodChar : String;
   uBadChar, uAdaptive, uRevival, uImmunity, uVirtue, uCurEnergy, uCurInPower : String;
   uCurOutPower, uCurMagic, uCurLife, uCurHealth, uCurSatiety, uCurPoisoning : String;
   uCurHeadSeak, uCurArmSeak, uCurLegSeak : String;
   uBasicMagic : array[0..10 - 1] of String;
   uWearItem : array[0..8 - 1] of String;
   uHaveItem : array[0..30 - 1] of String;
   uHaveMagic : array[0..30 - 1] of String;
   uname, ucount, ucolor, uskill : String;
begin
   // frmMain.AddLog (aData);

   rStr := aData;
   while true do begin
      rStr := GetTokenStr (rStr, Str, #13);
      if Str = '' then break;
      
      str := GetTokenStr (str, cmdStr, ',');
      str := GetTokenStr (str, keyStr, ',');

      cmdStr := Trim (cmdStr);
      keyStr := Trim (keyStr);
      if cmdStr = '' then exit;

      if RemoteType = rt_userdata then begin
         if UpperCase (cmdStr) = 'FIELDS' then begin
            RetStr := 'Fields,' + frmMain.GetUserDataFields;
            AddSendData (RetStr);
         end else if UpperCase (cmdStr) = 'CREATE' then begin
         end else if UpperCase (cmdStr) = 'DELETE' then begin
         end else if UpperCase (cmdStr) = 'READ' then begin
            if Trim (keyStr) = '' then exit;
            if DBProvider.Select (keyStr, @DBRecord) <> DB_OK then begin
               RetStr := 'Message,data read failed';
               Socket.SendText (RetStr);
               exit;
            end;
            if CurrentCharList.Select (KeyStr) <> nil then begin
               RetStr := 'Message,' + KeyStr + ' is playing now';
               Socket.SendText (RetStr);
               exit;
            end;
            RetStr := 'UserData,' + DBProvider.ChangeDataToStr (@DBRecord);
            AddSendData (RetStr);
         end else if UpperCase (cmdStr) = 'WRITE' then begin
            if keyStr = '' then exit;

            if CurrentCharList.Select (KeyStr) <> nil then begin
               RetStr := 'Message,' + KeyStr + ' is playing now';
               Socket.SendText (RetStr);
               exit;
            end;

            FillChar (DBRecord, SizeOf (TDBRecord), 0);
            DBRecord.boUsed := 1;

            uPrimaryKey := keyStr;
            str := GetTokenStr (str, uMasterName, ',');
            str := GetTokenStr (str, uGuild, ',');
            str := GetTokenStr (str, uLastDate, ',');
            str := GetTokenStr (str, uCreateDate, ',');
            str := GetTokenStr (str, uSex, ',');
            str := GetTokenStr (str, uServerId, ',');
            str := GetTokenStr (str, uX, ',');
            str := GetTokenStr (str, uY, ',');
            str := GetTokenStr (str, uLight, ',');
            str := GetTokenStr (str, uDark, ',');
            str := GetTokenStr (str, uEnergy, ',');
            str := GetTokenStr (str, uInPower, ',');
            str := GetTokenStr (str, uOutPower, ',');
            str := GetTokenStr (str, uMagic, ',');
            str := GetTokenStr (str, uLife, ',');
            str := GetTokenStr (str, uTalent, ',');
            str := GetTokenStr (str, uGoodChar, ',');
            str := GetTokenStr (str, uBadChar, ',');
            str := GetTokenStr (str, uAdaptive, ',');
            str := GetTokenStr (str, uRevival, ',');
            str := GetTokenStr (str, uImmunity, ',');
            str := GetTokenStr (str, uVirtue, ',');
            str := GetTokenStr (str, uCurEnergy, ',');
            str := GetTokenStr (str, uCurInPower, ',');
            str := GetTokenStr (str, uCurOutPower, ',');
            str := GetTokenStr (str, uCurMagic, ',');
            str := GetTokenStr (str, uCurLife, ',');
            str := GetTokenStr (str, uCurHealth, ',');
            str := GetTokenStr (str, uCurSatiety, ',');
            str := GetTokenStr (str, uCurPoisoning, ',');
            str := GetTokenStr (str, uCurHeadSeak, ',');
            str := GetTokenStr (str, uCurArmSeak, ',');
            str := GetTokenStr (str, uCurLegSeak, ',');
            for i := 0 to 10 - 1 do begin
               str := GetTokenStr (str, uBasicMagic[i], ',');
            end;
            for i := 0 to 8 - 1 do begin
               str := GetTokenStr (str, uWearItem[i], ',');
            end;
            for i := 0 to 30 - 1 do begin
               str := GetTokenStr (str, uHaveItem[i], ',');
            end;
            for i := 0 to 30 - 1 do begin
               str := GetTokenStr (str, uHaveMagic[i], ',');
            end;

            StrPCopy (@DBRecord.PrimaryKey, uPrimaryKey);
            StrPCopy (@DBRecord.MasterName, uMasterName);
            StrPCopy (@DBRecord.Guild, uGuild);
            StrPCopy (@DBRecord.LastDate, uLastDate);
            StrPCopy (@DBRecord.CreateDate, uCreateDate);
            StrPCopy (@DBRecord.Sex, uSex);
            DBRecord.ServerID := _StrToInt (uServerId);
            DBRecord.X := _StrToInt (uX);
            DBRecord.Y := _StrToInt (uY);
            DBRecord.Light := _StrToInt (uLight);
            DBRecord.Dark := _StrToInt (uDark);
            DBRecord.Energy := _StrToInt (uEnergy);
            DBRecord.InPower := _StrToInt (uInPower);
            DBRecord.OutPower := _StrToInt (uOutPower);
            DBRecord.Magic := _StrToInt (uMagic);
            DBRecord.Life := _StrToInt (uLife);
            DBRecord.Talent := _StrToInt (uTalent);
            DBRecord.GoodChar := _StrToInt (uGoodChar);
            DBRecord.BadChar := _StrToInt (uBadChar);
            DBRecord.Adaptive := _StrToInt (uAdaptive);
            DBRecord.Revival := _StrToInt (uRevival);
            DBRecord.Immunity := _StrToInt (uImmunity);
            DBRecord.Virtue := _StrToInt (uVirtue);
            DBRecord.CurEnergy := _StrToInt (uCurEnergy);
            DBRecord.CurInPower := _StrToInt (uCurInPower);
            DBRecord.CurOutPower := _StrToInt (uCurOutPower);
            DBRecord.CurMagic := _StrToInt (uCurMagic);
            DBRecord.CurLife := _StrToInt (uCurLife);
            DBRecord.CurHealth := _StrToInt (uCurHealth);
            DBRecord.CurSatiety := _StrToInt (uCurSatiety);
            DBRecord.CurPoisoning := _StrToInt (uCurPoisoning);
            DBRecord.CurHeadSeak := _StrToInt (uCurHeadSeak);
            DBRecord.CurArmSeak := _StrToInt (uCurArmSeak);
            DBRecord.CurLegSeak := _StrToInt (uCurLegSeak);

            for i := 0 to 10 - 1 do begin
               DBRecord.BasicMagicArr[i].Skill := _StrToInt (uBasicMagic[i]);
            end;
            for i := 0 to 8 - 1 do begin
               rdstr := uWearItem[i];
               rdstr := GetTokenStr (rdstr, uname, ':');
               rdstr := GetTokenStr (rdstr, ucolor, ':');
               rdstr := GetTokenStr (rdstr, ucount, ':');

               StrPCopy (@DBRecord.WearItemArr[i].Name, uname);
               DBRecord.WearItemArr[i].Color := _StrToInt (ucolor);
               DBRecord.WearItemArr[i].Count := _StrToInt (ucount);
            end;
            for i := 0 to 30 - 1 do begin
               rdstr := uHaveItem[i];
               rdstr := GetTokenStr (rdstr, uname, ':');
               rdstr := GetTokenStr (rdstr, ucolor, ':');
               rdstr := GetTokenStr (rdstr, ucount, ':');

               StrPCopy (@DBRecord.HaveItemArr[i].Name, uname);
               DBRecord.HaveItemArr[i].Color := _StrToInt (ucolor);
               DBRecord.HaveItemArr[i].Count := _StrToInt (ucount);
            end;
            for i := 0 to 30 - 1 do begin
               rdstr := uHaveMagic[i];
               rdstr := GetTokenStr (rdstr, uname, ':');
               rdstr := GetTokenStr (rdstr, uskill, ':');

               StrPCopy (@DBRecord.HaveMagicArr[i].Name, uname);
               DBRecord.HaveMagicArr[i].Skill := _StrToInt (uskill);
            end;

            if DBProvider.Update (keyStr, @DBRecord) <> DB_OK then begin
               RetStr := 'Message,data write failed';
               Socket.SendText (RetStr);
               exit;
            end;
         end else begin
            frmMain.AddLog ('Unknown Command Received - ' + aData);
         end;
      end else begin
         if UpperCase (cmdStr) = 'FIELDS' then begin
            RetStr := 'Fields,' + frmMain.GetItemDataFields;
            AddSendData (RetStr);
         end else if UpperCase (cmdStr) = 'CREATE' then begin
         end else if UpperCase (cmdStr) = 'DELETE' then begin
         end else if UpperCase (cmdStr) = 'READ' then begin
            if Trim (keyStr) = '' then exit;
            FillChar (DBRecord, SizeOf (TDBRecord), 0);
            StrPCopy (@DBRecord.PrimaryKey, KeyStr);
            ConnectorList.AddPacketToGameServer (ConnectID, DB_ITEMSELECT, 0, @DBRecord.PrimaryKey, SizeOf (DBRecord.PrimaryKey));
         end else if UpperCase (cmdStr) = 'WRITE' then begin
            if Trim (keyStr) = '' then exit;
            StrPCopy (@buffer, KeyStr + ',' + Str);
            ConnectorList.AddPacketToGameServer (ConnectID, DB_ITEMUPDATE, 0, @buffer, StrLen (buffer) + 1);
         end else begin
            frmMain.AddLog ('Unknown Command Received - ' + aData);
         end;
      end;
   end;
end;

// TRemoteConnectorList
constructor TRemoteConnectorList.Create;
begin
   UniqueID := 0;

   DataList := TList.Create;
end;

destructor TRemoteConnectorList.Destroy;
begin
   Clear;
   DataList.Free;

   inherited Destroy;
end;

procedure TRemoteConnectorList.Clear;
var
   i : Integer;
   RemoteConnector : TRemoteConnector;
begin
   for i := 0 to DataList.Count - 1 do begin
      RemoteConnector := DataList.Items [i];
      RemoteConnector.Free;
   end;
   DataList.Clear;
end;

function TRemoteConnectorList.GetCount : Integer;
begin
   Result := DataList.Count;
end;

function TRemoteConnectorList.CreateConnect (aSocket : TCustomWinSocket; aType : TRemoteType) : Boolean;
var
   RemoteConnector : TRemoteConnector;
begin
   Result := true;

   try
      RemoteConnector := TRemoteConnector.Create (aSocket, aType, UniqueID);
      DataList.Add (RemoteConnector);
      Inc (UniqueID);
   except
      frmMain.AddEvent ('TRemoteConnectorList.CreateConnect failed (' + aSocket.RemoteAddress + ')');
      Result := false;
   end;
end;

function TRemoteConnectorList.DeleteConnect (aSocket :  TCustomWinSocket) : Boolean;
var
   i : Integer;
   RemoteConnector : TRemoteConnector;
begin
   Result := true;

   for i := 0 to DataList.Count - 1 do begin
      RemoteConnector := DataList.Items [i];
      if RemoteConnector.Socket = aSocket then begin
         DataList.Delete (i);
         exit;
      end;
   end;

   frmMain.AddEvent ('TRemoteConnectorList.DeleteConnect failed (' + aSocket.RemoteAddress + ')');
   Result := false;
end;

procedure TRemoteConnectorList.AddReceiveData (aSocket :  TCustomWinSocket; aData : String);
var
   i : Integer;
   RemoteConnector : TRemoteConnector;
begin
   for i := 0 to DataList.Count - 1 do begin
      RemoteConnector := DataList.Items [i];
      if RemoteConnector.Socket = aSocket then begin
         RemoteConnector.AddReceiveData (aData);
         exit;
      end;
   end;

   frmMain.AddEvent ('TRemoteConnectorList.AddReceiveData failed (' + aSocket.RemoteAddress + ')');
end;

procedure TRemoteConnectorList.AddRequestData (aMsgID, aConnectID, aResultCode : Integer; aData : String);
var
   i : Integer;
   RemoteConnector : TRemoteConnector;
begin
   for i := 0 to DataList.Count - 1 do begin
      RemoteConnector := DataList.Items [i];
      if RemoteConnector.ConnectID = aConnectID then begin
         RemoteConnector.AddRequestData (aMsgID, aResultCode, aData);
         exit;
      end;
   end;

   frmMain.AddEvent ('TRemoteConnectorList.AddRequestData failed');
end;

procedure TRemoteConnectorList.Update (CurTick : Integer);
var
   i : Integer;
   RemoteConnector : TRemoteConnector;
begin
   for i := 0 to DataList.Count - 1 do begin
      RemoteConnector := DataList.Items [i];
      RemoteConnector.Update (CurTick);
   end;
end;

procedure TRemoteConnectorList.SetWriteAllow (aSocket : TCustomWinSocket);
var
   i : Integer;
   RemoteConnector : TRemoteConnector;
begin
   for i := 0 to DataList.Count - 1 do begin
      RemoteConnector := DataList.Items [i];
      if RemoteConnector.Socket = aSocket then begin
         RemoteConnector.WriteAllow := true;
         exit;
      end;
   end;
end;

end.

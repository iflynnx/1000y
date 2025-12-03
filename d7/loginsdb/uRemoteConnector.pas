unit uRemoteConnector;

interface

uses
   Windows, Classes, SysUtils, ScktComp, deftype, uLGRecordDef;

type
   TRemoteConnector = class
   private
      ConnectID : Integer;
      Socket : TCustomWinSocket;

      boWriteAllow : Boolean;

      ReceiveStringList : TStringList;
      SendStringList : TStringList;
   protected
   public
      constructor Create (aSocket :  TCustomWinSocket; aConnectID : Integer);
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

      function CreateConnect (aSocket :  TCustomWinSocket) : Boolean;
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
   FMain, uUtil, uDBAdapter;

// TRemoteConnector
constructor TRemoteConnector.Create (aSocket : TCustomWinSocket; aConnectID : Integer);
begin
   Socket := aSocket;
   boWriteAllow := false;

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
   LGRecord : TLGRecord;
//   buffer : array [0..2048 - 1] of Char;
   uPrimaryKey, uPassword : String;
   uCharInfo : array [0..5 - 1] of String;
   uIpAddr, uUserName, uBirth, uTelephone : String;
   uMakeDate, uLastDate, uAddress, uEmail, uNativeNumber, uMasterKey : String;
   uParentName, uParentNativeNumber : String;
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

      if UpperCase (cmdStr) = 'FIELDS' then begin
         RetStr := 'Fields,' + frmMain.GetUserDataFields;
         AddSendData (RetStr);
      end else if UpperCase (cmdStr) = 'CREATE' then begin
      end else if UpperCase (cmdStr) = 'DELETE' then begin
      end else if UpperCase (cmdStr) = 'READ' then begin
         if Trim (keyStr) = '' then exit;
         if DBAdapter.Select (keyStr, @LGRecord) <> DB_OK then begin
            RetStr := 'Message,data read failed';
            Socket.SendText (RetStr);
            exit;
         end;
         RetStr := 'UserData,' + DBAdapter.ChangeDataToStr (@LGRecord);
         AddSendData (RetStr);
      end else if UpperCase (cmdStr) = 'WRITE' then begin
         if keyStr = '' then exit;

         FillChar (LGRecord, SizeOf (TLGRecord), 0);

         uPrimaryKey := keyStr;

         str := GetTokenStr (str, uPassword, ',');
         for i := 0 to 5 - 1 do begin
            str := GetTokenStr (str, uCharInfo[i], ',');
         end;
         str := GetTokenStr (str, uIpAddr, ',');
         str := GetTokenStr (str, uUserName, ',');
         str := GetTokenStr (str, uBirth, ',');
         str := GetTokenStr (str, uTelephone, ',');
         str := GetTokenStr (str, uMakeDate, ',');
         str := GetTokenStr (str, uLastDate, ',');
         str := GetTokenStr (str, uAddress, ',');
         str := GetTokenStr (str, uEmail, ',');
         str := GetTokenStr (str, uNativeNumber, ',');
         str := GetTokenStr (str, uMasterKey, ',');
         str := GetTokenStr (str, uParentName, ',');
         str := GetTokenStr (str, uParentNativeNumber, ',');


         LGRecord.PrimaryKey := uPrimaryKey;
         LGRecord.PassWord := uPassWord;

         for i := 0 to 5 - 1 do begin
            if (Trim (uCharInfo[i]) <> ':') and (Trim (uCharInfo[i]) <> '') then begin
               ucharInfo[i] := GetTokenStr (uCharInfo[i], rdstr, ':');
               LGRecord.CharInfo [i].CharName := rdStr;
               ucharInfo[i] := GetTokenStr (uCharInfo[i], rdstr, ':');
               LGRecord.CharInfo [i].ServerName := rdStr;
            end;
         end;

         LGRecord.IpAddr := uIpAddr;
         LGRecord.MakeDate :=  uMakeDate;
         LGRecord.LastDate := uLastDate;
         LGRecord.UserName := uUserName;
         LGRecord.NativeNumber := uNativeNumber;
         LGRecord.MasterKey := uMasterKey;
         LGRecord.Email := uEmail;
         LGRecord.Phone := uTelephone;
         LGRecord.ParentName := uParentName;
         LGRecord.ParentNativeNumber := uParentNativeNumber;
         LGRecord.Address := uAddress;
         LGRecord.Birth := uBirth;

         if DBAdapter.Update (keyStr, @LGRecord) <> DB_OK then begin
            RetStr := 'Message,data write failed';
            Socket.SendText (RetStr);
            exit;
         end;
      end else begin
         frmMain.AddLog ('Unknown Command Received - ' + aData);
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

function TRemoteConnectorList.CreateConnect (aSocket : TCustomWinSocket) : Boolean;
var
   RemoteConnector : TRemoteConnector;
begin
   Result := true;

   try
      RemoteConnector := TRemoteConnector.Create (aSocket, UniqueID);
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

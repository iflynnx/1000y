unit uDBAdapter;

interface

uses
   SysUtils, db, dbTables, uLGRecordDef, uUtil, DefType;

type
   TDBAdapter = class
   private
      FDSN : String;
      FDatabaseName : String;
      FQuery : TQuery;
   public
      constructor Create (aDsn, aDatabase : String);
      destructor Destroy; override;

      function Select (aIndexName : String; aLGRecord : PTLGRecord) : Byte;
      function Insert (aIndexName : String; aLGRecord : PTLGRecord) : Byte;
      function Delete (aIndexName : String) : Byte;
      function Update (aIndexName : String; aLGRecord : PTLGRecord) : Byte;

      function ChangeDataToStr (aLGRecord : PTLGRecord) : String;

      property DSN : String read FDSN write FDSN;
      property DatabaseName : String read FDatabaseName write FDatabaseName;
   end;

var
   DBAdapter : TDBAdapter;

implementation

uses
   FMain;

constructor TDBAdapter.Create (aDsn, aDatabase : String);
begin
   FDSN := aDsn;
   FDatabaseName := aDatabase;

   FQuery := TQuery.Create (nil);
   FQuery.DatabaseName := aDsn;
   FQuery.Close;
   FQuery.SQL.Clear;
end;

destructor TDBAdapter.Destroy;
begin
   FQuery.Free;
   inherited Destroy;
end;

function TDBAdapter.Select (aIndexName : String; aLGRecord : PTLGRecord) : Byte;
var
   i : Integer;
   mStr, str : String;
   uPrimaryKey, uPassword : String;
   uCharInfo : array [0..5 - 1] of String;
   uIpAddr, uUserName, uBirth, uTelephone, uMakeDate : String;
   uParentName, uParentNativeNumber : String;
   uLastDate, uAddress, uEmail, uNativeNumber, uMasterKey : String;
   uCharName, uServerName : String;
begin
   Result := DB_OK;
   if aIndexName = '' then begin
      Result := DB_ERR_INVALIDDATA;
      exit;
   end;

   mStr := 'select * from account1000y where account = ''' + aIndexName + ''';';
   FQuery.Close;
   FQuery.SQL.Clear;
   FQuery.SQL.Add (mStr);

   try
      FQuery.Open;
   except
      frmMain.AddSQL (mStr);
   end;

   if FQuery.RecordCount <= 0 then begin
      FQuery.Close;
      Result := DB_ERR_NOTFOUND;
      exit;
   end;
   FQuery.First;
   while not (FQuery.Eof) do begin
      uPrimaryKey := FQuery.Fields[0].AsString;
      uPassword := FQuery.Fields[1].AsString;
      for i := 0 to 5 - 1 do begin
         uCharInfo[i] := FQuery.Fields[2 + i].AsString;
         if uCharInfo[i] = ':' then uCharInfo[i] := '';
      end;
      uIpAddr := FQuery.Fields[7].AsString;
      uUserName := FQuery.Fields[8].AsString;
      uBirth := FQuery.Fields[9].AsString;
      uTelephone := FQuery.Fields[10].AsString;
      uMakeDate := FQuery.Fields[11].AsString;
      uLastDate := FQuery.Fields[12].AsString;       
      uAddress := FQuery.Fields[13].AsString;
      uEmail := FQuery.Fields[14].AsString;
      uNativeNumber := FQuery.Fields[15].AsString;
      uMasterKey := FQuery.Fields[16].AsString;
      uParentName := FQuery.Fields[17].AsString;
      uParentNativeNumber := FQuery.Fields[18].AsString;

      aLGRecord^.PrimaryKey := Copy (uPrimaryKey, 1, 20);
      aLGRecord^.PassWord := Copy (uPassWord, 1, 20);

      for i := 0 to 5 - 1 do begin
         str := uCharInfo[i];
         str := GetTokenStr (str, uCharName, ':');
         str := GetTokenStr (str, uServerName, ':');

         aLGRecord^.CharInfo [i].CharName := Copy (uCharName, 1, 20);
         aLGRecord^.CharInfo [i].ServerName := Copy (uServerName, 1, 20);
      end;

      aLGRecord^.IpAddr := Copy (uIpAddr, 1, 16);
      aLGRecord^.MakeDate := Copy (uMakeDate, 1, 20);
      aLGrecord^.LastDate := Copy (uLastDate, 1, 20);
      aLGRecord^.Birth := Copy (uBirth, 1, 20);
      aLGRecord^.Address := Copy (uAddress, 1, 50);
      aLGRecord^.UserName := Copy (uUserName, 1, 20);
      aLGRecord^.NativeNumber := Copy (uNativeNumber, 1, 20);
      aLGRecord^.MasterKey := Copy (uMasterKey, 1, 20);
      aLGRecord^.Email := Copy (uEmail, 1, 50);
      aLGRecord^.Phone := Copy (uTelePhone, 1, 20);
      aLGRecord^.ParentName := Copy (uParentName, 1, 20);
      aLGRecord^.ParentNativeNumber := Copy(uParentNativeNumber, 1, 20);

      FQuery.Next;

      break;
   end;

   FQuery.Close;
end;

function TDBAdapter.Insert (aIndexName : String; aLGRecord : PTLGRecord) : Byte;
var
   i : Integer;
   mStr, str : String;
   uPrimaryKey, uPassword : String;
   uCharInfo : array [0..5 - 1] of String;
   uIpAddr, uUserName, uBirth, uTelephone, uMakeDate : String;
   uLastDate, uAddress, uEmail, uNativeNumber, uMasterKey : String;
   uParentName, uParentNativeNumber : String;
   uCharName, uServerName : String;
   LGRecord : TLGRecord;
begin
   Result := DB_OK;
   if aIndexName = '' then begin
      Result := DB_ERR_INVALIDDATA;
      exit;
   end;

   if Select (aIndexName, @LGRecord) = DB_OK then begin
      Result := DB_ERR_DUPLICATE;
      exit;
   end;

   uPrimaryKey := aLGRecord^.PrimaryKey;
   uPassWord := aLGRecord^.PassWord;

   for i := 0 to 5 - 1 do begin
      Str := aLGRecord^.CharInfo[i].CharName + ':' + aLGRecord^.CharInfo [i].ServerName;
      if str = ':' then str := '';
      uCharInfo [i] := str;
   end;

   uIpAddr := aLGRecord^.IpAddr;
   uMakeDate := aLGRecord^.MakeDate;
   uLastDate := aLGRecord^.LastDate;
   uUserName := aLGRecord^.UserName;
   uNativeNumber := aLGRecord^.NativeNumber;
   uMasterKey := aLGRecord^.MasterKey;
   uEmail := aLGRecord^.Email;
   uTelePhone := aLGRecord^.Phone;
   uParentName := aLGRecord^.ParentName;
   uParentNativeNumber := aLGRecord^.ParentNativeNumber;

   uBirth := '';
   uAddress := '';

   // account, password, char1, char2, char3, char4, char5, ipaddr, username, birth
   // telephone, makedate, lastdate, address, email, nativenumber, masterkey
   mStr := 'insert into account1000y ( ';
   mStr := mStr + ' account, password, char1, char2, char3, char4, char5,';
   mStr := mStr + ' ipaddr, username, birth, telephone, makedate, lastdate,';
   mStr := mStr + ' address, email, nativenumber, masterkey, ptname, ptnativenumber )';
   mStr := mStr + ' values ( ';
   mStr := mStr + '''' + uPrimaryKey + ''',';
   mStr := mStr + '''' + uPassword + ''',';
   mStr := mStr + '''' + uCharInfo[0] + ''',';
   mStr := mStr + '''' + uCharInfo[1] + ''',';
   mStr := mStr + '''' + uCharInfo[2] + ''',';
   mStr := mStr + '''' + uCharInfo[3] + ''',';
   mStr := mStr + '''' + uCharInfo[4] + ''',';
   mStr := mStr + '''' + uIpAddr + ''',';
   mStr := mStr + '''' + uUserName + ''',';
   mStr := mStr + '''' + uBirth + ''',';
   mStr := mStr + '''' + uTelephone + ''',';
   mStr := mStr + '''' + uMakeDate + ''',';
   mStr := mStr + '''' + uLastDate + ''',';
   mStr := mStr + '''' + uAddress + ''',';
   mStr := mStr + '''' + uEmail + ''',';
   mStr := mStr + '''' + uNativeNumber + ''',';
   mStr := mStr + '''' + uMasterKey + ''',';
   mStr := mStr + '''' + uParentName + ''',';
   mStr := mStr + '''' + uParentNativeNumber + ''' );';


   // FQuery.Close;
   FQuery.SQL.Clear;
   FQuery.SQL.Add (mStr);

   try
      FQuery.ExecSQL;
   except
      frmMain.AddSQL (mStr);
   end;

   if FQuery.RowsAffected < 1 then begin
      Result := DB_ERR_DUPLICATE;
   end;

   FQuery.Close;
end;

function TDBAdapter.Delete (aIndexName : String) : Byte;
begin
   //
end;

function TDBAdapter.Update (aIndexName : String; aLGRecord : PTLGRecord) : Byte;
var
   i : Integer;
   mStr, str : String;
   uPrimaryKey, uPassword : String;
   uCharInfo : array [0..5 - 1] of String;
   uIpAddr, uUserName, uBirth, uTelephone, uMakeDate : String;
   uLastDate, uAddress, uEmail, uNativeNumber, uMasterKey : String;
   uParentName, uParentNativeNumber : String;
   uCharName, uServerName : String;
   LGRecord : TLGRecord;
begin
   Result := DB_OK;
   if aIndexName = '' then begin
      Result := DB_ERR_INVALIDDATA;
      exit;
   end;

   if Select (aIndexName, @LGRecord) <> DB_OK then begin
      Result := DB_ERR_NOTFOUND;
      exit;
   end;

   uPrimaryKey := aLGRecord^.PrimaryKey;
   uPassWord := aLGRecord^.PassWord;

   for i := 0 to 5 - 1 do begin
      Str := aLGRecord^.CharInfo [i].CharName + ':' + aLGRecord^.CharInfo [i].ServerName;
      if str = ':' then str := '';
      uCharInfo [i] := str;
   end;
   uIpAddr := aLGRecord^.IpAddr;
   uMakeDate := aLGRecord^.MakeDate;
   uLastDate := aLGRecord^.LastDate;

   uUserName := aLGRecord^.UserName;
   uNativeNumber := aLGRecord^.NativeNumber;
   uMasterKey := aLGRecord^.MasterKey;
   uEmail := aLGRecord^.Email;
   uTelePhone := aLGRecord^.Phone;
   uParentName := aLGRecord^.ParentName;
   uParentNativeNumber := aLGRecord^.ParentNativeNumber;

   uBirth := aLGRecord^.Birth;
   uAddress := aLGRecord^.Address;

   // account, password, char1, char2, char3, char4, char5, ipaddr, username, birth
   // telephone, makedate, lastdate, address, email, nativenumber, masterkey
   mStr := 'update account1000y set ';
   mStr := mStr + ' password = ''' + uPassword + ''',';
   mStr := mStr + ' char1 = ''' + uCharInfo[0] + ''',';
   mStr := mStr + ' char2 = ''' + uCharInfo[1] + ''',';
   mStr := mStr + ' char3 = ''' + uCharInfo[2] + ''',';
   mStr := mStr + ' char4 = ''' + uCharInfo[3] + ''',';
   mStr := mStr + ' char5 = ''' + uCharInfo[4] + ''',';
   mStr := mStr + ' ipaddr = ''' + uIpAddr + ''',';
   mStr := mStr + ' username = ''' + uUserName + ''',';
   mStr := mStr + ' birth = ''' + uBirth + ''',';
   mStr := mStr + ' telephone = ''' + uTelephone + ''',';
   mStr := mStr + ' makedate = ''' + uMakeDate + ''',';
   mStr := mStr + ' lastdate = ''' + uLastDate + ''',';
   mStr := mStr + ' address = ''' + uAddress + ''',';
   mStr := mStr + ' email = ''' + uEmail + ''',';
   mStr := mStr + ' nativenumber = ''' + uNativeNumber + ''',';
   mStr := mStr + ' masterkey = ''' + uMasterKey + ''',';
   mStr := mStr + ' ptname = ''' + uParentName + ''',';
   mStr := mStr + ' ptnativenumber = ''' + uParentNativeNumber + '''';
   mStr := mStr + ' where account = ''' + uPrimaryKey + ''';';

   FQuery.Close;
   FQuery.SQL.Clear;
   FQuery.SQL.Add (mStr);

   try
      FQuery.ExecSQL;
   except
      frmMain.AddSQL (mStr);
   end;

   if FQuery.RowsAffected < 1 then begin
      Result := DB_ERR_NOTFOUND;
   end;

   FQuery.Close;
end;

function TDBAdapter.ChangeDataToStr (aLGRecord : PTLGRecord) : String;
var
   i : Integer;
   RetStr : String;
begin
   RetStr := aLGRecord^.PrimaryKey;
   RetStr := RetStr + ',' + aLGRecord^.PassWord;

   for i := 0 to 5 - 1 do begin
      if aLGRecord^.CharInfo [i].CharName <> '' then begin
         RetStr := RetStr + ',' + aLGRecord^.CharInfo[i].CharName + ':' + aLGRecord^.CharInfo [i].ServerName;
      end else begin
         RetStr := RetStr + ',';
      end;
   end;

   RetStr := RetStr + ',' + aLGRecord^.IpAddr;
   RetStr := RetStr + ',' + aLGRecord^.UserName;
   RetStr := RetStr + ',' + aLGRecord^.Birth;
   RetStr := RetStr + ',' + aLGRecord^.Phone;
   RetStr := RetStr + ',' + aLGRecord^.MakeDate;
   RetStr := RetStr + ',' + aLGRecord^.LastDate;
   RetStr := RetStr + ',' + aLGRecord^.Address;
   RetStr := RetStr + ',' + aLGRecord^.Email;
   RetStr := RetStr + ',' + aLGRecord^.NativeNumber;
   RetStr := RetStr + ',' + aLGRecord^.MasterKey;
   RetStr := RetStr + ',' + aLGRecord^.ParentName;
   RetStr := RetStr + ',' + aLGRecord^.ParentNativeNumber;

   Result := RetStr;
end;

end.
